import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_chat_app/helper/helperFunction.dart';
import 'package:firebase_chat_app/pages/chatPage.dart';
import 'package:firebase_chat_app/service/databaseService.dart';
import 'package:firebase_chat_app/widgets/widget.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController searchBarController = TextEditingController();
  bool _isLoading = false;
  QuerySnapshot? searchSnapshot;
  bool _hasUser = false;
  bool _isJoined = false;
  String fullName = "";
  User? user;

  @override
  void initState() {
    super.initState();
    getCurrentIDAndName();
  }

  getCurrentIDAndName() async {
    await HelperFunction.getUserName().then((value) {
      setState(() {
        fullName = value!;
      });
    });
    user = FirebaseAuth.instance.currentUser;
  }

  String getAdminName(String admin) {
    return admin.substring(admin.indexOf("_") + 1);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.arrow_back_ios_new)),
          elevation: 0,
          backgroundColor: Theme.of(context).primaryColor,
          centerTitle: true,
          title: const Text(
            "Search",
            style: TextStyle(
                fontSize: 25, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        body: Column(
          children: [
            Container(
              //  color: Theme.of(context).primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                      child: TextField(
                    controller: searchBarController,
                    style: const TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(
                              color: Color(
                                0xFFee7b64,
                              ),
                            )),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(
                                color: Color(
                                  0xFFee7b64,
                                ),
                                width: 2)),
                        hintText: "Search..",
                        hintStyle:
                            const TextStyle(color: Colors.black, fontSize: 16)),
                  )),
                  const SizedBox(
                    width: 5,
                  ),
                  GestureDetector(
                    onTap: () {
                      searchMethod();
                    },
                    child: Container(
                      width: 55,
                      height: 55,
                      decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20)),
                      child: const Icon(
                        Icons.search,
                        color: Colors.black,
                      ),
                    ),
                  )
                ],
              ),
            ),
            _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                    color: Theme.of(context).primaryColor,
                  ))
                : groupList(),
          ],
        ),
      ),
    );
  }

  searchMethod() async {
    if (searchBarController.text.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });

      DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
          .searchGroupName(searchBarController.text)
          .then((snapshot) {
        setState(() {
          searchSnapshot = snapshot;
          _isLoading = false;
          _hasUser = true;
        });
      });
    }
  }

  groupList() {
    return _hasUser
        ? ListView.builder(
            shrinkWrap: true,
            itemCount: searchSnapshot!.docs.length,
            itemBuilder: (context, index) {
              return gridTile(
                fullName,
                searchSnapshot!.docs[index]['groupId'],
                searchSnapshot!.docs[index]['groupName'],
                searchSnapshot!.docs[index]['admin'],
              );
            },
          )
        : Container();
  }

  Widget gridTile(
      String fullName, String groupId, String groupName, String admin) {
    //check user is already joined or not in group
    joinedOrNot(fullName, groupId, groupName, admin);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      leading: CircleAvatar(
        radius: 30,
        backgroundColor: Theme.of(context).primaryColor,
        child: Text(
          groupName.substring(0, 1).toUpperCase(),
          style:
              const TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
        ),
      ),
      title:
          Text(groupName, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(
        "Admin: ${getAdminName(admin)}",
      ),
      trailing: InkWell(
        onTap: () async {
          await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
              .joinGroup(groupId, fullName, groupName);
          if (_isJoined) {
            setState(() {
              _isJoined = !_isJoined;
            });
            if (mounted) {
              showSnackBar(context, Colors.green, "Successfully joined group");
            }
            Future.delayed(const Duration(seconds: 2), () {
              nextScreen(
                  context,
                  ChatPage(
                      groupId: groupId,
                      groupName: groupName,
                      fullName: fullName));
            });
          } else {
            setState(() {
              _isJoined = !_isJoined;
            });
            if (mounted) {
              showSnackBar(
                  context, Colors.redAccent, "Left the group $groupName");
            }
          }
        },
        child: _isJoined
            ? Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.black,
                    border: Border.all(color: Colors.white, width: 1)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: const Text(
                  "Joined",
                  style: TextStyle(color: Colors.white),
                ),
              )
            : Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Theme.of(context).primaryColor),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: const Text(
                  "Join now",
                  style: TextStyle(color: Colors.white),
                ),
              ),
      ),
    );
  }

  joinedOrNot(
      String fullName, String groupId, String groupName, String admin) async {
    await DatabaseService(uid: user!.uid)
        .isUserJoined(groupName, groupId, fullName)
        .then((value) {
      setState(() {
        _isJoined = value;
      });
    });
  }
}
