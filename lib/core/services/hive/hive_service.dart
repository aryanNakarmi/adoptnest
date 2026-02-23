import 'dart:io';

import 'package:adoptnest/core/constants/hive_table_constant.dart';
import 'package:adoptnest/features/adopt/data/models/animal_post_hive_model.dart';
import 'package:adoptnest/features/auth/data/models/auth_hive_model.dart';
import 'package:adoptnest/features/chat/domain/entities/chat_entity.dart';
import 'package:adoptnest/features/report_animals/data/models/animal_report_hive_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:adoptnest/features/chat/data/models/chat_hive_model.dart';
import 'package:adoptnest/features/chat/data/models/message_hive_model.dart';
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

    if(!Hive.isAdapterRegistered(HiveTableConstant.animalReportTypeId)){
      Hive.registerAdapter(AnimalReportHiveModelAdapter());
    }

    if(!Hive.isAdapterRegistered(HiveTableConstant.animalPostTypeId)){
      Hive.registerAdapter(AnimalPostHiveModelAdapter());
    } 
    if (!Hive.isAdapterRegistered(HiveTableConstant.chatTypeId)) {
    Hive.registerAdapter(ChatHiveModelAdapter());
    }
    if (!Hive.isAdapterRegistered(HiveTableConstant.messageTypeId)) {
    Hive.registerAdapter(MessageHiveModelAdapter());
    }
    
  }

  //Open all boxes
  Future<void> _openBoxes() async {

    await Hive.openBox<AuthHiveModel>(HiveTableConstant.authTable);
    await Hive.openBox<AnimalReportHiveModel>(HiveTableConstant.animalReportTable);
    await Hive.openBox<AnimalPostHiveModel>(HiveTableConstant.animalPostTable);
    await Hive.openBox<ChatHiveModel>(HiveTableConstant.chatTable);
    await Hive.openBox<MessageHiveModel>(HiveTableConstant.messageTable);


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
Future<List<AnimalReportHiveModel>> getReportsBySpecies(
      String species) async {
    try {
      if (species.isEmpty) return [];
      return _animalReportBox.values
          .where((report) =>
              report.species.toLowerCase() == species.toLowerCase())
          .toList();
    } catch (e) {
      return [];
    }
  }

Future<bool> updateAnimalReportStatus(String id, String status) async {
  final report = _animalReportBox.get(id);
  if (report != null) {
    final updated = AnimalReportHiveModel(
      reportId: report.reportId,
      species: report.species,
      locationAddress: report.locationAddress,  
      locationLat: report.locationLat,         
      locationLng: report.locationLng,          
      description: report.description,
      imageUrl: report.imageUrl,
      reportedBy: report.reportedBy,
      status: status,
      createdAt: report.createdAt,
      updatedAt: DateTime.now(),
    );
    await _animalReportBox.put(id, updated);
    return true;
  }
  return false;
}

 Future<String> uploadPhoto(File photo) async {
    try {
      if (!photo.existsSync()) {
        throw Exception("Photo file does not exist");
      }

      final directory = await getApplicationDocumentsDirectory();
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_photo.jpg';
      final savedImage = await photo.copy('${directory.path}/$fileName');

      return savedImage.path;
    } catch (e) {
      throw Exception('Failed to upload photo: $e');
    }
  }
Future<void> deleteAnimalReport(String id) async {
  await _animalReportBox.delete(id);
}




// ===============================Animal Post Queries====================

Box<AnimalPostHiveModel> get _animalPostBox =>
    Hive.box<AnimalPostHiveModel>(HiveTableConstant.animalPostTable);

Future<List<AnimalPostHiveModel>> getAllAnimalPosts() async {
  return _animalPostBox.values.toList();
}

AnimalPostHiveModel? getAnimalPostById(String postId) {
  try {
    return _animalPostBox.values.firstWhere((p) => p.postId == postId);
  } catch (e) {
    return null;
  }
}

Future<void> cacheAnimalPost(AnimalPostHiveModel post) async {
  await _animalPostBox.put(post.postId, post);
}

Future<void> clearAnimalPostCache() async {
  await _animalPostBox.clear();
}


// =================== Chat Queries ===================
Box<ChatHiveModel> get _chatBox =>
    Hive.box<ChatHiveModel>(HiveTableConstant.chatTable);

Box<MessageHiveModel> get _messageBox =>
    Hive.box<MessageHiveModel>(HiveTableConstant.messageTable);

Future<void> cacheChat(ChatEntity chat) async {
  final model = ChatHiveModel.fromEntity(chat);
  await _chatBox.put('my_chat', model);
}

Future<ChatEntity?> getCachedChat() async {
  final model = _chatBox.get('my_chat');
  return model?.toEntity();
}

Future<void> cacheMessages(String chatId, List<MessageEntity> messages) async {
  await _messageBox.clear();
  for (final msg in messages) {
    final model = MessageHiveModel.fromEntity(msg);
    await _messageBox.put(msg.id, model);
  }
}

Future<List<MessageEntity>> getCachedMessages(String chatId) async {
  return _messageBox.values
      .where((m) => m.chatId == chatId)
      .map((m) => m.toEntity())
      .toList()
    ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
}

Future<void> clearChatCache() async {
  await _chatBox.clear();
  await _messageBox.clear();
}




}