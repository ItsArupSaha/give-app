import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../constants/app_constants.dart';
import '../../models/batch.dart';
import '../../models/course_group.dart';
import '../../providers/course_group_provider.dart';
import '../../providers/user_provider.dart';
import '../../services/firestore_service.dart';
import '../../utils/helpers.dart';
import 'batch_details_screen.dart';
import 'create_batch_screen.dart';

class BatchManagementScreen extends StatefulWidget {
  final String? initialCourseGroupId;

  const BatchManagementScreen({super.key, this.initialCourseGroupId});

  @override
  State<BatchManagementScreen> createState() => _BatchManagementScreenState();
}

class _BatchManagementScreenState extends State<BatchManagementScreen> {
  String? _selectedCourseGroupId;
  List<Batch> _allBatches = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedCourseGroupId = widget.initialCourseGroupId;
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final courseGroupProvider = Provider.of<CourseGroupProvider>(
      context,
      listen: false,
    );

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
    final courseGroupProvider = Provider.of<CourseGroupProvider>(
      context,
      listen: false,
    );
    final firestoreService = FirestoreService();

    _allBatches.clear();

    for (final courseGroup in courseGroupProvider.courseGroups) {
      try {
        final batches = await firestoreService
            .getBatchesByCourseGroup(courseGroup.id)
            .first;
        _allBatches.addAll(batches);
      } catch (e) {
        print('Error loading batches for course group ${courseGroup.id}: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Batch Management')),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: Consumer<CourseGroupProvider>(
          builder: (context, courseGroupProvider, child) {
            if (_isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (courseGroupProvider.courseGroups.isEmpty) {
              return _buildEmptyState();
            }

            return Column(
              children: [
                // Course Group Filter
                _buildCourseGroupFilter(courseGroupProvider.courseGroups),

                // Batches List
                Expanded(child: _buildBatchesList()),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _selectedCourseGroupId != null
            ? _showCreateBatchDialog
            : null,
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
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
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
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppConstants.smallPadding),
          DropdownButtonFormField<String?>(
            value: _selectedCourseGroupId,
            decoration: const InputDecoration(
              hintText: 'All Course Groups',
              prefixIcon: Icon(Icons.filter_list),
            ),
            items: [
              const DropdownMenuItem<String?>(
                value: null,
                child: Text('All Course Groups'),
              ),
              ...courseGroups.map((courseGroup) {
                return DropdownMenuItem<String?>(
                  value: courseGroup.id,
                  child: Text(courseGroup.name),
                );
              }),
            ],
            onChanged: (String? value) {
              setState(() {
                _selectedCourseGroupId = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBatchesList() {
    final filteredBatches = _selectedCourseGroupId == null
        ? _allBatches
        : _allBatches
              .where((batch) => batch.courseGroupId == _selectedCourseGroupId)
              .toList();

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
              _selectedCourseGroupId == null
                  ? 'No Batches Found'
                  : 'No Batches in Selected Course Group',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
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
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => BatchDetailsScreen(batch: batch),
            ),
          );
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
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Row(
                          children: [
                            Text(
                              'Class Code: ${batch.classCode}',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                            const SizedBox(width: 4),
                            GestureDetector(
                              onTap: () => _copyBatchCode(batch.classCode),
                              child: Icon(
                                Icons.copy,
                                size: 16,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        _showEditBatchDialog(batch);
                      } else if (value == 'copy') {
                        _copyBatchCode(batch.classCode);
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
                        value: 'copy',
                        child: ListTile(
                          leading: Icon(Icons.copy),
                          title: Text('Copy Code'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: ListTile(
                          leading: Icon(Icons.delete, color: Colors.red),
                          title: Text(
                            'Delete',
                            style: TextStyle(color: Colors.red),
                          ),
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
    if (_selectedCourseGroupId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a course group first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Find the selected course group
    final courseGroupProvider = Provider.of<CourseGroupProvider>(
      context,
      listen: false,
    );
    final selectedCourseGroup = courseGroupProvider.courseGroups.firstWhere(
      (cg) => cg.id == _selectedCourseGroupId,
    );

    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) =>
                CreateBatchScreen(courseGroup: selectedCourseGroup),
          ),
        )
        .then((_) {
          // Refresh data when returning from create batch screen
          _loadData();
        });
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
              await _deleteBatch(batch);
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

  void _copyBatchCode(String batchCode) {
    Clipboard.setData(ClipboardData(text: batchCode));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check, color: Colors.white),
            const SizedBox(width: 8),
            Text('Batch code "$batchCode" copied to clipboard'),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showEditBatchDialog(Batch batch) {
    final nameController = TextEditingController(text: batch.name);
    final descriptionController = TextEditingController(
      text: batch.description,
    );
    DateTime selectedDate = batch.startDate ?? DateTime.now();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Batch'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Batch Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: Text(
                    'Start Date: ${Helpers.formatDate(selectedDate)}',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setState(() {
                        selectedDate = date;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(AppStrings.cancel),
            ),
            TextButton(
              onPressed: () async {
                if (nameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a batch name'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                Navigator.pop(context);
                await _updateBatch(
                  batch,
                  nameController.text.trim(),
                  descriptionController.text.trim(),
                  selectedDate,
                );
              },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateBatch(
    Batch batch,
    String name,
    String description,
    DateTime startDate,
  ) async {
    try {
      setState(() {
        _isLoading = true;
      });

      final updatedBatch = batch.copyWith(
        name: name,
        description: description,
        startDate: startDate,
        updatedAt: DateTime.now(),
      );

      final firestoreService = FirestoreService();
      await firestoreService.updateBatch(updatedBatch.id, updatedBatch);
      await _loadData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Batch updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update batch: ${e.toString()}'),
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

  Future<void> _deleteBatch(Batch batch) async {
    try {
      setState(() {
        _isLoading = true;
      });

      final firestoreService = FirestoreService();
      await firestoreService.deleteBatch(batch.id, batch.courseGroupId);
      await _loadData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Batch deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete batch: ${e.toString()}'),
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
