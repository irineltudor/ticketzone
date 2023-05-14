import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ticketzone/widget/menu_widget.dart';
import 'package:vector_math/vector_math_64.dart' as math;

import '../../model/ticket.dart';
import '../../model/tournament.dart';
import '../../model/user.dart';
import '../../service/storage_service.dart';
import '../../service/ticket_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  User? user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();
  TicketService ticketService = TicketService();

  List<Tournament> tournamentList = [];
  List<Ticket> userTicketList = [];
  List<Tournament> tournamentTicketList = [];
  List<int> tournamentDaysLeft = [];
  double percentage = 0;
  // late AnimationController animationController;

  final Storage storage = Storage();

  @override
  void initState() {
    super.initState();
    getData();
    // animationController = AnimationController(
    //     vsync: this, duration: const Duration(milliseconds: 1200));
    // animationController.forward();
    // animationController.addListener(() {
    //   setState(() {
    //     percentage = animationController.value;
    //   });
    // });
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
        DateTime tournamentDate = DateTime.parse(tournament.startDate!);
        int daysLeft = tournamentDate.difference(DateTime.now()).inDays;
        if (daysLeft <= 30 && daysLeft >= 0) {
          tournamentList.add(tournament);
        }
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
    if (loggedInUser.email == null) {
      return Container(
          color: Colors.black,
          child: const Center(
              child: CircularProgressIndicator(
            color: Colors.white,
          )));
    } else {
      List<Ticket> value = userTicketList;
      userTicketList = [];
      if (value.isNotEmpty && tournamentList.isNotEmpty) {
        tournamentTicketList = [];
        for (var tournament in tournamentList) {
          for (var ticket in value) {
            if (ticket.tournamentId == tournament.tournamentId) {
              tournamentTicketList.add(tournament);
              userTicketList.add(ticket);
              break;
            }
          }
        }
      }

      return Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: <Widget>[
              Positioned(
                top: 0,
                height: height * 0.17,
                left: 0,
                right: 0,
                child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                        bottom: const Radius.circular(45)),
                    child: Container(
                      padding: const EdgeInsets.only(
                          top: 21, left: 32, right: 32, bottom: 10),
                      color: Colors.white,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          ListTile(
                            title: Text(
                                "${DateFormat("EEEE").format(DateTime.now())}, ${DateFormat("d MMMM").format(DateTime.now())}",
                                style: const TextStyle(
                                    fontFamily: 'Kanit-Regular',
                                    fontSize: 14,
                                    color: Colors.grey)),
                            subtitle: Text("Hello, ${loggedInUser.firstname}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 26,
                                  color: Colors.black,
                                )),
                            trailing: ClipOval(
                              child: FutureBuilder(
                                future: storage
                                    .getProfilePicture('${loggedInUser.uid}'),
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
                    )),
              ),
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
                  top: height * 0.182,
                  height: height * 0.715,
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
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Center(
                                  child: Text("Incoming events",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 26,
                                          color: Colors.black,
                                          fontFamily: 'KanitRegular')),
                                ),
                                Expanded(
                                  child: GridView.builder(
                                      gridDelegate:
                                          SliverGridDelegateWithMaxCrossAxisExtent(
                                              maxCrossAxisExtent: width / 2,
                                              childAspectRatio: 3 / 1.5,
                                              crossAxisSpacing: width / 2,
                                              mainAxisSpacing: 20),
                                      // itemCount: userTicketList.length,
                                      itemCount: userTicketList.length,
                                      itemBuilder: (BuildContext ctx, index) {
                                        DateTime tournamentDate =
                                            DateTime.parse(
                                                tournamentTicketList[index]
                                                    .startDate!);
                                        int daysLeft = tournamentDate
                                            .difference(DateTime.now())
                                            .inDays;
                                        return FutureBuilder(
                                          future: storage.getTournamentPicture(
                                              tournamentTicketList[index]
                                                  .tournamentId!),
                                          builder: (BuildContext context,
                                              AsyncSnapshot<String> snapshot) {
                                            if (snapshot.connectionState ==
                                                    ConnectionState.done &&
                                                snapshot.hasData) {
                                              return Container(
                                                alignment: Alignment.center,
                                                margin: EdgeInsets.all(10),
                                                decoration: BoxDecoration(
                                                    image: DecorationImage(
                                                        image: NetworkImage(
                                                            snapshot.data!),
                                                        fit: BoxFit.cover),
                                                    color: Colors.black,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15),
                                                    border: Border.all(
                                                        color: Colors.black)),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    Expanded(
                                                      flex: 1,
                                                      child: Container(
                                                        padding:
                                                            EdgeInsets.only(
                                                                top: 10,
                                                                left: 10,
                                                                bottom: 10,
                                                                right: 0),
                                                        width: width / 4,
                                                        child: Center(
                                                          child:
                                                              _RadialProgress(
                                                            width: width * 0.20,
                                                            height:
                                                                width * 0.20,
                                                            daysLeft: daysLeft,
                                                            percentage:
                                                                percentage,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            }
                                            if (snapshot.connectionState ==
                                                    ConnectionState.waiting ||
                                                !snapshot.hasData) {
                                              return Center(
                                                child: Container(
                                                  width: width / 1.24,
                                                  decoration: BoxDecoration(
                                                      color: Colors.black,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15),
                                                      border: Border.all(
                                                          color: Colors.black)),
                                                  height: height / 5.4,
                                                  child:
                                                      CircularProgressIndicator(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              );
                                            }

                                            return Image.asset(
                                                "assets/tournament.jpg");
                                          },
                                        );
                                      }),
                                ),
                              ],
                            )
                          : Center(
                              child: Text(
                                "*You have no tickets for events this month.",
                                style: TextStyle(fontSize: 15),
                              ),
                            ),
                    ),
                  )),
            ],
          ));
    }
  }

  // @override
  // void dispose() {
  //   animationController.dispose();

  //   super.dispose();
  // }
}

