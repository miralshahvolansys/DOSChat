import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class LoadingAnimation extends StatelessWidget {
  final String nonAnimatedText;
  final String animatedText;
  LoadingAnimation(
    this.nonAnimatedText,
    this.animatedText,
  );
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Row(
        children: <Widget>[
          Text(
            nonAnimatedText,
            style: TextStyle(
              fontSize: 18.0,
              color: Colors.white,
            ),
          ),
          TyperAnimatedTextKit(
              speed: Duration(milliseconds: 650),
              text: [
                animatedText,
              ],
              textStyle: TextStyle(
                fontSize: 18.0,
                color: Colors.white,
              ),
              textAlign: TextAlign.start,
              alignment: AlignmentDirectional.topStart // or Alignment.topLeft
              ),
        ],
      ),
    );
  }
}
