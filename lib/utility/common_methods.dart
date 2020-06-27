import 'package:retrochat/provider/Model/chatmodel.dart';
import 'package:retrochat/provider/user_provider.dart';

String createKeyForChatRoom(List<User> usersArray) {
  usersArray.sort((a, b) => a.userName.compareTo(b.userName));
  return "${usersArray[0].userId}_${usersArray[1].userId}";
}

String nameFromEmail(String email) {
  return email.split("@")[0];
}

String precisionChatText(Chat objChat, User usermine, User userother) {
  return objChat.sender_id == usermine.userId
      ? "Me:> ${objChat.message}"
      : "${nameFromEmail(userother.userName)}:> ${objChat.message}";
}

bool isMyMessage(Chat objChat, User usermine, User userother) {
  return objChat.sender_id == usermine.userId
      ? true : false;
}
