import 'package:flutter/material.dart';

class UserListWidget extends StatelessWidget {
  final String userNameList;
  UserListWidget({
    @required this.userNameList,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: TextStyle(
          color: Colors.white,
          wordSpacing: 10,
          height: 1.7,
          fontSize: 12.0,
          fontFamily: 'Perfect DOS VGA',
        ),
        text: userNameList,
      ),
    );
  }
}
