import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/course_group_provider.dart';
import '../../constants/app_constants.dart';
import '../../utils/helpers.dart';
import 'create_course_group_screen.dart';

class CourseGroupsScreen extends StatefulWidget {
  const CourseGroupsScreen({super.key});

  @override
  State<CourseGroupsScreen> createState() => _CourseGroupsScreenState();
}

class _CourseGroupsScreenState extends State<CourseGroupsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCourseGroups();
    });
  }

  void _loadCourseGroups() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final courseGroupProvider = Provider.of<CourseGroupProvider>(context, listen: false);
    
    if (userProvider.currentUser != null) {
      courseGroupProvider.loadCourseGroups(userProvider.currentUser!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.courseGroups),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCourseGroups,
          ),
        ],
      ),
      body: Consumer<CourseGroupProvider>(
        builder: (context, courseGroupProvider, child) {
          if (courseGroupProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (courseGroupProvider.error != null) {
            return Center(
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
                    'Error loading course groups',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: AppConstants.smallPadding),
                  Text(
                    courseGroupProvider.error!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppConstants.defaultPadding),
                  ElevatedButton(
                    onPressed: _loadCourseGroups,
                    child: const Text(AppStrings.tryAgain),
                  ),
                ],
              ),
            );
          }

          if (courseGroupProvider.courseGroups.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () async {
              _loadCourseGroups();
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              itemCount: courseGroupProvider.courseGroups.length,
              itemBuilder: (context, index) {
                final courseGroup = courseGroupProvider.courseGroups[index];
                return _buildCourseGroupCard(courseGroup);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateCourseGroupScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text(AppStrings.createCourseGroup),
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
              'No Course Groups Yet',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.smallPadding),
            Text(
              'Create your first course group to start organizing your spiritual education courses',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.largePadding),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateCourseGroupScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text(AppStrings.createCourseGroup),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseGroupCard(courseGroup) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.defaultPadding),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        onTap: () {
          // TODO: Navigate to course group details
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
                      Helpers.getInitials(courseGroup.name),
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
                          courseGroup.name,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          Helpers.formatDate(courseGroup.createdAt),
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
                        // TODO: Navigate to edit course group
                      } else if (value == 'delete') {
                        _showDeleteDialog(courseGroup);
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
                courseGroup.description,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppConstants.defaultPadding),
              Row(
                children: [
                  _buildInfoChip(
                    Icons.groups,
                    '${courseGroup.batchCount} batches',
                    Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: AppConstants.smallPadding),
                  _buildInfoChip(
                    Icons.schedule,
                    Helpers.formatRelativeTime(courseGroup.updatedAt),
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

  void _showDeleteDialog(courseGroup) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Course Group'),
        content: Text(
          'Are you sure you want to delete "${courseGroup.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final courseGroupProvider = Provider.of<CourseGroupProvider>(context, listen: false);
              await courseGroupProvider.deleteCourseGroup(courseGroup.id);
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
