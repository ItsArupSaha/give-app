import 'package:cloud_firestore/cloud_firestore.dart';

class CourseGroup {
  final String id;
  final String name;
  final String description;
  final String? imageUrl;
  final String teacherId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final int batchCount;

  CourseGroup({
    required this.id,
    required this.name,
    required this.description,
    this.imageUrl,
    required this.teacherId,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
    this.batchCount = 0,
  });

  factory CourseGroup.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return CourseGroup(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'],
      teacherId: data['teacherId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      isActive: data['isActive'] ?? true,
      batchCount: data['batchCount'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'teacherId': teacherId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isActive': isActive,
      'batchCount': batchCount,
    };
  }

  CourseGroup copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    String? teacherId,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    int? batchCount,
  }) {
    return CourseGroup(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      teacherId: teacherId ?? this.teacherId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      batchCount: batchCount ?? this.batchCount,
    );
  }
}
