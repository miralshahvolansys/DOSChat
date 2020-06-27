import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import '../api_manager/http_exception.dart';
import '../api_manager/constant.dart' as CONSTANT;

class AuthProvider with ChangeNotifier {
  final _authInstance = FirebaseAuth.instance;
  AuthResult _authResult;
  FirebaseUser _authUser;

  FirebaseAuth get authInstance {
    return _authInstance;
  }

  String _getEmailFromUsername(String username) {
    return '$username@gmail.com';
  }

  Future<String> getUsername() async {
    if (_authUser == null) {
      _authUser = await authInstance.currentUser();
    }
    final username = _authUser.email.split('@').first;
    return username;
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
        },
      );
    } catch (err) {
      throw err;
    }
  }
}
