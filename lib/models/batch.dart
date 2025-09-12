import 'package:cloud_firestore/cloud_firestore.dart';

class Batch {
  final String id;
  final String name;
  final String description;
  final String courseGroupId;
  final String teacherId;
  final String classCode;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final int studentCount;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? schedule;
  final String? location;

  Batch({
    required this.id,
    required this.name,
    required this.description,
    required this.courseGroupId,
    required this.teacherId,
    required this.classCode,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
    this.studentCount = 0,
    this.startDate,
    this.endDate,
    this.schedule,
    this.location,
  });

  factory Batch.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Batch(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      courseGroupId: data['courseGroupId'] ?? '',
      teacherId: data['teacherId'] ?? '',
      classCode: data['classCode'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      isActive: data['isActive'] ?? true,
      studentCount: data['studentCount'] ?? 0,
      startDate: data['startDate'] != null
          ? (data['startDate'] as Timestamp).toDate()
          : null,
      endDate: data['endDate'] != null
          ? (data['endDate'] as Timestamp).toDate()
          : null,
      schedule: data['schedule'],
      location: data['location'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'courseGroupId': courseGroupId,
      'teacherId': teacherId,
      'classCode': classCode,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isActive': isActive,
      'studentCount': studentCount,
      'startDate': startDate != null ? Timestamp.fromDate(startDate!) : null,
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'schedule': schedule,
      'location': location,
    };
  }

  Batch copyWith({
    String? id,
    String? name,
    String? description,
    String? courseGroupId,
    String? teacherId,
    String? classCode,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    int? studentCount,
    DateTime? startDate,
    DateTime? endDate,
    String? schedule,
    String? location,
  }) {
    return Batch(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      courseGroupId: courseGroupId ?? this.courseGroupId,
      teacherId: teacherId ?? this.teacherId,
      classCode: classCode ?? this.classCode,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      studentCount: studentCount ?? this.studentCount,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      schedule: schedule ?? this.schedule,
      location: location ?? this.location,
    );
  }
}
