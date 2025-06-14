import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _firebaseUser;
  UserModel? _user;
  bool _isLoading = false;
  String _error = '';

  User? get firebaseUser => _firebaseUser;
  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _firebaseUser != null;
  String get error => _error;

  AuthProvider() {
    _auth.authStateChanges().listen((User? user) {
      _firebaseUser = user;
      if (user != null) {
        _fetchUserData();
      } else {
        _user = null;
      }
      notifyListeners();
    });
  }

  Future<void> _fetchUserData() async {
    if (_firebaseUser == null) return;

    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final doc = await _firestore
          .collection('users')
          .doc(_firebaseUser!.uid)
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        _user = UserModel.fromJson({'id': _firebaseUser!.uid, ...data});
      } else {
        // Create a new user document if it doesn't exist
        await _firestore.collection('users').doc(_firebaseUser!.uid).set({
          'name': _firebaseUser!.displayName ?? '',
          'email': _firebaseUser!.email ?? '',
          'address': '',
        });

        _user = UserModel(
          id: _firebaseUser!.uid,
          name: _firebaseUser!.displayName ?? '',
          email: _firebaseUser!.email ?? '',
          address: '',
        );
      }
    } catch (e) {
      _error = 'Error fetching user data: $e';
      debugPrint(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Sign in with email and password
  Future<bool> signInWithEmail(String email, String password) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        return true;
      }

      _error = 'Failed to sign in';
      return false;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          _error = 'No user found with this email';
          break;
        case 'wrong-password':
          _error = 'Wrong password provided';
          break;
        case 'invalid-email':
          _error = 'The email address is not valid';
          break;
        case 'user-disabled':
          _error = 'This user account has been disabled';
          break;
        default:
          _error = 'Authentication failed: ${e.message}';
      }
      return false;
    } catch (e) {
      _error = 'Error signing in: $e';
      debugPrint(_error);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Sign up with email and password
  Future<bool> signUpWithEmail(
    String name,
    String email,
    String password,
  ) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      // Create the user in Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        // Update the user's display name
        await userCredential.user!.updateDisplayName(name);

        // Create a new user document in Firestore
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'name': name,
          'email': email,
          'address': '',
        });

        return true;
      }

      _error = 'Failed to create account';
      return false;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          _error = 'The email address is already in use';
          break;
        case 'invalid-email':
          _error = 'The email address is not valid';
          break;
        case 'operation-not-allowed':
          _error = 'Email/password accounts are not enabled';
          break;
        case 'weak-password':
          _error = 'The password is too weak';
          break;
        default:
          _error = 'Registration failed: ${e.message}';
      }
      return false;
    } catch (e) {
      _error = 'Error creating account: $e';
      debugPrint(_error);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      // Handle sign-in based on platform
      UserCredential? userCredential;

      if (kIsWeb) {
        // Web platform
        GoogleAuthProvider googleProvider = GoogleAuthProvider();
        try {
          userCredential = await _auth.signInWithPopup(googleProvider);
        } catch (e) {
          debugPrint('Error with popup sign-in: $e');
          // Fallback to redirect for web
          await _auth.signInWithRedirect(googleProvider);
          // Note: Redirect will navigate away from the page,
          // so we'll handle the result when the page loads again
          return false;
        }
      } else {
        // Mobile platform
        // Start the Google sign-in process
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

        if (googleUser == null) {
          _error = 'Google sign-in was cancelled';
          _isLoading = false;
          notifyListeners();
          return false;
        }

        // Obtain auth details from the Google sign-in
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        // Create a new credential for Firebase
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        // Sign in to Firebase with the Google credential
        userCredential = await _auth.signInWithCredential(credential);
      }

      if (userCredential.user != null) {
        final user = userCredential.user!;

        // Check if user exists in Firestore
        final userDoc = await _firestore
            .collection('users')
            .doc(user.uid)
            .get();

        if (!userDoc.exists) {
          // Create a new user document
          await _firestore.collection('users').doc(user.uid).set({
            'name': user.displayName ?? '',
            'email': user.email ?? '',
            'address': '',
          });
        }

        return true;
      }

      _error = 'Failed to sign in with Google';
      return false;
    } catch (e) {
      _error = 'Error signing in with Google: $e';
      debugPrint(_error);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      if (!kIsWeb) {
        await _googleSignIn.signOut();
      }
      await _auth.signOut();
    } catch (e) {
      _error = 'Error signing out: $e';
      debugPrint(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateUserAddress(String address) async {
    if (_firebaseUser == null) return false;

    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      await _firestore.collection('users').doc(_firebaseUser!.uid).update({
        'address': address,
      });

      _user = _user!.copyWith(address: address);
      return true;
    } catch (e) {
      _error = 'Error updating user address: $e';
      debugPrint(_error);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
