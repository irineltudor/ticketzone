import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:intl/intl.dart';
import 'package:ticketzone/screen/tournament/tournament_screen.dart';

import '../../model/ticket.dart';
import '../../model/tournament.dart';
import '../../model/user.dart';
import '../../service/storage_service.dart';
import '../../service/ticket_service.dart';
import '../../widget/menu_widget.dart';
import '../settings/settings_screen.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import '../../widget/search_widget.dart';

class TournamentsScreen extends StatefulWidget {
  const TournamentsScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _TournamentsScreenState();
}

class _TournamentsScreenState extends State<TournamentsScreen> {
  User? user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();
  TicketService ticketService = TicketService();

  List<Tournament> tournamentList = [];
  List<Ticket> userTickets = [];

  List<Tournament> searchedTournaments = [];
  String query = '';

  final Storage storage = Storage();

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

    FirebaseFirestore.instance.collection("tournament").get().then((value) {
      Tournament tournament;
      for (var element in value.docs) {
        tournament = Tournament.fromMap(element.data());
        tournamentList.add(tournament);
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    if (loggedInUser.email == null || tournamentList.isEmpty) {
      return Container(
          color: Colors.black,
          child: const Center(
              child: CircularProgressIndicator(
            color: Colors.white,
          )));
    } else {
      if (query == '') {
        searchedTournaments = tournamentList;
      }
      return Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: <Widget>[
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
                              Icon(Icons.gamepad),
                              SizedBox(
                                width: 10,
                              ),
                              Text("Tournaments",
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
                  left: 0,
                  right: 0,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      bottom: const Radius.circular(45),
                      top: const Radius.circular(45),
                    ),
                    child: Container(
                      color: Colors.white,
                      child: Column(children: [
                        SizedBox(
                          height: 10,
                        ),
                        buildSearch(),
                        Expanded(
                            child: ListView.builder(
                                itemCount: searchedTournaments.length,
                                itemBuilder: (context, index) {
                                  return buildTournament(
                                      searchedTournaments[index]);
                                })),
                      ]),
                    ),
                  )),
            ],
          ));
    }
  }

  Widget buildSearch() {
    return SearchWidget(
        text: query,
        hintText: 'Search for tournament',
        onChanged: searchTournament);
  }

  Widget buildTournament(Tournament tournament) {
    DateTime tournamentDate = DateTime.parse(tournament.startDate!);
    int daysLeft = tournamentDate.difference(DateTime.now()).inDays;
    String stringDaysLeft = '${daysLeft} days left';
    if (daysLeft == 1) stringDaysLeft = '1 day left';
    if (daysLeft < 0) stringDaysLeft = 'ended';

    return MaterialButton(
        splashColor: Colors.grey,
        onPressed: () {
          //In order to use go back
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => TournamentScreen(
                      tournamentId: tournament.tournamentId!)));
        },
        child: ListTile(
          title: Text(tournament.name!),
          subtitle: Text(
              '${DateFormat("d-MMM-yy").format(tournamentDate)}, ${stringDaysLeft}'),
          trailing: ClipRRect(
            borderRadius: const BorderRadius.vertical(
              bottom: const Radius.circular(45),
              top: const Radius.circular(45),
            ),
            child: FutureBuilder(
              future: storage.getTournamentPicture(tournament.tournamentId!),
              builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                if (snapshot.connectionState == ConnectionState.done &&
                    snapshot.hasData) {
                  return Image.network(
                    snapshot.data!,
                  );
                }
                if (snapshot.connectionState == ConnectionState.waiting ||
                    !snapshot.hasData) {
                  return CircularProgressIndicator();
                }

                return Container();
              },
            ),
          ),
        ));
  }

  void searchTournament(String query) {
    final searchTournaments = tournamentList.where((tournament) {
      final tournamentName = tournament.name!.toLowerCase();
      final search = query.toLowerCase();
      return tournamentName.contains(search);
    }).toList();

    setState(() {
      this.query = query;
      searchedTournaments = searchTournaments;
    });
  }
}
