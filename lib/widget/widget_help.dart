import 'package:flutter/material.dart';

class HelpWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          HelpChildWidget(
            text: 'GNU bash, version 1.0.0-beta',
            leftPadding: EdgeInsets.only(left: 0),
          ),
          HelpChildWidget(
            text:
                'These shell commands are defined internally.  Type `help` to see this list.',
            leftPadding: EdgeInsets.only(left: 0),
          ),
          SizedBox(
            height: 12,
          ),
          HelpChildWidget(
            text: 'ls - Display the list of users.',
            leftPadding: EdgeInsets.only(left: 15),
          ),
          HelpChildWidget(
            text: 'ls - Display the list of users.',
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
        Padding(
          padding: leftPadding,
          child: Text(
            text,
            textAlign: TextAlign.left,
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(
          height: 8,
        ),
      ],
    );
  }
}
