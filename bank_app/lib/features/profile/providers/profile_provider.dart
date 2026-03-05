import 'package:bank_app/features/profile/model/profile_model.dart';
import 'package:bank_app/features/profile/service/profile_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileState {
  final ProfileModel? profile;
  final bool loading;
  final String? error;

  ProfileState({this.profile, this.loading = false, this.error});

  ProfileState copyWith({ProfileModel? profile, bool? loading, String? error}) {
    return ProfileState(
      profile: profile ?? this.profile,
      loading: loading ?? this.loading,
      error: error,
    );
  }
}

final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>((
  ref,
) {
  return ProfileNotifier(ref.read(profileServiceProvider));
});

class ProfileNotifier extends StateNotifier<ProfileState> {
  final ProfileService _service;

  ProfileNotifier(this._service) : super(ProfileState());

  Future<void> loadProfile() async {
    state = state.copyWith(loading: true, error: null);
    try {
      final profile = await _service.fetchProfile();
      state = state.copyWith(profile: profile, loading: false);
    } catch (_) {
      state = state.copyWith(
        loading: false,
        error: "Profil bilgileri alınamadı",
      );
    }
  }

  Future<void> saveProfile({
    required String firstName,
    required String lastName,
    String? phone,
  }) async {
    state = state.copyWith(loading: true);
    await _service.updateProfile(
      firstName: firstName,
      lastName: lastName,
      phone: phone,
    );
    await loadProfile();
  }
}
