import 'package:flutter/foundation.dart';
import '../models/course_group.dart';
import '../services/firestore_service.dart';

class CourseGroupProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  
  List<CourseGroup> _courseGroups = [];
  bool _isLoading = false;
  String? _error;

  List<CourseGroup> get courseGroups => _courseGroups;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load course groups for teacher
  Future<void> loadCourseGroups(String teacherId) async {
    _setLoading(true);
    try {
      // First, get the initial data
      final courseGroups = await _firestoreService.getCourseGroups(teacherId).first;
      _courseGroups = courseGroups;
      _clearError();
      notifyListeners();
      
      // Then listen for real-time updates
      _firestoreService.getCourseGroups(teacherId).listen((courseGroups) {
        _courseGroups = courseGroups;
        _clearError();
        notifyListeners();
      });
    } catch (e) {
      _setError('Failed to load course groups: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Create course group
  Future<bool> createCourseGroup(CourseGroup courseGroup) async {
    _setLoading(true);
    try {
      await _firestoreService.createCourseGroup(courseGroup);
      _clearError();
      // The real-time listener will automatically update the list
      return true;
    } catch (e) {
      _setError('Failed to create course group: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update course group
  Future<bool> updateCourseGroup(String id, CourseGroup courseGroup) async {
    _setLoading(true);
    try {
      await _firestoreService.updateCourseGroup(id, courseGroup);
      _clearError();
      return true;
    } catch (e) {
      _setError('Failed to update course group: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete course group
  Future<bool> deleteCourseGroup(String id) async {
    _setLoading(true);
    try {
      await _firestoreService.deleteCourseGroup(id);
      _clearError();
      return true;
    } catch (e) {
      _setError('Failed to delete course group: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Get course group by ID
  Future<CourseGroup?> getCourseGroupById(String id) async {
    try {
      return await _firestoreService.getCourseGroupById(id);
    } catch (e) {
      _setError('Failed to get course group: ${e.toString()}');
      return null;
    }
  }

  // Get course group by index
  CourseGroup? getCourseGroupByIndex(int index) {
    if (index >= 0 && index < _courseGroups.length) {
      return _courseGroups[index];
    }
    return null;
  }

  // Get course group count
  int get courseGroupCount => _courseGroups.length;

  // Get total batch count across all course groups
  int get totalBatchCount {
    return _courseGroups.fold(0, (sum, group) => sum + group.batchCount);
  }

  // Clear error
  void _clearError() {
    _error = null;
  }

  // Set error
  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  // Set loading
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Clear error manually
  void clearError() {
    _clearError();
  }
}
