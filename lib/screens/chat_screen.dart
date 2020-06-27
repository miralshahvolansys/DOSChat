import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:retrochat/provider/Model/chatmodel.dart';
import 'package:retrochat/api_manager/constant.dart';
import 'package:retrochat/provider/user_provider.dart';
import 'package:retrochat/utility/common_methods.dart';
import 'package:retrochat/keyboard/virtual_keyboard.dart';

final database = FirebaseDatabase.instance;

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  User userMine = User(
      userId: "1YTHlthZVQPxzSFlIN9afG7dUSU2",
      userName: "mirant.patel@gmail.com");
  User userOther = User(
      userId: "G2iAxPZqlwXi348vUfxcCJ3dQBu1",
      userName: "ankit_khatri@gmail.com");

  final _childSenderQuery = database.reference().child(keyTableMainChild);
  StreamSubscription<Event> _onChatAddedSenderSubscription;

  List<Chat> listChatAllData = [];
  List<Chat> listChatCommand = [];
  String keyChatRoom;

  ScrollController scrollListView = ScrollController();
  bool isShowKeyboard = false;

  // Holds the text that user typed.
  String text = '';
  StreamController<String> _events;

  // True if shift enabled.
  bool shiftEnabled = false;

  TextEditingController textEnterMessage = TextEditingController();
  FocusNode focusNodeMessage = FocusNode();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    keyChatRoom = createKeyForChatRoom([userMine, userOther]);

    _onChatAddedSenderSubscription =
        _childSenderQuery.child(keyChatRoom).onChildAdded.listen(_getReadData);

    textEnterMessage.text = "Me:> ";

    _events = StreamController<String>.broadcast();
    _events.add("MirantMiker:>");
  }

  @override
  void dispose() {
    _onChatAddedSenderSubscription.cancel();
    super.dispose();
  }

  void sendData(Chat objChat) {
    _childSenderQuery.child(keyChatRoom).push().set(objChat.toMap()).then((_) {
//      print(objChat.toMap());
    });
  }

  void _getReadData(Event event) {
    Chat objChat = Chat.fromSnapshot(event.snapshot);
//    print("Mirant${event.snapshot.value}");
    setState(() {
      listChatAllData.add(objChat);
    });
    Future.delayed(const Duration(milliseconds: 50), () {
      setState(() {
        scrollListView.jumpTo(scrollListView.position.maxScrollExtent);
//        focusNodeMessage.requestFocus();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
//      appBar: AppBar(
//        actions: <Widget>[
//          FlatButton(
//              onPressed: () {
//                setState(() {
////                  focusNodeMessage.unfocus();
//                  listChatCommand.add(Chat(
//                      "",
//                      "Do you want to exit from chat(y/n)?",
//                      DateTime.now().millisecondsSinceEpoch));
//                  Future.delayed(const Duration(milliseconds: 50), () {
//                    setState(() {
//                      scrollListView
//                          .jumpTo(scrollListView.position.maxScrollExtent);
////                      focusNodeMessage.requestFocus();
//                    });
//                  });
//                });
//              },
//              child: Text("Exit")),
//        ],
//      ),
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
                child: ListView.builder(
//                  physics: NeverScrollableScrollPhysics(),
              controller: scrollListView,
              itemCount: (listChatAllData.length + listChatCommand.length + 1),
              itemBuilder: (context, index) {
                if (index ==
                    (listChatAllData.length + listChatCommand.length)) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(15, 0, 15, 15),
                    child: GestureDetector(
                      onTap: () {
                        FocusScope.of(context).requestFocus(focusNodeMessage);
                        setState(() {
                          isShowKeyboard = true;
                        });
                      },
                      child: AbsorbPointer(
                        child: StreamBuilder(
                            stream: _events.stream,
                            builder: (BuildContext context, snapshot) {
                              textEnterMessage.text = snapshot.data;
                              textEnterMessage.selection =
                                  TextSelection.fromPosition(TextPosition(
                                      offset: textEnterMessage.text.length));
                              return TextField(
                                showCursor: true,
                                readOnly: true,
                                focusNode: focusNodeMessage,
                                cursorColor: Colors.white,
                                cursorWidth: 10,
                                keyboardType: TextInputType.multiline,
                                textInputAction: TextInputAction.done,
                                maxLines: null,
                                maxLength: listChatCommand.length > 0 ? 6 : null,
                                style: TextStyle(
                                    color: Colors.white, fontSize: 18.0),
                                controller: textEnterMessage,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                ),
                              );
                            }),
                      ),
                    ),
                  );
                } else if (index >= listChatAllData.length) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
                    child: Text(
                      "${listChatCommand[index - listChatAllData.length].sender_id == "" ? "C:/>" : "Me:>"} ${listChatCommand[index - listChatAllData.length].message}",
                      style: TextStyle(color: Colors.white, fontSize: 18.0),
                    ),
                  );
                } else {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
                    child: Text(
                      precisionChatText(
                          listChatAllData[index], userMine, userOther),
                      style: TextStyle(
                          color: isMyMessage(
                                  listChatAllData[index], userMine, userOther)
                              ? Colors.white
                              : Colors.lightGreen,
                          fontSize: 18.0),
                    ),
                  );
                }
              },
            )),
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
            ),
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
