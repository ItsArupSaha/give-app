import 'package:cloud_firestore/cloud_firestore.dart';

enum CommentType { public, private }

class Comment {
  final String id;
  final String content;
  final String authorId;
  final String authorName;
  final String? authorImageUrl;
  final CommentType type;
  final String? batchId;
  final String? taskId;
  final String? submissionId;
  final String? parentCommentId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isEdited;
  final List<String> attachments;

  Comment({
    required this.id,
    required this.content,
    required this.authorId,
    required this.authorName,
    this.authorImageUrl,
    required this.type,
    this.batchId,
    this.taskId,
    this.submissionId,
    this.parentCommentId,
    required this.createdAt,
    required this.updatedAt,
    this.isEdited = false,
    this.attachments = const [],
  });

  factory Comment.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Comment(
      id: doc.id,
      content: data['content'] ?? '',
      authorId: data['authorId'] ?? '',
      authorName: data['authorName'] ?? '',
      authorImageUrl: data['authorImageUrl'],
      type: CommentType.values.firstWhere(
        (e) => e.toString() == 'CommentType.${data['type']}',
        orElse: () => CommentType.public,
      ),
      batchId: data['batchId'],
      taskId: data['taskId'],
      submissionId: data['submissionId'],
      parentCommentId: data['parentCommentId'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      isEdited: data['isEdited'] ?? false,
      attachments: List<String>.from(data['attachments'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'content': content,
      'authorId': authorId,
      'authorName': authorName,
      'authorImageUrl': authorImageUrl,
      'type': type.toString().split('.').last,
      'batchId': batchId,
      'taskId': taskId,
      'submissionId': submissionId,
      'parentCommentId': parentCommentId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isEdited': isEdited,
      'attachments': attachments,
    };
  }

  Comment copyWith({
    String? id,
    String? content,
    String? authorId,
    String? authorName,
    String? authorImageUrl,
    CommentType? type,
    String? batchId,
    String? taskId,
    String? submissionId,
    String? parentCommentId,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isEdited,
    List<String>? attachments,
  }) {
    return Comment(
      id: id ?? this.id,
      content: content ?? this.content,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorImageUrl: authorImageUrl ?? this.authorImageUrl,
      type: type ?? this.type,
      batchId: batchId ?? this.batchId,
      taskId: taskId ?? this.taskId,
      submissionId: submissionId ?? this.submissionId,
      parentCommentId: parentCommentId ?? this.parentCommentId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isEdited: isEdited ?? this.isEdited,
      attachments: attachments ?? this.attachments,
    );
  }

  bool get isPublic => type == CommentType.public;
  bool get isPrivate => type == CommentType.private;
  bool get isReply => parentCommentId != null;
}
