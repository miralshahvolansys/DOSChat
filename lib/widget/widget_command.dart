// AUTHENTICATION WIDGET
import 'package:flutter/material.dart';
import 'package:retrochat/utility/app_style.dart';
import 'dart:async';

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
        style: AppStyle.commandTextSyle,
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
          style: AppStyle.commandTextSyle,
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
  bool obscureText = false,
  StreamController<String> event,
  FocusNode focusNode,
  Function(String) onSubmitted,
  Function onTap,
}) {
  return Row(
    children: <Widget>[
      Text(
        '${command.prefixText}',
        style: AppStyle.commandTextSyle,
      ),
      SizedBox(
        width: 8.0,
      ),
      Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: AbsorbPointer(
            child: StreamBuilder(
              stream: event.stream,
              builder: (sbContext, snapshot) {
                controller.text = snapshot.data;
                controller.selection = TextSelection.fromPosition(
                  TextPosition(offset: controller.text.length),
                );
                return TextField(
                  controller: controller,
                  focusNode: focusNode,
                  showCursor: true,
                  readOnly: true,
                  cursorWidth: 8,
                  cursorColor: Colors.white,
                  onSubmitted: onSubmitted,
                  autocorrect: false,
                  obscureText: obscureText,
                  textCapitalization: TextCapitalization.none,
                  style: AppStyle.commandTextSyle,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    ],
  );
}

//TextStyle commandTextStyle() {
//  return TextStyle(
//    color: AppStyle.keyboardbg,
//    fontSize: 15.0,
//    fontFamily: 'Perfect DOS VGA',
//  );
//}
