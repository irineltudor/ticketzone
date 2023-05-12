import '../helper/DBHelper.dart';
import '../model/ticket.dart';

class TicketService {
  String table = "ticket";

  Future<void> saveTicket(Ticket ticket) async {
    await DBHelper.insert(table, ticket.toMap());
  }

  Future<Ticket> getTicketWithId(String id) async {
    List<Map<String, dynamic>> tickets = await DBHelper.getObject(table, id);
    Ticket ticketModel = Ticket.fromMap(tickets[0]);
    return ticketModel;
  }

  Future<List<Ticket>> getTickets() async {
    List<Map<String, dynamic>> tickets = await DBHelper.getData(table);

    return List.generate(tickets.length, (i) {
      return Ticket.fromMap(tickets[i]);
    });
  }

  Future<void> deleteTicket(String id) async {
    // Remove the Dog from the database.
    await DBHelper.delete(table, id);
  }

  Future<List<Ticket>> getTicketsForTournament(int tournamentId) async {
    List<Map<String, dynamic>> tournamentTickets =
        await DBHelper.getObjectWhere(
            table, 'tournamentId', tournamentId.toString());

    return List.generate(tournamentTickets.length, (i) {
      return Ticket.fromMap(tournamentTickets[i]);
    });
  }

  Future<List<Ticket>> getTicketsAvailableForTournament(
      int tournamentId) async {
    List<Map<String, dynamic>> tournamentTickets =
        await DBHelper.getObjectWhereAvailable(
            table, 'tournamentId', tournamentId.toString());

    return List.generate(tournamentTickets.length, (i) {
      return Ticket.fromMap(tournamentTickets[i]);
    });
  }

  Future<List<Ticket>> getTicketsForUser(String userId) async {
    List<Map<String, dynamic>> userTickets =
        await DBHelper.getObjectWhere(table, 'userId', userId);

    return List.generate(userTickets.length, (i) {
      return Ticket.fromMap(userTickets[i]);
    });
  }

  Future<void> updateTicket(Ticket ticket) async {
    await DBHelper.updateData(table, ticket.toMap(), ticket.barcode);
  }

  Future<bool> existsTicket(Ticket ticket) async {
    return await DBHelper.existsTicket(table, ticket.barcode);
  }

  Future<void> deleteFromTable() async {
    await DBHelper.deleteFrom(table);
  }
}
