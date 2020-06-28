import 'dart:ffi';

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:retrochat/screens/command_screen.dart';

class Splash extends StatefulWidget {

  @override
  _SplashState createState() => _SplashState();
  static const routeName = '/Splash';
}

class _SplashState extends State<Splash> {
  Timer _timer;
  int _start = 4;

  String _loadingText = "Loading Dos Chat";
  String _loadingTextSuffix = "";
  bool _visible = false;

  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) => setState(
        () {
          _visible = !_visible;

          if (_start == 9) {
            _loadingTextSuffix = ".";
          } else if (_start == 8) {
            _loadingTextSuffix = "..";
          } else if (_start == 7) {
            _loadingTextSuffix = "...";
          } else if (_start == 6) {
            _loadingTextSuffix = "....";
          } else if (_start == 5) {
            _loadingTextSuffix = ".....";
          } else if (_start == 4) {
            _loadingTextSuffix = ".";
          } else if (_start == 3) {
            _loadingTextSuffix = "..";
          } else if (_start == 2) {
            _loadingTextSuffix = "...";
          } else if (_start == 1) {
            _loadingTextSuffix = "....";
          }

          if (_start < 1) {
            timer.cancel();
            Navigator.popAndPushNamed(context, CommandScreen.routeName);
          } else {
            _start = _start - 1;
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Container(
          width: double.infinity,
          child: Center(
              child: AnimatedOpacity(
            opacity: _visible ? 1.0 : 0.7,
            duration: Duration(milliseconds: 500),
            child: Text(
              _loadingText + _loadingTextSuffix,
              style: TextStyle(fontSize: 22, color: (Colors.grey),fontFamily: 'Perfect DOS VGA'),

              /*Text(
                'Roboto Mono sample',
                style: TextStyle(fontFamily: 'RobotoMono'),
              );*/
              textDirection: TextDirection.ltr,
            ),
          ))),
    );
  }
}
