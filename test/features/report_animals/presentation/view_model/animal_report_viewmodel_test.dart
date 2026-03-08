import 'package:flutter_test/flutter_test.dart';

import 'package:adoptnest/features/report_animals/domain/entities/animal_report_entity.dart';
import 'package:adoptnest/features/report_animals/presentation/state/animal_report_state.dart';
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
  group('AnimalReportViewModel Unit Tests', () {
    test('initial state has initial status', () {
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

    test('initial state has empty reports list', () {
      final vm = FakeAnimalReportViewModel(const AnimalReportState());
      expect(vm.build().reports, isEmpty);
    });

    test('loading state has loading status', () {
      final vm = FakeAnimalReportViewModel(
          const AnimalReportState(status: AnimalReportViewStatus.loading));
      expect(vm.build().status, AnimalReportViewStatus.loading);
    });

    test('error state has error message', () {
      const errorMsg = 'Something went wrong';
      final vm = FakeAnimalReportViewModel(const AnimalReportState(
        status: AnimalReportViewStatus.error,
        errorMessage: errorMsg,
      ));
      expect(vm.build().errorMessage, errorMsg);
      expect(vm.build().status, AnimalReportViewStatus.error);
    });

    test('resetUploadedPhoto clears photo url', () {
      final vm = FakeAnimalReportViewModel(
          const AnimalReportState(uploadedPhotoUrl: 'https://example.com/photo.jpg'));
      vm.resetUploadedPhoto();
      expect(vm.build().uploadedPhotoUrl, isNull);
    });
  });
}