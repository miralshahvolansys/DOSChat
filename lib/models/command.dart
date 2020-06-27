class ModelCommand {
  String prefixText = 'C:\\';
  eCommandType commandType = eCommandType.none;
  eInputType inputType = eInputType.none;
  bool allowEditing = false;
  String infoText = '';
  String inputText = '';
}

enum eInputType {
  none,
  normalTextField,
  passwordTextField,
  infoText,
  authenticating,
  commandTextField,
  text,
}

enum eCommandType {
  none,
  authenticationRequired,
  help,
}
