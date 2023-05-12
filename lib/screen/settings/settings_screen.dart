import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ticketzone/model/user.dart';
import 'package:ticketzone/screen/settings/change_password_screen.dart';
import 'package:ticketzone/screen/settings/change_profile_picture_screen.dart';
import 'package:ticketzone/service/ticket_service.dart';

import '../../service/storage_service.dart';
import '../../widget/menu_widget.dart';
import '../home/home_screen.dart';
import '../signup-signin/login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final Storage storage = Storage();
  User? user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();
  final TicketService ticketService = TicketService();
  final GoogleSignIn googleSignIn = GoogleSignIn();
  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
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
    final width = MediaQuery.of(context).size.width;

    FilePickerResult? result;
    final changePictureButton = Material(
      elevation: 5,
      borderRadius: BorderRadius.circular(30),
      color: Colors.white,
      child: MaterialButton(
        padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
            side: BorderSide(color: Colors.black)),
        minWidth: MediaQuery.of(context).size.width / 2,
        onPressed: () async => {
          //In order to use go back
          // Navigator.push(
          //     context,
          //     MaterialPageRoute(
          //         builder: (context) => const ChangeProfilePictureScreen()))
          Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, animationTime) {
                  return const ChangeProfilePictureScreen();
                },
                transitionDuration: const Duration(seconds: 1),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  animation = CurvedAnimation(
                      parent: animation, curve: Curves.bounceInOut);
                  return ScaleTransition(
                    scale: animation,
                    alignment: Alignment.center,
                    child: child,
                  );
                },
              )),
        },
        child: const FittedBox(
          child: Text(
            'Change Profile Picture',
            style: TextStyle(fontSize: 16, color: Colors.black),
          ),
        ),
      ),
    );

    final changePassword = Material(
      elevation: 5,
      borderRadius: BorderRadius.circular(30),
      color: Colors.white,
      child: MaterialButton(
        padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
            side: const BorderSide(color: Colors.black)),
        minWidth: MediaQuery.of(context).size.width / 2,
        onPressed: () => {
          // //In order to use go back
          // Navigator.push(context,
          //     MaterialPageRoute(builder: (context) => ChangePasswordScreen()))
          Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, animationTime) {
                  return const ChangePasswordScreen();
                },
                transitionDuration: const Duration(seconds: 1),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  animation = CurvedAnimation(
                      parent: animation, curve: Curves.bounceInOut);
                  return ScaleTransition(
                    scale: animation,
                    alignment: Alignment.center,
                    child: child,
                  );
                },
              )),
        },
        child: const FittedBox(
          child: Text(
            'Change Password',
            style: TextStyle(fontSize: 16, color: Colors.black),
          ),
        ),
      ),
    );

    final logoutButton = Material(
      elevation: 5,
      borderRadius: BorderRadius.circular(30),
      color: Colors.black,
      child: MaterialButton(
        padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
            side: BorderSide(color: Colors.white)),
        minWidth: MediaQuery.of(context).size.width / 2,
        onPressed: () => {logout(context)},
        child: const FittedBox(
          child: Text(
            'Log out',
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
        ),
      ),
    );

    if (loggedInUser.dob == null) {
      return Container(
          color: Colors.black,
          child: Center(
              child: CircularProgressIndicator(
            color: Colors.white,
          )));
    } else {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            Positioned(
                top: 0,
                height: height * 0.12,
                left: 0,
                right: 0,
                child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                        bottom: const Radius.circular(45)),
                    child: Container(
                      padding: const EdgeInsets.only(
                          top: 21, left: 32, right: 32, bottom: 10),
                      color: Colors.white,
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.settings),
                            SizedBox(
                              width: 10,
                            ),
                            Text("Settings",
                                style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 26,
                                    color: Colors.black,
                                    fontFamily: 'KanitRegular'))
                          ],
                        ),
                      ),
                    ))),
            Positioned(
                top: height * 0.04,
                height: height * 0.05,
                left: 0,
                right: height / 2.5,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Colors.black, blurRadius: 3)
                      ]),
                  child: MenuWidget(),
                )),
            Positioned(
              top: height * 0.13,
              height: height * 0.77,
              left: height * 0.005,
              right: height * 0.005,
              child: Center(
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(45)),
                  child: Container(
                      color: Colors.white,
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: height * 0.01,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: width * 0.2,
                                  child: ClipOval(
                                    child: FutureBuilder(
                                      future: storage.getProfilePicture(
                                          '${loggedInUser.uid}'),
                                      builder: (BuildContext context,
                                          AsyncSnapshot<String> snapshot) {
                                        if (snapshot.connectionState ==
                                                ConnectionState.done &&
                                            snapshot.hasData) {
                                          return Image.network(
                                            snapshot.data!,
                                          );
                                        }
                                        if (snapshot.connectionState ==
                                                ConnectionState.waiting ||
                                            !snapshot.hasData) {
                                          return CircularProgressIndicator();
                                        }

                                        return Image.asset(
                                            "assets/profile/profile.png");
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                                "${loggedInUser.firstname}, ${loggedInUser.lastname}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 26,
                                    color: Colors.black)),
                            const SizedBox(
                              height: 45,
                            ),
                            changePictureButton,
                            const SizedBox(
                              height: 15,
                            ),
                            changePassword,
                            const SizedBox(
                              height: 45,
                            ),
                            logoutButton
                          ])),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.remove("email");
    pref.remove("password");
    pref.remove("googleAuth.accessToken");
    pref.remove("googleAuth.idToken");
    ticketService.deleteFromTable();
    googleSignIn.signOut();
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginScreen()));
  }
}
