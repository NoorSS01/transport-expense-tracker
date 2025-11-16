import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_profile.dart';
import '../services/database_service.dart';

class AuthProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  final DatabaseService _databaseService = DatabaseService();
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? _user;
  UserProfile? _userProfile;
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  UserProfile? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _initializeAuth();
  }

  void _initializeAuth() {
    _user = _supabase.auth.currentUser;
    if (_user != null) {
      _loadUserProfile();
    }
    
    _supabase.auth.onAuthStateChange.listen((data) {
      _user = data.session?.user;
      if (_user != null) {
        _loadUserProfile();
      } else {
        _userProfile = null;
      }
      notifyListeners();
    });
  }

  Future<void> _loadUserProfile() async {
    if (_user == null) return;
    
    try {
      _userProfile = await _databaseService.getUserProfile(_user!.id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading user profile: $e');
    }
  }

  Future<bool> signInWithEmail(String email, String password) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        _user = response.user;
        await _loadUserProfile();
        return true;
      }
      return false;
    } on AuthException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('An unexpected error occurred');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signUpWithEmail(String email, String password, String fullName) async {
    try {
      _setLoading(true);
      _clearError();

      debugPrint('Starting signup for email: $email');
      
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName},
      );

      debugPrint('Signup response: ${response.user?.id}');

      if (response.user != null) {
        // Create user profile
        debugPrint('Creating user profile...');
        await _databaseService.createUserProfile(
          response.user!.id,
          email,
          fullName,
        );
        
        _user = response.user;
        await _loadUserProfile();
        debugPrint('Signup successful');
        return true;
      }
      _setError('Signup failed: No user returned');
      return false;
    } on AuthException catch (e) {
      debugPrint('Auth error during signup: ${e.message}');
      _setError(e.message);
      return false;
    } catch (e) {
      debugPrint('Unexpected error during signup: $e');
      _setError('Signup failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signInWithGoogle() async {
    try {
      _setLoading(true);
      _clearError();

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return false; // User cancelled
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: googleAuth.idToken!,
        accessToken: googleAuth.accessToken,
      );

      if (response.user != null) {
        _user = response.user;
        
        // Check if user profile exists, create if not
        try {
          await _loadUserProfile();
        } catch (e) {
          // Profile doesn't exist, create it
          await _databaseService.createUserProfile(
            response.user!.id,
            response.user!.email!,
            response.user!.userMetadata?['full_name'] ?? googleUser.displayName,
          );
          await _loadUserProfile();
        }
        
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Google sign-in error: $e');
      _setError('Google sign-in failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    try {
      _setLoading(true);
      await _supabase.auth.signOut();
      await _googleSignIn.signOut();
      _user = null;
      _userProfile = null;
    } catch (e) {
      _setError('Sign out failed');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> resetPassword(String email) async {
    try {
      _setLoading(true);
      _clearError();

      await _supabase.auth.resetPasswordForEmail(email);
      return true;
    } on AuthException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('Password reset failed');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }
}
