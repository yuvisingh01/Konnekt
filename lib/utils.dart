import 'package:firebase_core/firebase_core.dart';
import 'package:konnekt/firebase_options.dart';
import 'package:get_it/get_it.dart';
import 'package:konnekt/services/alert_service.dart';
import 'package:konnekt/services/auth_service.dart';
import 'package:konnekt/services/database_service.dart';
import 'package:konnekt/services/media_service.dart';
import 'package:konnekt/services/storage_service.dart';

import 'services/navigation_service.dart';

Future<void> setupFirebase() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

Future<void> registerServices() async {
  final GetIt getIt = GetIt.instance;
  getIt.registerSingleton<AuthService>(
    AuthService(),
  );
  getIt.registerSingleton<NavigationService>(
    NavigationService(),
  );
  getIt.registerSingleton<AlertService>(
    AlertService(),
  );
  getIt.registerSingleton<MediaService>(
    MediaService(),
  );
  getIt.registerSingleton<StorageService>(
    StorageService(),
  );
  getIt.registerSingleton<DatabaseService>(
    DatabaseService(),
  );
}



String generateChatId({required String uid1, required String  uid2 }){
  List<String> uids = [uid1,uid2];
  uids.sort();
  String chatId=uids.fold("",(id,uid)=> "$id$uid");
  return chatId;
}