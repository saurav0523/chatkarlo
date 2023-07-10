
// ignore_for_file: file_names

class ChatRoomModel {
  String? chatroomid;
  Map<String, dynamic>? participants;
  String? lastmessage;
  List<dynamic>? users;
  DateTime? createdon;
 

  ChatRoomModel({this.chatroomid, this.participants,
   this.lastmessage, this.users, this.createdon });

  ChatRoomModel.fromMap(Map<String, dynamic> map) {
    chatroomid = map["chatroomid"];
    participants = map["participants"];
    lastmessage = map["last message"];
     users = map["users"];
     createdon = map["createdon"].toDate();
  }

  
  Map<String, dynamic> toMap() {
    return {
      "participants": participants,
      "lastmessage": lastmessage,
      "chatroomid" : chatroomid,
      "users" : users,
      "createdon" : createdon
    };
  }
}
