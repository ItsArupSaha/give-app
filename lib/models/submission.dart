import 'package:cloud_firestore/cloud_firestore.dart';

enum SubmissionStatus { draft, submitted, graded, late }

class Submission {
  final String id;
  final String taskId;
  final String studentId;
  final String batchId;
  final String title;
  final String? description;
  final List<String> fileUrls;
  final List<String> fileNames;
  final SubmissionStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? submittedAt;
  final int? points;
  final String? feedback;
  final DateTime? gradedAt;
  final String? gradedBy;
  final bool isLate;

  Submission({
    required this.id,
    required this.taskId,
    required this.studentId,
    required this.batchId,
    required this.title,
    this.description,
    this.fileUrls = const [],
    this.fileNames = const [],
    this.status = SubmissionStatus.draft,
    required this.createdAt,
    required this.updatedAt,
    this.submittedAt,
    this.points,
    this.feedback,
    this.gradedAt,
    this.gradedBy,
    this.isLate = false,
  });

  factory Submission.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Submission(
      id: doc.id,
      taskId: data['taskId'] ?? '',
      studentId: data['studentId'] ?? '',
      batchId: data['batchId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'],
      fileUrls: List<String>.from(data['fileUrls'] ?? []),
      fileNames: List<String>.from(data['fileNames'] ?? []),
      status: SubmissionStatus.values.firstWhere(
        (e) => e.toString() == 'SubmissionStatus.${data['status']}',
        orElse: () => SubmissionStatus.draft,
      ),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      submittedAt: data['submittedAt'] != null
          ? (data['submittedAt'] as Timestamp).toDate()
          : null,
      points: data['points'],
      feedback: data['feedback'],
      gradedAt: data['gradedAt'] != null
          ? (data['gradedAt'] as Timestamp).toDate()
          : null,
      gradedBy: data['gradedBy'],
      isLate: data['isLate'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'taskId': taskId,
      'studentId': studentId,
      'batchId': batchId,
      'title': title,
      'description': description,
      'fileUrls': fileUrls,
      'fileNames': fileNames,
      'status': status.toString().split('.').last,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'submittedAt': submittedAt != null ? Timestamp.fromDate(submittedAt!) : null,
      'points': points,
      'feedback': feedback,
      'gradedAt': gradedAt != null ? Timestamp.fromDate(gradedAt!) : null,
      'gradedBy': gradedBy,
      'isLate': isLate,
    };
  }

  Submission copyWith({
    String? id,
    String? taskId,
    String? studentId,
    String? batchId,
    String? title,
    String? description,
    List<String>? fileUrls,
    List<String>? fileNames,
    SubmissionStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? submittedAt,
    int? points,
    String? feedback,
    DateTime? gradedAt,
    String? gradedBy,
    bool? isLate,
  }) {
    return Submission(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      studentId: studentId ?? this.studentId,
      batchId: batchId ?? this.batchId,
      title: title ?? this.title,
      description: description ?? this.description,
      fileUrls: fileUrls ?? this.fileUrls,
      fileNames: fileNames ?? this.fileNames,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      submittedAt: submittedAt ?? this.submittedAt,
      points: points ?? this.points,
      feedback: feedback ?? this.feedback,
      gradedAt: gradedAt ?? this.gradedAt,
      gradedBy: gradedBy ?? this.gradedBy,
      isLate: isLate ?? this.isLate,
    );
  }

  bool get isSubmitted => status == SubmissionStatus.submitted || status == SubmissionStatus.graded;
  bool get isGraded => status == SubmissionStatus.graded;
  bool get isDraft => status == SubmissionStatus.draft;
}
