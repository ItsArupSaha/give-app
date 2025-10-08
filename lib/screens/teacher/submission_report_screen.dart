import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'dart:convert';
import '../../constants/app_constants.dart';
import '../../models/batch.dart';
import '../../models/task.dart';
import '../../models/submission.dart';
import '../../models/user.dart' as app_user;
import '../../providers/user_provider.dart';
import '../../services/firestore_service.dart';
import '../../utils/helpers.dart';

class SubmissionReportScreen extends StatefulWidget {
  final Batch batch;

  const SubmissionReportScreen({
    super.key,
    required this.batch,
  });

  @override
  State<SubmissionReportScreen> createState() => _SubmissionReportScreenState();
}

class _SubmissionReportScreenState extends State<SubmissionReportScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  List<SubmissionReport> _reports = [];
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.batch.name} - Submission Report'),
        backgroundColor: const Color(AppColors.primaryColorValue),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Date Range Selection
          _buildDateRangeSelector(),
          
          // Generate Report Button
          Padding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _generateReport,
                icon: _isLoading 
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.analytics),
                label: Text(_isLoading ? 'Generating...' : 'Generate Report'),
              ),
            ),
          ),
          
          // Export Button (only show when report is generated)
          if (_reports.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _exportToExcel,
                  icon: const Icon(Icons.table_chart),
                  label: const Text('Export Excel'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ),
          
          // Report Results
          Expanded(
            child: _reports.isEmpty
                ? _buildEmptyState()
                : _buildReportTable(),
          ),
        ],
      ),
    );
  }

  Widget _buildDateRangeSelector() {
    return Card(
      margin: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Date Range',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Start Date'),
                      const SizedBox(height: 4),
                      InkWell(
                        onTap: _selectStartDate,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 20),
                              const SizedBox(width: 8),
                              Text(Helpers.formatDate(_startDate)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppConstants.defaultPadding),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('End Date'),
                      const SizedBox(height: 4),
                      InkWell(
                        onTap: _selectEndDate,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 20),
                              const SizedBox(width: 8),
                              Text(Helpers.formatDate(_endDate)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.analytics_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          Text(
            'No Report Generated',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            'Select a date range and generate report',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportTable() {
    return Card(
      margin: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppConstants.borderRadius),
                topRight: Radius.circular(AppConstants.borderRadius),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'Student Name',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Daily Listening Tasks',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: Text(
                    'Submitted',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: Text(
                    'Percentage',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          
          // Data Rows
          Expanded(
            child: ListView.builder(
              itemCount: _reports.length,
              itemBuilder: (context, index) {
                final report = _reports[index];
                return Container(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          report.studentName,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          '${report.totalTasks}',
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          '${report.submittedTasks}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: report.submittedTasks == report.totalTasks 
                                ? Colors.green 
                                : Colors.orange,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          '${report.percentage.toStringAsFixed(1)}%',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: _getPercentageColor(report.percentage),
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Color _getPercentageColor(double percentage) {
    if (percentage >= 90) return Colors.green;
    if (percentage >= 70) return Colors.orange;
    return Colors.red;
  }

  Future<void> _selectStartDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() {
        _startDate = date;
      });
    }
  }

  Future<void> _selectEndDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: _startDate,
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() {
        _endDate = date;
      });
    }
  }

  Future<void> _generateReport() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get all students in the batch
      final enrollments = await _firestoreService
          .getEnrollmentsByBatch(widget.batch.id)
          .map((enrollments) => enrollments.where((e) => e.isActive).toList())
          .first;

      // Get all Daily Listening tasks in the date range
      final allTasks = await _firestoreService.getTasksByBatch(widget.batch.id).first;
      final tasksInRange = allTasks.where((task) {
        // Only count Daily Listening tasks
        if (task.type != TaskType.dailyListening) return false;
        
        final taskDate = DateTime(
          task.createdAt.year,
          task.createdAt.month,
          task.createdAt.day,
        );
        return taskDate.isAfter(_startDate.subtract(const Duration(days: 1))) &&
               taskDate.isBefore(_endDate.add(const Duration(days: 1)));
      }).toList();

      // Get all submissions for the batch
      final allSubmissions = await _firestoreService
          .getSubmissionsByBatch(widget.batch.id);

      List<SubmissionReport> reports = [];

      for (final enrollment in enrollments) {
        // Get student details
        final student = await _firestoreService.getUserById(enrollment.studentId);
        if (student == null) continue;

        // Count submitted tasks for this student
        final studentSubmissions = allSubmissions.where((submission) {
          return submission.studentId == enrollment.studentId &&
                 submission.status == SubmissionStatus.submitted &&
                 tasksInRange.any((task) => task.id == submission.taskId);
        }).toList();

        // Count tasks that were published in the date range
        final totalTasksInRange = tasksInRange.length;

        reports.add(SubmissionReport(
          studentName: student.name,
          studentId: student.id,
          totalTasks: totalTasksInRange,
          submittedTasks: studentSubmissions.length,
          percentage: totalTasksInRange > 0 
              ? (studentSubmissions.length / totalTasksInRange) * 100 
              : 0,
        ));
      }

      // Sort by percentage (highest first)
      reports.sort((a, b) => b.percentage.compareTo(a.percentage));

      setState(() {
        _reports = reports;
        _isLoading = false;
      });

    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error generating report: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  

  Future<void> _exportToExcel() async {
    try {
      final content = _generateCSVContent();
      final fileName = 'daily_listening_report_${widget.batch.name}_${_startDate.day}_${_startDate.month}_${_startDate.year}_to_${_endDate.day}_${_endDate.month}_${_endDate.year}.csv';
      
      // Create a temporary file with proper extension
      final tempDir = Directory.systemTemp;
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsString(content);
      
      await Share.shareXFiles([XFile(file.path, mimeType: 'text/csv')]);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error exporting Excel: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }


  String _generateCSVContent() {
    final buffer = StringBuffer();
    buffer.writeln('Student Name,Daily Listening Tasks,Submitted,Percentage');
    
    for (final report in _reports) {
      buffer.writeln('${report.studentName},${report.totalTasks},${report.submittedTasks},${report.percentage.toStringAsFixed(1)}%');
    }
    
    return buffer.toString();
  }
}

class SubmissionReport {
  final String studentName;
  final String studentId;
  final int totalTasks;
  final int submittedTasks;
  final double percentage;

  SubmissionReport({
    required this.studentName,
    required this.studentId,
    required this.totalTasks,
    required this.submittedTasks,
    required this.percentage,
  });
}
