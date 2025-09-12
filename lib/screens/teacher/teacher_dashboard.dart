import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/course_group_provider.dart';
import '../../constants/app_constants.dart';
import '../../utils/helpers.dart';
import 'course_groups_screen.dart';

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  void _initializeData() {
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
        title: const Text(AppStrings.teacherDashboard),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Implement notifications
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'profile') {
                // TODO: Navigate to profile
              } else if (value == 'logout') {
                _showLogoutDialog();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'profile',
                child: ListTile(
                  leading: Icon(Icons.person_outlined),
                  title: Text(AppStrings.profile),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: ListTile(
                  leading: Icon(Icons.logout),
                  title: Text(AppStrings.logout),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: Consumer2<UserProvider, CourseGroupProvider>(
        builder: (context, userProvider, courseGroupProvider, child) {
          if (courseGroupProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              if (userProvider.currentUser != null) {
                courseGroupProvider.loadCourseGroups(userProvider.currentUser!.id);
              }
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Section
                  _buildWelcomeSection(userProvider.currentUser?.name ?? ''),
                  const SizedBox(height: AppConstants.largePadding),
                  
                  // Statistics Cards
                  _buildStatisticsCards(courseGroupProvider),
                  const SizedBox(height: AppConstants.largePadding),
                  
                  // Course Groups Section
                  _buildCourseGroupsSection(courseGroupProvider),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CourseGroupsScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Manage Course Groups'),
      ),
    );
  }

  Widget _buildWelcomeSection(String name) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.largePadding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome back,',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.9),
            ),
          ),
          Text(
            Helpers.capitalizeWords(name),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Theme.of(context).colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            'Continue inspiring students on their spiritual journey',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCards(CourseGroupProvider courseGroupProvider) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Course Groups',
            courseGroupProvider.courseGroupCount.toString(),
            Icons.school,
            Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(width: AppConstants.defaultPadding),
        Expanded(
          child: _buildStatCard(
            'Total Batches',
            courseGroupProvider.totalBatchCount.toString(),
            Icons.groups,
            Theme.of(context).colorScheme.secondary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: color,
            ),
            const SizedBox(height: AppConstants.smallPadding),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseGroupsSection(CourseGroupProvider courseGroupProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Course Groups',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CourseGroupsScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.arrow_forward),
              label: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.defaultPadding),
        
        if (courseGroupProvider.courseGroups.isEmpty)
          _buildEmptyState()
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: courseGroupProvider.courseGroups.take(3).length,
            itemBuilder: (context, index) {
              final courseGroup = courseGroupProvider.courseGroups[index];
              return _buildCourseGroupCard(courseGroup);
            },
          ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.largePadding),
        child: Column(
          children: [
            Icon(
              Icons.school_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            Text(
              'No Course Groups Yet',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.smallPadding),
            Text(
              'Create your first course group to start teaching',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CourseGroupsScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Create Course Group'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseGroupCard(courseGroup) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.defaultPadding),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: Text(
            Helpers.getInitials(courseGroup.name),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          courseGroup.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          courseGroup.description,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${courseGroup.batchCount} batches',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
        onTap: () {
          // TODO: Navigate to course group details
        },
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final userProvider = Provider.of<UserProvider>(context, listen: false);
              await userProvider.signOut();
            },
            child: const Text(AppStrings.logout),
          ),
        ],
      ),
    );
  }
}
