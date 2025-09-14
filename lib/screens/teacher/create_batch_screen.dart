import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_constants.dart';
import '../../providers/user_provider.dart';
import '../../providers/course_group_provider.dart';
import '../../providers/batch_provider.dart';
import '../../models/batch.dart';
import '../../models/course_group.dart';
import '../../utils/helpers.dart';
import '../../services/firestore_service.dart';

class CreateBatchScreen extends StatefulWidget {
  final CourseGroup courseGroup;

  const CreateBatchScreen({
    super.key,
    required this.courseGroup,
  });

  @override
  State<CreateBatchScreen> createState() => _CreateBatchScreenState();
}

class _CreateBatchScreenState extends State<CreateBatchScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _startDateController = TextEditingController();
  
  DateTime? _selectedStartDate;
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _startDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Batch'),
        backgroundColor: const Color(AppColors.primaryColorValue),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Course Group Info
              _buildCourseGroupInfo(),
              const SizedBox(height: AppConstants.largePadding),
              
              // Batch Name
              _buildNameField(),
              const SizedBox(height: AppConstants.defaultPadding),
              
              // Description
              _buildDescriptionField(),
              const SizedBox(height: AppConstants.defaultPadding),
              
              // Start Date
              _buildStartDateField(),
              const SizedBox(height: AppConstants.largePadding),
              
              // Error Message
              if (_error != null) _buildErrorMessage(),
              
              // Create Button
              _buildCreateButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCourseGroupInfo() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: const Icon(
              Icons.folder,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: AppConstants.defaultPadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Course Group',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  widget.courseGroup.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Batch Name *',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppConstants.smallPadding),
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            hintText: 'Enter batch name (e.g., "Batch 1 - Morning")',
            prefixIcon: Icon(Icons.class_),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter batch name';
            }
            if (value.trim().length < 3) {
              return 'Batch name must be at least 3 characters';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description *',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppConstants.smallPadding),
        TextFormField(
          controller: _descriptionController,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'Describe the batch, schedule, and any special instructions...',
            prefixIcon: Icon(Icons.description),
            alignLabelWithHint: true,
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter batch description';
            }
            if (value.trim().length < 10) {
              return 'Description must be at least 10 characters';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildStartDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Start Date *',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppConstants.smallPadding),
        TextFormField(
          controller: _startDateController,
          readOnly: true,
          decoration: const InputDecoration(
            hintText: 'Select start date',
            prefixIcon: Icon(Icons.calendar_today),
            suffixIcon: Icon(Icons.arrow_drop_down),
          ),
          onTap: _selectStartDate,
          validator: (value) {
            if (_selectedStartDate == null) {
              return 'Please select start date';
            }
            return null;
          },
        ),
      ],
    );
  }


  Widget _buildErrorMessage() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      margin: const EdgeInsets.only(bottom: AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(
          color: Theme.of(context).colorScheme.error.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Theme.of(context).colorScheme.error,
            size: 20,
          ),
          const SizedBox(width: AppConstants.smallPadding),
          Expanded(
            child: Text(
              _error!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onErrorContainer,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _createBatch,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(AppColors.primaryColorValue),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            vertical: AppConstants.defaultPadding,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'Create Batch',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Future<void> _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        _selectedStartDate = picked;
        _startDateController.text = Helpers.formatDate(picked);
      });
    }
  }


  Future<void> _createBatch() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final batchProvider = Provider.of<BatchProvider>(context, listen: false);
      final firestoreService = FirestoreService();

      // Generate unique batch code
      String batchCode = Helpers.generateBatchCode();

      // Create batch
      final batch = Batch(
        id: '', // Will be set by Firestore
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        courseGroupId: widget.courseGroup.id,
        teacherId: userProvider.currentUser!.id,
        classCode: batchCode,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        startDate: _selectedStartDate,
      );

      // Save to Firestore
      await firestoreService.createBatch(batch);
      
      // Update local state
      await batchProvider.loadBatchesByCourseGroup(widget.courseGroup.id);

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.white),
                    SizedBox(width: 8),
                    Text('Batch created successfully!'),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Batch Code: $batchCode',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Text(
                  'Share this code with students to join the batch',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 5),
          ),
        );

        // Navigate back
        Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to create batch: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
