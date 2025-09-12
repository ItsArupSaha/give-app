import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart' as app_user;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Get current user stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password
  Future<app_user.User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (result.user != null) {
        return await _getUserFromFirestore(result.user!.uid);
      }
      return null;
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'Wrong credentials. Please try again with correct email and password.';
          break;
        case 'wrong-password':
          errorMessage = 'Wrong credentials. Please try again with correct email and password.';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email format.';
          break;
        case 'user-disabled':
          errorMessage = 'Account disabled. Contact support.';
          break;
        case 'too-many-requests':
          errorMessage = 'Too many attempts. Try again later.';
          break;
        case 'invalid-credential':
          errorMessage = 'Wrong credentials. Please try again with correct email and password.';
          break;
        case 'network-request-failed':
          errorMessage = 'Network error. Check connection.';
          break;
        default:
          errorMessage = 'Sign in failed. Please try again.';
      }
      throw errorMessage;
    } catch (e) {
      throw Exception('Sign in failed: ${e.toString()}');
    }
  }

  // Register new user
  Future<app_user.User?> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    String? whatsappNumber,
    required app_user.UserRole role,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (result.user != null) {
        // Create user document in Firestore
        app_user.User newUser = app_user.User(
          id: result.user!.uid,
          email: email,
          name: name,
          whatsappNumber: whatsappNumber,
          role: role,
          createdAt: DateTime.now(),
        );
        
        await _firestore
            .collection('users')
            .doc(result.user!.uid)
            .set(newUser.toFirestore());
        
        return newUser;
      }
      return null;
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'weak-password':
          errorMessage = 'Password too weak. Choose a stronger one.';
          break;
        case 'email-already-in-use':
          errorMessage = 'Email already registered.';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email format.';
          break;
        case 'operation-not-allowed':
          errorMessage = 'Registration disabled. Contact support.';
          break;
        case 'network-request-failed':
          errorMessage = 'Network error. Check connection.';
          break;
        default:
          errorMessage = 'Registration failed. Please try again.';
      }
      throw errorMessage;
    } catch (e) {
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Sign out failed: ${e.toString()}');
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'Email not found.';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email format.';
          break;
        case 'too-many-requests':
          errorMessage = 'Too many requests. Try again later.';
          break;
        case 'network-request-failed':
          errorMessage = 'Network error. Check connection.';
          break;
        default:
          errorMessage = 'Password reset failed. Please try again.';
      }
      throw errorMessage;
    } catch (e) {
      throw Exception('Password reset failed: ${e.toString()}');
    }
  }

  // Get user from Firestore
  Future<app_user.User?> _getUserFromFirestore(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return app_user.User.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user data: ${e.toString()}');
    }
  }

  // Get user by ID
  Future<app_user.User?> getUserById(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return app_user.User.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user: ${e.toString()}');
    }
  }

  // Update user profile
  Future<void> updateUserProfile(app_user.User user) async {
    try {
      await _firestore
          .collection('users')
          .doc(user.id)
          .update(user.toFirestore());
    } catch (e) {
      throw Exception('Failed to update profile: ${e.toString()}');
    }
  }

  // Update last login time
  Future<void> updateLastLogin(String uid) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .update({'lastLoginAt': Timestamp.fromDate(DateTime.now())});
    } catch (e) {
      // Don't throw error for this as it's not critical
      print('Failed to update last login: ${e.toString()}');
    }
  }

  // Check if user is teacher
  Future<bool> isTeacher(String uid) async {
    try {
      app_user.User? user = await getUserById(uid);
      return user?.isTeacher ?? false;
    } catch (e) {
      return false;
    }
  }

  // Check if user is student
  Future<bool> isStudent(String uid) async {
    try {
      app_user.User? user = await getUserById(uid);
      return user?.isStudent ?? false;
    } catch (e) {
      return false;
    }
  }

}
