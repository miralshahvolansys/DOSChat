import 'package:flutter/material.dart';
import 'package:retrochat/utility/app_style.dart';

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
          color: AppStyle.keyboardbg,
          wordSpacing: 10,
          height: 1.7,
          fontSize: 15.0,
          fontFamily: 'Perfect DOS VGA',
        ),
        text: userNameList,
      ),
    );
  }
}