class _RadialProgress extends StatelessWidget {
  final double height, width;
  final int daysLeft;
  final double percentage;

  const _RadialProgress(
      {Key? key,
      required this.height,
      required this.width,
      required this.daysLeft,
      required this.percentage})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    String dayLeftString = "days Left";
    if (daysLeft == 1) dayLeftString = "day left";
    return CustomPaint(
      foregroundPainter:
          _RadialPainter(daysLeft: daysLeft, percentage: percentage),
      child: SizedBox(
        height: height,
        width: width,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(40),
            color: Color.fromARGB(190, 0, 0, 0),
          ),
          child: Center(
            child: RichText(
                textAlign: TextAlign.center,
                text: this.daysLeft > 0
                    ? TextSpan(children: [
                        TextSpan(
                            text: this.daysLeft.toString(),
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    blurRadius: 1,
                                    color: Colors.black,
                                  ),
                                ])),
                        TextSpan(text: "\n"),
                        TextSpan(
                          text: dayLeftString,
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  blurRadius: 1,
                                  color: Colors.black,
                                ),
                              ]),
                        )
                      ])
                    : TextSpan(
                        text: "Today",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                blurRadius: 1,
                                color: Colors.black,
                              ),
                            ]))),
          ),
        ),
      ),
    );
  }
}

class _RadialPainter extends CustomPainter {
  final int daysLeft;
  final double percentage;

  _RadialPainter({
    required this.daysLeft,
    required this.percentage,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint paintWhite = Paint()
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke
      ..color = Colors.black
      ..strokeCap = StrokeCap.round;

    Paint paintBlack = Paint()
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke
      ..color = Colors.white
      ..strokeCap = StrokeCap.butt;

    Offset center = Offset(size.width / 2, size.height / 2);

    canvas.drawArc(Rect.fromCircle(center: center, radius: size.width / 2),
        math.radians(-90), math.radians(-360), false, paintWhite);
    canvas.drawArc(
        Rect.fromCircle(center: center, radius: size.width / 2),
        math.radians(-90),
        math.radians(-360 * ((30 - daysLeft.toDouble()) / 30)),
        false,
        paintBlack);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
