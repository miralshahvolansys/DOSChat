import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:retrochat/models/chatmodel.dart';
import 'package:retrochat/api_manager/constant.dart';
import 'package:retrochat/provider/user_provider.dart';
import 'package:retrochat/utility/common_methods.dart';
import 'package:retrochat/keyboard/virtual_keyboard.dart';

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

  double yPosition = 0;

  double scrollHeight = 50;
  double scrollWidth = 25;

  double totalHeightScrollMain = 0;
  double scrollContentSizeMain = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    keyChatRoom = createKeyForChatRoom([userMine, userOther]);

    _onChatAddedSenderSubscription =
        _childSenderQuery.child(keyChatRoom).onChildAdded.listen(_getReadData);

    textEnterMessage.text = keyForMe;

    focusNodeMessage.requestFocus();
    _events = StreamController<String>.broadcast();
    _events.add(keyForMe);

    getManageSize();
  }

  void getManageSize() {
    Future.delayed(const Duration(milliseconds: 50), () {
      scrollContentSizeMain = (totalHeightScrollMain + scrollListView.position.maxScrollExtent);
      double sizeGet =
          scrollHeightManage(totalHeightScrollMain, scrollContentSizeMain);
      setState(() {
        scrollHeight = sizeGet > 15 ? sizeGet : 15;
        yPosition = totalHeightScrollMain - scrollHeight;
      });
    });
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
    Future.delayed(const Duration(milliseconds: 50), () {
      setState(() {
        scrollListView.jumpTo(scrollListView.position.maxScrollExtent - (isShowKeyboard ? 300 : 0));
        focusNodeMessage.requestFocus();
        getManageSize();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Expanded(
                      child: ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
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
                                Future.delayed(const Duration(milliseconds: 50),
                                    () {
                                  setState(() {
                                    scrollListView.jumpTo(scrollListView
                                        .position.maxScrollExtent);
                                    focusNodeMessage.requestFocus();
                                    getManageSize();
                                  });
                                });
                              });
                            },
                            child: AbsorbPointer(
                              child: StreamBuilder(
                                  stream: _events.stream,
                                  builder: (BuildContext context, snapshot) {
                                    textEnterMessage.text = snapshot.data;
                                    textEnterMessage.selection =
                                        TextSelection.fromPosition(TextPosition(
                                            offset:
                                                textEnterMessage.text.length));
                                    return TextField(
                                      showCursor: true,
                                      readOnly: true,
                                      focusNode: focusNodeMessage,
                                      cursorColor: Colors.white,
                                      cursorWidth: 10,
                                      keyboardType: TextInputType.multiline,
                                      textInputAction: TextInputAction.done,
                                      maxLines: null,
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
                            "${listChatCommand[index - listChatAllData.length].sender_id == "" ? keyForCommandPrecision : keyForMe}${listChatCommand[index - listChatAllData.length].message}",
                            style:
                                TextStyle(color: Colors.white, fontSize: 18.0),
                          ),
                        );
                      } else {
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
                          child: Text(
                            precisionChatText(
                                listChatAllData[index], userMine, userOther),
                            style: TextStyle(
                                color: isMyMessage(listChatAllData[index],
                                        userMine, userOther)
                                    ? Colors.white
                                    : Colors.lightGreen,
                                fontSize: 18.0),
                          ),
                        );
                      }
                    },
                  )),
                  Container(
                    width: scrollWidth,
                    color: Colors.grey.shade400,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        GestureDetector(
                          onTap: () {
                            getUpDownMethod(
                                true,
                                totalHeightScrollMain,
                                scrollListView.position.maxScrollExtent,
                                scrollHeight,
                                yPosition);
                          },
                          child: Container(
                            alignment: Alignment.center,
                            height: scrollWidth,
                            width: scrollWidth,
                            color: Colors.grey.shade700,
                            child: Icon(Icons.arrow_drop_up),
                          ),
                        ),
                        Expanded(child: LayoutBuilder(builder:
                            (BuildContext context, BoxConstraints constraints) {
                          totalHeightScrollMain = constraints.maxHeight;
                          return Stack(
                            children: <Widget>[
                              Positioned(
                                top: yPosition,
                                child: GestureDetector(
                                  onPanUpdate: (tapInfo) {
                                    var totalPoint =
                                        yPosition + tapInfo.delta.dy;
                                    setState(() {
                                      yPosition = getCursorPoint(
                                          yPosition,
                                          totalPoint,
                                          constraints.maxHeight,
                                          scrollHeight);

                                      scrollListView.jumpTo(
                                          getScrollContentForJump(
                                              constraints.maxHeight,
                                              scrollListView
                                                  .position.maxScrollExtent,
                                              scrollHeight,
                                              yPosition));
                                    });
                                  },
                                  child: Container(
                                    height: scrollHeight,
                                    width: scrollWidth,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          );
                        })),
                        GestureDetector(
                          onTap: () {
                            getUpDownMethod(
                                false,
                                totalHeightScrollMain,
                                scrollListView.position.maxScrollExtent,
                                scrollHeight,
                                yPosition);
                          },
                          child: Container(
                            alignment: Alignment.center,
                            height: scrollWidth,
                            width: scrollWidth,
                            color: Colors.grey.shade700,
                            child: Icon(Icons.arrow_drop_down),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
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
            ),
          ],
        ),
      ),
    );
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
          setState(() {
            scrollListView.jumpTo(scrollListView.position.maxScrollExtent);
            getManageSize();
          });
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
          getManageSize();
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
            listChatCommand.add(Chat(
                "", keyForExit, "${DateTime.now().millisecondsSinceEpoch}"));
            Future.delayed(const Duration(milliseconds: 50), () {
              setState(() {
                scrollListView.jumpTo(scrollListView.position.maxScrollExtent);
                focusNodeMessage.requestFocus();
                getManageSize();
              });
            });
          });
          break;
        case VirtualKeyboardKeyAction.send:
          getSendButtonFromKeyboard();
          break;
        default:
      }
    }
  }

  void getUpDownMethod(
      bool isUp,
      double totalHeightScroll,
      double scrollContentSize,
      double scrollCurrentHeight,
      double scrollCurrentPosition) {
    double increOrDecre = 0;

    if (isUp) {
      increOrDecre = -10;
    } else {
      increOrDecre = 10;
    }

    setState(() {
      yPosition = getCursorPoint(yPosition, (yPosition + increOrDecre),
          totalHeightScroll, scrollCurrentHeight);

      scrollListView.jumpTo(getScrollContentForJump(totalHeightScroll,
          scrollListView.position.maxScrollExtent, scrollHeight, yPosition));
    });
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
          Future.delayed(const Duration(milliseconds: 150), () {
            setState(() {
              scrollListView.jumpTo(scrollListView.position.maxScrollExtent);
              getManageSize();
            });
          });
        } else {
          Future.delayed(const Duration(milliseconds: 50), () {
            setState(() {
              isShownNormalReloadWithTextField = true;
              listChatAllData = List.from(listChatAllDataTempStore);
              Future.delayed(const Duration(milliseconds: 50), () {
                setState(() {
                  scrollListView
                      .jumpTo(scrollListView.position.maxScrollExtent);
                  getManageSize();
                });
              });
            });
          });
        }
      });
    }
  }
}
