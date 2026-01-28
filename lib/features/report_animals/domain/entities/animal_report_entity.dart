import 'package:equatable/equatable.dart';

enum AnimalReportStatus {
  pending,
  approved,
  rejected,
}


class AnimalReportEntity extends Equatable {
  final String reportId;
  final String species;
  final String location;
  final String? description; 
  final String imageUrl;
  final String reportedBy; 
  final String reportedByName; 
  final String status; // pending, rescued
  final DateTime createdAt;
  final DateTime? updatedAt; 

  const AnimalReportEntity({
    required this.reportId,
    required this.species,
    required this.location,
    this.description,
    required this.imageUrl,
    required this.reportedBy,
    required this.reportedByName,
    required this.status,
    required this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
    reportId,
    species,
    location,
    description,
    imageUrl,
    reportedBy,
    reportedByName,
    status,
    createdAt,
    updatedAt,
  ];
}