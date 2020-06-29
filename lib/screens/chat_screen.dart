import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:retrochat/models/chatmodel.dart';
import 'package:retrochat/api_manager/constant.dart';
import 'package:retrochat/provider/user_provider.dart';
import 'package:retrochat/utility/app_style.dart';
import 'package:retrochat/utility/common_methods.dart';
import 'package:retrochat/keyboard/virtual_keyboard.dart';
import 'package:intl/intl.dart';

import '../api_manager/constant.dart';

final database = FirebaseDatabase.instance;

class ChatScreen extends StatefulWidget {
  final User userMine;
  final User userOther;

  ChatScreen({@required this.userMine, @required this.userOther});

  @override
  _ChatScreenState createState() =>
      _ChatScreenState(userMine: this.userMine, userOther: this.userOther);
}

class _ChatScreenState extends State<ChatScreen> {
  final User userMine;
  final User userOther;

  _ChatScreenState({@required this.userMine, @required this.userOther});

  final _childSenderQuery = database.reference().child(keyTableMainChild);
  StreamSubscription<Event> _onChatAddedSenderSubscription;

  List<Chat> listChatAllData = [];
  List<Chat> listChatAllDataTempStore = [];
  List<Chat> listChatCommand = [];
  String keyChatRoom;

  ScrollController scrollListView = ScrollController();
  bool isShowKeyboard = true;
  bool isShownNormalReloadWithTextField = true;

  // Holds the text that user typed.
  String text = keyForMe;
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

    textEnterMessage.text = keyForMe;

//    focusNodeMessage.requestFocus();
    _events = StreamController<String>.broadcast();
    _events.add(keyForMe);
  }

  @override
  void dispose() {
    _events.close();
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
    _scrollToBottom();
  }



  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async => false,
    child:Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
                child: ListView.builder(
//                  physics: NeverScrollableScrollPhysics(),
              controller: scrollListView,
              itemCount: isShownNormalReloadWithTextField
                  ? (listChatAllData.length + listChatCommand.length + 1)
                  : 0,
              itemBuilder: (context, index) {
                if (index ==
                    (listChatAllData.length + listChatCommand.length)) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(15, 0, 15, 15),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          isShowKeyboard = true;
                          _scrollToBottom();
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
                              FocusScope.of(context).requestFocus(focusNodeMessage);
                              return TextField(
                                showCursor: true,
                                readOnly: true,
                                focusNode: focusNodeMessage,
                                cursorColor: Colors.white,
                                cursorWidth: 10,
                                keyboardType: TextInputType.multiline,
                                textInputAction: TextInputAction.done,
                                maxLines: null,
                                style:AppStyle.commandTextSyle,
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
                      "${listChatCommand[index - listChatAllData.length].sender_id == "" ? keyForCommandPrecision : keyForMe} ${listChatCommand[index - listChatAllData.length].message}",
                      style: AppStyle.commandTextSyle,
                    ),
                  );
                } else {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
                    child: Text(

                      "${ timestampToDateDisplayFormat(listChatAllData[index].timeStamp)} ${precisionChatText(listChatAllData[index], userMine, userOther)}",
                      style: TextStyle(
                          color: isMyMessage(
                                  listChatAllData[index], userMine, userOther)
                              ? AppStyle.keyboardbg
                              : Colors.lightGreen,
                          fontSize: 15.0),
                    ),
                  );
                }
              },
            )),
            Container(
              color: AppStyle.keyboardbg ,
              child: Visibility(
                  visible: isShowKeyboard,
                  child: VirtualKeyboard(
                      height: 300,
                      textColor: Colors.black54 ,
                      fontSize: 23,
                      isChatScreen: true,
//                  type: isNumericMode
//                      ? VirtualKeyboardType.chatAlphanumeric
//                      : VirtualKeyboardType.Alphanumeric,
                      type: VirtualKeyboardType.Alphanumeric,
                      onKeyPress: _onKeyPress)),
            ),
          ],
        ),
      ),
    ),);
  }

  _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 40), () {
      setState(() {
        scrollListView.animateTo(
          scrollListView.position.maxScrollExtent,
          duration: Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
        focusNodeMessage.requestFocus();
      });
    });
  }

  /// Fired when the virtual keyboard key is pressed.
  _onKeyPress(VirtualKeyboardKey key) {
    if (key.keyType == VirtualKeyboardKeyType.String) {
      if (listChatCommand.length > 0) {
        if (text.length < (keyForMe.length + 1)) {
          text = text + (shiftEnabled ? key.capsText : key.text);
        }
      } else {
        text = text + (shiftEnabled ? key.capsText : key.text);
      }
      _events.add(text);
    } else if (key.keyType == VirtualKeyboardKeyType.Action) {
      switch (key.action) {
        case VirtualKeyboardKeyAction.Backspace:
          if (text.length == keyForMe.length) return;
          text = text.substring(0, text.length - 1);
          _events.add(text);
          break;
        case VirtualKeyboardKeyAction.Return:
          if (listChatCommand.length > 0) return;
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
          text = keyForMe;
          _events.add(text);

          setState(() {
            textEnterMessage.text = keyForMe;
            listChatCommand.add(Chat(
                "", keyForExit, "${DateTime.now().millisecondsSinceEpoch}"));
            _scrollToBottom();
          });
          break;
        case VirtualKeyboardKeyAction.send:
          getSendButtonFromKeyboard();
          break;
        default:
      }
    }
  }

  void getSendButtonFromKeyboard() {
    String mainValue = text;
    mainValue = mainValue.substring(keyForMe.length, text.length).trim();

    if (mainValue.length > 0) {
      text = keyForMe;
      _events.add(text);
      if (listChatCommand.length > 0) {
        switch (mainValue.toLowerCase()) {
          case "y":
            Navigator.pop(context);
            return;
            break;
          case "n":
            isShownNormalReloadWithTextField = false;
            listChatAllDataTempStore = List.from(listChatAllData);
            listChatCommand = [];
            listChatAllData = [];
            break;
          default:
            {
              listChatCommand.add(Chat("xyz", mainValue,
                  "${DateTime.now().millisecondsSinceEpoch}"));
              listChatCommand.add(Chat("", keyForCommandNotFound,
                  "${DateTime.now().millisecondsSinceEpoch}"));
              listChatCommand.add(Chat(
                  "", keyForExit, "${DateTime.now().millisecondsSinceEpoch}"));
            }
            break;
        }
      } else {
        sendData(Chat(userMine.userId, mainValue,
            "${DateTime.now().millisecondsSinceEpoch}"));
      }

      setState(() {
        textEnterMessage.text = keyForMe;
        if (isShownNormalReloadWithTextField) {
          _scrollToBottom();
        } else {
          Future.delayed(const Duration(milliseconds: 50), () {
            setState(() {
              isShownNormalReloadWithTextField = true;
              listChatAllData = List.from(listChatAllDataTempStore);
              _scrollToBottom();
            });
          });
        }
      });
    }
  }
}
