import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:konnekt/model/message.dart';
import 'package:konnekt/model/user_profile.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:konnekt/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:konnekt/services/database_service.dart';
import 'package:konnekt/services/media_service.dart';
import 'package:konnekt/services/storage_service.dart';
import 'package:konnekt/utils.dart';

import '../model/chat.dart';

class ChatPage extends StatefulWidget {
  final UserProfile chatUser;
  const ChatPage({super.key, required this.chatUser});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final GetIt _getIt = GetIt.instance;
  late AuthService _authService;
  late DatabaseService _databaseService;
  late MediaService _mediaService;
  late StorageService _storageService;

  ChatUser? currentUser, otherUser;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _authService = _getIt.get<AuthService>();
    _databaseService = _getIt.get<DatabaseService>();
    _mediaService = _getIt.get<MediaService>();
    _storageService = _getIt.get<StorageService>();

    currentUser = ChatUser(
      id: _authService.user!.uid,
      firstName: _authService.user!.displayName,
      profileImage: _authService.user!.photoURL,
    );
    otherUser = ChatUser(
      id: widget.chatUser.uid!,
      firstName: widget.chatUser.name,
      profileImage: widget.chatUser.pfpURL,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.chatUser.name!,
        ),
      ),
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    return StreamBuilder(
        stream: _databaseService.getChatData(currentUser!.id, otherUser!.id),
        builder: (context, snapshots) {
          Chat? chat = snapshots.data?.data();
          List<ChatMessage> messages = [];
          if (chat != null && chat.messages != null) {
            messages = _generateChatMessageList(chat.messages!);
          }
          return DashChat(
            messageOptions: const MessageOptions(
              // showCurrentUserAvatar: true,
              showOtherUsersAvatar: true,
              showTime: true,
              showOtherUsersName: true,
            ),
            inputOptions: InputOptions(alwaysShowSend: true, trailing: [
              _mediaMessageButton(),
            ]),
            currentUser: currentUser!,
            onSend: (message) {
              _sendMessage(message);
            },
            messages: messages,
          );
        });
  }

  Future<void> _sendMessage(ChatMessage chatMessage) async {
    if (chatMessage.medias?.isNotEmpty ?? false) {
      if(chatMessage.medias!.first.type==MediaType.image){
        Message message = Message(
          senderID: chatMessage.user.id,
          content: chatMessage.medias!.first.url,
          messageType: MessageType.Image,
          sentAt: Timestamp.fromDate(chatMessage.createdAt),
        );
        await _databaseService.sendChatmessage(
          currentUser!.id,
          otherUser!.id,
          message,
        );
      }
    } else {
      Message message = Message(
        senderID: currentUser!.id,
        content: chatMessage.text,
        messageType: MessageType.Text,
        sentAt: Timestamp.fromDate(chatMessage.createdAt),
      );
      await _databaseService.sendChatmessage(
        currentUser!.id,
        otherUser!.id,
        message,
      );
    }
  }

  List<ChatMessage> _generateChatMessageList(List<Message> messages) {
    List<ChatMessage> chatMessages = messages.map((m) {
      if(m.messageType==MessageType.Image){
        return ChatMessage(
          user: m.senderID == currentUser!.id ? currentUser! : otherUser!,
          createdAt: m.sentAt!.toDate(),
          medias: [
            ChatMedia(
              url: m.content.toString(),
              fileName: '',
              type: MediaType.image,
            ),
          ],
        );
      }
      return ChatMessage(
        user: m.senderID == currentUser!.id ? currentUser! : otherUser!,
        createdAt: m.sentAt!.toDate(),
        text: m.content.toString(),
      );
    }).toList();
    chatMessages.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return chatMessages;
  }

  Widget _mediaMessageButton() {
    return IconButton(
      onPressed: () async {
        File? file = await _mediaService.getImageFromGallery();
        if (file != null) {
          String chatId =
              generateChatId(uid1: currentUser!.id, uid2: otherUser!.id);
          bool isUploaded = await _storageService.uploadImageToChat(
              file: file, chatId: chatId);
          if (isUploaded) {
            String? uploadedImageUrl = _storageService.uploadedImageUrl;
            if (uploadedImageUrl != null) {
              ChatMessage chatMessage = ChatMessage(
                user: currentUser!,
                createdAt: DateTime.now(),
                medias: [
                  ChatMedia(
                    url: uploadedImageUrl,
                    fileName: '',
                    type: MediaType.image,
                  ),
                ],
              );
              _sendMessage(chatMessage);
            }
          }
        }
      },
      icon: Icon(
        Icons.image,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
