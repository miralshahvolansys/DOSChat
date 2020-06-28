library constant;

// API KEY
const String API_KEY = 'AIzaSyBsOPJVj7m5Glp1IpuqpD47Tb28b3NW9Es';

// BASE URL
const String baseURL = 'https://retrochat2020-d602a.firebaseio.com/';

// AUTH URL
const String authURLSignup =
    'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=$API_KEY';
const String authURLSignIn =
    'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=$API_KEY';

// Firebase Node
const firebaseNodeUser = 'users';
const firebaseNodeRecentChat = 'recentChat';
const firebaseNodeMessage = 'message';

//Keys For chat
const keyTableMainChild = 'chatuser';
const keyId = 'id';
const keySenderId = 'sender_id';
const keySenderName = 'sender_name';
const keyTimeStamp = 'timestamp';
const keyReceiverName = 'receiver_name';
const keyMessage = 'message';
const keyForMe = 'Me:> ';
const keyForCommandPrecision = "C:/>";
const keyForExit = "Do you want to exit chat(y/n)?";
const keyForCommandNotFound = "Command not found...";

// COMMAND CONSTANT
const help = 'help';
const ls = 'ls';
const startChat = 'start chat';
const exit = 'exit';
const clear = 'clear';
const signup = 'signup';
const signin = 'signin';

const username = 'username';
const userid = 'userid';

// APPLICATION COMMAND
List<String> helpCommands = [
  signup,
  signin,
  ls,
  startChat,
  exit,
  clear,
];
const createUser = 'create user';
