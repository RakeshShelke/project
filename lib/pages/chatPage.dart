import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_chat_app/pages/groupInfo.dart';
import 'package:firebase_chat_app/service/databaseService.dart';
import 'package:firebase_chat_app/widgets/messageTile.dart';
import 'package:firebase_chat_app/widgets/widget.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';

import '../widgets/pickerImage.dart';

class ChatPage extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String fullName;

  const ChatPage({
    Key? key,
    required this.groupId,
    required this.groupName,
    required this.fullName,
  }) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  String admin = "";
  Stream<QuerySnapshot>? chats;
  bool showEmoji = false;
  File? imageFile;

  TextEditingController messageController = TextEditingController();
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    getChatAndAdmin();
  }

  getChatAndAdmin() {
    DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
        .getChat(widget.groupId)
        .then((value) {
      setState(() {
        chats = value;
      });
    });

    DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
        .getGroupAdmin(widget.groupId)
        .then((value) {
      setState(() {
        admin = value;
      });
    });
  }

  String _imageName = '';

  String get imageName => _imageName;
  XFile? _pickedFile;

  XFile? get pickFile => _pickedFile;
  late File _filePath;

  File get filePath => _filePath;

  Future<void> pickImage({
    required BuildContext context,
  }) async {
    final imagePick = ImagePicker();
    await Permission.photos.request();
    var permissionStatus = await Permission.photos.status;
    if (permissionStatus.isGranted) {
      _pickedFile = await imagePick.pickImage(source: ImageSource.gallery);

      if (_pickedFile != null) {
        _filePath = File(_pickedFile!.path);
        _imageName = filePath.path.split('/').last;
        print("imageName--$imageName");

        if (mounted) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => Images(
                        file: filePath,
                      )));
        }
      } else {
        print("Please Pick image");
      }
    } else {
      print("Please allow permission");
    }
  }

  Future getImage() async {
    ImagePicker picker = ImagePicker();
    await picker.pickImage(source: ImageSource.gallery).then((XFile? file) {
      if (file != null) {
        imageFile = File(file.path);
        uploadImage();
      }
    });
  }

  //firebase storage
  Future uploadImage() async {
    String fileName = const Uuid().v1();
    int value = 1;
    var reference =
        FirebaseStorage.instance.ref().child('Photos').child("$fileName.jpg");
    var upload = await reference.putFile(imageFile!).catchError((error) async {
      value = 0;
      print(error.toString());
    });
    if (value == 1) {
      String imageUrl = await upload.ref.getDownloadURL();
      print("URL-::$imageUrl");
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: WillPopScope(
        onWillPop: () {
          if (showEmoji) {
            setState(() => showEmoji = !showEmoji);
            return Future.value(false);
          } else {
            return Future.value(true);
          }
        },
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
            leading: IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.arrow_back_ios_new)
            ),
            centerTitle: true,
            elevation: 0,
            title: Text(widget.groupName),
            backgroundColor: Theme.of(context).primaryColor,
            actions: [
              IconButton(
                  onPressed: () {
                    nextScreen(
                        context,
                        GroupInfo(
                            groupId: widget.groupId,
                            groupName: widget.groupName,
                            adminName: admin));
                  },
                  icon: const Icon(Icons.info_rounded))
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: chatMessage(),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                width: Get.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: TextField(
                        keyboardType: TextInputType.text,
                        maxLines: null,
                        onTap: () {
                          if (showEmoji) {
                            setState(() {
                              showEmoji = !showEmoji;
                            });
                          }
                        },
                        controller: messageController,
                        decoration: textInputDecoration.copyWith(
                          hintText: "Send a message",
                          prefixIcon: IconButton(
                            onPressed: () {
                              FocusScope.of(context).unfocus();
                              setState(() {
                                showEmoji = !showEmoji;
                              });
                            },
                            icon: const Icon(
                              Icons.emoji_emotions,
                            ),
                            color: Theme.of(context).primaryColor,
                          ),
                          // suffixIcon: IconButton(
                          //   icon: Icon(
                          //     Icons.image,
                          //     color: Theme.of(context).primaryColor,
                          //   ),
                          //   onPressed: () async {
                          //     getImage();
                          //     //pickImage(context: context);
                          //   },
                          // ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: Container(
                          height: 55,
                          width: 60,
                          color: Theme.of(context).primaryColor,
                          child: IconButton(
                            onPressed: () {
                              sendingMessage();
                            },
                            icon: const Icon(
                              Icons.send_sharp,
                              color: Colors.white,
                            ),
                          )),
                    ),
                  ],
                ),
              ),
              Offstage(
                offstage: !showEmoji,
                child: SizedBox(
                  height: 300,
                  child: EmojiPicker(
                    textEditingController: messageController,
                    config: Config(
                      verticalSpacing: 0,
                      horizontalSpacing: 0,
                      columns: 8,
                      emojiSizeMax: 30.0,
                      initCategory: Category.RECENT,
                      bgColor: Colors.grey.shade200,
                      indicatorColor: const Color(0xFFee7b64),
                      iconColor: Colors.grey,
                      iconColorSelected: const Color(0xFFee7b64),
                      backspaceColor: const Color(0xFFee7b64),
                      skinToneDialogBgColor: Colors.white,
                      skinToneIndicatorColor: Colors.grey,
                      enableSkinTones: true,
                      showRecentsTab: true,
                      recentsLimit: 30,
                      buttonMode: ButtonMode.MATERIAL,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  chatMessage() {
    if (scrollController.hasClients) {
      scrollController.jumpTo(scrollController.position.minScrollExtent);
    }
    return StreamBuilder(
        stream: chats,
        builder: (context, snapshot) {
          return snapshot.hasData
              ? ListView.builder(
                  reverse: true,
                  controller: scrollController,
                  itemCount: snapshot.data?.docs.length,
                  itemBuilder: (context, index) {
                    return MessageTile(
                      message: snapshot.data?.docs[index]['message'],
                      sender: snapshot.data?.docs[index]['sender'],
                      sentByMe: widget.fullName ==
                          snapshot.data?.docs[index]['sender'],
                    );
                  })
              : Container();
        });
  }

  sendingMessage() {
    if (messageController.text.isNotEmpty) {
      Map<String, dynamic> chatMessageMap = {
        "message": messageController.text,
        "sender": widget.fullName,
        "type": "type",
        "time": DateTime.now()
      };
      DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
          .sendMessage(widget.groupId, chatMessageMap);
      setState(() {
        messageController.clear();
      });
    }
  }
}
