import 'package:flutter/material.dart';
import 'package:guardian_plus_app/core/service_locator.dart';
import 'package:guardian_plus_app/core/session/care_context_store.dart';
import 'package:guardian_plus_app/features/auth/presentation/logout_dialog.dart';
import 'package:guardian_plus_app/features/health_monitoring/presentation/wearable/wearable_details_page.dart';
import 'package:guardian_plus_app/features/health_monitoring/presentation/wearable/wearable_details_view_model.dart';
import 'package:guardian_plus_app/features/profile/domain/profile_repository.dart';
import 'package:guardian_plus_app/features/profile/presentation/about/about_page.dart';
import 'package:guardian_plus_app/features/profile/presentation/accessibility/accessibility_page.dart';
import 'package:guardian_plus_app/features/profile/presentation/accessibility/accessibility_view_model.dart';
import 'package:guardian_plus_app/features/profile/presentation/care_circle/care_circle_page.dart';
import 'package:guardian_plus_app/features/profile/presentation/care_circle/care_circle_view_model.dart';
import 'package:guardian_plus_app/features/profile/presentation/care_recipient/care_recipient_page.dart';
import 'package:guardian_plus_app/features/profile/presentation/care_recipient/care_recipient_view_model.dart';
import 'package:guardian_plus_app/features/profile/presentation/home/profile_home_page.dart';
import 'package:guardian_plus_app/features/profile/presentation/language/language_page.dart';
import 'package:guardian_plus_app/features/profile/presentation/language/language_view_model.dart';
import 'package:guardian_plus_app/features/profile/presentation/personal_data/personal_data_page.dart';
import 'package:guardian_plus_app/features/profile/presentation/personal_data/personal_data_view_model.dart';
import 'package:guardian_plus_app/features/profile/presentation/settings/settings_page.dart';
import 'package:guardian_plus_app/features/profile/presentation/terms/terms_page.dart';
import 'package:guardian_plus_app/features/profile/presentation/settings/settings_view_model.dart';

Future<void> openProfile(
  BuildContext context, {
  required VoidCallback onLogout,
}) {
  // Never open account screens before sign-in has supplied their identifiers.
  getIt<CareContextStore>().require();
  return Navigator.push<void>(
    context,
    MaterialPageRoute<void>(builder: (_) => _ProfileEntry(onLogout: onLogout)),
  );
}

class _ProfileEntry extends StatefulWidget {
  final VoidCallback onLogout;

  const _ProfileEntry({required this.onLogout});

  @override
  State<_ProfileEntry> createState() => _ProfileEntryState();
}

class _ProfileEntryState extends State<_ProfileEntry> {
  final _store = getIt<CareContextStore>();
  late String _userName = _store.require().userFullName;
  late String _recipientName = _store.require().careRecipientName;
  bool _confirmingLogout = false;

