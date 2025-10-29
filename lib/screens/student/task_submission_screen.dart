import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../constants/app_constants.dart';
import '../../models/submission.dart';
import '../../models/task.dart';
import '../../providers/user_provider.dart';
import '../../services/firestore_service.dart';
import '../../utils/helpers.dart';

class TaskSubmissionScreen extends StatefulWidget {
  final Task task;

  const TaskSubmissionScreen({super.key, required this.task});

  @override
  State<TaskSubmissionScreen> createState() => _TaskSubmissionScreenState();
}

class _TaskSubmissionScreenState extends State<TaskSubmissionScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();
  bool _isRecording = false;
  bool _isPaused = false;
  bool _hasRecording = false;
  String? _recordingPath;
  List<String> _uploadedFiles = [];
  final TextEditingController _notesController = TextEditingController();
  bool _isSubmitting = false;
  bool _alreadySubmitted = false;

  @override
  void dispose() {
    _notesController.dispose();
    _recorder.dispose();
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task.title),
        backgroundColor: const Color(AppColors.primaryColorValue),
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _isSubmitting || _alreadySubmitted ? null : _submitTask,
            child: _isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    _alreadySubmitted ? 'Submitted' : 'Submit',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Task Info Card
            _buildTaskInfoCard(),
            const SizedBox(height: AppConstants.largePadding),

            // Submission Options
            AbsorbPointer(
              absorbing: _alreadySubmitted,
              child: _buildSubmissionOptions(),
            ),
            const SizedBox(height: AppConstants.largePadding),

            // Notes Section
            _buildNotesSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getTaskTypeIcon(widget.task.type),
                  color: _getTaskTypeColor(widget.task.type),
                  size: 24,
                ),
                const SizedBox(width: AppConstants.smallPadding),
                Expanded(
                  child: Text(
                    widget.task.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildTaskStatusChip(widget.task.status),
              ],
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            _buildLinkifiedText(
              widget.task.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (widget.task.type != TaskType.announcement) ...[
              const SizedBox(height: AppConstants.defaultPadding),
              Wrap(
                spacing: AppConstants.smallPadding,
                runSpacing: AppConstants.smallPadding,
                children: [
                  if (widget.task.dueDate != null)
                    _buildInfoChip(
                      Icons.schedule,
                      'Due: ${Helpers.formatDate(widget.task.dueDate!)}',
                      widget.task.isOverdue ? Colors.red : Colors.orange,
                    ),
                  _buildInfoChip(
                    Icons.stars,
                    '${widget.task.maxPoints} points',
                    Colors.blue,
                  ),
                ],
              ),
            ],
            if (widget.task.instructions != null) ...[
              const SizedBox(height: AppConstants.defaultPadding),
              Container(
                padding: const EdgeInsets.all(AppConstants.smallPadding),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(
                    AppConstants.smallBorderRadius,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Instructions:',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _buildLinkifiedText(
                      widget.task.instructions!,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Renders text with clickable links
  Widget _buildLinkifiedText(
    String text, {
    TextStyle? style,
    int? maxLines,
    TextOverflow? overflow,
  }) {
    final urlRegex = RegExp(r'(https?:\/\/[^\s]+)');
    final spans = <TextSpan>[];
    int start = 0;

    for (final match in urlRegex.allMatches(text)) {
      if (match.start > start) {
        spans.add(
          TextSpan(text: text.substring(start, match.start), style: style),
        );
      }
      final url = text.substring(match.start, match.end);
      spans.add(
        TextSpan(
          text: url,
          style: (style ?? const TextStyle()).copyWith(
            color: Theme.of(context).colorScheme.primary,
            decoration: TextDecoration.underline,
          ),
          recognizer: (TapGestureRecognizer()
            ..onTap = () async {
              try {
                final uri = Uri.parse(url);
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              } catch (_) {}
            }),
        ),
      );
      start = match.end;
    }

    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start), style: style));
    }

    return RichText(
      maxLines: maxLines,
      overflow: overflow ?? TextOverflow.clip,
      text: TextSpan(children: spans, style: style),
    );
  }

  Widget _buildSubmissionOptions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Submission Options',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppConstants.defaultPadding),

            // Voice Recording (only for Daily Listening)
            if (widget.task.type == TaskType.dailyListening) ...[
              _buildVoiceRecordingSection(),
              const SizedBox(height: AppConstants.defaultPadding),
            ],

            // File Upload Section
            _buildFileUploadSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildVoiceRecordingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Voice Recording',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppConstants.smallPadding),
        Container(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    Icons.mic,
                    color: _isRecording
                        ? Colors.red
                        : Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: AppConstants.smallPadding),
                  Expanded(
                    child: Text(
                      _isRecording
                          ? 'Recording... Tap to stop'
                          : _hasRecording
                          ? 'Recording completed'
                          : 'Tap to start recording',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.defaultPadding),
              Row(
                children: [
                  if (!_isRecording) ...[
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _startRecording,
                        icon: const Icon(Icons.mic),
                        label: const Text('Start Recording'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ] else if (_isPaused) ...[
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _resumeRecording,
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Resume'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppConstants.smallPadding),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _stopRecording,
                        icon: const Icon(Icons.stop),
                        label: const Text('Stop'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ] else ...[
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _pauseRecording,
                        icon: const Icon(Icons.pause),
                        label: const Text('Pause'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppConstants.smallPadding),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _stopRecording,
                        icon: const Icon(Icons.stop),
                        label: const Text('Stop'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                  if (_hasRecording && !_isRecording) ...[
                    const SizedBox(width: AppConstants.smallPadding),
                    IconButton(
                      onPressed: _playRecording,
                      icon: const Icon(Icons.play_arrow),
                      tooltip: 'Play Recording',
                    ),
                    IconButton(
                      onPressed: _deleteRecording,
                      icon: const Icon(Icons.delete, color: Colors.red),
                      tooltip: 'Delete Recording',
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFileUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'File Upload',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppConstants.smallPadding),
        Text(
          'Upload pictures or PDF files',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppConstants.smallPadding),
        OutlinedButton.icon(
          onPressed: _uploadFile,
          icon: const Icon(Icons.upload_file),
          label: const Text('Upload File'),
        ),
        if (_uploadedFiles.isNotEmpty) ...[
          const SizedBox(height: AppConstants.defaultPadding),
          ..._uploadedFiles.map((file) => _buildUploadedFileItem(file)),
        ],
      ],
    );
  }

  Widget _buildUploadedFileItem(String fileName) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.smallPadding),
      child: ListTile(
        leading: const Icon(Icons.attach_file),
        title: Text(fileName),
        trailing: IconButton(
          onPressed: () => _removeFile(fileName),
          icon: const Icon(Icons.close, color: Colors.red),
        ),
      ),
    );
  }

  Widget _buildNotesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Additional Notes (Optional)',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppConstants.smallPadding),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                hintText: 'Add any additional notes or comments...',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskStatusChip(TaskStatus status) {
    Color color;
    String text;

    switch (status) {
      case TaskStatus.draft:
        color = Colors.grey;
        text = 'Draft';
        break;
      case TaskStatus.published:
        color = Colors.green;
        text = 'Published';
        break;
      case TaskStatus.closed:
        color = Colors.red;
        text = 'Closed';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.smallPadding,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getTaskTypeIcon(TaskType type) {
    switch (type) {
      case TaskType.dailyListening:
        return Icons.headphones;
      case TaskType.cba:
        return Icons.quiz;
      case TaskType.oba:
        return Icons.assignment;
      case TaskType.slokaMemorization:
        return Icons.menu_book;
      case TaskType.announcement:
        return Icons.announcement;
    }
  }

  Color _getTaskTypeColor(TaskType type) {
    switch (type) {
      case TaskType.dailyListening:
        return Colors.blue;
      case TaskType.cba:
        return Colors.purple;
      case TaskType.oba:
        return Colors.orange;
      case TaskType.slokaMemorization:
        return Colors.teal;
      case TaskType.announcement:
        return Colors.green;
    }
  }

  Future<void> _startRecording() async {
    // Request mic permission
    var status = await Permission.microphone.status;
    if (status.isDenied) {
      status = await Permission.microphone.request();
    }
    if (status.isPermanentlyDenied) {
      _showPermissionDialog();
      return;
    }
    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Microphone permission is required for recording'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Prepare local path
    final dir = await getApplicationDocumentsDirectory();
    final recordingsDir = Directory(p.join(dir.path, 'recordings'));
    if (!await recordingsDir.exists()) {
      await recordingsDir.create(recursive: true);
    }
    final filePath = p.join(
      recordingsDir.path,
      'dl_${DateTime.now().millisecondsSinceEpoch}.m4a',
    );

    // Start recording
    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: 128000,
        sampleRate: 44100,
      ),
      path: filePath,
    );

    setState(() {
      _isRecording = true;
      _isPaused = false;
      _hasRecording = false;
      _recordingPath = filePath;
    });
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Microphone Permission Required'),
        content: const Text(
          'This app needs microphone permission to record audio. Please enable it in app settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  Future<void> _pauseRecording() async {
    if (await _recorder.isRecording()) {
      await _recorder.pause();
      setState(() {
        _isPaused = true;
      });
    }
  }

  Future<void> _resumeRecording() async {
    if (await _recorder.isPaused()) {
      await _recorder.resume();
      setState(() {
        _isPaused = false;
      });
    }
  }

  Future<void> _stopRecording() async {
    final path = await _recorder.stop();
    setState(() {
      _isRecording = false;
      _isPaused = false;
      _hasRecording = path != null && path.isNotEmpty;
      _recordingPath = path ?? _recordingPath;
    });
  }

  Future<void> _playRecording() async {
    if (_recordingPath == null) return;
    try {
      await _player.stop();
      await _player.play(DeviceFileSource(_recordingPath!));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to play recording: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _deleteRecording() {
    setState(() {
      _hasRecording = false;
      _recordingPath = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Recording deleted'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  Future<void> _uploadFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx'],
        allowMultiple: true,
      );

      if (result != null) {
        for (var file in result.files) {
          setState(() {
            _uploadedFiles.add(file.name);
          });
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${result.files.length} file(s) selected'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error selecting files: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _removeFile(String fileName) {
    setState(() {
      _uploadedFiles.remove(fileName);
    });
  }

  Future<void> _submitTask() async {
    if (_alreadySubmitted) {
      return;
    }
    // For Daily Listening, no validation needed - just mark as submitted for the date
    if (widget.task.type != TaskType.dailyListening) {
      if (!_hasRecording &&
          _uploadedFiles.isEmpty &&
          _notesController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Please add at least one submission (recording, file, or notes)',
            ),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
    }

    // Check for late submission for Daily Listening
    if (widget.task.type == TaskType.dailyListening) {
      // current date used for due date comparison
      final now = DateTime.now();
      final currentDate = DateTime(now.year, now.month, now.day);

      if (widget.task.dueDate != null) {
        final dueDate = DateTime(
          widget.task.dueDate!.year,
          widget.task.dueDate!.month,
          widget.task.dueDate!.day,
        );

        if (currentDate.isAfter(dueDate)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Daily Listening cannot be submitted after the due date',
              ),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final now = DateTime.now();

      final submission = Submission(
        id: '', // Will be generated by Firestore
        taskId: widget.task.id,
        studentId: userProvider.currentUser!.id,
        batchId: widget.task.batchId,
        status: SubmissionStatus.submitted,
        createdAt: now,
        updatedAt: now,
        submittedAt: now,
        fileUrls: widget.task.type == TaskType.dailyListening
            ? []
            : _uploadedFiles,
        recordingUrl: widget.task.type == TaskType.dailyListening
            ? null
            : _recordingPath,
        notes: widget.task.type == TaskType.dailyListening
            ? null
            : (_notesController.text.trim().isEmpty
                  ? null
                  : _notesController.text.trim()),
      );

      await _firestoreService.createSubmission(submission);

      // Delete local recording after successful submission
      if (_recordingPath != null) {
        try {
          final f = File(_recordingPath!);
          if (await f.exists()) {
            await f.delete();
          }
        } catch (_) {}
        _recordingPath = null;
        _hasRecording = false;
      }

      _alreadySubmitted = true;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.task.type == TaskType.dailyListening
                  ? 'Daily Listening marked as completed for today!'
                  : 'Task submitted successfully!',
            ),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.of(context).pop(true); // Return true to indicate submission
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit task: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}
