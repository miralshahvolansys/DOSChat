import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class User {
  final String userId;
  final String userName;
  final int timeStamp;

  User({
    this.userId,
    this.userName,
    this.timeStamp,
  });
}

class UserList with ChangeNotifier {
  List<User> _userList = [];
  List<User> get userList {
    return [..._userList];
  }

  Future<String> fetchUserList() async {
    final database = FirebaseDatabase.instance;
    try {
      await database.reference().child('users').once().then((snapshot) {
        final values = snapshot.value;
        if (snapshot.value != null) {
          _userList.clear();
          values.forEach((userKey, userData) {
            _userList.add(User(
              userId: userData['user_id'],
              userName: userData['username'],
            ));
          });
        }
      });
      String userNameList = '';
      _userList.forEach((item) {
        userNameList += item.userName + " ";
      });
      return Future.value(userNameList);
    } catch (error) {
      throw error;
    }
  }
}
