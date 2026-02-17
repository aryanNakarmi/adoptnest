import 'dart:io';

import 'package:adoptnest/features/report_animals/domain/usecases/get_all_reports_usecase.dart';
import 'package:adoptnest/features/report_animals/domain/usecases/create_animal_report_usecase.dart';
import 'package:adoptnest/features/report_animals/domain/usecases/get_my_report_usecase.dart';
import 'package:adoptnest/features/report_animals/domain/usecases/get_report_by_id_usecase.dart';
import 'package:adoptnest/features/report_animals/domain/usecases/get_report_by_species_usecase.dart';
import 'package:adoptnest/features/report_animals/domain/usecases/update_report_status_usecase.dart';
import 'package:adoptnest/features/report_animals/domain/usecases/delete_report_usecase.dart';
import 'package:adoptnest/features/report_animals/domain/usecases/upload_photo_usecase.dart';
import 'package:adoptnest/features/report_animals/presentation/state/animal_report_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/animal_report_entity.dart';

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

  /// Get all reports
  Future<void> getAllReports() async {
    state = state.copyWith(status: AnimalReportViewStatus.loading);

    final result = await _getAllReportsUsecase();

    result.fold(
      (failure) => state = state.copyWith(
        status: AnimalReportViewStatus.error,
        errorMessage: failure.message,
      ),
      (reports) => state = state.copyWith(
        status: AnimalReportViewStatus.loaded,
        reports: reports,
      ),
    );
  }

  /// Get report by ID
  Future<void> getReportById(String reportId) async {
    state = state.copyWith(status: AnimalReportViewStatus.loading);

    final result = await _getReportByIdUsecase(
      GetAnimalReportByIdParams(reportId: reportId),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: AnimalReportViewStatus.error,
        errorMessage: failure.message,
      ),
      (report) => state = state.copyWith(
        status: AnimalReportViewStatus.loaded,
        selectedReport: report,
      ),
    );
  }

  /// Search by species
  Future<void> searchBySpecies(String species) async {
    state = state.copyWith(status: AnimalReportViewStatus.loading);

    final result = await _getReportsBySpeciesUsecase(
      GetReportsBySpeciesParams(species: species),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: AnimalReportViewStatus.error,
        errorMessage: failure.message,
      ),
      (reports) => state = state.copyWith(
        status: AnimalReportViewStatus.loaded,
        reports: reports,
      ),
    );
  }

  /// Get my reports
  Future<void> getMyReports(String userId) async {
    state = state.copyWith(status: AnimalReportViewStatus.loading);

    final result = await _getMyReportsUsecase(
      GetMyReportsParams(userId: userId),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: AnimalReportViewStatus.error,
        errorMessage: failure.message,
      ),
      (reports) => state = state.copyWith(
        status: AnimalReportViewStatus.loaded,
        myReports: reports,
      ),
    );
  }

  /// Create report
  Future<void> createReport(AnimalReportEntity report) async {
    state = state.copyWith(status: AnimalReportViewStatus.loading);

    final result =
        await _createReportUsecase(CreateReportParams(report: report));

    result.fold(
      (failure) => state = state.copyWith(
        status: AnimalReportViewStatus.error,
        errorMessage: failure.message,
      ),
      (_) {
        state = state.copyWith(status: AnimalReportViewStatus.created);
        getAllReports(); // Refresh list
      },
    );
  }

  /// Update report status
  Future<void> updateReportStatus({
    required String reportId,
    required AnimalReportStatus newStatus,
  }) async {
    state = state.copyWith(status: AnimalReportViewStatus.loading);

    final result = await _updateReportStatusUsecase(
      UpdateReportStatusParams(
        reportId: reportId,
        newStatus: newStatus,
      ),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: AnimalReportViewStatus.error,
        errorMessage: failure.message,
      ),
      (updatedReport) {
        final updatedList = state.reports.map((report) {
          return report.reportId == updatedReport.reportId
              ? updatedReport
              : report;
        }).toList();

        state = state.copyWith(
          status: AnimalReportViewStatus.updated,
          reports: updatedList,
        );
      },
    );
  }

 /// Delete report
Future<bool> deleteReport(String reportId) async {
  state = state.copyWith(status: AnimalReportViewStatus.loading);

  final result = await _deleteReportUsecase(
    DeleteReportParams(reportId: reportId),
  );

  return result.fold(
    (failure) {
      state = state.copyWith(
        status: AnimalReportViewStatus.error,
        errorMessage: failure.message,
      );
      return false;
    },
    (success) {
      if (success) {
        final updatedReports =
            state.myReports.where((r) => r.reportId != reportId).toList();
        state = state.copyWith(
          status: AnimalReportViewStatus.deleted,
          myReports: updatedReports,
        );
        return true;
      }
      return false;
    },
  );
}

  /// Upload photo
  Future<void> uploadPhoto(File photo) async {
    state = state.copyWith(status: AnimalReportViewStatus.loading);

    final result = await _uploadPhotoUsecase(
      UploadPhotoParams(photo: photo),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: AnimalReportViewStatus.error,
        errorMessage: failure.message,
      ),
      (photoUrl){

       state = state.copyWith(
        status: AnimalReportViewStatus.initial,
        uploadedPhotoUrl: photoUrl,
      );
      }
    );
  }
  

  /// Helpers
  

  // In animal_report_viewmodel.dart

void resetUploadedPhoto() {
  state = state.copyWith(
    uploadedPhotoUrl: null,
    resetUploadedPhotoUrl: true,
  );
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