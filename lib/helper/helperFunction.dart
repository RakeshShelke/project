import 'package:shared_preferences/shared_preferences.dart';

class HelperFunction {
  //save the data In preference

  static String userLoggedKey = "LOGGEDKEY";
  static String userNameKey = "NAMEKEY";
  static String userEmailKey = "EMAILKEY";

  //save data
  static Future<bool?> saveUserLogged(bool isUserLoggedIn) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    return sharedPreferences.setBool(userLoggedKey, isUserLoggedIn);
  }

  static Future<bool?> saveUserName(String userName) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    return sharedPreferences.setString(userNameKey, userName);
  }

  static Future<bool?> saveUserEmail(String userEmail) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    return sharedPreferences.setString(userEmailKey, userEmail);
  }

  //get data
  static Future<bool?> getUserLogged() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getBool(userLoggedKey);

  }

  static Future<String?> getUserEmail() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    return sharedPreferences.getString(userEmailKey);
  }

  static Future<String?> getUserName() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString(userNameKey);
  }
}
