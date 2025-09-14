import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_constants.dart';
import '../../models/batch.dart';
import '../../models/enrollment.dart';
import '../../models/user.dart' as app_user;
import '../../services/firestore_service.dart';
import '../../utils/helpers.dart';

class BatchDetailsScreen extends StatefulWidget {
  final Batch batch;

  const BatchDetailsScreen({
    super.key,
    required this.batch,
  });

  @override
  State<BatchDetailsScreen> createState() => _BatchDetailsScreenState();
}

class _BatchDetailsScreenState extends State<BatchDetailsScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  List<Enrollment> _pendingEnrollments = [];
  List<Enrollment> _activeEnrollments = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadEnrollments();
  }

  Future<void> _loadEnrollments() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Load pending enrollments
      final pendingStream = _firestoreService
          .getEnrollmentsByBatch(widget.batch.id)
          .map((enrollments) => enrollments.where((e) => e.isPending).toList());
      
      // Load active enrollments
      final activeStream = _firestoreService
          .getEnrollmentsByBatch(widget.batch.id)
          .map((enrollments) => enrollments.where((e) => e.isActive).toList());

      final pendingEnrollments = await pendingStream.first;
      final activeEnrollments = await activeStream.first;

      setState(() {
        _pendingEnrollments = pendingEnrollments;
        _activeEnrollments = activeEnrollments;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.batch.name),
        backgroundColor: const Color(AppColors.primaryColorValue),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadEnrollments,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorState()
              : _buildContent(),
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
              'Error Loading Data',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
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
            ElevatedButton(
              onPressed: _loadEnrollments,
              child: const Text('Retry'),
            ),
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
          
          // Pending Requests Section
          if (_pendingEnrollments.isNotEmpty) ...[
            _buildPendingRequestsSection(),
            const SizedBox(height: AppConstants.largePadding),
          ],
          
          // Active Students Section
          _buildActiveStudentsSection(),
        ],
      ),
    );
  }

  Widget _buildBatchInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
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
                        'Batch Code: ${widget.batch.classCode}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            Text(
              widget.batch.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            Row(
              children: [
                _buildInfoChip(
                  Icons.people,
                  '${_activeEnrollments.length} Active Students',
                  Colors.green,
                ),
                const SizedBox(width: AppConstants.smallPadding),
                _buildInfoChip(
                  Icons.pending,
                  '${_pendingEnrollments.length} Pending Requests',
                  Colors.orange,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingRequestsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.pending_actions,
              color: Colors.orange,
            ),
            const SizedBox(width: AppConstants.smallPadding),
            Text(
              'Pending Requests (${_pendingEnrollments.length})',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.defaultPadding),
        ..._pendingEnrollments.map((enrollment) => _buildPendingEnrollmentCard(enrollment)),
      ],
    );
  }

  Widget _buildActiveStudentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.people,
              color: Colors.green,
            ),
            const SizedBox(width: AppConstants.smallPadding),
            Text(
              'Active Students (${_activeEnrollments.length})',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.defaultPadding),
        if (_activeEnrollments.isEmpty)
          _buildEmptyState('No active students yet')
        else
          ..._activeEnrollments.map((enrollment) => _buildActiveEnrollmentCard(enrollment)),
      ],
    );
  }

  Widget _buildPendingEnrollmentCard(Enrollment enrollment) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.smallPadding),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: FutureBuilder<app_user.User?>(
          future: _firestoreService.getUserById(enrollment.studentId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const ListTile(
                leading: CircularProgressIndicator(),
                title: Text('Loading...'),
              );
            }

            final user = snapshot.data;
            if (user == null) {
              return const ListTile(
                leading: Icon(Icons.error),
                title: Text('User not found'),
              );
            }

            return Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Text(
                      Helpers.getInitials(user.name),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    user.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.email),
                      if (user.whatsappNumber != null)
                        Text('WhatsApp: ${user.whatsappNumber}'),
                      Text(
                        'Requested: ${Helpers.formatRelativeTime(enrollment.enrolledAt)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppConstants.smallPadding),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _approveEnrollment(enrollment),
                        icon: const Icon(Icons.check, color: Colors.green),
                        label: const Text('Approve'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.green,
                          side: const BorderSide(color: Colors.green),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppConstants.smallPadding),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _declineEnrollment(enrollment),
                        icon: const Icon(Icons.close, color: Colors.red),
                        label: const Text('Decline'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildActiveEnrollmentCard(Enrollment enrollment) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.smallPadding),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: FutureBuilder<app_user.User?>(
          future: _firestoreService.getUserById(enrollment.studentId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const ListTile(
                leading: CircularProgressIndicator(),
                title: Text('Loading...'),
              );
            }

            final user = snapshot.data;
            if (user == null) {
              return const ListTile(
                leading: Icon(Icons.error),
                title: Text('User not found'),
              );
            }

            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: Colors.green,
                child: Text(
                  Helpers.getInitials(user.name),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                user.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.email),
                  if (user.whatsappNumber != null)
                    Text('WhatsApp: ${user.whatsappNumber}'),
                  Text(
                    'Joined: ${Helpers.formatRelativeTime(enrollment.enrolledAt)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'remove') {
                    _removeStudent(enrollment);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'remove',
                    child: ListTile(
                      leading: Icon(Icons.remove_circle, color: Colors.red),
                      title: Text('Remove Student'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
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
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.people_outline,
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

  Future<void> _approveEnrollment(Enrollment enrollment) async {
    try {
      // Update enrollment status to active
      final updatedEnrollment = enrollment.copyWith(
        status: EnrollmentStatus.active,
      );
      
      await _firestoreService.updateEnrollment(enrollment.id, updatedEnrollment);
      
      // Refresh the data
      await _loadEnrollments();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Student approved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to approve student: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _declineEnrollment(Enrollment enrollment) async {
    try {
      // Update enrollment status to declined
      final updatedEnrollment = enrollment.copyWith(
        status: EnrollmentStatus.declined,
      );
      
      await _firestoreService.updateEnrollment(enrollment.id, updatedEnrollment);
      
      // Refresh the data
      await _loadEnrollments();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Enrollment request declined'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to decline enrollment: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _removeStudent(Enrollment enrollment) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Student'),
        content: const Text('Are you sure you want to remove this student from the batch?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        // Update enrollment status to dropped
        final updatedEnrollment = enrollment.copyWith(
          status: EnrollmentStatus.dropped,
          droppedAt: DateTime.now(),
        );
        
        await _firestoreService.updateEnrollment(enrollment.id, updatedEnrollment);
        
        // Refresh the data
        await _loadEnrollments();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Student removed successfully'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to remove student: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
