import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:retrochat/screens/chat_screen.dart';

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

  List<ModelCommand> arrCommand = [];
  AuthProvider auth;

  @override
  void initState() {
    super.initState();
    if (!widget.isLoggedIn) {
      _setInitialArray();
    } else {
      _addInfoTextInList(
          message: 'Welcome to Retro Chat. Start chatting with your friends.');
      _addCommandTextField();
    }
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
    print(auth.userNames);
  }

  // SIGN IN
  Future<void> _signIn() async {
    try {
      final auth = _getAuth;
      await auth.signUp(
        username: _usernameController.text,
        password: _passwordController.text,
      );
      _handleAuthSuccess();
    } on HTTPException catch (err) {
      _handleAuthenticationError(error: err.toString());
    } catch (err) {
      _handleAuthenticationError(error: err.toString());
    }
  }

  _handleAuthenticationError({String error}) {
    arrCommand = [];
    _addInfoTextInList(message: error);
    _setInitialArray();
  }

  _handleAuthSuccess() {
    final index = arrCommand.indexWhere(
        (element) => element.inputType == eInputType.authenticating);
    if (index >= 0) {
      final arrFiltered = arrCommand
          .where((element) =>
              element.commandType == eCommandType.authenticationRequired)
          .toList();
      arrFiltered.forEach((element) {
        element.allowEditing = false;
      });
      arrCommand[index].infoText = 'Login successfully. Welcome to Reto Chat';
    }
    _addInfoTextInList(
      message: 'Type \'help\' to see command list of Retro Chat.',
      inputType: eInputType.infoText,
    );
    _addCommandTextField();
  }

  // SETUP INITIAL ARRAY
  _setInitialArray() {
    _addInfoTextInList(
        message: 'Please enter your credential to start Retro Chat!');
    _usernameController.text = '';
    _passwordController.text = '';
    _addAuthTextField(inputType: eInputType.normalTextField);
  }

  // ADD TEXTFIELD FOR AUTHENTICATION
  void _addAuthTextField({eInputType inputType}) {
    final obj = ModelCommand();
    obj.commandType = eCommandType.authenticationRequired;
    obj.allowEditing = true;
    obj.inputType = inputType;
    if (inputType == eInputType.normalTextField) {
      obj.prefixText = '${obj.prefixText} username >';
    } else {
      obj.prefixText = '${obj.prefixText} password >';
    }
    _addObjectInArray(obj);
  }

  // CHECK HAS PASSWORD TEXTFIELD OR NOT
  bool hasPasswordTextField() {
    final hasField = arrCommand
        .where((element) => element.inputType == eInputType.passwordTextField)
        .toList();
    return hasField.length > 0;
  }

  _addObjectInArray(ModelCommand command) {
    setState(() {
      arrCommand.add(command);
    });
  }

  // ADD INFO TEXT
  _addInfoTextInList({
    String message,
    eInputType inputType = eInputType.infoText,
  }) {
    final obj = ModelCommand();
    obj.inputType = inputType;
    obj.prefixText = '${obj.prefixText} >';
    obj.infoText = message;
    _addObjectInArray(obj);
  }

  // HANDLE COMMAND
  _addCommandTextField({String inputText}) async {
    final index = arrCommand.indexWhere(
        (element) => element.inputType == eInputType.commandTextField);
    if (index >= 0) {
      arrCommand[index].infoText = inputText;
      arrCommand[index].inputType = eInputType.infoText;
    }

    _commandController.text = '';
    final obj = ModelCommand();
    obj.inputType = eInputType.commandTextField;
    final username =
        await Provider.of<AuthProvider>(context, listen: false).getUsername();
    obj.prefixText = '${obj.prefixText} $username >';
    _addObjectInArray(obj);
  }

  _handleInputCommand({String inputCommand}) {
    final command = _mapInputCommand(inputCommand: inputCommand);
    print(command);
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
        break;
      case CONSTANT.exit:
        break;
      default:
        final obj = ModelCommand();
        //obj.commandType = eCommandType.help;
        obj.inputType = eInputType.infoText;
        obj.infoText = 'Invalid command. Type \'help\' to get command list.';
        _addObjectInArray(obj);

        final arrFiltered = arrCommand.where((element) {
          return element.inputType == eInputType.commandTextField;
        }).toList();

        arrFiltered.forEach((element) {
          final index = arrCommand.indexOf(element);
          if (index >= 0) {
            arrCommand[index].infoText = inputCommand;
            arrCommand[index].inputType = eInputType.infoText;
          }
        });
        _addCommandTextField();
        break;
    }
  }

  String _mapInputCommand({String inputCommand}) {
    final arr = inputCommand.split(' ');
    if (inputCommand.contains(CONSTANT.help) && arr.length == 1) {
      return CONSTANT.help;
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

  _showUserList({String inputCommand}) {
    final obj = ModelCommand();
    obj.commandType = eCommandType.ls_userlist;
    _addObjectInArray(obj);

    final index = arrCommand.indexWhere(
        (element) => element.inputType == eInputType.commandTextField);
    if (index >= 0) {
      arrCommand[index].inputType = eInputType.infoText;
      arrCommand[index].infoText = inputCommand;
      _addCommandTextField();
    }
  }

  _showAllCommandList({String inputCommand}) {
    final obj = ModelCommand();
    obj.commandType = eCommandType.help;
    _addObjectInArray(obj);

    final index = arrCommand.indexWhere(
        (element) => element.inputType == eInputType.commandTextField);
    if (index >= 0) {
      arrCommand[index].inputType = eInputType.infoText;
      arrCommand[index].infoText = inputCommand;
      _addCommandTextField();
    }
  }

  _startChat({String inputCommand}) async {
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
              message: 'Invalid username! Please try with different username.');
          _addCommandTextField(inputText: inputCommand);
        }
      }
    }
  }

  // BUILD METHOD
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.exit_to_app),
              onPressed: () {
                Provider.of<AuthProvider>(context, listen: false).signOut();
              })
        ],
      ),
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
                    // AUTHENTICATION
                    if (command.commandType ==
                        eCommandType.authenticationRequired) {
                      // ASSIGN TEXT EDITING CONTROLLER
                      TextEditingController controller =
                          command.inputType == eInputType.normalTextField
                              ? _usernameController
                              : _passwordController;

                      return getWidgetTextField(
                        command: command,
                        obscureText:
                            command.inputType == eInputType.passwordTextField,
                        controller: controller,
                        onSubmitted: (text) {
                          final trimmedText = text.trim();
                          if (trimmedText.length > 0) {
                            if (!hasPasswordTextField()) {
                              _addAuthTextField(
                                  inputType: eInputType.passwordTextField);
                            } else {
                              _addInfoTextInList(
                                message: 'Authenticating...',
                                inputType: eInputType.authenticating,
                              );
                              _signIn();
                            }
                          }
                        },
                      );
                    } // AUTHENTICATION
                    // SHELL COMMAND
                    else if (command.inputType == eInputType.commandTextField) {
                      return getCommandTextField(
                        command: command,
                        controller: _commandController,
                        onSubmitted: (text) {
                          final trimmedText = text.trim();
                          if (trimmedText.length > 0) {
                            _handleInputCommand(inputCommand: trimmedText);
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

  // Future<String> _calculation = provider.fetchUserList();
  // return FutureBuilder<String>(
  //   future: _calculation, // a Future<String> or null
  //   builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
  //     switch (snapshot.connectionState) {
  //       case ConnectionState.waiting:
  //         return new Text('loading...', style: TextStyle(color: Colors.white));
  //       case ConnectionState.done:
  //         return new UserListWidget(
  //           userNameList: '${snapshot.data}',
  //         );
  //       default:
  //         if (snapshot.hasError)
  //           return new Text('Error: ${snapshot.error}',
  //               style: TextStyle(color: Colors.white));
  //         else
  //           return new Text('Result: ${snapshot.data}',
  //               style: TextStyle(color: Colors.white));
  //     }
  //   },
  // );
}
