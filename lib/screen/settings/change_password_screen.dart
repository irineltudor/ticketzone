import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../model/user.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({Key? key}) : super(key: key);

  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  User? user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();

  final _formKey = GlobalKey<FormState>();

  final TextEditingController oldPasswordEditingController =
      TextEditingController();
  final TextEditingController newPasswordEditingController =
      TextEditingController();
  final TextEditingController renewPasswordEditingController =
      TextEditingController();
  // string for displaying the error
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    FirebaseFirestore.instance
        .collection("user")
        .doc(user!.uid)
        .get()
        .then((value) {
      loggedInUser = UserModel.fromMap(value.data());
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    final oldPasswordField = TextFormField(
      autofocus: false,
      controller: oldPasswordEditingController,
      obscureText: true,
      style: const TextStyle(color: Colors.black),
      keyboardType: TextInputType.visiblePassword,
      validator: (value) {
        RegExp regex = new RegExp(r'^.{6,}$');
        if (value!.isEmpty) {
          return ("Current Password is required for login");
        }

        if (!regex.hasMatch(value)) {
          return ("Enter a valid password (min 6 characters)");
        }

        return null;
      },
      onSaved: (value) {
        oldPasswordEditingController.text = value!;
      },
      textInputAction: TextInputAction.next,
      decoration: const InputDecoration(
        prefixIcon: Icon(Icons.vpn_key, color: Colors.black),
        contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
        hintText: "Current Password",
        hintStyle: TextStyle(color: Colors.black),
        errorStyle: TextStyle(color: Colors.black),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
            borderSide: BorderSide(color: Colors.black)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
            borderSide: BorderSide(color: Colors.black)),
      ),
    );

    final newPasswordField = TextFormField(
      autofocus: false,
      controller: newPasswordEditingController,
      obscureText: true,
      style: const TextStyle(color: Colors.black),
      keyboardType: TextInputType.visiblePassword,
      validator: (value) {
        RegExp regex = new RegExp(r'^.{6,}$');
        if (value!.isEmpty) {
          return ("Password is required for login");
        }

        if (!regex.hasMatch(value)) {
          return ("Enter a valid password (min 6 characters)");
        }

        return null;
      },
      onSaved: (value) {
        newPasswordEditingController.text = value!;
      },
      textInputAction: TextInputAction.next,
      decoration: const InputDecoration(
        prefixIcon: Icon(Icons.vpn_key, color: Colors.black),
        contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
        hintText: "New Password",
        hintStyle: TextStyle(color: Colors.black),
        errorStyle: TextStyle(color: Colors.black),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
            borderSide: BorderSide(color: Colors.black)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
            borderSide: BorderSide(color: Colors.black)),
      ),
    );

    final renewPasswordField = TextFormField(
      autofocus: false,
      obscureText: true,
      controller: renewPasswordEditingController,
      style: const TextStyle(color: Colors.black),
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (newPasswordEditingController.text !=
            renewPasswordEditingController.text) {
          return ("Passwords don't match");
        }

        return null;
      },
      onSaved: (value) {
        renewPasswordEditingController.text = value!;
      },
      textInputAction: TextInputAction.next,
      decoration: const InputDecoration(
        prefixIcon: Icon(Icons.restart_alt, color: Colors.black),
        contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
        hintText: "Confirm Password",
        hintStyle: TextStyle(color: Colors.black),
        errorStyle: TextStyle(color: Colors.black),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
            borderSide: BorderSide(color: Colors.black)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
            borderSide: BorderSide(color: Colors.black)),
      ),
    );

    final updateButton = Material(
      elevation: 5,
      color: Colors.white,
      child: MaterialButton(
        splashColor: Colors.white30,
        padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
        minWidth: MediaQuery.of(context).size.width / 4,
        onPressed: () {
          changePassword(newPasswordEditingController.text,
              oldPasswordEditingController.text);
        },
        child: const Text(
          "Update",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            color: Colors.black,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );

    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          centerTitle: true,
          title: const Text('Change Password',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Kanit-Regular',
              )),
        ),
        bottomNavigationBar: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
            child: updateButton),
        body: Stack(
          children: [
            Positioned(
              top: height * 0.02,
              height: height * 0.815,
              left: height * 0.005,
              right: height * 0.005,
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(45)),
                child: Container(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(36),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Change your password ',
                            style: TextStyle(
                              color: Colors.black,
                              fontFamily: 'Kanit-Regular',
                              fontSize: 30,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 30,
                              ),
                              Text(
                                'Current Password ',
                                style: TextStyle(
                                    color: Color.fromARGB(202, 0, 0, 0),
                                    fontSize: 18,
                                    fontFamily: 'Kanit-Regular',
                                    fontWeight: FontWeight.w600),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Material(
                                  elevation: 10,
                                  shadowColor: Colors.black,
                                  borderRadius: BorderRadius.circular(20),
                                  child: oldPasswordField),
                              SizedBox(
                                height: 20,
                              ),
                              Text(
                                'New Password',
                                style: TextStyle(
                                    color: Color.fromARGB(202, 0, 0, 0),
                                    fontFamily: 'Kanit-Regular',
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Material(
                                  elevation: 10,
                                  shadowColor: Colors.black,
                                  borderRadius: BorderRadius.circular(20),
                                  child: newPasswordField),
                              SizedBox(
                                height: 20,
                              ),
                              Material(
                                  elevation: 10,
                                  shadowColor: Colors.black,
                                  borderRadius: BorderRadius.circular(20),
                                  child: renewPasswordField),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ));
  }

  Future<void> changePassword(String newPassword, String oldPassword) async {
    if (_formKey.currentState!.validate()) {
      var credentials = EmailAuthProvider.credential(
          email: user?.email ?? " ", password: oldPassword);
      try {
        await user?.reauthenticateWithCredential(credentials).then((value) => {
              user
                  ?.updatePassword(newPassword)
                  .then((value) => {
                        errorMessage = "Successfully changed password",
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('{$errorMessage}'),
                          backgroundColor: Colors.green,
                          showCloseIcon: true,
                          closeIconColor: Colors.white,
                        )),
                        Future.delayed(const Duration(seconds: 1), () {
                          Navigator.of(context).pop();
                        }),
                      })
                  // ignore: body_might_complete_normally_catch_error
                  .catchError((onError) {
                errorMessage = "Password can't be changed" + onError.toString();
                Fluttertoast.showToast(msg: '$errorMessage');
              })
            });
      } on FirebaseAuthException catch (error) {
        switch (error.code) {
          case "invalid-email":
            errorMessage = "Your email address appears to be malformed.";

            break;
          case "wrong-password":
            errorMessage = "Current password is wrong.";
            break;
          case "user-not-found":
            errorMessage = "User with this email doesn't exist.";
            break;
          case "user-disabled":
            errorMessage = "User with this email has been disabled.";
            break;
          case "too-many-requests":
            errorMessage = "Too many requests";
            break;
          case "operation-not-allowed":
            errorMessage = "Signing in with Email and Password is not enabled.";
            break;
          default:
            errorMessage = "An undefined Error happened.";
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              errorMessage!,
            ),
            backgroundColor: Colors.red,
            closeIconColor: Colors.white,
            showCloseIcon: true,
          ),
        );
      }
    }
  }
}
