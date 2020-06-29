import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:retrochat/utility/app_style.dart';
import 'dart:async';

import '../keyboard/virtual_keyboard.dart';
import '../screens/chat_screen.dart';
import '../api_manager/http_exception.dart';
import '../widget/widget_command.dart';
import '../provider/auth_provider.dart';
import '../models/command.dart';
import '../widget/widget_help.dart';
import '../utility/enum.dart';
import '../api_manager/constant.dart' as CONSTANT;

import '../widget/widget_user_list.dart';

class CommandScreen extends StatefulWidget {
  static const routeName = '/command_screen';
  final bool isLoggedIn;

  CommandScreen({this.isLoggedIn});

  @override
  _CommandScreenState createState() => _CommandScreenState();
}

class _CommandScreenState extends State<CommandScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _commandController = TextEditingController();

  String username = '';
  String password = '';
  String loginUsername = '';

  List<ModelCommand> arrCommand = [];
  AuthProvider auth;
  eCurrentCommandType _currentCommandType = eCurrentCommandType.none;

  // KEYBOARD
  ScrollController _scrollController = ScrollController();
  bool isShowKeyboard = false;
  // Holds the text that user typed.
  StreamController<String> _events;
  // True if shift enabled.
  bool shiftEnabled = false;
  String text = '';
  FocusNode focusNodeCommand = FocusNode();
  ModelCommand _command;

  @override
  void initState() {
    super.initState();

    _events = StreamController<String>.broadcast();
    _fetchUser();
  }

  @override
  void dispose() {
    _events.close();
    _usernameController.dispose();
    _passwordController.dispose();
    _commandController.dispose();
    super.dispose();
  }

  AuthProvider get _getAuth {
    if (auth == null) {
      auth = Provider.of<AuthProvider>(context, listen: false);
    }
    return auth;
  }

  _fetchUser() async {
    final auth = _getAuth;
    await auth.getUserList();
    loginUsername = await auth.getUsername();
    _setInitialData();
  }

  _setInitialData() {
    String infoMessage = '';
    infoMessage =
        'Welcome to DOSChat. Start chatting with your friends and enjoy retro look. Type \'help\' to see available commands and start over.';

    _addInfoTextInList(message: infoMessage);
    _addCommandTextField();
  }

  Future<void> _handleAuthentication({eCurrentCommandType commandType}) async {
    final uname = username.trim();
    final pass = password.trim();

    if (uname.length > 0 && pass.trim().length > 0) {
      try {
        final auth = _getAuth;
        if (commandType == eCurrentCommandType.signUp) {
          await auth.signUp(
            username: uname,
            password: pass,
          );
          _handleAuthSuccess();
        } else if (commandType == eCurrentCommandType.signIn) {
          await auth.signIn(
            username: uname,
            password: pass,
          );
          _handleAuthSuccess();
        } else {
          print('INVALID AUTH COMMAND TYPE');
        }
      } on HTTPException catch (err) {
        _handleAuthenticationError(error: err.toString());
      } catch (err) {
        _handleAuthenticationError(error: err.toString());
      } finally {
        _currentCommandType = eCurrentCommandType.none;
        setState(() {
          arrCommand.removeWhere(
              (element) => element.inputType == eInputType.authenticating);
          arrCommand.removeLast();
          _addCommandTextField();
        });
      }
    } else {
      //
    }
  }

  _handleAuthenticationError({String error}) {
    loginUsername = '';
    username = '';
    password = '';
    _addInfoTextInList(message: error);
  }

  _handleAuthSuccess() {
    loginUsername = username;
    username = '';
    password = '';
    _addInfoTextInList(message: 'Login successfully. Welcome to DOSChat');
    arrCommand.removeLast();
    _addCommandTextField();
  }

  // CHECK HAS PASSWORD TEXTFIELD OR NOT
  bool hasPasswordTextField() {
    final hasField = arrCommand
        .where((element) => element.inputType == eInputType.passwordTextField)
        .toList();
    return hasField.length > 0;
  }

  _addObjectInArray(ModelCommand command) {
    _commandController.text = '';
    setState(() {
      int index = 0;
      if (arrCommand.length > 0) {
        index = arrCommand.length - 1;
      }
      arrCommand.insert(index, command);
    });
  }

  // ADD INFO TEXT
  _addInfoTextInList(
      {String message, eInputType inputType = eInputType.infoText}) {
    final obj = ModelCommand();
    obj.inputType = inputType;

    if (inputType == eInputType.usernameTextField) {
      obj.prefixText = '${obj.prefixText} username>';
    } else if (inputType == eInputType.passwordTextField) {
      obj.prefixText = '${obj.prefixText} password>';
    } else if (loginUsername != null && loginUsername.length > 0) {
      obj.prefixText = '${obj.prefixText} ${loginUsername ?? ''}>';
    } else {
      obj.prefixText = '${obj.prefixText}>';
    }
    obj.infoText = message;
    _addObjectInArray(obj);
  }

  // HANDLE COMMAND
  _addCommandTextField({String inputText}) {
    _commandController.text = '';
    _currentCommandType = eCurrentCommandType.command;

    final obj = ModelCommand();
    obj.inputType = eInputType.commandTextField;

    //final username = await Provider.of<AuthProvider>(context, listen: false).getUsername();
    if (loginUsername != null && loginUsername.length > 0) {
      obj.prefixText = '${obj.prefixText} ${loginUsername ?? ''}>';
    } else {
      obj.prefixText = '${obj.prefixText}>';
    }
    setState(() {
      arrCommand.add(obj);
      isShowKeyboard = true;
    });
  }

  _handleInputCommand({String inputCommand}) {
    final command = _mapInputCommand(inputCommand: inputCommand);
    switch (command) {
      case CONSTANT.help:
        _showAllCommandList(inputCommand: inputCommand);
        break;
      case CONSTANT.ls:
        _showUserList(inputCommand: inputCommand);
        break;
      case CONSTANT.startChat:
        _startChat(inputCommand: inputCommand);
        break;
      case CONSTANT.clear:
        _clearScreen();
        break;
      case CONSTANT.exit:
        _logout();
        break;
      case CONSTANT.signup:
        _signup();
        break;
      case CONSTANT.signin:
        _signIn();
        break;
      default:
        _addInfoTextInList(message: inputCommand);
        final obj = ModelCommand();
        obj.prefixText = '${obj.prefixText}>';
        obj.inputType = eInputType.infoText;
        obj.infoText = 'Invalid command. Type \'help\' to get command list.';
        _addObjectInArray(obj);
        break;
    }
  }

  String _mapInputCommand({String inputCommand}) {
    final arr = inputCommand.split(' ');
    if (inputCommand.contains(CONSTANT.help) && arr.length == 1) {
      return CONSTANT.help;
    } else if (inputCommand.contains(CONSTANT.signup) && arr.length == 1) {
      return CONSTANT.signup;
    } else if (inputCommand.contains(CONSTANT.signin) && arr.length == 1) {
      return CONSTANT.signin;
    } else if (inputCommand.contains(CONSTANT.ls) && arr.length == 1) {
      return CONSTANT.ls;
    } else if (inputCommand.contains(CONSTANT.startChat) && arr.length == 3) {
      return CONSTANT.startChat;
    } else if (inputCommand.contains(CONSTANT.clear) && arr.length == 1) {
      return CONSTANT.clear;
    } else if (inputCommand.contains(CONSTANT.exit) && arr.length == 1) {
      return CONSTANT.exit;
    } else {
      return '';
    }
  }

  _showUserList({String inputCommand}) async {
    _addInfoTextInList(message: inputCommand);
    final isLoggedIn =
        await Provider.of<AuthProvider>(context, listen: false).isLoggedIn();
    if (isLoggedIn) {
      final obj = ModelCommand();
      obj.commandType = eCommandType.ls_userlist;
      _addObjectInArray(obj);
    } else {
      // HANDLE LOGIIN ERROR
      _addInfoTextInList(message: 'Please login to see user list.');
    }
  }

  _showAllCommandList({String inputCommand}) {
    _addInfoTextInList(message: inputCommand);
    final obj = ModelCommand();
    obj.commandType = eCommandType.help;
    _addObjectInArray(obj);
  }

  _startChat({String inputCommand}) async {
    _addInfoTextInList(message: inputCommand);
    final isLoggedIn =
        await Provider.of<AuthProvider>(context, listen: false).isLoggedIn();
    if (isLoggedIn) {
      if (inputCommand.trim().length > 0) {
        final username = inputCommand.split(' ').last;
        if (username != null) {
          final auth = _getAuth;
          try {
            final otherUser = auth.userList.firstWhere((element) =>
                element.userName.toLowerCase() == username.toLowerCase());
            final loginUser = await auth.getLoginUserObject();
            if (loginUser != null && otherUser != null) {
              // REDIRECT TO CHAT SCREEN
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(
                    userMine: loginUser,
                    userOther: otherUser,
                  ),
                ),
              );
            }
          } catch (err) {
            _addInfoTextInList(
                message:
                    'Invalid username! Please try with different username.');
          }
        }
      }
    } else {
      _addInfoTextInList(message: 'Please login to start chat.');
    }
  }

  _clearScreen() {
    arrCommand = [];
    _addCommandTextField();
  }

  _logout() {
    _addInfoTextInList(message: CONSTANT.exit);
    arrCommand.last.commandType = eCommandType.exit;
    _addInfoTextInList(message: 'Are you sure you want to logout (y/n)?');
    //loginUsername = '';
  }

  _handleLogout() {
    loginUsername = '';
    final auth = _getAuth;
    auth.signOut();
    arrCommand = [];
    _fetchUser();
  }

  _signup() async {
    final isLoggedIn =
        await Provider.of<AuthProvider>(context, listen: false).isLoggedIn();
    if (isLoggedIn) {
      _addInfoTextInList(message: 'Please exit before signup.');
    } else {
      _currentCommandType = eCurrentCommandType.signUp;
      _addInfoTextInList(message: CONSTANT.signup);
      setState(() {
        arrCommand.last.commandType = eCommandType.username;
        _setPrefixText(eCommandType.username);
      });
    }
  }

  _signIn() async {
    final isLoggedIn =
        await Provider.of<AuthProvider>(context, listen: false).isLoggedIn();
    if (isLoggedIn) {
      _addInfoTextInList(message: 'You are already logged in!');
    } else {
      _currentCommandType = eCurrentCommandType.signIn;
      _addInfoTextInList(message: CONSTANT.signin);
      setState(() {
        arrCommand.last.commandType = eCommandType.username;
        _setPrefixText(eCommandType.username);
      });
    }
  }

  _setPrefixText(eCommandType commandType) {
    final index =
        arrCommand.indexWhere((element) => element.commandType == commandType);
    String postFixText = '';
    if (commandType == eCommandType.username) {
      postFixText = 'username';
    } else if (commandType == eCommandType.password) {
      postFixText = 'password';
    }
    arrCommand[index].prefixText = 'C:\\ $postFixText>';
  }

  _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 40), () {
      setState(() {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
        focusNodeCommand.requestFocus();
      });
    });
  }

  // BUILD METHOD
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   actions: <Widget>[
      //     IconButton(
      //         icon: Icon(Icons.exit_to_app),
      //         onPressed: () {
      //           Provider.of<AuthProvider>(context, listen: false).signOut();
      //         })
      //   ],
      // ),
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8.0,
                ),
                child: ListView.builder(
                  itemCount: arrCommand.length,
                  controller: _scrollController,
                  itemBuilder: (lvContext, index) {
                    final command = arrCommand[index];
                    if (command.inputType == eInputType.commandTextField) {
                      _command = command;
                      FocusScope.of(context).requestFocus(focusNodeCommand);
                      return getCommandTextField(
                          command: command,
                          controller: _commandController,
                          focusNode: focusNodeCommand,
                          obscureText:
                              (command.commandType == eCommandType.password),
                          event: _events,
                          onSubmitted: (text) {},
                          onTap: () {
                            setState(() {
                              isShowKeyboard = true;
                            });
                            FocusScope.of(context)
                                .requestFocus(focusNodeCommand);
                            _scrollToBottom();
                          });
                    } else if (command.commandType == eCommandType.help) {
                      return getCommandListWidget();
                    } else if (command.commandType ==
                        eCommandType.ls_userlist) {
                      return getUserListWidget(context, _getAuth);
                    }
                    // SHELL COMMAND
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        '${command.prefixText} ${command.infoText}',
                        style: AppStyle.commandTextSyle,
                      ),
                    );
                  },
                ),
              ),
            ),
            Container(
              color: AppStyle.keyboardbg,
              child: Visibility(
                visible: isShowKeyboard,
                child: VirtualKeyboard(
                    height: 300,
                    fontSize: 23,
                    textColor: Colors.black54,
                    isChatScreen: false,
                    type: VirtualKeyboardType.Alphanumeric,
                    onKeyPress: _onKeyPress),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
          print(text);
          //text = text + '\n';
          //_events.add(text);
          _commandController.text = '';
          if (_command == null) {
            return;
          }
          final trimmedText = text.trim();
          if (trimmedText.length > 0) {
            if (_command.commandType == eCommandType.username) {
              _command.commandType = eCommandType.password;
              _setPrefixText(eCommandType.password);
              username = text;
              _addInfoTextInList(
                  message: text, inputType: eInputType.usernameTextField);
            } else if (_command.commandType == eCommandType.password) {
              _command.commandType = eCommandType.none;
              password = text;
              _addInfoTextInList(
                  message: '', inputType: eInputType.passwordTextField);
              _addInfoTextInList(
                  message: 'Authenticating please wait...',
                  inputType: eInputType.authenticating);
              _handleAuthentication(commandType: _currentCommandType);
            } else if (_command.commandType == eCommandType.exit) {
              if (trimmedText.toLowerCase() == 'y') {
                _handleLogout();
              } else if (trimmedText.toLowerCase() == 'n') {
                _addInfoTextInList(message: 'n');
              } else {
                _handleInputCommand(inputCommand: trimmedText);
              }
            } else {
              _handleInputCommand(inputCommand: trimmedText);
            }
          }
          text = '';
          _scrollToBottom();
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

Widget getCommandListWidget() {
  return HelpWidget();
}

Widget getUserListWidget(BuildContext context, AuthProvider auth) {
  return new UserListWidget(
    userNameList: '${auth.userNames}',
  );
}
