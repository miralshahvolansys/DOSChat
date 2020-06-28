import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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

  @override
  void initState() {
    super.initState();
    _fetchUser();
  }

  @override
  void dispose() {
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
    if (!widget.isLoggedIn) {
      infoMessage =
          'Welcome to Retro Chat. Type \'help\' to see command list of Retro Chat.';
    } else {
      infoMessage = 'Welcome to Retro Chat. Start chatting with your friends.';
    }

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
    _addInfoTextInList(message: 'Login successfully. Welcome to Retro Chat');
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
      obj.prefixText = '${obj.prefixText} username >';
    } else if (inputType == eInputType.passwordTextField) {
      obj.prefixText = '${obj.prefixText} password >';
    } else if (loginUsername != null && loginUsername.length > 0) {
      obj.prefixText = '${obj.prefixText} ${loginUsername ?? ''} >';
    } else {
      obj.prefixText = '${obj.prefixText} >';
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
      obj.prefixText = '${obj.prefixText} ${loginUsername ?? ''} >';
    } else {
      obj.prefixText = '${obj.prefixText} >';
    }
    setState(() {
      arrCommand.add(obj);
    });
  }

  _handleInputCommand({String inputCommand}) {
    final command = _mapInputCommand(inputCommand: inputCommand);
    switch (command) {
      case CONSTANT.help:
        _showAllCommandList(inputCommand: inputCommand);
        break;
      case CONSTANT.ls_userlist:
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
        obj.prefixText = '${obj.prefixText} >';
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
    } else if (inputCommand.contains(CONSTANT.ls_userlist) && arr.length == 2) {
      return CONSTANT.ls_userlist;
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
    if (inputCommand.trim().length > 0) {
      final username = inputCommand.split(' ').last;
      if (username != null) {
        final auth = _getAuth;
        try {
          final otherUser = auth.userList.firstWhere((element) =>
              element.userName.toLowerCase() == username.toLowerCase());
          final loginUser = await auth.getLoginUser();
          if (loginUser != null && otherUser != null) {
            // REDIRECT TO CHAT SCREEN
            /*Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatScreen(
                  userMine: loginUser,
                  userOther: otherUser,
                ),
              ),
            );*/
          }
        } catch (err) {
          _addInfoTextInList(
              message: 'Invalid username! Please try with different username.');
          _addCommandTextField(inputText: inputCommand);
        }
      }
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
    arrCommand[index].prefixText = 'C:\\ $postFixText >';
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
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8.0,
          ),
          child: Column(
            children: <Widget>[
              Expanded(
                child: ListView.builder(
                  itemCount: arrCommand.length,
                  itemBuilder: (lvContext, index) {
                    final command = arrCommand[index];
                    if (command.inputType == eInputType.commandTextField) {
                      return getCommandTextField(
                        command: command,
                        controller: _commandController,
                        obscureText:
                            (command.commandType == eCommandType.password),
                        onSubmitted: (text) {
                          final trimmedText = text.trim();
                          if (trimmedText.length > 0) {
                            if (command.commandType == eCommandType.username) {
                              command.commandType = eCommandType.password;
                              _setPrefixText(eCommandType.password);
                              username = text;
                              _addInfoTextInList(
                                  message: text,
                                  inputType: eInputType.usernameTextField);
                            } else if (command.commandType ==
                                eCommandType.password) {
                              command.commandType = eCommandType.none;
                              password = text;
                              _addInfoTextInList(
                                  message: '',
                                  inputType: eInputType.passwordTextField);
                              _addInfoTextInList(
                                  message: 'Authenticating please wait...',
                                  inputType: eInputType.authenticating);
                              _handleAuthentication(
                                  commandType: _currentCommandType);
                            } else if (command.commandType ==
                                eCommandType.exit) {
                              if (trimmedText.toLowerCase() == 'y') {
                                _handleLogout();
                              }
                            } else {
                              _handleInputCommand(inputCommand: trimmedText);
                            }
                          }
                        },
                      );
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
                        style: commandTextStyle(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
