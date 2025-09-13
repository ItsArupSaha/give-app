import 'package:flutter/foundation.dart';
import '../services/firestore_service.dart';

class StatsProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  
  int _enrolledStudentsCount = 0;
  int _totalBatchesCount = 0;
  bool _isLoading = false;
  String? _error;

  int get enrolledStudentsCount => _enrolledStudentsCount;
  int get totalBatchesCount => _totalBatchesCount;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load stats for a teacher
  Future<void> loadStatsForTeacher(String teacherId) async {
    _setLoading(true);
    try {
      // Load enrolled students count
      _enrolledStudentsCount = await _firestoreService.getEnrolledStudentsCountForTeacher(teacherId);
      
      // Load total batches count
      _totalBatchesCount = await _firestoreService.getBatchesCountForTeacher(teacherId);
      
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load stats: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Refresh stats
  Future<void> refreshStats(String teacherId) async {
    await loadStatsForTeacher(teacherId);
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  void clear() {
    _enrolledStudentsCount = 0;
    _totalBatchesCount = 0;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}
