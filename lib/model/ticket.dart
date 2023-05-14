class Ticket {
  String barcode;
  String? userId;
  String tournamentId;

  Ticket({required this.barcode, this.userId, required this.tournamentId});

  // data from server
  factory Ticket.fromMap(map) {
    return Ticket(
        barcode: map['barcode'],
        userId: map['userId'],
        tournamentId: map['tournamentId']);
  }

  // sendig data to our server
  Map<String, dynamic> toMap() {
    return {'barcode': barcode, 'userId': userId, 'tournamentId': tournamentId};
  }

  @override
  String toString() {
    return 'Ticket{barcode: $barcode, userId: $userId, tournamentId: $tournamentId}';
  }
}
