// COMMAND INPUT TYPE
enum eInputType {
  none,
  usernameTextField,
  passwordTextField,
  infoText,
  authenticating,
  commandTextField,
  text,
}

// COMMAND TYPE
enum eCommandType {
  none,
  username,
  password,
  help,
  exit,
  ls_userlist,
}

enum eCurrentCommandType {
  none,
  exit,
  signUp,
  signIn,
  command,
}
