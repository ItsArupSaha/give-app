import 'package:cloud_firestore/cloud_firestore.dart';

enum EnrollmentStatus { pending, active, completed, dropped, declined }

class Enrollment {
  final String id;
  final String studentId;
  final String batchId;
  final String courseGroupId;
  final EnrollmentStatus status;
  final DateTime enrolledAt;
  final DateTime? completedAt;
  final DateTime? droppedAt;
  final String? classCode;
  final String? notes;

  Enrollment({
    required this.id,
    required this.studentId,
    required this.batchId,
    required this.courseGroupId,
    required this.status,
    required this.enrolledAt,
    this.completedAt,
    this.droppedAt,
    this.classCode,
    this.notes,
  });

  factory Enrollment.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Enrollment(
      id: doc.id,
      studentId: data['studentId'] ?? '',
      batchId: data['batchId'] ?? '',
      courseGroupId: data['courseGroupId'] ?? '',
      status: EnrollmentStatus.values.firstWhere(
        (e) => e.toString() == 'EnrollmentStatus.${data['status']}',
        orElse: () => EnrollmentStatus.pending,
      ),
      enrolledAt: (data['enrolledAt'] as Timestamp).toDate(),
      completedAt: data['completedAt'] != null
          ? (data['completedAt'] as Timestamp).toDate()
          : null,
      droppedAt: data['droppedAt'] != null
          ? (data['droppedAt'] as Timestamp).toDate()
          : null,
      classCode: data['classCode'],
      notes: data['notes'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'studentId': studentId,
      'batchId': batchId,
      'courseGroupId': courseGroupId,
      'status': status.toString().split('.').last,
      'enrolledAt': Timestamp.fromDate(enrolledAt),
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'droppedAt': droppedAt != null ? Timestamp.fromDate(droppedAt!) : null,
      'classCode': classCode,
      'notes': notes,
    };
  }

  Enrollment copyWith({
    String? id,
    String? studentId,
    String? batchId,
    String? courseGroupId,
    EnrollmentStatus? status,
    DateTime? enrolledAt,
    DateTime? completedAt,
    DateTime? droppedAt,
    String? classCode,
    String? notes,
  }) {
    return Enrollment(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      batchId: batchId ?? this.batchId,
      courseGroupId: courseGroupId ?? this.courseGroupId,
      status: status ?? this.status,
      enrolledAt: enrolledAt ?? this.enrolledAt,
      completedAt: completedAt ?? this.completedAt,
      droppedAt: droppedAt ?? this.droppedAt,
      classCode: classCode ?? this.classCode,
      notes: notes ?? this.notes,
    );
  }

  bool get isActive => status == EnrollmentStatus.active;
  bool get isCompleted => status == EnrollmentStatus.completed;
  bool get isDropped => status == EnrollmentStatus.dropped;
  bool get isPending => status == EnrollmentStatus.pending;
  bool get isDeclined => status == EnrollmentStatus.declined;
}
