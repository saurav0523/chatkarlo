
// ignore_for_file: camel_case_types, file_names

class messageModel {
  String? sender;
  String? text;
  bool? seen;
  DateTime? createdon;
  String? messageid;

  messageModel(
      {this.sender, this.text, this.seen, this.createdon, this.messageid});

  messageModel.fromMap(Map<String, dynamic> map) {
    messageid = map["messageid"];
    sender = map["sender"];
    text = map["text"];
    seen = map["seen"];
    createdon = map["createdon"].toDate();
  }

  Map<String, dynamic> toMap() {
    return {
      "messageid": messageid,
      "sender": sender,
      "text": text,
      "seen": seen,
      "createdon": createdon,
    };
  }
}
