import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/course_group_provider.dart';
import '../../models/course_group.dart';
import '../../constants/app_constants.dart';
import '../../utils/helpers.dart';

class CreateCourseGroupScreen extends StatefulWidget {
  const CreateCourseGroupScreen({super.key});

  @override
  State<CreateCourseGroupScreen> createState() => _CreateCourseGroupScreenState();
}

class _CreateCourseGroupScreenState extends State<CreateCourseGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.createCourseGroup),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.largePadding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Text(
                'Create New Course Group',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppConstants.smallPadding),
              Text(
                'Organize your spiritual education courses into groups',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppConstants.largePadding),
              
              // Course Group Name
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: AppStrings.courseGroupName,
                  hintText: 'e.g., ISKCON Disciple Course, Bhakti Sastri',
                  prefixIcon: Icon(Icons.school),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter course group name';
                  }
                  if (value.trim().length < 3) {
                    return 'Name must be at least 3 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppConstants.defaultPadding),
              
              // Description
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: AppStrings.courseGroupDescription,
                  hintText: 'Describe what this course group covers...',
                  prefixIcon: Icon(Icons.description),
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  if (value.trim().length < 10) {
                    return 'Description must be at least 10 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppConstants.largePadding),
              
              // Course Group Preview
              _buildCourseGroupPreview(),
              const SizedBox(height: AppConstants.largePadding),
              
              // Create Button
              ElevatedButton(
                onPressed: _isLoading ? null : _handleCreateCourseGroup,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(AppStrings.createCourseGroup),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCourseGroupPreview() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Preview',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(
                    _nameController.text.isNotEmpty
                        ? Helpers.getInitials(_nameController.text)
                        : 'CG',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: AppConstants.defaultPadding),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _nameController.text.isNotEmpty
                            ? _nameController.text
                            : 'Course Group Name',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Created just now',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (_descriptionController.text.isNotEmpty) ...[
              const SizedBox(height: AppConstants.defaultPadding),
              Text(
                _descriptionController.text,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: AppConstants.defaultPadding),
            Row(
              children: [
                _buildPreviewChip(
                  Icons.groups,
                  '0 batches',
                  Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: AppConstants.smallPadding),
                _buildPreviewChip(
                  Icons.schedule,
                  'Just created',
                  Theme.of(context).colorScheme.secondary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewChip(IconData icon, String text, Color color) {
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

  Future<void> _handleCreateCourseGroup() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        final courseGroupProvider = Provider.of<CourseGroupProvider>(context, listen: false);

        if (userProvider.currentUser == null) {
          throw Exception('User not found');
        }

        final courseGroup = CourseGroup(
          id: '', // Will be set by Firestore
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          teacherId: userProvider.currentUser!.id,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final success = await courseGroupProvider.createCourseGroup(courseGroup);

        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Course group "${courseGroup.name}" created successfully!'),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          );
          Navigator.pop(context);
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(courseGroupProvider.error ?? 'Failed to create course group'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Theme.of(context).colorScheme.error,
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
}
