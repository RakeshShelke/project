import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final String uid;

  DatabaseService({required this.uid});

  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection("Users");

  final CollectionReference groupCollection =
      FirebaseFirestore.instance.collection("Group");

  Future savingData(String fullName, String email) async {
    return await userCollection.doc(uid).set({
      "fullName": fullName,
      "email": email,
      "uid": uid,
      "Group": [],
      "profilePic": ""
    });
  }

  //get UsersData
  Future getUserData(String email) async {
    QuerySnapshot snapshot =
        await userCollection.where("email", isEqualTo: email).get();
    return snapshot;
  }

  //get UsersGroups
  getUserGroups() async {
    return userCollection.doc(uid).snapshots();
  }

  //create the group
  Future createGroup(String fullName, String id, String groupName) async {
    DocumentReference documentReference = await groupCollection.add({
      "groupName": groupName,
      "groupIcon": "",
      "admin": "${id}_$fullName",
      "members": [],
      "groupId": "",
      "recentMessage": "",
      "recentMessageSender": "",
    });

    //update members
    await documentReference.update({
      "members": FieldValue.arrayUnion(["${uid}_$fullName"]),
      "groupId": documentReference.id,
    });

    DocumentReference userReference = userCollection.doc(uid);
    return userReference.update({
      "Group": FieldValue.arrayUnion(["${documentReference.id}_$groupName"]),
    });
  }

  //get Chat
  getChat(String groupId) async {
    return groupCollection
        .doc(groupId)
        .collection("message")
        .orderBy("time", descending: true)
        .snapshots();
  }

  Future getGroupAdmin(String groupId) async {
    DocumentReference documentReference = groupCollection.doc(groupId);
    DocumentSnapshot snapshot = await documentReference.get();
    return snapshot['admin'];
  }

  getGroupMembers(groupId) async {
    return groupCollection.doc(groupId).snapshots();
  }

  //search group
  searchGroupName(String groupName) {
    return groupCollection.where("groupName", isEqualTo: groupName).get();
  }

  //check userJoined

  Future<bool> isUserJoined(
      String groupName, String groupId, String fullName) async {
    DocumentReference documentReference = userCollection.doc(uid);
    DocumentSnapshot snapshot = await documentReference.get();

    List<dynamic> groups = await snapshot['Group'];
    if (groups.contains("${groupId}_$groupName")) {
      return true;
    } else {
      return false;
    }
  }

  //group joining
  Future joinGroup(String groupId, String fullName, String groupName) async {
    DocumentReference userDocumentReference = userCollection.doc(uid);
    DocumentReference groupReference = groupCollection.doc(groupId);

    DocumentSnapshot snapshot = await userDocumentReference.get();
    List<dynamic> groups = await snapshot['Group'];

    if (groups.contains("${groupId}_$groupName")) {
      await userDocumentReference.update({
        "Group": FieldValue.arrayRemove(["${groupId}_$groupName"])
      });

      await groupReference.update({
        "members": FieldValue.arrayRemove(["${uid}_$fullName"])
      });
    } else {
      await userDocumentReference.update({
        "Group": FieldValue.arrayUnion(["${groupId}_$groupName"])
      });

      await groupReference.update({
        "members": FieldValue.arrayUnion(["${uid}_$fullName"])
      });
    }
  }

  sendMessage(String groupId, Map<String, dynamic> chatMessageData) async {
    groupCollection.doc(groupId).collection('message').add(chatMessageData);
    groupCollection.doc(groupId).update({
      "recentMessage": chatMessageData['message'],
      "recentMessageSender": chatMessageData['sender'],
      "recentMessageTime": chatMessageData['time'].toString(),
    });
  }
}
