import 'package:flutter/material.dart';
import 'package:retrochat/utility/app_style.dart';

class HelpWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            height: 8,
          ),
          HelpChildWidget(
            text:
                'DOSChat, version 1.0.0-beta \nThese commands are defined internally. Type \'help\' to see this list.',
            leftPadding: EdgeInsets.only(left: 0),
          ),
          /*HelpChildWidget(
            text:
                'These shell commands are defined internally.  Type `help` to see this list.',
            leftPadding: EdgeInsets.only(left: 0),
          ),*/
          SizedBox(
            height: 12,
          ),
          HelpChildWidget(
            text: 'help -  Provide more information on the commands.',
            leftPadding: EdgeInsets.only(left: 15),
          ),
          HelpChildWidget(
            text: 'signin - Sign in using the username.',
            leftPadding: EdgeInsets.only(left: 15),
          ),
          HelpChildWidget(
            text: 'signup - Create a new user.',
            leftPadding: EdgeInsets.only(left: 15),
          ),
          HelpChildWidget(
            text: 'ls - Display the list of users.',
            leftPadding: EdgeInsets.only(left: 15),
          ),
          HelpChildWidget(
            text:
                'start chat - Start chat with user. e.g. start chat (username)',
            leftPadding: EdgeInsets.only(left: 15),
          ),
          HelpChildWidget(
            text:
                'clear -  Use to remove all previous commands and output from screen.',
            leftPadding: EdgeInsets.only(left: 15),
          ),
          HelpChildWidget(
            text: 'exit - Logout current user.',
            leftPadding: EdgeInsets.only(left: 15),
          ),
        ],
      ),
    );
  }
}

class HelpChildWidget extends StatelessWidget {
  final String text;
  final EdgeInsets leftPadding;
  const HelpChildWidget({Key key, this.text, this.leftPadding})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 8,
        ),
        Padding(
          padding: leftPadding,
          child: Text(
            text,
            textAlign: TextAlign.left,
            style: AppStyle.commandTextSyle,
          ),
        ),
      ],
    );
  }
}
