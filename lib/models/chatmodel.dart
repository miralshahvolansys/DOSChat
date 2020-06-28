import 'package:firebase_database/firebase_database.dart';
import 'package:retrochat/api_manager/constant.dart';

class Chat {
  String _id;
  String _sender_id;
//  String _sender_name;
//  String _receiver_name;
  String _timeStamp;
  String _message;

//  Chat(this._sender_id, this._sender_name,this._receiver_name,this._message,this._timeStamp);
  Chat(this._sender_id, this._message,this._timeStamp);

  Chat.map(dynamic obj) {
    this._id = obj[keyId];
    this._sender_id = obj[keySenderId];
//    this._sender_name = obj[keySenderName];
//    this._receiver_name = obj[keyReceiverName];
    this._message = obj[keyMessage];
    this._timeStamp = obj[keyTimeStamp];
  }

  String get id => _id;
  String get sender_id => _sender_id;
//  String get sender_name => _sender_name;
//  String get receiver_name => _receiver_name;
  String get message => _message;
  String get timeStamp => _timeStamp;

  Chat.fromSnapshot(DataSnapshot snapshot) {
    _id = snapshot.key;
    _sender_id = snapshot.value[keySenderId];
//    _sender_name = snapshot.value[keySenderName];
//    _receiver_name = snapshot.value[keyReceiverName];
    _message = snapshot.value[keyMessage];
    _timeStamp = snapshot.value[keyTimeStamp];
  }

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    map[keySenderId] = this.sender_id;
//    map[keySenderName] = this.sender_name;
//    map[keyReceiverName] = this.receiver_name;
    map[keyMessage] = this.message;
    map[keyTimeStamp] = this.timeStamp;
    return map;
  }
}