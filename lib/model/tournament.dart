class Tournament {
  String? tournamentId;
  String? name;
  String? game;
  String? prize;
  String? location;
  String? startDate;

  Tournament(
      {this.tournamentId,
      this.name,
      this.game,
      this.prize,
      this.location,
      this.startDate});

  // data from server
  factory Tournament.fromMap(map) {
    return Tournament(
        tournamentId: map['tournamentId'],
        name: map['name'],
        game: map['game'],
        prize: map['prize'],
        location: map['location'],
        startDate: map['startDate']);
  }

  // sendig data to our server
  Map<String, dynamic> toMap() {
    return {
      'tournamentId': tournamentId,
      'name': name,
      'game': game,
      'prize': prize,
      'location': location,
      'startDate': startDate
    };
  }

  @override
  String toString() {
    return 'Tournament{tournamentId: $tournamentId, name: $name, game:$game, prize: $prize, location: $location, startDate: $startDate}';
  }
}
