import 'package:firebase_chat_app/widgets/widget.dart';
import 'package:flutter/material.dart';

import '../pages/chatPage.dart';

class GroupTiles extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String fullName;

  const GroupTiles({
    Key? key,
    required this.groupId,
    required this.groupName,
    required this.fullName,
  }) : super(key: key);

  @override
  State<GroupTiles> createState() => _GroupTilesState();
}

class _GroupTilesState extends State<GroupTiles> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        nextScreen(
            context,
            ChatPage(
              groupId: widget.groupId,
              groupName: widget.groupName,
              fullName: widget.fullName,
            ));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
        child: ListTile(
          leading: CircleAvatar(
            radius: 30,
            backgroundColor: Theme.of(context).primaryColor,
            child: Text(
              widget.groupName.substring(0, 1).toUpperCase(),
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w500),
            ),
          ),
          title: Text(widget.groupName,
              style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}
