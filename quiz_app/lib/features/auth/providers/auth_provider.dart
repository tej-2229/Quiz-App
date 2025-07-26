import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:quiz_app/features/auth/data/models/user_model.dart';
import 'package:quiz_app/features/auth/data/repositories/auth_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'auth_provider.freezed.dart';
part 'auth_state.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(FirebaseAuth.instance, FirebaseFirestore.instance);
});

final userDataProvider = StreamProvider.autoDispose.family<AppUser?, String>((ref, userId) {
  return ref.watch(authRepositoryProvider).user;
});


final authStateProvider = StreamProvider<AppUser?>((ref) {
  return ref.read(authRepositoryProvider).user;
});

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<AuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  late final SharedPreferences _prefs;

  AuthNotifier() : super(const AuthState.initial()) {
    SharedPreferences.getInstance().then((prefs) {
      _prefs = prefs;
      _checkPersistedAuth();
    });
  }

  Future<void> _checkPersistedAuth() async {
    try {
      final email = await _secureStorage.read(key: 'email');
      final password = await _secureStorage.read(key: 'password');
      
      if (email != null && password != null) {
        await signInWithEmailAndPassword(email: email, password: password);
      } else {
        state = const AuthState.unauthenticated();
      }
    } catch (e) {
      state = const AuthState.unauthenticated();
    }
  }

  Future<void> _persistAuth(String email, String password) async {
    await _secureStorage.write(key: 'email', value: email);
    await _secureStorage.write(key: 'password', value: password);
    await _prefs.setBool('isLoggedIn', true);
  }

  Future<void> _clearPersistedAuth() async {
    await _secureStorage.delete(key: 'email');
    await _secureStorage.delete(key: 'password');
    await _prefs.setBool('isLoggedIn', false);
  }

  Future<bool> isFirstTimeUser(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    return !doc.exists;
  }

  Future<void> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      state = const AuthState.loading();
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      await credential.user?.updateDisplayName(fullName);
      
      await _firestore.collection('users').doc(credential.user?.uid).set({
        'uid': credential.user?.uid,
        'email': email,
        'fullName': fullName,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      state = const AuthState.unauthenticated();
    } on FirebaseAuthException catch (e) {
      state = AuthState.error(e.message ?? 'Sign up failed');
      rethrow;
    } catch (e) {
      state = AuthState.error('An unexpected error occurred');
      rethrow;
    }
  }

  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    try {
      state = const AuthState.loading();
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (rememberMe) {
        await _persistAuth(email, password);
      }

      if (credential.user != null) {
        state = AuthState.authenticated(credential.user!);
      } else {
        state = const AuthState.unauthenticated();
      }
    } on FirebaseAuthException catch (e) {
      state = AuthState.error(e.message ?? 'Sign in failed');
      rethrow;
    } catch (e) {
      state = AuthState.error('An unexpected error occurred');
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await _clearPersistedAuth();
      state = const AuthState.unauthenticated();
    } catch (e) {
      state = AuthState.error('Error signing out');
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      state = const AuthState.loading();
      await _auth.sendPasswordResetEmail(email: email);
      state = const AuthState.unauthenticated();
    } on FirebaseAuthException catch (e) {
      state = AuthState.error(e.message ?? 'Password reset failed');
    } catch (e) {
      state = AuthState.error('An unexpected error occurred');
    }
  }
}