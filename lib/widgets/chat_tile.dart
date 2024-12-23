import 'package:flutter/material.dart';
import 'package:konnekt/model/user_profile.dart';

class ChatTile extends StatelessWidget {
  final UserProfile userProfile;
  final Function onTap;
  const ChatTile({
    super.key,
    required this.userProfile,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onTap();
      },
      child: ListTile(
        dense: false,
        leading: CircleAvatar(
          radius: 25.0,
          backgroundImage: NetworkImage(
            userProfile.pfpURL!,
          ),
        ),
        title: Text(
          userProfile.name!,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: const Text(
          'Hello, how are you?',
          style: TextStyle(
            color: Colors.grey,
          ),
        ),
        trailing: const Text(
          '10:00 AM',
          style: TextStyle(
            color: Colors.grey,
          ),
        ),
      ),
    );
  }
}
