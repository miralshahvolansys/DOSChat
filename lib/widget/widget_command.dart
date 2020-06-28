// AUTHENTICATION WIDGET
import 'package:flutter/material.dart';

import '../models/command.dart';

Widget getWidgetTextField(
    {ModelCommand command,
    bool obscureText = false,
    TextEditingController controller,
    Function(String) onSubmitted}) {
  return Row(
    children: <Widget>[
      Text(
        '${command.prefixText}',
        style: commandTextStyle(),
      ),
      SizedBox(
        width: 8.0,
      ),
      Expanded(
        child: TextField(
          controller: controller,
          showCursor: true,
          cursorWidth: 8,
          cursorColor: Colors.white,
          onSubmitted: onSubmitted,
          obscureText: obscureText,
          enabled: command.allowEditing,
          autocorrect: false,
          textCapitalization: TextCapitalization.none,
          style: commandTextStyle(),
          decoration: InputDecoration(
            border: InputBorder.none,
          ),
        ),
      )
    ],
  );
}

// COMMAND TEXTFIELD WIDGET
Widget getCommandTextField({
  ModelCommand command,
  TextEditingController controller,
  Function(String) onSubmitted,
}) {
  return Row(
    children: <Widget>[
      Text(
        '${command.prefixText}',
        style: commandTextStyle(),
      ),
      SizedBox(
        width: 8.0,
      ),
      Expanded(
        child: TextField(
          controller: controller,
          showCursor: true,
          cursorWidth: 8,
          cursorColor: Colors.white,
          onSubmitted: onSubmitted,
          autocorrect: false,
          textCapitalization: TextCapitalization.none,
          style: commandTextStyle(),
          decoration: InputDecoration(
            border: InputBorder.none,
          ),
        ),
      )
    ],
  );
}

TextStyle commandTextStyle() {
  return TextStyle(
    color: Colors.white,
    fontSize: 12.0,
  );
}
