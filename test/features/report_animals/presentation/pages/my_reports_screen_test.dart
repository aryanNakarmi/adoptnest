import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:adoptnest/core/services/storage/user_session_service.dart';
import 'package:adoptnest/features/report_animals/domain/entities/animal_report_entity.dart';
import 'package:adoptnest/features/report_animals/presentation/pages/my_reports_screen.dart';
import 'package:adoptnest/features/report_animals/presentation/state/animal_report_state.dart';
import 'package:adoptnest/features/report_animals/presentation/view_model/animal_report_viewmodel.dart';

class _SilentHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..connectionTimeout = const Duration(milliseconds: 1);
  }
}

class FakeAnimalReportViewModel extends AnimalReportViewModel {
  final AnimalReportState _fakeState;
  FakeAnimalReportViewModel(this._fakeState);

  @override
  AnimalReportState build() => _fakeState;

  @override
  Future<void> getMyReports(String userId) async {}
}

final _location = LocationValue(address: 'Kathmandu', lat: 27.7, lng: 85.3);

AnimalReportEntity makeReport({
  String id = 'r1',
  AnimalReportStatus status = AnimalReportStatus.pending,
}) =>
    AnimalReportEntity(
      reportId: id,
      species: 'Cat',
      location: _location,
      imageUrl: '',
      reportedBy: 'user-1',
      status: status,
      createdAt: DateTime(2024, 1, 1),
    );

Future<Widget> buildMyReportsScreen(AnimalReportState state) async {
  SharedPreferences.setMockInitialValues({'user_id': 'user-1'});
  final prefs = await SharedPreferences.getInstance();
  final session = UserSessionService(prefs: prefs);

  return ProviderScope(
    overrides: [
      animalReportViewModelProvider
          .overrideWith(() => FakeAnimalReportViewModel(state)),
      sharedPreferencesProvider.overrideWithValue(prefs),
      userSessionServiceProvider.overrideWithValue(session),
    ],
    child: const MaterialApp(home: MyReportsScreen()),
  );
}

void main() {
  setUpAll(() {
    HttpOverrides.global = _SilentHttpOverrides();
  });

  tearDownAll(() {
    HttpOverrides.global = null;
  });

  group('MyReportsScreen Widget Tests', () {
    testWidgets('shows loading indicator when loading', (tester) async {
      await tester.pumpWidget(await buildMyReportsScreen(
          const AnimalReportState(status: AnimalReportViewStatus.loading)));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows empty state when no reports', (tester) async {
      await tester.pumpWidget(await buildMyReportsScreen(
          const AnimalReportState(status: AnimalReportViewStatus.loaded)));
      await tester.pump();

      expect(find.text('No reports yet'), findsOneWidget);
    });

    testWidgets('shows error state with retry button', (tester) async {
      await tester.pumpWidget(await buildMyReportsScreen(const AnimalReportState(
        status: AnimalReportViewStatus.error,
        errorMessage: 'Failed to load',
      )));
      await tester.pump();

      expect(find.text('Failed to load'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('appbar shows My Reports title', (tester) async {
      await tester.pumpWidget(await buildMyReportsScreen(
          const AnimalReportState(status: AnimalReportViewStatus.loaded)));
      await tester.pump();

      expect(find.text('My Reports'), findsOneWidget);
    });
  });
}