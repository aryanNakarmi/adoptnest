import 'package:flutter_test/flutter_test.dart';

import 'package:adoptnest/features/report_animals/presentation/state/animal_report_state.dart';
import 'package:adoptnest/features/report_animals/domain/entities/animal_report_entity.dart';
import 'package:adoptnest/features/report_animals/presentation/view_model/animal_report_viewmodel.dart';

class FakeAnimalReportViewModel extends AnimalReportViewModel {
  AnimalReportState _state;
  FakeAnimalReportViewModel(this._state);

  @override
  AnimalReportState build() => _state;

  @override
  Future<void> createReport(AnimalReportEntity report) async {
    _state = _state.copyWith(status: AnimalReportViewStatus.loading);
  }

  @override
  void resetUploadedPhoto() {
    _state = _state.copyWith(resetUploadedPhotoUrl: true);
  }
}

void main() {
  group('ReportAnimalScreen Unit Tests', () {
    test('initial state status is initial', () {
      final vm = FakeAnimalReportViewModel(const AnimalReportState());
      expect(vm.build().status, AnimalReportViewStatus.initial);
    });

    test('initial state has no error message', () {
      final vm = FakeAnimalReportViewModel(const AnimalReportState());
      expect(vm.build().errorMessage, isNull);
    });

    test('initial state has no uploaded photo url', () {
      final vm = FakeAnimalReportViewModel(const AnimalReportState());
      expect(vm.build().uploadedPhotoUrl, isNull);
    });

    test('initial state reports list is empty', () {
      final vm = FakeAnimalReportViewModel(const AnimalReportState());
      expect(vm.build().reports, isEmpty);
    });

    test('initial state myReports list is empty', () {
      final vm = FakeAnimalReportViewModel(const AnimalReportState());
      expect(vm.build().myReports, isEmpty);
    });

    test('loading status is set correctly', () {
      final vm = FakeAnimalReportViewModel(
          const AnimalReportState(status: AnimalReportViewStatus.loading));
      expect(vm.build().status, AnimalReportViewStatus.loading);
    });

    test('error state contains error message', () {
      final vm = FakeAnimalReportViewModel(const AnimalReportState(
        status: AnimalReportViewStatus.error,
        errorMessage: 'Network error',
      ));
      expect(vm.build().errorMessage, 'Network error');
    });
  });
}