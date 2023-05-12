import 'package:ticketzone/model/ticket.dart';

class UserModel {
  String? uid;
  String? email;
  String? firstname;
  String? lastname;
  String? dob;

  UserModel({this.uid, this.email, this.firstname, this.lastname, this.dob});

  // data from server
  factory UserModel.fromMap(map) {
    return UserModel(
        uid: map['uid'],
        email: map['email'],
        firstname: map['firstname'],
        lastname: map['lastname'],
        dob: map['dob']);
  }

  // sendig data to our server
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'firstname': firstname,
      'lastname': lastname,
      'dob': dob
    };
  }

  @override
  String toString() {
    return 'UserModel{uid: $uid, email: $email, firstname: $firstname, lastname: $lastname, dob: $dob}';
  }
}
