import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;
  String? _error;
  String? _userRole;
  User? _currentUser;

  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get userRole => _userRole;
  User? get currentUser => _currentUser;

  AuthProvider() {
    _auth.authStateChanges().listen((User? user) {
      _currentUser = user;
      if (user != null) {
        _loadUserRole(user.uid);
      } else {
        _userRole = null;
      }
      notifyListeners();
    });
  }

  // Register with email and password
  Future<void> register({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
    required String role,
  }) async {
    try {
      setLoading(true);
      clearError();

      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _saveUserData(
        userCredential.user!,
        fullName,
        email,
        phoneNumber,
        role,
      );

      setLoading(false);
    } on FirebaseAuthException catch (e) {
      setLoading(false);
      if (e.code == 'email-already-in-use') {
        setError('This email is already registered. Please login instead.');
      } else if (e.code == 'weak-password') {
        setError('Password is too weak. Please choose a stronger password.');
      } else {
        setError('Registration failed: ${e.message}');
      }
    } catch (e) {
      setLoading(false);
      setError('Registration failed: Please check your connection.');
    }
  }

  // Login with email and password
  Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      setLoading(true);
      clearError();

      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _loadUserRole(userCredential.user!.uid);
      setLoading(false);
    } on FirebaseAuthException catch (e) {
      setLoading(false);
      if (e.code == 'user-not-found') {
        setError('No account found with this email. Please register.');
      } else if (e.code == 'wrong-password') {
        setError('Incorrect password. Please try again.');
      } else {
        setError('Login failed: ${e.message}');
      }
    } catch (e) {
      setLoading(false);
      setError('Login failed: Please check your connection.');
    }
  }

  // Google Sign-In
  Future<void> signInWithGoogle({required String role}) async {
    try {
      setLoading(true);
      clearError();

      final GoogleAuthProvider googleProvider = GoogleAuthProvider();
      
      final userCredential = await _auth.signInWithPopup(googleProvider);
      
      if (userCredential.additionalUserInfo?.isNewUser ?? false) {
        await _saveUserData(
          userCredential.user!,
          userCredential.user!.displayName ?? 'User',
          userCredential.user!.email ?? '',
          '',
          role,
        );
      } else {
        await _loadUserRole(userCredential.user!.uid);
      }

      setLoading(false);
    } on FirebaseAuthException catch (e) {
      setLoading(false);
      if (e.code == 'auth/popup-closed-by-user') {
        setError('Sign-in was cancelled');
      } else {
        setError('Google sign-in failed: ${e.message}');
      }
    } catch (e) {
      setLoading(false);
      setError('Google sign-in failed: Please try again.');
    }
  }

  // Save user data to Firestore
  Future<void> _saveUserData(
    User user,
    String fullName,
    String email,
    String phoneNumber,
    String role,
  ) async {
    final userData = <String, dynamic>{
      'uid': user.uid,
      'fullName': fullName,
      'email': email,
      'phone': phoneNumber,
      'userType': role,
      'medicalConditions': <String>[],
      'emergencyContacts': <String>[],
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    await _firestore.collection('users').doc(user.uid).set(userData);
    _userRole = role;
    notifyListeners();
  }

  // Load user role from Firestore
  Future<void> _loadUserRole(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data();
        if (data != null) {
          _userRole = data['userType'] as String?;
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Error loading user role: $e');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      _userRole = null;
      _currentUser = null;
      notifyListeners();
    } catch (e) {
      debugPrint('Error signing out: $e');
    }
  }

  // Utility methods - MAKE SURE THESE ARE PUBLIC (no underscore)
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String error) {
    _error = error;
    notifyListeners();
  }

  void clearError() {  // THIS MUST BE PUBLIC
    _error = null;
    notifyListeners();
  }

  bool get isAuthenticated => _auth.currentUser != null;
  String? get userId => _auth.currentUser?.uid;
}