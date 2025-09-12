import 'package:cloud_firestore/cloud_firestore.dart';

enum TaskStatus { draft, published, closed }
enum TaskType { assignment, quiz, material, announcement }

class Task {
  final String id;
  final String title;
  final String description;
  final String batchId;
  final String teacherId;
  final TaskType type;
  final TaskStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? dueDate;
  final int maxPoints;
  final List<String> attachments;
  final List<String> allowedFileTypes;
  final bool allowLateSubmission;
  final int lateSubmissionDays;
  final String? instructions;
  final int submissionCount;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.batchId,
    required this.teacherId,
    required this.type,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.dueDate,
    this.maxPoints = 100,
    this.attachments = const [],
    this.allowedFileTypes = const ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
    this.allowLateSubmission = true,
    this.lateSubmissionDays = 3,
    this.instructions,
    this.submissionCount = 0,
  });

  factory Task.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Task(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      batchId: data['batchId'] ?? '',
      teacherId: data['teacherId'] ?? '',
      type: TaskType.values.firstWhere(
        (e) => e.toString() == 'TaskType.${data['type']}',
        orElse: () => TaskType.assignment,
      ),
      status: TaskStatus.values.firstWhere(
        (e) => e.toString() == 'TaskStatus.${data['status']}',
        orElse: () => TaskStatus.draft,
      ),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      dueDate: data['dueDate'] != null
          ? (data['dueDate'] as Timestamp).toDate()
          : null,
      maxPoints: data['maxPoints'] ?? 100,
      attachments: List<String>.from(data['attachments'] ?? []),
      allowedFileTypes: List<String>.from(data['allowedFileTypes'] ?? ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png']),
      allowLateSubmission: data['allowLateSubmission'] ?? true,
      lateSubmissionDays: data['lateSubmissionDays'] ?? 3,
      instructions: data['instructions'],
      submissionCount: data['submissionCount'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'batchId': batchId,
      'teacherId': teacherId,
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'dueDate': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
      'maxPoints': maxPoints,
      'attachments': attachments,
      'allowedFileTypes': allowedFileTypes,
      'allowLateSubmission': allowLateSubmission,
      'lateSubmissionDays': lateSubmissionDays,
      'instructions': instructions,
      'submissionCount': submissionCount,
    };
  }

  Task copyWith({
    String? id,
    String? title,
    String? description,
    String? batchId,
    String? teacherId,
    TaskType? type,
    TaskStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? dueDate,
    int? maxPoints,
    List<String>? attachments,
    List<String>? allowedFileTypes,
    bool? allowLateSubmission,
    int? lateSubmissionDays,
    String? instructions,
    int? submissionCount,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      batchId: batchId ?? this.batchId,
      teacherId: teacherId ?? this.teacherId,
      type: type ?? this.type,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      dueDate: dueDate ?? this.dueDate,
      maxPoints: maxPoints ?? this.maxPoints,
      attachments: attachments ?? this.attachments,
      allowedFileTypes: allowedFileTypes ?? this.allowedFileTypes,
      allowLateSubmission: allowLateSubmission ?? this.allowLateSubmission,
      lateSubmissionDays: lateSubmissionDays ?? this.lateSubmissionDays,
      instructions: instructions ?? this.instructions,
      submissionCount: submissionCount ?? this.submissionCount,
    );
  }

  bool get isOverdue {
    if (dueDate == null) return false;
    return DateTime.now().isAfter(dueDate!);
  }

  bool get isDueSoon {
    if (dueDate == null) return false;
    final daysUntilDue = dueDate!.difference(DateTime.now()).inDays;
    return daysUntilDue <= 3 && daysUntilDue >= 0;
  }
}
