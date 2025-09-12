import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/course_group.dart';
import '../models/batch.dart';
import '../models/task.dart';
import '../models/submission.dart';
import '../models/comment.dart';
import '../models/enrollment.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Course Group Operations
  Future<String> createCourseGroup(CourseGroup courseGroup) async {
    try {
      DocumentReference docRef = await _firestore
          .collection('courseGroups')
          .add(courseGroup.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create course group: ${e.toString()}');
    }
  }

  Future<void> updateCourseGroup(String id, CourseGroup courseGroup) async {
    try {
      await _firestore
          .collection('courseGroups')
          .doc(id)
          .update(courseGroup.toFirestore());
    } catch (e) {
      throw Exception('Failed to update course group: ${e.toString()}');
    }
  }

  Future<void> deleteCourseGroup(String id) async {
    try {
      await _firestore.collection('courseGroups').doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete course group: ${e.toString()}');
    }
  }

  Stream<List<CourseGroup>> getCourseGroups(String teacherId) {
    return _firestore
        .collection('courseGroups')
        .where('teacherId', isEqualTo: teacherId)
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CourseGroup.fromFirestore(doc))
            .toList());
  }

  Future<CourseGroup?> getCourseGroupById(String id) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('courseGroups')
          .doc(id)
          .get();
      if (doc.exists) {
        return CourseGroup.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get course group: ${e.toString()}');
    }
  }

  // Batch Operations
  Future<String> createBatch(Batch batch) async {
    try {
      DocumentReference docRef = await _firestore
          .collection('batches')
          .add(batch.toFirestore());
      
      // Update course group batch count
      await _firestore
          .collection('courseGroups')
          .doc(batch.courseGroupId)
          .update({
        'batchCount': FieldValue.increment(1),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
      
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create batch: ${e.toString()}');
    }
  }

  Future<void> updateBatch(String id, Batch batch) async {
    try {
      await _firestore
          .collection('batches')
          .doc(id)
          .update(batch.toFirestore());
    } catch (e) {
      throw Exception('Failed to update batch: ${e.toString()}');
    }
  }

  Future<void> deleteBatch(String id, String courseGroupId) async {
    try {
      await _firestore.collection('batches').doc(id).delete();
      
      // Update course group batch count
      await _firestore
          .collection('courseGroups')
          .doc(courseGroupId)
          .update({
        'batchCount': FieldValue.increment(-1),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('Failed to delete batch: ${e.toString()}');
    }
  }

  Stream<List<Batch>> getBatchesByCourseGroup(String courseGroupId) {
    return _firestore
        .collection('batches')
        .where('courseGroupId', isEqualTo: courseGroupId)
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Batch.fromFirestore(doc))
            .toList());
  }

  Future<Batch?> getBatchByClassCode(String classCode) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('batches')
          .where('classCode', isEqualTo: classCode)
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();
      
      if (snapshot.docs.isNotEmpty) {
        return Batch.fromFirestore(snapshot.docs.first);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get batch by class code: ${e.toString()}');
    }
  }

  // Task Operations
  Future<String> createTask(Task task) async {
    try {
      DocumentReference docRef = await _firestore
          .collection('tasks')
          .add(task.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create task: ${e.toString()}');
    }
  }

  Future<void> updateTask(String id, Task task) async {
    try {
      await _firestore
          .collection('tasks')
          .doc(id)
          .update(task.toFirestore());
    } catch (e) {
      throw Exception('Failed to update task: ${e.toString()}');
    }
  }

  Future<void> deleteTask(String id) async {
    try {
      await _firestore.collection('tasks').doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete task: ${e.toString()}');
    }
  }

  Stream<List<Task>> getTasksByBatch(String batchId) {
    return _firestore
        .collection('tasks')
        .where('batchId', isEqualTo: batchId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Task.fromFirestore(doc))
            .toList());
  }

  Future<Task?> getTaskById(String id) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('tasks')
          .doc(id)
          .get();
      if (doc.exists) {
        return Task.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get task: ${e.toString()}');
    }
  }

  // Submission Operations
  Future<String> createSubmission(Submission submission) async {
    try {
      DocumentReference docRef = await _firestore
          .collection('submissions')
          .add(submission.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create submission: ${e.toString()}');
    }
  }

  Future<void> updateSubmission(String id, Submission submission) async {
    try {
      await _firestore
          .collection('submissions')
          .doc(id)
          .update(submission.toFirestore());
    } catch (e) {
      throw Exception('Failed to update submission: ${e.toString()}');
    }
  }

  Future<Submission?> getSubmissionByTaskAndStudent(String taskId, String studentId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('submissions')
          .where('taskId', isEqualTo: taskId)
          .where('studentId', isEqualTo: studentId)
          .limit(1)
          .get();
      
      if (snapshot.docs.isNotEmpty) {
        return Submission.fromFirestore(snapshot.docs.first);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get submission: ${e.toString()}');
    }
  }

  Stream<List<Submission>> getSubmissionsByTask(String taskId) {
    return _firestore
        .collection('submissions')
        .where('taskId', isEqualTo: taskId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Submission.fromFirestore(doc))
            .toList());
  }

  // Enrollment Operations
  Future<String> createEnrollment(Enrollment enrollment) async {
    try {
      DocumentReference docRef = await _firestore
          .collection('enrollments')
          .add(enrollment.toFirestore());
      
      // Update batch student count
      await _firestore
          .collection('batches')
          .doc(enrollment.batchId)
          .update({
        'studentCount': FieldValue.increment(1),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
      
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create enrollment: ${e.toString()}');
    }
  }

  Future<void> updateEnrollment(String id, Enrollment enrollment) async {
    try {
      await _firestore
          .collection('enrollments')
          .doc(id)
          .update(enrollment.toFirestore());
    } catch (e) {
      throw Exception('Failed to update enrollment: ${e.toString()}');
    }
  }

  Stream<List<Enrollment>> getEnrollmentsByStudent(String studentId) {
    return _firestore
        .collection('enrollments')
        .where('studentId', isEqualTo: studentId)
        .where('status', isEqualTo: 'active')
        .orderBy('enrolledAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Enrollment.fromFirestore(doc))
            .toList());
  }

  Stream<List<Enrollment>> getEnrollmentsByBatch(String batchId) {
    return _firestore
        .collection('enrollments')
        .where('batchId', isEqualTo: batchId)
        .where('status', isEqualTo: 'active')
        .orderBy('enrolledAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Enrollment.fromFirestore(doc))
            .toList());
  }

  // Comment Operations
  Future<String> createComment(Comment comment) async {
    try {
      DocumentReference docRef = await _firestore
          .collection('comments')
          .add(comment.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create comment: ${e.toString()}');
    }
  }

  Future<void> updateComment(String id, Comment comment) async {
    try {
      await _firestore
          .collection('comments')
          .doc(id)
          .update(comment.toFirestore());
    } catch (e) {
      throw Exception('Failed to update comment: ${e.toString()}');
    }
  }

  Future<void> deleteComment(String id) async {
    try {
      await _firestore.collection('comments').doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete comment: ${e.toString()}');
    }
  }

  Stream<List<Comment>> getCommentsByBatch(String batchId) {
    return _firestore
        .collection('comments')
        .where('batchId', isEqualTo: batchId)
        .where('type', isEqualTo: 'public')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Comment.fromFirestore(doc))
            .toList());
  }

  Stream<List<Comment>> getCommentsByTask(String taskId) {
    return _firestore
        .collection('comments')
        .where('taskId', isEqualTo: taskId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Comment.fromFirestore(doc))
            .toList());
  }
}
