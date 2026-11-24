import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/localization/app_strings.dart';
export '../../core/localization/app_strings.dart';

class LocaleNotifier extends StateNotifier<AppLanguage> {
  LocaleNotifier() : super(AppLanguage.id);

  void setLanguage(AppLanguage language) {
    state = language;
  }

  void toggleLanguage() {
    state = state == AppLanguage.id ? AppLanguage.en : AppLanguage.id;
  }
}

final localeProvider = StateNotifierProvider<LocaleNotifier, AppLanguage>((ref) {
  return LocaleNotifier();
});

final appStringsProvider = Provider<AppStrings>((ref) {
  final lang = ref.watch(localeProvider);
  return AppStrings(lang);
});
