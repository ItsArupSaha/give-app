import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../constants/app_constants.dart';
import '../../models/batch.dart';
import '../../models/submission.dart';
import '../../models/task.dart';
import '../../providers/user_provider.dart';
import '../../services/firestore_service.dart';
import '../../utils/helpers.dart';
import 'task_submission_screen.dart';

class BatchTasksScreen extends StatefulWidget {
  final Batch batch;

  const BatchTasksScreen({super.key, required this.batch});

  @override
  State<BatchTasksScreen> createState() => _BatchTasksScreenState();
}

class _BatchTasksScreenState extends State<BatchTasksScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  List<Task> _tasks = [];
  Map<String, Submission> _submissions = {};
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTasks();
    _loadSubmissions();
  }

  Future<void> _loadTasks() async {
    try {
      final tasksStream = _firestoreService.getTasksByBatch(widget.batch.id);
      final tasks = await tasksStream.first;

      setState(() {
        _tasks = tasks;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadSubmissions() async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      if (userProvider.currentUser != null) {
        final submissionsStream = _firestoreService.getSubmissionsByStudent(
          userProvider.currentUser!.id,
        );
        final submissions = await submissionsStream.first;

        Map<String, Submission> submissionMap = {};
        for (var submission in submissions) {
          submissionMap[submission.taskId] = submission;
        }

        setState(() {
          _submissions = submissionMap;
        });
      }
    } catch (e) {
      print('Error loading submissions: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.batch.name} - Tasks'),
        backgroundColor: const Color(AppColors.primaryColorValue),
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadTasks();
          await _loadSubmissions();
        },
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? _buildErrorState()
            : _buildContent(),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.largePadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            Text(
              'Error Loading Tasks',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppConstants.smallPadding),
            Text(
              _error!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            ElevatedButton(onPressed: _loadTasks, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Batch Info Card
          _buildBatchInfoCard(),
          const SizedBox(height: AppConstants.largePadding),

          // Tasks List
          _buildTasksList(),
        ],
      ),
    );
  }

  Widget _buildBatchInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Text(
                Helpers.getInitials(widget.batch.name),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
            const SizedBox(width: AppConstants.defaultPadding),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.batch.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Class Code: ${widget.batch.classCode}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.batch.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTasksList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.assignment,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: AppConstants.smallPadding),
            Text(
              'Tasks (${_tasks.length})',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.defaultPadding),
        if (_tasks.isEmpty)
          _buildEmptyState('No tasks available yet')
        else
          ..._tasks.map((task) => _buildTaskCard(task)),
      ],
    );
  }

  Widget _buildTaskCard(Task task) {
    final submission = _submissions[task.id];
    final isSubmitted = submission?.status == SubmissionStatus.submitted;
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.smallPadding),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        onTap: task.type == TaskType.announcement || isSubmitted
            ? null
            : () => _viewTaskDetails(task),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _getTaskTypeIcon(task.type),
                    color: _getTaskTypeColor(task.type),
                    size: 20,
                  ),
                  const SizedBox(width: AppConstants.smallPadding),
                  Expanded(
                    child: Text(
                      task.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      _buildSubmissionStatusChip(task),
                      const SizedBox(width: AppConstants.smallPadding),
                      _buildTaskStatusChip(task.status),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.smallPadding),
              _buildLinkifiedText(
                task.description,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppConstants.smallPadding),
              if (task.type != TaskType.announcement)
                Wrap(
                  spacing: AppConstants.smallPadding,
                  runSpacing: AppConstants.smallPadding,
                  children: [
                    _buildInfoChip(
                      Icons.schedule,
                      task.dueDate != null
                          ? 'Due: ${Helpers.formatDate(task.dueDate!)}'
                          : 'No due date',
                      task.isOverdue ? Colors.red : Colors.orange,
                    ),
                    _buildInfoChip(
                      Icons.stars,
                      '${task.maxPoints} points',
                      Colors.blue,
                    ),
                    if (task.isDueSoon)
                      _buildInfoChip(Icons.warning, 'Due Soon', Colors.red),
                  ],
                ),
            ],
          ),
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

  Widget _buildSubmissionStatusChip(Task task) {
    final submission = _submissions[task.id];

    if (submission == null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          'Not Submitted',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    Color color;
    String text;
    IconData icon;

    switch (submission.status) {
      case SubmissionStatus.draft:
        color = Colors.orange;
        text = 'Draft';
        icon = Icons.edit;
        break;
      case SubmissionStatus.submitted:
        color = Colors.green;
        text = 'Submitted';
        icon = Icons.check_circle;
        break;
      case SubmissionStatus.graded:
        color = Colors.blue;
        text = 'Graded';
        icon = Icons.grade;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
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

  Widget _buildEmptyState(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.largePadding),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 48,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          Text(
            message,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
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

  void _viewTaskDetails(Task task) {
    // Announcements are not clickable
    if (task.type == TaskType.announcement) {
      return;
    }

    // Navigate to task submission screen for other task types
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => TaskSubmissionScreen(task: task),
          ),
        )
        .then((submitted) {
          // Refresh submissions if task was submitted
          if (submitted == true) {
            _loadSubmissions();
          }
        });
  }
}
