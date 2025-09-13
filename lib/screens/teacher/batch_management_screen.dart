import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/course_group_provider.dart';
import '../../providers/batch_provider.dart';
import '../../constants/app_constants.dart';
import '../../utils/helpers.dart';
import '../../models/batch.dart';
import '../../models/course_group.dart';

class BatchManagementScreen extends StatefulWidget {
  const BatchManagementScreen({super.key});

  @override
  State<BatchManagementScreen> createState() => _BatchManagementScreenState();
}

class _BatchManagementScreenState extends State<BatchManagementScreen> {
  CourseGroup? _selectedCourseGroup;
  List<Batch> _allBatches = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final courseGroupProvider = Provider.of<CourseGroupProvider>(context, listen: false);
    
    if (userProvider.currentUser != null) {
      await courseGroupProvider.loadCourseGroups(userProvider.currentUser!.id);
      
      // Load batches for all course groups
      await _loadAllBatches();
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadAllBatches() async {
    final courseGroupProvider = Provider.of<CourseGroupProvider>(context, listen: false);
    final batchProvider = Provider.of<BatchProvider>(context, listen: false);
    
    _allBatches.clear();
    
    for (final courseGroup in courseGroupProvider.courseGroups) {
      await batchProvider.loadBatchesByCourseGroup(courseGroup.id);
      _allBatches.addAll(batchProvider.batches);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Batch Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: Consumer<CourseGroupProvider>(
        builder: (context, courseGroupProvider, child) {
          if (_isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (courseGroupProvider.courseGroups.isEmpty) {
            return _buildEmptyState();
          }

          return Column(
            children: [
              // Course Group Filter
              _buildCourseGroupFilter(courseGroupProvider.courseGroups),
              
              // Batches List
              Expanded(
                child: _buildBatchesList(),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _selectedCourseGroup != null ? _showCreateBatchDialog : null,
        icon: const Icon(Icons.add),
        label: const Text('Create Batch'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.largePadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.school_outlined,
              size: 120,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: AppConstants.largePadding),
            Text(
              'No Course Groups Found',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.smallPadding),
            Text(
              'Create a course group first to manage batches',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseGroupFilter(List<CourseGroup> courseGroups) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filter by Course Group',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppConstants.smallPadding),
          DropdownButtonFormField<CourseGroup?>(
            value: _selectedCourseGroup,
            decoration: const InputDecoration(
              hintText: 'All Course Groups',
              prefixIcon: Icon(Icons.filter_list),
            ),
            items: [
              const DropdownMenuItem<CourseGroup?>(
                value: null,
                child: Text('All Course Groups'),
              ),
              ...courseGroups.map((courseGroup) {
                return DropdownMenuItem<CourseGroup?>(
                  value: courseGroup,
                  child: Text(courseGroup.name),
                );
              }),
            ],
            onChanged: (CourseGroup? value) {
              setState(() {
                _selectedCourseGroup = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBatchesList() {
    final filteredBatches = _selectedCourseGroup == null
        ? _allBatches
        : _allBatches.where((batch) => batch.courseGroupId == _selectedCourseGroup!.id).toList();

    if (filteredBatches.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.class_,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            Text(
              _selectedCourseGroup == null
                  ? 'No Batches Found'
                  : 'No Batches in ${_selectedCourseGroup!.name}',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.smallPadding),
            Text(
              'Create your first batch to start organizing students',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      itemCount: filteredBatches.length,
      itemBuilder: (context, index) {
        final batch = filteredBatches[index];
        return _buildBatchCard(batch);
      },
    );
  }

  Widget _buildBatchCard(Batch batch) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.defaultPadding),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        onTap: () {
          // TODO: Navigate to batch details
        },
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Text(
                      Helpers.getInitials(batch.name),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppConstants.defaultPadding),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          batch.name,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Class Code: ${batch.classCode}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        // TODO: Navigate to edit batch
                      } else if (value == 'delete') {
                        _showDeleteDialog(batch);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: ListTile(
                          leading: Icon(Icons.edit),
                          title: Text('Edit'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: ListTile(
                          leading: Icon(Icons.delete, color: Colors.red),
                          title: Text('Delete', style: TextStyle(color: Colors.red)),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.defaultPadding),
              Text(
                batch.description,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppConstants.defaultPadding),
              Row(
                children: [
                  _buildInfoChip(
                    Icons.people,
                    '${batch.studentCount} students',
                    Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: AppConstants.smallPadding),
                  _buildInfoChip(
                    Icons.schedule,
                    Helpers.formatRelativeTime(batch.updatedAt),
                    Theme.of(context).colorScheme.secondary,
                  ),
                ],
              ),
            ],
          ),
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

  void _showCreateBatchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Batch'),
        content: const Text('Batch creation feature will be implemented soon.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(Batch batch) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Batch'),
        content: Text(
          'Are you sure you want to delete "${batch.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              // TODO: Implement batch deletion
            },
            child: const Text(
              AppStrings.delete,
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
