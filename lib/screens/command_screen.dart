import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../api_manager/http_exception.dart';
import '../widget/widget_command.dart';
import '../provider/auth_provider.dart';
import '../models/command.dart';
import '../widget/widget_help.dart';
import '../utility/enum.dart';
import '../api_manager/constant.dart' as CONSTANT;

import '../provider/user_provider.dart';
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
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _commandController.dispose();
    super.dispose();
  }

  // SIGN IN
  Future<void> _signIn() async {
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
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
  _addCommandTextField() async {
    final obj = ModelCommand();
    obj.inputType = eInputType.commandTextField;
    final username =
        await Provider.of<AuthProvider>(context, listen: false).getUsername();
    obj.prefixText = '${obj.prefixText} $username >';
    _addObjectInArray(obj);
  }

  _handleInputCommand({String command}) {
    switch (command) {
      case CONSTANT.help:
        _showAllCommandList(command: command);
        break;
      case CONSTANT.ls_userlist:
        _showUserList(command: command);
        break;
      case CONSTANT.clear:
        break;
      case CONSTANT.exit:
        break;
      default:
        final obj = ModelCommand();
        //obj.commandType = eCommandType.help;
        obj.inputType = eInputType.infoText;
        obj.infoText = 'Command not found.';
        _addObjectInArray(obj);
        break;
    }
  }

  _showUserList({String command}) {
    final obj = ModelCommand();
    obj.commandType = eCommandType.ls_userlist;
    _addObjectInArray(obj);

    final index = arrCommand.indexWhere(
        (element) => element.inputType == eInputType.commandTextField);
    if (index >= 0) {
      arrCommand[index].inputType = eInputType.infoText;
      arrCommand[index].infoText = command;

      _commandController.text = '';
      //_addCommandTextField();
    }
  }

  _showAllCommandList({String command}) {
    final obj = ModelCommand();
    obj.commandType = eCommandType.help;
    _addObjectInArray(obj);

    final index = arrCommand.indexWhere(
        (element) => element.inputType == eInputType.commandTextField);
    if (index >= 0) {
      arrCommand[index].inputType = eInputType.infoText;
      arrCommand[index].infoText = command;

      _commandController.text = '';
      _addCommandTextField();
    }
  }

  _startChat() {}

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
                            _handleInputCommand(command: trimmedText);
                          }
                        },
                      );
                    } else if (command.commandType == eCommandType.help) {
                      return getCommandListWidget();
                    } else if (command.commandType ==
                        eCommandType.ls_userlist) {
                      return getUserListWidget(context, () {
                        // _addCommandTextField();
                      });
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

Widget getUserListWidget(BuildContext context, Function onComplete) {
  final provider = Provider.of<UserList>(context, listen: false);
  Future<String> _calculation = provider.fetchUserList();
  return FutureBuilder<String>(
    future: _calculation, // a Future<String> or null
    builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
      switch (snapshot.connectionState) {
        case ConnectionState.waiting:
          return new Text('Awaiting result...',
              style: TextStyle(color: Colors.white));
        case ConnectionState.done:
          return new UserListWidget(
            userNameList: '${snapshot.data}',
          );
        default:
          if (snapshot.hasError)
            return new Text('Error: ${snapshot.error}',
                style: TextStyle(color: Colors.white));
          else
            return new Text('Result: ${snapshot.data}',
                style: TextStyle(color: Colors.white));
      }
    },
  );
}
