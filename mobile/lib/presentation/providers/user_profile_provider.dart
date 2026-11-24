import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserProfile {
  final String name;
  final String email;
  final String avatarUrl;
  final String? pin;
  final bool isPinEnabled;

  const UserProfile({
    required this.name,
    required this.email,
    this.avatarUrl = '',
    this.pin,
    this.isPinEnabled = false,
  });

  bool get hasPin => pin != null && pin!.isNotEmpty;

  UserProfile copyWith({
    String? name,
    String? email,
    String? avatarUrl,
    String? pin,
    bool? isPinEnabled,
  }) {
    return UserProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      pin: pin ?? this.pin,
      isPinEnabled: isPinEnabled ?? this.isPinEnabled,
    );
  }
}

class UserProfileNotifier extends StateNotifier<UserProfile> {
  UserProfileNotifier()
      : super(const UserProfile(
          name: 'Olivia',
          email: 'demo@kainatledger.com',
        ));

  void updateName(String newName) {
    if (newName.trim().isNotEmpty) {
      state = state.copyWith(name: newName.trim());
    }
  }

  void updateEmail(String newEmail) {
    if (newEmail.trim().isNotEmpty) {
      state = state.copyWith(email: newEmail.trim());
    }
  }

  void setPin(String newPin) {
    state = state.copyWith(pin: newPin, isPinEnabled: true);
  }

  void togglePin(bool enabled) {
    state = state.copyWith(isPinEnabled: enabled);
  }
}

final userProfileProvider =
    StateNotifierProvider<UserProfileNotifier, UserProfile>((ref) {
  return UserProfileNotifier();
});
