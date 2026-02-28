import 'package:equatable/equatable.dart';
import 'package:adoptnest/features/report_animals/domain/entities/animal_report_entity.dart';

enum AnimalReportViewStatus {
  initial,
  loading,
  loaded,
  error,
  created,
  updated,
  deleted,
}

class AnimalReportState extends Equatable {
  final AnimalReportViewStatus status;
  final List<AnimalReportEntity> reports;
  final List<AnimalReportEntity> pendingReports;
  final List<AnimalReportEntity> rescuedReports;
  final List<AnimalReportEntity> myReports;
  final AnimalReportEntity? selectedReport;
  final String? errorMessage;
  final String? uploadedPhotoUrl;

  const AnimalReportState({
    this.status = AnimalReportViewStatus.initial,
    this.reports = const [],
    this.pendingReports = const [],
    this.rescuedReports = const [],
    this.myReports = const [],
    this.selectedReport,
    this.errorMessage,
    this.uploadedPhotoUrl,
  });

  AnimalReportState copyWith({
    AnimalReportViewStatus? status,
    List<AnimalReportEntity>? reports,
    List<AnimalReportEntity>? pendingReports,
    List<AnimalReportEntity>? rescuedReports,
    List<AnimalReportEntity>? myReports,
    AnimalReportEntity? selectedReport,
    bool resetSelectedReport = false,
    String? errorMessage,
    bool resetErrorMessage = false,
    String? uploadedPhotoUrl,
    bool resetUploadedPhotoUrl = false,
  }) {
    return AnimalReportState(
      status: status ?? this.status,
      reports: reports ?? this.reports,
      pendingReports: pendingReports ?? this.pendingReports,
      rescuedReports: rescuedReports ?? this.rescuedReports,
      myReports: myReports ?? this.myReports,
      selectedReport: resetSelectedReport ? null : (selectedReport ?? this.selectedReport),
      errorMessage: resetErrorMessage ? null : (errorMessage ?? this.errorMessage),
      uploadedPhotoUrl: resetUploadedPhotoUrl ? null : (uploadedPhotoUrl ?? this.uploadedPhotoUrl),
    );
  }

  @override
  List<Object?> get props => [
        status,
        reports,
        pendingReports,
        rescuedReports,
        myReports,
        selectedReport,
        errorMessage,
        uploadedPhotoUrl,
      ];
}
