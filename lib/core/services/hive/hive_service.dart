import 'package:adoptnest/core/constants/hive_table_constant.dart';
import 'package:adoptnest/features/auth/data/models/auth_hive_model.dart';
import 'package:adoptnest/features/report_animals/data/models/animal_report_hive_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import 'package:path_provider/path_provider.dart';

final hiveServiceProvider = Provider<HiveService>((ref){
  return HiveService();
});


class HiveService {
  //Initial Hive
  Future <void> init() async{
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/${HiveTableConstant.dbName}';
    
     Hive.init(path);
    _registerAdapters();
    await _openBoxes();
   
  }


  //Register all type adapters
 void _registerAdapters(){

    if(!Hive.isAdapterRegistered(HiveTableConstant.authTypeId)){
      Hive.registerAdapter(AuthHiveModelAdapter());
    }

    if(!Hive.)
  }

  //Open all boxes
  Future<void> _openBoxes() async {

    await Hive.openBox<AuthHiveModel>(HiveTableConstant.authTable);

  }


  //Close all boxes
  Future<void> close() async{
    await Hive.close();
  }


// ==================Auth Queries===================
Box<AuthHiveModel> get _authBox =>
Hive.box<AuthHiveModel>(HiveTableConstant.authTable);

Future<AuthHiveModel> registerUser(AuthHiveModel model) async {
  await _authBox.put(model.authId, model);
  return model;
}

//Login
  AuthHiveModel? loginUser(String email, String password) {
    try {
      return _authBox.values.firstWhere(
        (user) => user.email == email && user.password == password,
      );
    } catch (e) {
      return null;
    }
  }

  //logout
  Future<void> logoutUser() async{
   
  }
  //get current user
   AuthHiveModel? getCurrentUser(String authId) {
    return _authBox.get(authId);
  }

  //is email exist
  bool isExistingEmail(String email){
    final users = _authBox.values.where((user)=> user.email == email);
    return users.isNotEmpty;
  }

  //delete user
  Future<void> deleteUser(String authId) async {
    await _authBox.delete(authId);
  }
  
    // Update user
  Future<bool> updateUser(AuthHiveModel user) async {
    if (_authBox.containsKey(user.authId)) {
      await _authBox.put(user.authId, user);
      return true;
    }
    return false;
  }
    // Get user by email
  AuthHiveModel? getUserByEmail(String email) {
    try {
      return _authBox.values.firstWhere((user) => user.email == email);
    } catch (e) {
      return null;
    }
  }
    // Get user by ID
  AuthHiveModel? getUserById(String authId) {
    return _authBox.get(authId);
  }

// ===============================Animal Request Querries====================

Box<AnimalReportHiveModel> get _animalReportBox =>
    Hive.box<AnimalReportHiveModel>(HiveTableConstant.animalReportTable);

Future<AnimalReportHiveModel> createAnimalReport(
    AnimalReportHiveModel report) async {
  await _animalReportBox.put(report.reportId, report);
  return report;
}

List<AnimalReportHiveModel> getAllAnimalReports() {
  return _animalReportBox.values.toList();
}

List<AnimalReportHiveModel> getMyAnimalReports(String userId) {
  return _animalReportBox.values
      .where((r) => r.reportedBy == userId)
      .toList();
}

AnimalReportHiveModel? getAnimalReportById(String id) {
  return _animalReportBox.get(id);
}

Future<bool> updateAnimalReportStatus(String id, String status) async {
  final report = _animalReportBox.get(id);
  if (report != null) {
    final updated = AnimalReportHiveModel(
      reportId: report.reportId,
      species: report.species,
      location: report.location,
      description: report.description,
      imageUrl: report.imageUrl,
      reportedBy: report.reportedBy,
      reportedByName: report.reportedByName,
      status: status,
      createdAt: report.createdAt,
      updatedAt: DateTime.now(),
    );
    await _animalReportBox.put(id, updated);
    return true;
  }
  return false;
}

Future<void> deleteAnimalReport(String id) async {
  await _animalReportBox.delete(id);
}

}