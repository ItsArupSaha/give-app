import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { teacher, student }

class User {
  final String id;
  final String email;
  final String name;
  final String? profileImageUrl;
  final String? whatsappNumber;
  final UserRole role;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final bool isActive;

  User({
    required this.id,
    required this.email,
    required this.name,
    this.profileImageUrl,
    this.whatsappNumber,
    required this.role,
    required this.createdAt,
    this.lastLoginAt,
    this.isActive = true,
  });

  factory User.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return User(
      id: doc.id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      profileImageUrl: data['profileImageUrl'],
      whatsappNumber: data['whatsappNumber'],
      role: UserRole.values.firstWhere(
        (e) => e.toString() == 'UserRole.${data['role']}',
        orElse: () => UserRole.student,
      ),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastLoginAt: data['lastLoginAt'] != null
          ? (data['lastLoginAt'] as Timestamp).toDate()
          : null,
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'name': name,
      'profileImageUrl': profileImageUrl,
      'whatsappNumber': whatsappNumber,
      'role': role.toString().split('.').last,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLoginAt': lastLoginAt != null ? Timestamp.fromDate(lastLoginAt!) : null,
      'isActive': isActive,
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? name,
    String? profileImageUrl,
    String? whatsappNumber,
    UserRole? role,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    bool? isActive,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      whatsappNumber: whatsappNumber ?? this.whatsappNumber,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isActive: isActive ?? this.isActive,
    );
  }

  bool get isTeacher => role == UserRole.teacher;
  bool get isStudent => role == UserRole.student;
}
