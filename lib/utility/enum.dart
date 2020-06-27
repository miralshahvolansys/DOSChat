// COMMAND INPUT TYPE
enum eInputType {
  none,
  normalTextField,
  passwordTextField,
  infoText,
  authenticating,
  commandTextField,
  text,
}

// COMMAND TYPE
enum eCommandType {
  none,
  authenticationRequired,
  help,
  ls_userlist,
}
