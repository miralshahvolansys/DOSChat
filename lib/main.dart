import 'package:retrochat/provider/auth_provider.dart';
import 'package:retrochat/screens/command_screen.dart';
import 'package:retrochat/screens/splash_screen.dart';
import 'package:retrochat/provider/user_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

///added this to check all dependancies are downloaded or not

void main() {
  runApp(
    MyApp(),
  );
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  bool isLoggedIn = false;
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: AuthProvider(),
        ),
        ChangeNotifierProvider.value(
          value: UserList(),
        )
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.deepOrange,
          accentColor: Colors.deepOrangeAccent,
          fontFamily: 'Perfect DOS VGA',
          textTheme: TextTheme(
            headline6: TextStyle(
              fontFamily: 'Anton',
            ),
          ),
        ),
        home: StreamBuilder(
          stream: FirebaseAuth.instance.onAuthStateChanged,
          builder: (sbContext, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Splash();
              /* Center(
                child: Scaffold(
                  body: Text('Loading...'),
                ),
              );*/
            } else {
              print('HAS DATA ${snapshot.hasData}');
              isLoggedIn = snapshot.hasData;
              return Splash();
              /*CommandScreen(
                isLoggedIn: snapshot.hasData,
              );*/
            }
          },
        ),
        debugShowCheckedModeBanner: false,
        routes: {
          CommandScreen.routeName: (cntx) => CommandScreen(isLoggedIn: isLoggedIn,),
          Splash.routeName: (cntx) => Splash(),
        },
      ),
    );
  }
}
