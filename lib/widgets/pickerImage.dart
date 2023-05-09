import 'dart:io';

import 'package:firebase_chat_app/widgets/widget.dart';
import 'package:flutter/material.dart';

class Images extends StatefulWidget {
  final File file;

  const Images({
    Key? key,
    required this.file,
  }) : super(key: key);

  @override
  State<Images> createState() => _ImagesState();
}

class _ImagesState extends State<Images> {
  TextEditingController messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
            child: Stack(
          children: <Widget>[
            Container(
              height: size.height,
              width: size.width,
              alignment: Alignment.center,
              child: Image.file(
                widget.file,
                height: size.height,
                width: size.width,
              ),
            ),
            Positioned(
              top: 0.0,
              child: Container(
                width: size.width,
                color: Colors.black,
                child: Row(
                  children: <Widget>[
                    IconButton(
                        onPressed: () {
                          popUpScreenReplace(context);
                        },
                        icon: const Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                          size: 25,
                        )),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 0.0,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                width: size.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: TextField(
                          style: const TextStyle(
                              color: Colors.white, fontSize: 15),
                          keyboardType: TextInputType.text,
                          maxLines: null,
                          textAlign: TextAlign.center,
                          controller: messageController,
                          decoration: newInputDecoration.copyWith(
                              hintText: "Add a caption...",
                              hintStyle: const TextStyle(
                                  color: Colors.white, fontSize: 15))),
                    ),
                    const SizedBox(
                      width: 6,
                    ),
                    IconButton(
                      splashRadius: 25,
                      splashColor: Colors.white,
                      onPressed: () {
                        sendingImage("$widget.file");
                      },
                      icon: const Icon(
                        Icons.arrow_forward_sharp,
                        color: Colors.white,
                        size: 25,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        )),
      ),
    );
  }

  sendingImage(String file) {
    file = file.split('/').last;
    print("File Path-: $file");
  }
}
