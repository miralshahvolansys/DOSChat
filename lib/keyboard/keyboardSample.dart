import 'dart:async';


import 'package:flutter/material.dart';

import 'virtual_keyboard.dart';

//void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Virtual Keyboard Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Virtual Keyboard Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  StreamController<String> _events;
  TextEditingController controller = TextEditingController();

  // Holds the text that user typed.
  String text = '';

  // True if shift enabled.
  bool shiftEnabled = false;

  // is true will show the numeric keyboard.
  bool isNumericMode = true;

  bool isShowKeyboard = false;
  final FocusNode fnOne = FocusNode();
  final FocusNode fntwo = FocusNode();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _events = new StreamController<String>();
    _events.add("");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Text(text, style: Theme.of(context).textTheme.display1),
            SizedBox(
              height: 20,
            ),
            GestureDetector(
              onTap: () {
                print("Tap event");
                FocusScope.of(context).requestFocus(fntwo);
                setState(() {
                  isShowKeyboard = true;
                });
              },
              child: AbsorbPointer(
                child: StreamBuilder(
                  stream: _events.stream,
                  builder: (BuildContext context, snapshot) {
                    controller.text = snapshot.data;
                    controller.selection = TextSelection.fromPosition(
                        TextPosition(offset: controller.text.length));
                    return TextField(
                        focusNode: fntwo,
                        onChanged: (text) {
                          print(text);
                          TextSelection previousSelection =
                              controller.selection;
                          controller.text = text;
                          controller.selection = previousSelection;
                        },
                        cursorWidth: 10,
                        controller: controller,
                        showCursor: true,
                        readOnly: true,
                        decoration:
                        InputDecoration(border: OutlineInputBorder()));
                  },
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              color: Colors.black,
              child: Visibility(
                  visible: isShowKeyboard,
                  child: VirtualKeyboard(
                      height: 300,
                      textColor: Colors.white,
//                  type: isNumericMode
//                      ? VirtualKeyboardType.chatAlphanumeric
//                      : VirtualKeyboardType.Alphanumeric,
                      type: VirtualKeyboardType.Alphanumeric,
                      onKeyPress: _onKeyPress)),
            )
          ],
        ),
      ),
    );
  }

  /// Fired when the virtual keyboard key is pressed.
  _onKeyPress(VirtualKeyboardKey key) {
    if (key.keyType == VirtualKeyboardKeyType.String) {
      text = text + (shiftEnabled ? key.capsText : key.text);
      _events.add(text);
    } else if (key.keyType == VirtualKeyboardKeyType.Action) {
      switch (key.action) {
        case VirtualKeyboardKeyAction.Backspace:
          if (text.length == 0) return;
          text = text.substring(0, text.length - 1);
          _events.add(text);
          break;
        case VirtualKeyboardKeyAction.Return:
          text = text + '\n';
          _events.add(text);
          break;
        case VirtualKeyboardKeyAction.Space:
          text = text + key.text;
          _events.add(text);
          break;
        case VirtualKeyboardKeyAction.Shift:
          shiftEnabled = !shiftEnabled;
          break;
        case VirtualKeyboardKeyAction.close:
          isShowKeyboard = false;
          setState(() {});
          break;
        default:
      }
    } else if (key.keyType == VirtualKeyboardKeyType.Hybrid) {
      switch (key.action) {
        case VirtualKeyboardKeyAction.escape:
          print("Escape");
          break;
        case VirtualKeyboardKeyAction.send:
          print("Send");
          break;
        default:
      }
    }
  }
}
