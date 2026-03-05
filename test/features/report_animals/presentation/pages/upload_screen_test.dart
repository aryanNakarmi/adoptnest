import 'package:adoptnest/features/report_animals/presentation/pages/upload_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:adoptnest/features/report_animals/domain/entities/animal_report_entity.dart';
import 'package:adoptnest/features/report_animals/presentation/state/animal_report_state.dart';
import 'package:adoptnest/features/report_animals/presentation/view_model/animal_report_viewmodel.dart';

class FakeAnimalReportViewModel extends AnimalReportViewModel {
  final AnimalReportState _fakeState;
  FakeAnimalReportViewModel(this._fakeState);

  @override
  AnimalReportState build() => _fakeState;

  @override
  Future<void> createReport(AnimalReportEntity report) async {}

  @override
  void resetUploadedPhoto() {}
}

Widget buildReportAnimalScreen(AnimalReportState state) {
  return ProviderScope(
    overrides: [
      animalReportViewModelProvider
          .overrideWith(() => FakeAnimalReportViewModel(state)),
    ],
    child: const MaterialApp(home: ReportAnimalScreen()),
  );
}

void main() {
  group('ReportAnimalScreen Widget Tests', () {
    testWidgets('TW-36: renders Report an Animal header', (tester) async {
      await tester.pumpWidget(
          buildReportAnimalScreen(const AnimalReportState()));
      await tester.pump();

      expect(find.text('Report an Animal'), findsOneWidget);
    });

    testWidgets('TW-37: shows species text field', (tester) async {
      await tester.pumpWidget(
          buildReportAnimalScreen(const AnimalReportState()));
      await tester.pump();

      expect(find.byType(TextFormField), findsWidgets);
    });

    testWidgets('TW-38: shows photo capture area with camera icon',
        (tester) async {
      await tester.pumpWidget(
          buildReportAnimalScreen(const AnimalReportState()));
      await tester.pump();

      expect(find.byIcon(Icons.camera_alt_outlined), findsOneWidget);
    });

    testWidgets('TW-39: Submit Report button is present', (tester) async {
      await tester.pumpWidget(
          buildReportAnimalScreen(const AnimalReportState()));
      await tester.pump();

      expect(find.text('Submit Report'), findsOneWidget);
    });

    testWidgets('TW-40: Clear Form button is present', (tester) async {
      await tester.pumpWidget(
          buildReportAnimalScreen(const AnimalReportState()));
      await tester.pump();

      expect(find.text('Clear Form'), findsOneWidget);
    });

    testWidgets(
        'TW-41: shows species validation error when submitting empty form',
        (tester) async {
      await tester.pumpWidget(
          buildReportAnimalScreen(const AnimalReportState()));
      await tester.pump();

      await tester.tap(find.text('Submit Report'));
      await tester.pump();

      expect(find.text('Please enter animal species'), findsOneWidget);
    });

    testWidgets('TW-42: shows loading overlay when status is loading',
        (tester) async {
      await tester.pumpWidget(buildReportAnimalScreen(
          const AnimalReportState(status: AnimalReportViewStatus.loading)));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });
  });
}