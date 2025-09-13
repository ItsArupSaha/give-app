import 'package:flutter/foundation.dart';
import '../models/batch.dart';
import '../services/firestore_service.dart';

class BatchProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  
  List<Batch> _batches = [];
  bool _isLoading = false;
  String? _error;

  List<Batch> get batches => _batches;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load batches for a course group
  Future<void> loadBatchesByCourseGroup(String courseGroupId) async {
    _setLoading(true);
    try {
      _firestoreService.getBatchesByCourseGroup(courseGroupId).listen((batches) {
        _batches = batches;
        _clearError();
        notifyListeners();
      });
    } catch (e) {
      _setError('Failed to load batches: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Create batch
  Future<bool> createBatch(Batch batch) async {
    _setLoading(true);
    try {
      await _firestoreService.createBatch(batch);
      _clearError();
      // The real-time listener will automatically update the list
      return true;
    } catch (e) {
      _setError('Failed to create batch: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update batch
  Future<bool> updateBatch(String id, Batch batch) async {
    _setLoading(true);
    try {
      await _firestoreService.updateBatch(id, batch);
      _clearError();
      return true;
    } catch (e) {
      _setError('Failed to update batch: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete batch
  Future<bool> deleteBatch(String id, String courseGroupId) async {
    _setLoading(true);
    try {
      await _firestoreService.deleteBatch(id, courseGroupId);
      _clearError();
      return true;
    } catch (e) {
      _setError('Failed to delete batch: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Get batch by class code
  Future<Batch?> getBatchByClassCode(String classCode) async {
    try {
      return await _firestoreService.getBatchByClassCode(classCode);
    } catch (e) {
      _setError('Failed to get batch: ${e.toString()}');
      return null;
    }
  }

  // Get batch by index
  Batch? getBatchByIndex(int index) {
    if (index >= 0 && index < _batches.length) {
      return _batches[index];
    }
    return null;
  }

  // Get batch count
  int get batchCount => _batches.length;

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
