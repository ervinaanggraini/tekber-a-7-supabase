import 'package:flutter/foundation.dart';
import 'package:flutter_application/core/constants/urls.dart';
import 'package:flutter_application/features/auth/data/mapper/auth_mapper.dart';
import 'package:flutter_application/features/auth/domain/entity/auth_user_entity.dart';
import 'package:flutter_application/features/auth/domain/exception/login_with_email_exception.dart';
import 'package:flutter_application/features/auth/domain/repository/auth_repository.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@Injectable(as: AuthRepository)
class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository(
    this._supabaseAuth,
    this._supabaseClient,
  );

  final GoTrueClient _supabaseAuth;
  final SupabaseClient _supabaseClient;

  @override
  Future<void> loginWithEmail(String email) async {
    try {
      await _supabaseAuth.signInWithOtp(
        email: email,
        emailRedirectTo: kIsWeb ? null : Urls.loginCallbackUrl,
      );
    } on AuthException catch (error) {
      throw LoginWithEmailException(error.message);
    }
  }

  @override
  Future<void> loginWithEmailAndPassword(String email, String password) async {
    try {
      await _supabaseAuth.signInWithPassword(
        email: email,
        password: password,
      );
    } on AuthException catch (error) {
      debugPrint("Login Error: ${error.message}");
      throw LoginWithEmailException(error.message);
    } catch (e) {
      debugPrint("Login Unknown Error: $e");
      throw LoginWithEmailException(e.toString());
    }
  }

  @override
  Future<void> signUpWithEmailAndPassword(String email, String password) async {
    try {
      final response = await _supabaseAuth.signUp(
        email: email,
        password: password,
      );

      // Create user profile after successful signup
      if (response.user != null) {
        await _createUserProfile(response.user!);
      }
    } on AuthException catch (error) {
      debugPrint("SignUp Error: ${error.message}");
      throw LoginWithEmailException(error.message);
    } catch (e) {
      debugPrint("SignUp Unknown Error: $e");
      throw LoginWithEmailException(e.toString());
    }
  }

  Future<void> _createUserProfile(User user) async {
    try {
      await _supabaseClient.from('user_profiles').insert({
        'id': user.id,
        'full_name': user.userMetadata?['full_name'] ?? user.email?.split('@')[0] ?? 'User',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      // Ignore error if profile already exists
      if (!e.toString().contains('duplicate key')) {
        debugPrint("Create User Profile Error: $e");
      }
    }
  }

  @override
  Future<void> logout() async {
    await _supabaseAuth.signOut();
  }

  @override
  Stream<AuthState> getCurrentAuthState() {
    return _supabaseAuth.onAuthStateChange.asyncMap((authState) async {
      try {
        final user = authState.session?.user;
        if (user != null) {
          await _createUserProfile(user);
        }
      } catch (e) {
        debugPrint('Ensure profile on auth state change error: $e');
      }
      return authState;
    });
  }

  @override
  AuthUserEntity? getLoggedInUser() {
    return _supabaseAuth.currentUser?.toUserEntity();
  }
}
