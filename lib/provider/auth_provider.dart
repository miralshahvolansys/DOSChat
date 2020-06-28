import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:retrochat/provider/user_provider.dart';

import '../api_manager/http_exception.dart';
import '../api_manager/constant.dart' as CONSTANT;

class AuthProvider with ChangeNotifier {
  final _authInstance = FirebaseAuth.instance;
  AuthResult _authResult;
  FirebaseUser _authUser;
  List<User> _users = [];

  FirebaseAuth get authInstance {
    return _authInstance;
  }

  String _getEmailFromUsername(String username) {
    return '$username@gmail.com';
  }

  List<User> get userList {
    return [..._users];
  }

  Future<User> getLoginUser() async {
    try {
      final username = await getUsername();
      final user = _users.firstWhere((element) =>
          element.userName.toLowerCase() == username.toLowerCase());
      return user;
    } catch (err) {
      return null;
    }
  }

  String get userNames {
    String userNameList = '';
    _users.forEach((item) {
      userNameList += item.userName + " ";
    });
    return userNameList;
  }

  Future<String> getUsername() async {
    if (_authUser == null) {
      _authUser = await authInstance.currentUser();
    }
    final username = _authUser.email.split('@').first;
    return username;
  }

  Future<void> getUserList() async {
    final userRef =
        FirebaseDatabase.instance.reference().child(CONSTANT.firebaseNodeUser);
    try {
      final snapshot = await userRef.once();
      if (snapshot.value != null) {
        final values = snapshot.value;
        values.forEach((userKey, userData) {
          _users.add(User(
            userId: userData['user_id'],
            userName: userData['username'],
            timeStamp: userData['timestamp'],
          ));
        });
      }

      _users.sort((a, b) => a.timeStamp.compareTo(b.timeStamp));
      userRef
          .orderByChild('timestamp')
          .startAt(_users.last.timeStamp + 1)
          .onChildAdded
          .listen(_addNewUser);
    } catch (error) {
      throw error;
    }
  }

  void _addNewUser(Event event) {
    final user = _getUserFromSnapshot(event.snapshot.value);

    print('NEW USER ADDED :: ${user.userName}');
    _users.add(user);
  }

  User _getUserFromSnapshot(dynamic values) {
    return User(
      userId: values['user_id'],
      userName: values['username'],
      timeStamp: values['timestamp'],
    );
  }

  Future<void> signIn({username: String, password: String}) async {
    try {
      _authResult = await _authInstance.signInWithEmailAndPassword(
        email: _getEmailFromUsername(username),
        password: password,
      );
      if (_authResult != null) {
        print(_authResult);
        notifyListeners();
      }
    } catch (err) {
      throw HTTPException(errorMessage: 'Invalid credentials!');
    }
  }

  Future<void> signUp({username: String, password: String}) async {
    AuthResult authResult;

    try {
      authResult = await _authInstance.createUserWithEmailAndPassword(
        email: _getEmailFromUsername(username),
        password: password,
      );

      if (authResult != null) {
        try {
          _storeUserInFirebase(userID: authResult.user.uid, username: username);
          notifyListeners();
        } catch (err) {
          throw HTTPException(errorMessage: err.toString());
        }
      }
    } catch (err) {
      if (err.code == 'ERROR_EMAIL_ALREADY_IN_USE') {
        await signIn(username: username, password: password);
      } else {
        throw HTTPException(errorMessage: err.toString());
      }
    }
  }

  Future<void> signOut() async {
    _authUser = null;
    await FirebaseAuth.instance.signOut();
  }

  Future<void> _storeUserInFirebase({String userID, String username}) async {
    final firebaseRef = FirebaseDatabase.instance.reference();
    try {
      await firebaseRef.child(CONSTANT.firebaseNodeUser).child(userID).set(
        {
          'username': username,
          'user_id': userID,
          'timestamp': ServerValue.timestamp,
        },
      );
    } catch (err) {
      throw err;
    }
  }
}
