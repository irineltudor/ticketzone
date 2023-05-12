import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ticketzone/screen/signup-signin/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';

import 'model/ticket.dart';
import 'model/tournament.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  //populateFirebaseFirestoreTickets();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Email and pass login',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        splashColor: Colors.black,
      ),
      home: LoginScreen(),
    );
  }
}

Future<void> populateFirebaseFirestoreTickets() async {
  await FirebaseFirestore.instance
      .collection("tournament")
      .get()
      .then((value) async {
    Tournament tournament;
    for (var element in value.docs) {
      tournament = Tournament.fromMap(element.data());
      for (int i = 0; i <= 50; i++) {
        String barcode =
            FirebaseFirestore.instance.collection("ticket").doc().id;
        Ticket ticket = Ticket(
            barcode: barcode,
            tournamentId: tournament.tournamentId!,
            userId: "");
        await FirebaseFirestore.instance
            .collection("ticket")
            .doc(barcode)
            .set(ticket.toMap());
      }
    }
  });
}
