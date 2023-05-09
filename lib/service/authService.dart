import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_chat_app/helper/helperFunction.dart';
import 'package:firebase_chat_app/service/databaseService.dart';

class AuthService {
  final FirebaseAuth auth = FirebaseAuth.instance;


  Future loginUserWithEmailAndPassword(String email, String password) async {
    try {
      User user = (await auth.signInWithEmailAndPassword(
              email: email, password: password))
          .user!;
      if (user != null) {
        return true;
      }
    } on FirebaseAuthException catch (e) {
      print(e.toString());
      return e.message;
    }
  }

  Future registerUserWithEmailAndPassword(
      String fullName, String email, String password) async {
    try {
      User user = (await auth.createUserWithEmailAndPassword(
              email: email, password: password))
          .user!;

      if (user != null) {
        //data store
        await DatabaseService(uid: user.uid).savingData(fullName, email);

        return true;
      }
    } on FirebaseAuthException catch (e) {
      print(e.toString());
      return e.message;
    }
  }

  Future signOut() async {
    try {
      HelperFunction.saveUserLogged(false);
      HelperFunction.saveUserEmail("");
      HelperFunction.saveUserName("");
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      return null;
    }
  }


}
