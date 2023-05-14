import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../model/ticket.dart';
import '../../model/tournament.dart';
import '../../model/user.dart';
import '../../service/storage_service.dart';
import '../../service/ticket_service.dart';
import 'package:video_player/video_player.dart';

// ignore: must_be_immutable
class TournamentScreen extends StatefulWidget {
  String tournamentId;
  TournamentScreen({super.key, required this.tournamentId});

  @override
  State<TournamentScreen> createState() =>
      _TournamentScreenState(tournamentId: tournamentId);
}

class _TournamentScreenState extends State<TournamentScreen> {
  final String tournamentId;
  final Storage storage = Storage();
  User? user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();
  TicketService ticketService = TicketService();
  Tournament tournament = Tournament();

  List<Ticket> tournamentTicketList = [];
  List<Ticket> usertTicketList = [];

  final ticketNoEditingController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late VideoPlayerController controller;
  bool promoVideo = false;

  _TournamentScreenState({required this.tournamentId});

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

    FirebaseFirestore.instance
        .collection("tournament")
        .doc(tournamentId)
        .get()
        .then((value) {
      tournament = Tournament.fromMap(value.data());
      print(value.data());
      print(tournament);
      setState(() {});
    });

    FirebaseFirestore.instance.collection("ticket").get().then((value) {
      tournamentTicketList = [];
      for (var element in value.docs) {
        if (element.data().isNotEmpty) {
          Ticket ticket = Ticket.fromMap(element.data());
          if (ticket.tournamentId == tournamentId && ticket.userId == "") {
            tournamentTicketList.add(ticket);
          }
        }
      }
      setState(() {});
    });

    await ticketService.getTicketsForUser(user!.uid).then((value) {
      usertTicketList = value;
      setState(() {});
    });

