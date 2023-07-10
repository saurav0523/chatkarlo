
// ignore: camel_case_types
class usermodel {
  String? uid;
  String? fullname;
  String? email;
  String? profilepic;

  usermodel({this.uid, this.fullname, this.email, this.profilepic});

  usermodel.fromMap(Map<String, dynamic> map) {
    uid = map["uid"];
    fullname = map["fullname"];
    email = map["email"];
    profilepic = map["profilepic"];
  }

  Map<String, dynamic> toMap() {
    return {
      "uid": uid,
      "fullname": fullname,
      "email": email,
      "profilepic": profilepic,
    };
  }
}
