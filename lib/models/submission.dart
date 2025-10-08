import 'package:cloud_firestore/cloud_firestore.dart';

enum SubmissionStatus { draft, submitted, graded }

class Submission {
  final String id;
  final String taskId;
  final String studentId;
  final String batchId;
  final SubmissionStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? submittedAt;
  final List<String> fileUrls;
  final String? recordingUrl;
  final String? notes;
  final int? grade;
  final String? feedback;
  final DateTime? gradedAt;

  Submission({
    required this.id,
    required this.taskId,
    required this.studentId,
    required this.batchId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.submittedAt,
    this.fileUrls = const [],
    this.recordingUrl,
    this.notes,
    this.grade,
    this.feedback,
    this.gradedAt,
  });

  factory Submission.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Submission(
      id: doc.id,
      taskId: data['taskId'] ?? '',
      studentId: data['studentId'] ?? '',
      batchId: data['batchId'] ?? '',
      status: SubmissionStatus.values.firstWhere(
        (e) => e.toString().split('.').last == data['status'],
        orElse: () => SubmissionStatus.draft,
      ),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      submittedAt: data['submittedAt'] != null
          ? (data['submittedAt'] as Timestamp).toDate()
          : null,
      fileUrls: List<String>.from(data['fileUrls'] ?? []),
      recordingUrl: data['recordingUrl'],
      notes: data['notes'],
      grade: data['grade'],
      feedback: data['feedback'],
      gradedAt: data['gradedAt'] != null
          ? (data['gradedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'taskId': taskId,
      'studentId': studentId,
      'batchId': batchId,
      'status': status.toString().split('.').last,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'submittedAt': submittedAt != null ? Timestamp.fromDate(submittedAt!) : null,
      'fileUrls': fileUrls,
      'recordingUrl': recordingUrl,
      'notes': notes,
      'grade': grade,
      'feedback': feedback,
      'gradedAt': gradedAt != null ? Timestamp.fromDate(gradedAt!) : null,
    };
  }

  Submission copyWith({
    String? id,
    String? taskId,
    String? studentId,
    String? batchId,
    SubmissionStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? submittedAt,
    List<String>? fileUrls,
    String? recordingUrl,
    String? notes,
    int? grade,
    String? feedback,
    DateTime? gradedAt,
  }) {
    return Submission(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      studentId: studentId ?? this.studentId,
      batchId: batchId ?? this.batchId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      submittedAt: submittedAt ?? this.submittedAt,
      fileUrls: fileUrls ?? this.fileUrls,
      recordingUrl: recordingUrl ?? this.recordingUrl,
      notes: notes ?? this.notes,
      grade: grade ?? this.grade,
      feedback: feedback ?? this.feedback,
      gradedAt: gradedAt ?? this.gradedAt,
    );
  }

  bool get isSubmitted => status == SubmissionStatus.submitted;
  bool get isGraded => status == SubmissionStatus.graded;
  bool get isDraft => status == SubmissionStatus.draft;
}