    await storage.getTournamentPromo(tournamentId).then((value) {
      if (value != "error") {
        controller = VideoPlayerController.network(value)
          ..initialize().then((_) {
            setState(() {});
          });
        controller.play();
        controller.setVolume(0.0);
        promoVideo = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final textColor = Colors.white;

    int ticketsLeft = tournamentTicketList.length;

    if (loggedInUser.uid == null || tournament.tournamentId == null) {
      return Container(
          color: Colors.black,
          child: const Center(
              child: CircularProgressIndicator(
            color: Colors.white,
          )));
    } else {
      DateTime tournamentDate = DateTime.parse(tournament.startDate!);
      int daysLeft = tournamentDate.difference(DateTime.now()).inDays;
      String stringDaysLeft = '${daysLeft} days left';
      if (daysLeft == 1) stringDaysLeft = '1 day left';

      String ticketsLeftString = "";
      switch (ticketsLeft) {
        case 0:
          {
            ticketsLeftString = "There are no tickets left";
          }
          break;

        case 1:
          {
            ticketsLeftString = "There is 1 ticket left";
          }
          break;

        default:
          {
            ticketsLeftString = "There are $ticketsLeft tickets left";
          }
          break;
      }

      if (daysLeft < 0) {
        stringDaysLeft = 'ended';
        ticketsLeftString = 'This tournament is over';
      }

      final ticketNoField = TextFormField(
        autofocus: false,
        controller: ticketNoEditingController,
        style: const TextStyle(color: Colors.black),
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r"^[0-9]+$"))
        ],
        validator: (value) {
          if (value!.isEmpty) {
            return ("Number of tickets cannot be empty");
          }

          if (int.parse(value) > ticketsLeft) {
            return (ticketsLeftString);
          }

          if (int.parse(value) == 0) {
            return ("Number of tickets cannot be zero");
          }

          return null;
        },
        onSaved: (value) {
          ticketNoEditingController.text = value!;
        },
        textInputAction: TextInputAction.next,
        decoration: const InputDecoration(
          prefixIcon: Icon(
            Icons.shopping_bag,
            color: Colors.grey,
          ),
          contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
          hintText: "Number of tickets",
          hintStyle: TextStyle(color: Colors.grey),
          errorStyle: TextStyle(color: Colors.red),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(20)),
              borderSide: BorderSide(color: Colors.black)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(20)),
              borderSide: BorderSide(color: Colors.black)),
        ),
      );

      final buyTicketButtonUnavailable = Container(
        width: width,
        child: Material(
            elevation: 5,
            color: Colors.grey,
            child: IconButton(
                icon: const Icon(Icons.shopping_cart,
                    color: Colors.white, size: 30),
                disabledColor: Colors.grey,
                onPressed: null)),
      );

      final buyTicketButton = Container(
        width: width,
        child: Material(
            elevation: 5,
            color: Colors.green,
            child: IconButton(
                icon: const Icon(Icons.shopping_cart,
                    color: Colors.white, size: 30),
                onPressed: () => {openDialog(ticketNoField)})),
      );

      return Scaffold(
          backgroundColor: Colors.black,
          bottomNavigationBar: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(40)),
                child: SizedBox(
                  width: width / 2.3,
                  child: Material(
                      elevation: 5,
                      color: Colors.black,
                      child: Center(
                        child: Text(
                          ticketsLeftString,
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      )),
                ),
              ),
              SizedBox(
                height: 6,
              ),
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(40)),
                child: ticketsLeft > 0 && daysLeft >= 0
                    ? buyTicketButton
                    : buyTicketButtonUnavailable,
              ),
            ],
          ),
          body: CustomScrollView(slivers: <Widget>[
            SliverAppBar(
              snap: true,
              floating: true,
              backgroundColor: Colors.black,
              expandedHeight: 200,
              iconTheme: IconThemeData(
                  color: Colors.white,
                  size: 25,
                  shadows: [Shadow(blurRadius: 6, color: Colors.black)]),
              shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.vertical(bottom: Radius.circular(40))),
              flexibleSpace: FlexibleSpaceBar(
                background: ClipRRect(
                  borderRadius:
                      BorderRadius.vertical(bottom: Radius.circular(40)),
                  child: Flex(
                    direction: Axis.horizontal,
                    children: [
                      Flexible(
                        fit: FlexFit.tight,
                        child: ClipRRect(
                          borderRadius: BorderRadius.vertical(
                              bottom: Radius.circular(40)),
                          child: promoVideo
                              ? InkWell(
                                  onTap: () {
                                    if (controller.value.isPlaying) {
                                      controller.pause();
                                    } else {
                                      controller.play();
                                    }
                                  },
                                  child: AspectRatio(
                                    aspectRatio: controller.value.aspectRatio,
                                    child: VideoPlayer(controller),
                                  ),
                                )
                              : FutureBuilder(
                                  future: storage
                                      .getTournamentPicture(tournamentId),
                                  builder: (BuildContext context,
                                      AsyncSnapshot<String> snapshot) {
                                    if (snapshot.connectionState ==
                                            ConnectionState.done &&
                                        snapshot.hasData) {
                                      return Image.network(snapshot.data!,
                                          width: width, fit: BoxFit.cover);
                                    }
                                    if (snapshot.connectionState ==
                                            ConnectionState.waiting ||
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
                    ],
                  ),
                ),
              ),
            ),
            SliverList(
                delegate: SliverChildListDelegate([
              SizedBox(
                height: 20,
              ),
              ListTile(
                title: Text(
                  '${tournament.game}',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: Colors.grey,
                  ),
                ),
                subtitle: Text(
                  '${tournament.name}',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 26,
                    color: textColor,
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "Location",
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: Colors.blueGrey,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 32),
                child: Text(
                  "${tournament.location}",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "Prize",
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: Colors.blueGrey,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 32),
                child: Text(
                  "${tournament.prize}\$",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "Date",
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: Colors.blueGrey,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 32),
                child: Text(
                  "${DateFormat("d-MMM-yy").format(tournamentDate)}, ${stringDaysLeft}",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                ),
              ),
            ])),
          ]));
    }
  }

  Future openDialog(TextFormField ticketNoField) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("No of tickets : "),
        content: Form(
          key: _formKey,
          child: ticketNoField,
        ),
        actions: [
          TextButton(
              onPressed: () {
                buyTickets();
              },
              child: Text("Buy"))
        ],
      ),
    );
  }

  Future<void> buyTickets() async {
    if (_formKey.currentState!.validate()) {
      int tickets = int.parse(ticketNoEditingController.text);

      for (int i = 0; i < tickets; i++) {
        Ticket ticket = tournamentTicketList[i];
        ticket.userId = loggedInUser.uid;

        if (await ticketService.existsTicket(ticket)) {
          ticketService.updateTicket(ticket);
        } else {
          ticketService.saveTicket(ticket);
        }
        await FirebaseFirestore.instance
            .collection("ticket")
            .doc(ticket.barcode)
            .set(ticket.toMap());
      }

      Navigator.of(context).pop();
      setState(() {
        getData();
      });
    }
  }

  @override
  void dispose() {
    if (promoVideo) {
      controller.dispose();
    }
    super.dispose();
  }
}