  Future<void> _personalData() {
    final care = _store.require();
    final viewModel = PersonalDataViewModel(
      repository: getIt<ProfileRepository>(),
      userId: care.userAccountId,
    );
    return Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (pageContext) => PersonalDataPage(
          viewModel: viewModel,
          onBack: () => Navigator.pop(pageContext),
          onProfileUpdated: (profile) {
            if (!mounted) return;
            final current = _store.current;
            if (current == null ||
                current.userAccountId != care.userAccountId) {
              return;
            }
            _store.save(current.copyWith(userFullName: profile.fullName));
            setState(() => _userName = profile.fullName);
          },
        ),
      ),
    );
  }

  Future<void> _careRecipient() {
    final care = _store.require();
    final viewModel = CareRecipientViewModel(
      repository: getIt<ProfileRepository>(),
      careRecipientProfileId: care.careRecipientProfileId,
    );
    return Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (pageContext) => CareRecipientPage(
          viewModel: viewModel,
          onBack: () => Navigator.pop(pageContext),
          onCareRecipientUpdated: (recipient) {
            if (!mounted) return;
            final current = _store.current;
            if (current == null ||
                current.userAccountId != care.userAccountId ||
                current.careRecipientProfileId != care.careRecipientProfileId) {
              return;
            }
            _store.save(
              current.copyWith(careRecipientName: recipient.fullName),
            );
            setState(() => _recipientName = recipient.fullName);
          },
        ),
      ),
    );
  }

  Future<void> _careCircle() {
    final id = _store.require().careRecipientProfileId;
    final viewModel = CareCircleViewModel(
      repository: getIt<ProfileRepository>(),
      careRecipientProfileId: id,
    );
    return Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (pageContext) => CareCirclePage(
          viewModel: viewModel,
          onBack: () => Navigator.pop(pageContext),
        ),
      ),
    );
  }

  Future<void> _wearable() => Navigator.push<void>(
    context,
    MaterialPageRoute<void>(
      builder: (_) =>
          WearableDetailsPage(viewModel: getIt<WearableDetailsViewModel>()),
    ),
  );

  Future<void> _logout() async {
    if (_confirmingLogout) return;
    _confirmingLogout = true;
    try {
      final confirmed = await showLogoutDialog(
        context,
        careRecipientFirstName: _recipientName.split(' ').first,
      );
      if (mounted && confirmed) widget.onLogout();
    } finally {
      _confirmingLogout = false;
    }
  }

  @override
  Widget build(BuildContext context) => ProfileHomePage(
    userFullName: _userName,
    careRecipientName: _recipientName,
    onBack: () => Navigator.pop(context),
    onPersonalData: _personalData,
    onCareRecipient: _careRecipient,
    onCareCircle: _careCircle,
    onWearable: _wearable,
    onMyPlan: () => ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Mi plan estará disponible próximamente.')),
    ),
    onSettings: () => _openSettings(context),
    onLogout: _logout,
  );
}

Future<void> _openSettings(BuildContext context) {
  final userId = getIt<CareContextStore>().require().userAccountId;

  final viewModel = SettingsViewModel(
    repository: getIt<ProfileRepository>(),
    userId: userId,
  );

  return Navigator.push<void>(
    context,
    MaterialPageRoute<void>(
      builder: (pageContext) => SettingsPage(
        viewModel: viewModel,
        onBack: () => Navigator.pop(pageContext),
        onLanguage: () => _openLanguage(pageContext),
        onAccessibility: () => _openAccessibility(pageContext),
        onTerms: () => _openTerms(pageContext),
        onAbout: () => _openAbout(pageContext),
      ),
    ),
  );
}

Future<void> _openLanguage(BuildContext context) {
  final userId = getIt<CareContextStore>().require().userAccountId;
  final viewModel = LanguageViewModel(
    repository: getIt<ProfileRepository>(),
    userId: userId,
  );
  return Navigator.push<void>(
    context,
    MaterialPageRoute<void>(
      builder: (pageContext) => LanguagePage(
        viewModel: viewModel,
        onBack: () => Navigator.pop(pageContext),
      ),
    ),
  );
}

Future<void> _openAccessibility(BuildContext context) {
  final userId = getIt<CareContextStore>().require().userAccountId;
  final viewModel = AccessibilityViewModel(
    repository: getIt<ProfileRepository>(),
    userId: userId,
  );
  return Navigator.push<void>(
    context,
    MaterialPageRoute<void>(
      builder: (pageContext) => AccessibilityPage(
        viewModel: viewModel,
        onBack: () => Navigator.pop(pageContext),
      ),
    ),
  );
}

Future<void> _openTerms(BuildContext context) => Navigator.push<void>(
  context,
  MaterialPageRoute<void>(
    builder: (pageContext) =>
        TermsPage(onBack: () => Navigator.pop(pageContext)),
  ),
);

Future<void> _openAbout(BuildContext context) => Navigator.push<void>(
  context,
  MaterialPageRoute<void>(
    builder: (pageContext) => AboutPage(
      onBack: () => Navigator.pop(pageContext),
      onTerms: () => _openTerms(pageContext),
    ),
  ),
);
