import 'dart:ffi';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:retrochat/provider/auth_provider.dart';
import 'dart:async';
import 'package:retrochat/screens/command_screen.dart';

class Splash extends StatefulWidget {
  final bool isLogin;
  Splash({this.isLogin});

  @override
  _SplashState createState() => _SplashState();
  static const routeName = '/Splash';
}

class _SplashState extends State<Splash> {
  Timer _timer;
  int _start = 5;

  String _loadingText = "Loading DOSChat";
  String _loadingTextSuffix = "";
  bool _visible = false;

  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) => setState(
        () {
          _visible = !_visible;

          if (_start == 5) {
            _loadingTextSuffix = ".";
          } else if (_start == 4) {
            _loadingTextSuffix = "..";
          } else if (_start == 3) {
            _loadingTextSuffix = "...";
          } else if (_start == 2) {
            _loadingTextSuffix = "....";
          } else if (_start == 1) {
            _loadingTextSuffix = ".....";
          }

          if (_start < 1) {
            timer.cancel();
            _loadingText = "";
            _loadingTextSuffix = "";
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (ctx) {
                  return CommandScreen(
                    isLoggedIn: widget.isLogin,
                  );
                },
              ),
            );
            //Navigator.popAndPushNamed(context, CommandScreen.routeName);
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
    MediaQueryData queryData;
    queryData = MediaQuery.of(context);
    return Material(
      type: MaterialType.transparency,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            width: queryData.size.width / 4,
          ),
          AnimatedOpacity(
            opacity: _visible ? 1.0 : 0.7,
            duration: Duration(milliseconds: 500),
            child: Text(
              _loadingText + _loadingTextSuffix,
              style: Theme.of(context).textTheme.headline6,
              textDirection: TextDirection.ltr,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
      /* child: Center(
          child: Expanded(flex: ,
            child: AnimatedOpacity(
              opacity: _visible ? 1.0 : 0.7,
              duration: Duration(milliseconds: 500),
              child: Text(
                _loadingText + _loadingTextSuffix,
                style: Theme.of(context).textTheme.headline6,
                textDirection: TextDirection.ltr,
                textAlign: TextAlign.left,
              ),
            ),
          )
      ),*/
    );
  }
}
