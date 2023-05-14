import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../model/ticket.dart';
import '../../model/tournament.dart';
import '../../model/user.dart';
import '../../service/storage_service.dart';
import '../../service/ticket_service.dart';
import '../../widget/menu_widget.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'dart:math' as math;

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  User? user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();
  TicketService ticketService = TicketService();

  List<Tournament> tournamentList = [];
  List<Ticket> userTicketList = [];
  List<Tournament> tournamentTicketList = [];

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
      tournamentList = [];
      Tournament tournament;
      for (var element in value.docs) {
        tournament = Tournament.fromMap(element.data());
        tournamentList.add(tournament);
      }
      setState(() {});
    });

    await ticketService.getTicketsForUser(user!.uid).then((value) {
      userTicketList = value;
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
      tournamentTicketList = [];
      userTicketList.forEach(
        (ticket) {
          tournamentList.forEach((tournament) {
            if (ticket.tournamentId == tournament.tournamentId) {
              tournamentTicketList.add(tournament);
            }
          });
        },
      );
      return Scaffold(
        backgroundColor: Colors.black,
        body: Stack(children: <Widget>[
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
                          Icon(Icons.inventory),
                          SizedBox(
                            width: 10,
                          ),
                          Text("Inventory",
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
                    boxShadow: [BoxShadow(color: Colors.black, blurRadius: 3)]),
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
                  padding: const EdgeInsets.only(
                      top: 30, left: 32, right: 32, bottom: 10),
                  child: userTicketList.isNotEmpty
                      ? GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: width / 2,
                                  childAspectRatio: 3 / 1.5,
                                  crossAxisSpacing: width / 2,
                                  mainAxisSpacing: 20),
                          // itemCount: userTicketList.length,
                          itemCount: userTicketList.length,
                          itemBuilder: (BuildContext ctx, index) {
                            return GestureDetector(
                              onTap: () {
                                openDialog(index);
                              },
                              child: Container(
                                alignment: Alignment.center,
                                margin: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(color: Colors.black)),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: Container(
                                        padding: EdgeInsets.only(
                                            top: 10,
                                            left: 10,
                                            bottom: 10,
                                            right: 0),
                                        width: width / 4,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              tournamentTicketList[index].name!,
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 13),
                                            ),
                                            Expanded(
                                                child: Center(
                                              child: Image.asset(
                                                  "assets/logo/ticketzone-logo-black.png"),
                                            )),
                                            Row(
                                              children: [
                                                Text(
                                                  tournamentTicketList[index]
                                                      .game!,
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Expanded(child: SizedBox()),
                                                Text(
                                                  tournamentTicketList[index]
                                                      .startDate!,
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: width / 3,
                                      height: height / 7,
                                      child: Transform.rotate(
                                        angle: -math.pi / 2,
                                        child: BarcodeWidget(
                                          barcode: Barcode.code128(),
                                          data: userTicketList[0].barcode,
                                          drawText: false,
                                          width: width / 3,
                                          height: height / 6,
                                          backgroundColor: Colors.white,
                                          padding: EdgeInsets.all(9),
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.only(
                                                  bottomLeft:
                                                      Radius.circular(10),
                                                  bottomRight:
                                                      Radius.circular(10))),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          })
                      : Center(
                          child: Text("*Your invetory is empty"),
                        ),
                ),
              )),
        ]),
      );
    }
  }

  Future openDialog(int index) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${tournamentTicketList[index].name}'),
        titleTextStyle: TextStyle(
            color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        backgroundColor: Colors.black,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              fit: FlexFit.loose,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: FutureBuilder(
                  future: storage.getTournamentPicture(
                      tournamentTicketList[index].tournamentId!),
                  builder:
                      (BuildContext context, AsyncSnapshot<String> snapshot) {
                    if (snapshot.connectionState == ConnectionState.done &&
                        snapshot.hasData) {
                      return Image.network(snapshot.data!,
                          width: width, fit: BoxFit.fitWidth);
                    }
                    if (snapshot.connectionState == ConnectionState.waiting ||
                        !snapshot.hasData) {
                      return Center(
                        child: Container(
                          width: 150,
                          height: 150,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                          color: Colors.black,
                        ),
                      );
                    }

                    return Image.asset("assets/tournament.jpg");
                  },
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Text(
                  tournamentTicketList[index].game!,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Expanded(child: SizedBox()),
                Text(
                  tournamentTicketList[index].startDate!,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            BarcodeWidget(
              barcode: Barcode.code128(),
              data: userTicketList[index].barcode,
              drawText: false,
              width: width,
              height: height / 6,
              backgroundColor: Colors.white,
              padding: EdgeInsets.all(9),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(20)),
            ),
          ],
        ),
        actions: [
          Material(
            borderRadius: BorderRadius.circular(30),
            color: Colors.black,
            child: MaterialButton(
              padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                  side: BorderSide(color: Colors.white)),
              onPressed: () => {refundTicket(userTicketList[index])},
              minWidth: width,
              child: const FittedBox(
                child: Text(
                  'Refund',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> refundTicket(Ticket ticket) async {
    ticket.userId = "";

    FirebaseFirestore.instance
        .collection("ticket")
        .doc(ticket.barcode)
        .set(ticket.toMap());

    ticketService.deleteTicket(ticket.barcode);

    Navigator.of(context).pop();
    setState(() {
      getData();
    });
  }
}
