import 'package:retrochat/api_manager/constant.dart';
import 'package:retrochat/models/chatmodel.dart';
import 'package:retrochat/provider/user_provider.dart';

String createKeyForChatRoom(List<User> usersArray) {
  usersArray.sort((a, b) => a.userName.compareTo(b.userName));
  return "${usersArray[0].userId}_${usersArray[1].userId}";
}

//String nameFromEmail(String email) {
//  return email.split("@")[0];
//}

String precisionChatText(Chat objChat, User usermine, User userother) {
  return objChat.sender_id == usermine.userId
      ? "${keyForMe}${objChat.message}"
      : "${userother.userName}:\\> ${objChat.message}";
}

bool isMyMessage(Chat objChat, User usermine, User userother) {
  return objChat.sender_id == usermine.userId
      ? true : false;
}

double getCursorPoint(
    double currentPoint, double futurePoint, double totalHeightScroll, double scrollHeightM) {
  if (futurePoint < 0) {
    return 0;
  } else if (futurePoint > (totalHeightScroll - scrollHeightM)) {
    return (totalHeightScroll - scrollHeightM);
  } else {
    return futurePoint;
  }
}

double scrollHeightManage(
    double totalHeightScroll, double scrollContentSize) {
  double ratio = totalHeightScroll / (scrollContentSize == 0 ? 1 : scrollContentSize);
  ratio = ratio > 1 ? 1 : ratio;
  double sizeGet = totalHeightScroll * ratio;
  return sizeGet;
}

double getScrollContentForJump(
    double totalHeightScroll,
    double scrollContentSize,
    double scrollCurrentHeight,
    double scrollCurrentPosition) {
  double scrollingArea = totalHeightScroll - scrollCurrentHeight;
  double ratio = scrollContentSize / (scrollingArea == 0 ? 1 : scrollingArea);
  ratio = ratio < 0 ? 0 : ratio;
  return scrollCurrentPosition * ratio;
}
