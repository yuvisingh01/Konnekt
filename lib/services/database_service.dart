import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import 'package:konnekt/model/chat.dart';
import 'package:konnekt/services/auth_service.dart';
import 'package:konnekt/utils.dart';

import '../model/message.dart';
import '../model/user_profile.dart';

class DatabaseService {
  final GetIt _getIt = GetIt.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late AuthService _authService;
  CollectionReference? _usersCollection;
  CollectionReference? _chatsCollection;

  DatabaseService() {
    _authService = _getIt.get<AuthService>();
    _setupCollectionReference();
  }

  void _setupCollectionReference() {
    _usersCollection =
        _firestore.collection('users').withConverter<UserProfile>(
              fromFirestore: (snapshots, _) =>
                  UserProfile.fromJson(snapshots.data()!),
              toFirestore: (userProfile, _) => userProfile.toJson(),
            );
    _chatsCollection = _firestore.collection('chats').withConverter<Chat>(
          fromFirestore: (snapshots, _) => Chat.fromJson(snapshots.data()!),
          toFirestore: (chat, _) => chat.toJson(),
        );
  }

  Future<void> createUserProfile({required UserProfile userProfile}) async {
    try {
      await _usersCollection!.doc(userProfile.uid).set(userProfile);
    } catch (error) {
      print(error);
    }
  }

  Stream<QuerySnapshot<UserProfile>> getUserProfile(String uid) {
    return _usersCollection
        ?.where('uid', isNotEqualTo: _authService.user!.uid)
        .snapshots() as Stream<QuerySnapshot<UserProfile>>;
  }

  Future<bool> checkChatExists(String uid1, String uid2) async {
    String chatId = generateChatId(uid1: uid1, uid2: uid2);
    final result = await _chatsCollection!.doc(chatId).get();
    if (result != null) {
      return result.exists;
    }
    return false;
  }

  Future<void> createNewChat(String uid1, String uid2) async {
    try {
      String chatId = generateChatId(uid1: uid1, uid2: uid2);
      final docRef = _chatsCollection!.doc(chatId);
      final chat = Chat(
        id: chatId,
        participants: [uid1, uid2],
        messages: [],
      );
      await docRef.set(chat);
    } catch (error) {
      print(error);
    }
  }

  Future<void> sendChatmessage(String uid1, uid2, Message message) async {
    String chatId = generateChatId(uid1: uid1, uid2: uid2);
    final docRef = _chatsCollection!.doc(chatId);
    await docRef.update({
      'messages': FieldValue.arrayUnion(
        [
          message.toJson(),
        ],
      ),
    });
  }

  Stream<DocumentSnapshot<Chat>> getChatData(String uid1, String uid2) {
    String chatId = generateChatId(uid1: uid1, uid2: uid2);
    return _chatsCollection!.doc(chatId).snapshots()
        as Stream<DocumentSnapshot<Chat>>;
  }
}
