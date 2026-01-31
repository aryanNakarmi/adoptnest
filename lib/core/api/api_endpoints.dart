import 'dart:io';

import 'package:flutter/foundation.dart';

class ApiEndpoints {
  ApiEndpoints._();
  // // Base URL - change this for production
  // static const String baseUrl = 'http://10.0.2.2:5050/api/v1';
  // //static const String baseUrl = 'http://localhost:3000/api/v1';
  // // For Android Emulator use: 'http://10.0.2.2:3000/api/v1'
  // // For iOS Simulator use: 'http://localhost:5000/api/v1'
  // // For Physical Device use your computer's IP: 'http://192.168.x.x:5000/api/v1'

static const bool isPhysicalDevice = false;

  static const String compIpAddress = "192.168.1.7";  //for home
  // static const String compIpAddress = "10.1.25.186"; //college

  static String get baseUrl {
    if (isPhysicalDevice) {
      return 'http://$compIpAddress:5050/api/v1';
    }
    // yadi android
    if (kIsWeb) {
      return 'http://localhost:5050/api/v1';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:5050/api/v1';
    } else if (Platform.isIOS) {
      return 'http://localhost:5050/api/v1';
    } else {
      return 'http://localhost:5050/api/v1';
    }
  }

  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

 // ===================  Users EndPoints ===================
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String currentUser = '/auth/currentUser';
  static String userById(String id) => '/users/$id';
  static String updateUser(String id) => '/users/$id'; // PUT for profile update

  
// =================== Animal Reports ===================

// Create report
static const String createReport = '/reports';

// Upload report image
static const String uploadReportImage = '/reports/upload-photo';

// Get my reports
static const String myReports = '/reports/my-reports';

// Get all reports (admin)
static const String allReports = '/reports/all';

// Get report by ID
static String reportById(String id) => '/reports/$id';

// Delete report
static String deleteReport(String id) => '/reports/$id';

// Update report status
static String updateReportStatus(String id) => '/reports/$id/status';

// Filter by species
static String reportsBySpecies(String species) => '/reports/species/$species';


}
