import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class User {
  final String userId;
  final String userName;

  User({
    this.userId,
    this.userName,
  });
}

class UserList with ChangeNotifier {
  List<User> _userList = [];
  List<User> get userList {
    return [..._userList];
  }

  Future<void> fetchUserList() async {
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
    } catch (error) {
      throw error;
    }
  }
}
