import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_constants.dart';
import '../../models/batch.dart';
import '../../models/task.dart';
import '../../providers/user_provider.dart';
import '../../services/firestore_service.dart';
import '../../utils/helpers.dart';

class CreateTaskScreen extends StatefulWidget {
  final Batch batch;

  const CreateTaskScreen({
    super.key,
    required this.batch,
  });

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _instructionsController = TextEditingController();
  final _pointsController = TextEditingController(text: '100');
  
  TaskType _selectedType = TaskType.dailyListening;
  DateTime? _dueDate;
  bool _allowLateSubmission = true;
  int _lateSubmissionDays = 3;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _instructionsController.dispose();
    _pointsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Task'),
        backgroundColor: const Color(AppColors.primaryColorValue),
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveTask,
            child: const Text(
              'Save',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Task Type Selection
              _buildTaskTypeSection(),
              const SizedBox(height: AppConstants.largePadding),
              
              // Basic Information
              _buildBasicInfoSection(),
              const SizedBox(height: AppConstants.largePadding),
              
              // Due Date and Points (not for announcements)
              if (_selectedType != TaskType.announcement) ...[
                _buildDueDateAndPointsSection(),
                const SizedBox(height: AppConstants.largePadding),
                
                // Late Submission Settings
                _buildLateSubmissionSection(),
                const SizedBox(height: AppConstants.largePadding),
              ],
              
              // Instructions
              _buildInstructionsSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTaskTypeSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Task Type',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            Wrap(
              spacing: AppConstants.smallPadding,
              children: TaskType.values.map((type) {
                final isSelected = _selectedType == type;
                return FilterChip(
                  label: Text(_getTaskTypeLabel(type)),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedType = type;
                    });
                  },
                  selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                  checkmarkColor: Theme.of(context).colorScheme.primary,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Basic Information',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Task Title *',
                hintText: 'Enter task title',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a task title';
                }
                return null;
              },
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description *',
                hintText: 'Enter task description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDueDateAndPointsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Due Date & Points',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    title: Text(
                      _dueDate == null 
                          ? 'No due date' 
                          : 'Due: ${Helpers.formatDate(_dueDate!)}',
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: _selectDueDate,
                  ),
                ),
                const SizedBox(width: AppConstants.defaultPadding),
                SizedBox(
                  width: 100,
                  child: TextFormField(
                    controller: _pointsController,
                    decoration: const InputDecoration(
                      labelText: 'Points',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Required';
                      }
                      final points = int.tryParse(value);
                      if (points == null || points <= 0) {
                        return 'Invalid';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLateSubmissionSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Late Submission',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            SwitchListTile(
              title: const Text('Allow late submission'),
              subtitle: const Text('Students can submit after due date'),
              value: _allowLateSubmission,
              onChanged: (value) {
                setState(() {
                  _allowLateSubmission = value;
                });
              },
            ),
            if (_allowLateSubmission) ...[
              const SizedBox(height: AppConstants.smallPadding),
              TextFormField(
                initialValue: _lateSubmissionDays.toString(),
                decoration: const InputDecoration(
                  labelText: 'Days after due date',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  _lateSubmissionDays = int.tryParse(value) ?? 3;
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Instructions (Optional)',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            TextFormField(
              controller: _instructionsController,
              decoration: const InputDecoration(
                labelText: 'Additional instructions',
                hintText: 'Enter any specific instructions for students',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
          ],
        ),
      ),
    );
  }

  String _getTaskTypeLabel(TaskType type) {
    switch (type) {
      case TaskType.dailyListening:
        return 'Daily Listening';
      case TaskType.cba:
        return 'CBA';
      case TaskType.oba:
        return 'OBA';
      case TaskType.announcement:
        return 'Announcement';
    }
  }

  Future<void> _selectDueDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() {
        _dueDate = date;
      });
    }
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final firestoreService = FirestoreService();

      final task = Task(
        id: '', // Will be generated by Firestore
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        batchId: widget.batch.id,
        teacherId: userProvider.currentUser!.id,
        type: _selectedType,
        status: TaskStatus.published,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        dueDate: _selectedType == TaskType.announcement ? null : _dueDate,
        maxPoints: _selectedType == TaskType.announcement ? 0 : int.parse(_pointsController.text.trim()),
        allowLateSubmission: _selectedType == TaskType.announcement ? false : _allowLateSubmission,
        lateSubmissionDays: _selectedType == TaskType.announcement ? 0 : _lateSubmissionDays,
        instructions: _instructionsController.text.trim().isEmpty 
            ? null 
            : _instructionsController.text.trim(),
      );

      await firestoreService.createTask(task);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Task created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create task: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
