import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/storage/secure_storage.dart';
import '../../core/network/dio_client.dart';

enum AuthStatus { unknown, signedOut, signedIn }

class UserProfile {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final DateTime? signedInAt;

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.signedInAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'User',
      email: json['email'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String?,
      signedInAt: json['signed_in_at'] != null 
          ? DateTime.tryParse(json['signed_in_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'avatar_url': avatarUrl,
    'signed_in_at': signedInAt?.toIso8601String(),
  };

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarUrl,
    DateTime? signedInAt,
  }) => UserProfile(
    id: id ?? this.id,
    name: name ?? this.name,
    email: email ?? this.email,
    avatarUrl: avatarUrl ?? this.avatarUrl,
    signedInAt: signedInAt ?? this.signedInAt,
  );
}

class AuthState {
  final AuthStatus status;
  final UserProfile? user;
  final String? error;

  const AuthState({
    this.status = AuthStatus.unknown,
    this.user,
    this.error,
  });

  bool get isSignedIn => status == AuthStatus.signedIn && user != null;

  AuthState copyWith({
    AuthStatus? status,
    UserProfile? user,
    String? error,
  }) => AuthState(
    status: status ?? this.status,
    user: user ?? this.user,
    error: error,
  );
}

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    _loadAuthState();
    return const AuthState();
  }

  Future<void> _loadAuthState() async {
    final userJson = await SecureStorageService.instance.getUserProfile();
    if (userJson != null) {
      final user = UserProfile.fromJson(userJson);
      state = AuthState(status: AuthStatus.signedIn, user: user);
    } else {
      state = const AuthState(status: AuthStatus.signedOut);
    }
  }

  Future<void> signInWithGoogle() async {
    state = state.copyWith(error: null);
    try {
      await Future.delayed(const Duration(seconds: 1));
      
      const demoToken = 'demo_token_123456789';
      final demoUser = UserProfile(
        id: 'google-${DateTime.now().millisecondsSinceEpoch}',
        name: 'Demo User',
        email: 'demo@nestshift.com',
        signedInAt: DateTime.now(),
      );
      
      await SecureStorageService.instance.saveUserProfile(demoUser.toJson());
      await SecureStorageService.instance.saveToken(demoToken);
      await BrainDioClient.instance.updateToken();
      state = AuthState(status: AuthStatus.signedIn, user: demoUser);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> updateProfile({String? name, String? email}) async {
    if (state.user == null) return;
    final updated = state.user!.copyWith(
      name: name ?? state.user!.name,
      email: email ?? state.user!.email,
    );
    await SecureStorageService.instance.saveUserProfile(updated.toJson());
    state = AuthState(status: AuthStatus.signedIn, user: updated);
  }

  Future<void> signOut() async {
    await SecureStorageService.instance.clearUserProfile();
    await SecureStorageService.instance.clearAll();
    state = const AuthState(status: AuthStatus.signedOut);
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(() => AuthNotifier());