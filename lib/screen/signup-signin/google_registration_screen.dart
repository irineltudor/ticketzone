import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ticketzone/screen/main/main_screen.dart';
import 'package:ticketzone/service/ticket_service.dart';
import 'package:ticketzone/widget/date_picker_widget.dart';

import '../../model/user.dart';

class GoogleRegistrationScreen extends StatefulWidget {
  final UserModel user;
  GoogleRegistrationScreen({Key? key, required this.user}) : super(key: key);

  @override
  _GoogleRegistrationScreenState createState() =>
      _GoogleRegistrationScreenState(user: user);
}

class _GoogleRegistrationScreenState extends State<GoogleRegistrationScreen> {
  final UserModel user;

  final _formKey = GlobalKey<FormState>();

  final firstNameEditingController = TextEditingController();
  final lastNameEditingController = TextEditingController();
  final birthEditingController = TextEditingController();

  final TicketService ticketService = TicketService();

  // string for displaying the error
  String? errorMessage;

  _GoogleRegistrationScreenState({required this.user});

  @override
  Widget build(BuildContext context) {
    //first name field
    final firstNameField = TextFormField(
      autofocus: false,
      controller: firstNameEditingController,
      style: const TextStyle(color: Colors.white),
      keyboardType: TextInputType.name,
      validator: (value) {
        RegExp regex = RegExp(r'^.{3,}$');
        if (value!.isEmpty) {
          return ("First Name cannot be empty");
        }

        if (!regex.hasMatch(value)) {
          return ("Enter a valid name(min 3 characters)");
        }

        return null;
      },
      onSaved: (value) {
        firstNameEditingController.text = value!;
      },
      textInputAction: TextInputAction.next,
      decoration: const InputDecoration(
        prefixIcon: Icon(
          Icons.person,
          color: Colors.white,
        ),
        contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
        hintText: "First Name",
        hintStyle: TextStyle(color: Colors.white),
        errorStyle: TextStyle(color: Colors.white),
        border: InputBorder.none,
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
            borderSide: BorderSide(color: Colors.white)),
      ),
    );

    //second name field
    final lastNameField = TextFormField(
      autofocus: false,
      controller: lastNameEditingController,
      style: const TextStyle(color: Colors.white),
      keyboardType: TextInputType.name,
      validator: (value) {
        RegExp regex = RegExp(r'^.{3,}$');
        if (value!.isEmpty) {
          return ("Last Name cannot be empty");
        }

        if (!regex.hasMatch(value)) {
          return ("Enter a valid name(min 3 characters)");
        }

        return null;
      },
      onSaved: (value) {
        lastNameEditingController.text = value!;
      },
      textInputAction: TextInputAction.next,
      decoration: const InputDecoration(
        prefixIcon: Icon(
          Icons.person,
          color: Colors.white,
        ),
        contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
        hintText: "Last Name",
        hintStyle: TextStyle(color: Colors.white),
        errorStyle: TextStyle(color: Colors.white),
        border: InputBorder.none,
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
            borderSide: BorderSide(color: Colors.white)),
      ),
    );

    //date picker
    final datePicker = DatePickerWidget(
        color: Colors.white,
        userDate: 'Pick Date',
        buttonColor: Colors.black,
        dob: birthEditingController);

    firstNameEditingController.text = user.firstname!;
    lastNameEditingController.text = user.lastname!;

//sign up button
    final addDetailsButton = Material(
      elevation: 5,
      borderRadius: BorderRadius.circular(30),
      color: Colors.black,
      child: MaterialButton(
        padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
            side: const BorderSide(color: Colors.white)),
        minWidth: MediaQuery.of(context).size.width / 1.5,
        onPressed: () {
          postDetailsToDB(user);
        },
        child: const Text(
          "Add Details",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );

    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              // passing this to our root
              Navigator.of(context).pop();
            },
          ),
        ),
        body: Center(
            child: SingleChildScrollView(
          child: Container(
            color: Colors.black,
            child: Padding(
              padding: const EdgeInsets.all(36),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      height: 150,
                      child: Image.asset(
                        "assets/logo/ticketzone-logo-black.png",
                        fit: BoxFit.contain,
                      ),
                    ),
                    Column(
                      children: const [
                        Text('Welcome,',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 25,
                                fontFamily: 'Kanit-Regular')),
                        SizedBox(height: 5),
                        Text("Check and update your account details",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontFamily: 'Kanit-Regular',
                                fontStyle: FontStyle.italic)),
                      ],
                    ),
                    const SizedBox(height: 30),
                    firstNameField,
                    const SizedBox(height: 20),
                    lastNameField,
                    const SizedBox(height: 20),
                    datePicker,
                    const SizedBox(height: 25),
                    addDetailsButton,
                    const SizedBox(height: 15)
                  ],
                ),
              ),
            ),
          ),
        )));
  }

  postDetailsToDB(UserModel user) async {
    UserModel userModel = UserModel(
        uid: user.uid,
        email: user.email,
        firstname: firstNameEditingController.text,
        lastname: lastNameEditingController.text,
        dob: birthEditingController.text);

    await FirebaseFirestore.instance
        .collection("user")
        .doc(user.uid)
        .set(userModel.toMap());

    Navigator.pushAndRemoveUntil(
        (context),
        MaterialPageRoute(builder: (context) => const MainScreen()),
        (route) => false);
  }
}
