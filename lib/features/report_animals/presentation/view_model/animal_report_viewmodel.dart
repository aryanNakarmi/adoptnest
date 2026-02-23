import 'dart:io';
import 'package:adoptnest/features/report_animals/domain/usecases/create_animal_report_usecase.dart';
import 'package:adoptnest/features/report_animals/domain/usecases/delete_report_usecase.dart';
import 'package:adoptnest/features/report_animals/domain/usecases/get_all_reports_usecase.dart';
import 'package:adoptnest/features/report_animals/domain/usecases/get_my_report_usecase.dart';
import 'package:adoptnest/features/report_animals/domain/usecases/get_report_by_id_usecase.dart';
import 'package:adoptnest/features/report_animals/domain/usecases/get_report_by_species_usecase.dart';
import 'package:adoptnest/features/report_animals/domain/usecases/update_report_status_usecase.dart';
import 'package:adoptnest/features/report_animals/domain/usecases/upload_photo_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:adoptnest/features/report_animals/domain/entities/animal_report_entity.dart';
import 'package:adoptnest/features/report_animals/presentation/state/animal_report_state.dart';

final animalReportViewModelProvider =
    NotifierProvider<AnimalReportViewModel, AnimalReportState>(
  AnimalReportViewModel.new,
);

class AnimalReportViewModel extends Notifier<AnimalReportState> {
  late final GetAllAnimalReportsUsecase _getAllReportsUsecase;
  late final GetAnimalReportByIdUsecase _getReportByIdUsecase;
  late final GetReportsBySpeciesUsecase _getReportsBySpeciesUsecase;
  late final GetMyReportsUsecase _getMyReportsUsecase;
  late final CreateAnimalReportUsecase _createReportUsecase;
  late final UpdateReportStatusUsecase _updateReportStatusUsecase;
  late final DeleteReportUsecase _deleteReportUsecase;
  late final UploadPhotoUsecase _uploadPhotoUsecase;

  @override
  AnimalReportState build() {
    _getAllReportsUsecase = ref.read(getAllAnimalReportsUsecaseProvider);
    _getReportByIdUsecase = ref.read(getAnimalReportByIdUsecaseProvider);
    _getReportsBySpeciesUsecase = ref.read(getReportsBySpeciesUsecaseProvider);
    _getMyReportsUsecase = ref.read(getMyReportsUsecaseProvider);
    _createReportUsecase = ref.read(createAnimalReportUsecaseProvider);
    _updateReportStatusUsecase = ref.read(updateReportStatusUsecaseProvider);
    _deleteReportUsecase = ref.read(deleteReportUsecaseProvider);
    _uploadPhotoUsecase = ref.read(uploadPhotoUsecaseProvider);
    return const AnimalReportState();
  }

  Future<void> getAllReports() async {
    state = state.copyWith(status: AnimalReportViewStatus.loading);
    final result = await _getAllReportsUsecase();
    result.fold(
      (f) => state = state.copyWith(status: AnimalReportViewStatus.error, errorMessage: f.message),
      (reports) => state = state.copyWith(status: AnimalReportViewStatus.loaded, reports: reports),
    );
  }

  Future<void> getReportById(String reportId) async {
    state = state.copyWith(status: AnimalReportViewStatus.loading);
    final result = await _getReportByIdUsecase(GetAnimalReportByIdParams(reportId: reportId));
    result.fold(
      (f) => state = state.copyWith(status: AnimalReportViewStatus.error, errorMessage: f.message),
      (report) => state = state.copyWith(status: AnimalReportViewStatus.loaded, selectedReport: report),
    );
  }

  Future<void> searchBySpecies(String species) async {
    state = state.copyWith(status: AnimalReportViewStatus.loading);
    final result = await _getReportsBySpeciesUsecase(GetReportsBySpeciesParams(species: species));
    result.fold(
      (f) => state = state.copyWith(status: AnimalReportViewStatus.error, errorMessage: f.message),
      (reports) => state = state.copyWith(status: AnimalReportViewStatus.loaded, reports: reports),
    );
  }

  Future<void> getMyReports(String userId) async {
    state = state.copyWith(status: AnimalReportViewStatus.loading);
    final result = await _getMyReportsUsecase(GetMyReportsParams(userId: userId));
    result.fold(
      (f) => state = state.copyWith(status: AnimalReportViewStatus.error, errorMessage: f.message),
      (reports) => state = state.copyWith(status: AnimalReportViewStatus.loaded, myReports: reports),
    );
  }

  Future<void> createReport(AnimalReportEntity report) async {
    state = state.copyWith(status: AnimalReportViewStatus.loading);
    final result = await _createReportUsecase(CreateReportParams(report: report));
    result.fold(
      (f) => state = state.copyWith(status: AnimalReportViewStatus.error, errorMessage: f.message),
      (_) {
        state = state.copyWith(status: AnimalReportViewStatus.created);
        getAllReports();
      },
    );
  }

  Future<void> updateReportStatus({
    required String reportId,
    required AnimalReportStatus newStatus,
  }) async {
    state = state.copyWith(status: AnimalReportViewStatus.loading);
    final result = await _updateReportStatusUsecase(
      UpdateReportStatusParams(reportId: reportId, newStatus: newStatus),
    );
    result.fold(
      (f) => state = state.copyWith(status: AnimalReportViewStatus.error, errorMessage: f.message),
      (updated) {
        final updatedList = state.reports
            .map((r) => r.reportId == updated.reportId ? updated : r)
            .toList();
        state = state.copyWith(status: AnimalReportViewStatus.updated, reports: updatedList);
      },
    );
  }

  Future<bool> deleteReport(String reportId) async {
    state = state.copyWith(status: AnimalReportViewStatus.loading);
    final result = await _deleteReportUsecase(DeleteReportParams(reportId: reportId));
    return result.fold(
      (f) {
        state = state.copyWith(status: AnimalReportViewStatus.error, errorMessage: f.message);
        return false;
      },
      (success) {
        if (success) {
          state = state.copyWith(
            status: AnimalReportViewStatus.deleted,
            myReports: state.myReports.where((r) => r.reportId != reportId).toList(),
          );
          return true;
        }
        return false;
      },
    );
  }

  Future<void> uploadPhoto(File photo) async {
    state = state.copyWith(status: AnimalReportViewStatus.loading);
    final result = await _uploadPhotoUsecase(UploadPhotoParams(photo: photo));
    result.fold(
      (f) => state = state.copyWith(status: AnimalReportViewStatus.error, errorMessage: f.message),
      (url) => state = state.copyWith(status: AnimalReportViewStatus.initial, uploadedPhotoUrl: url),
    );
  }

  void resetUploadedPhoto() {
    state = state.copyWith(uploadedPhotoUrl: null, resetUploadedPhotoUrl: true);
  }

  void clearError() {
    state = state.copyWith(resetErrorMessage: true);
  }

  void clearSelectedReport() {
    state = state.copyWith(resetSelectedReport: true);
  }

  void resetState() {
    state = const AnimalReportState();
  }
}
