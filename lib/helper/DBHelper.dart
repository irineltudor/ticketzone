import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static final DBHelper instance = DBHelper._initialize();
  static Database? _database;

  DBHelper._initialize();

  Future _createDB(Database db, int version) async {
    await db.execute('''
        CREATE TABLE ticket(
          barcode TEXT PRIMARY KEY,
          userId TEXT NULL,
          tournamentId TEXT);''');
  }

  Future _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<Database> _initDB(String fileName) async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, fileName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      onConfigure: _onConfigure,
    );
  }

  Future close() async {
    final db = await instance.database;
    db!.close();
  }

  Future<Database?> get database async {
    if (_database != null) {
      return _database;
    } else {
      _database = await _initDB('ticketzone3.db');
      return _database;
    }
  }

  static Future<void> insert(String table, Map<String, dynamic> data) async {
    final db = await instance.database;
    await db!.insert(table, data, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<List<Map<String, dynamic>>> getData(String table) async {
    final db = await instance.database;
    return await db!.query(table);
  }

  static Future<void> updateUser(Map<String, dynamic> data, String uid) async {
    final db = await instance.database;
    await db!.update("user", data, where: 'uid = ?', whereArgs: [uid]);
  }

  static Future<void> updateData(
      String table, Map<String, dynamic> data, String id) async {
    final db = await instance.database;
    await db!.update(table, data, where: 'barcode = ?', whereArgs: [id]);
  }

  static Future<void> updateTicket(
      String table, Map<String, dynamic> data, String barcode) async {
    final db = await instance.database;
    await db!.update(table, data, where: 'barcode = ?', whereArgs: [barcode]);
  }

  static Future<void> delete(String table, String id) async {
    final db = await instance.database;
    await db!.delete(
      table,
      where: 'barcode = ?',
      whereArgs: [id],
    );
  }

  static Future<List<Map<String, Object?>>> getObject(
      String table, String id) async {
    final db = await instance.database;
    return await db!.query(
      table,
      where: '${table}Id = ?',
      whereArgs: [id],
    );
  }

  static Future<List<Map<String, Object?>>> getUser(
      String table, String uid) async {
    final db = await instance.database;
    return await db!.query(
      table,
      where: 'uid = ?',
      whereArgs: [uid],
    );
  }

  static Future<List<Map<String, Object?>>> getObjectWhere(
      String table, String what, String value) async {
    final db = await instance.database;
    return await db!.query(table, where: '$what = ?', whereArgs: [value]);
  }

  static getObjectWhereAvailable(
      String table, String what, String value) async {
    final db = await instance.database;
    return await db!.query(table,
        where: '$what = ? and userId is null', whereArgs: [value]);
  }

  static Future<bool> existsTicket(String table, String barcode) async {
    final db = await instance.database;
    bool result = true;
    await db!
        .query(table, where: 'barcode = ?', whereArgs: [barcode]).then((value) {
      result = value.isEmpty ? false : true;
    });
    return result;
  }

  static Future<void> deleteFrom(String table) async {
    final db = await instance.database;
    await db!.delete(table);
  }
}
// -- Insert Games
// INSERT INTO game (title, genre, release_date) VALUES
//                                                   ('Dota2', 'MOBA', '2013-07-09'),
//                                                   ('Fortnite', 'BattleRoyale', '2017-07-21'),
//                                                   ('Counter-Strike: Global Offensive', 'TacticalShooter', '2012-08-21'),
//                                                   ('PUBG', 'BattleRoyale', '2017-03-23');

// -- Insert Locations
// INSERT INTO location (name, address) VALUES
//                                          ('United States', 'Washington, D.C.'),
//                                          ('France', 'Paris'),
//                                          ('South Korea', 'Seul');

// -- Insert Sponsors
// INSERT INTO sponsor (name) VALUES ('INTEL'), ('COCA-COLA'), ('RED BULL');

// -- Insert Players
// INSERT INTO player (first_name, last_name, dob, team_id) VALUES
//                                                              ('Ivan', 'Ivanov', '1995-01-20', 1),
//                                                              ('Johan', 'Sundstein', '1993-10-08', 2),
//                                                              ('Sumail', 'Hassan', '1999-02-13', 3),
//                                                              ('Magomed', 'Khalilov', '2002-02-25', 4);

// -- Insert Tournaments
// INSERT INTO tournament (name, type, date, prize,game_id,location_id) VALUES
//                                                                          ('Dota 2 – The International 2023', '5v5', '2023-10-02', '2.000.000$',1,1),
//                                                                          ('Fortnite - World Cup 2023', '5v5', '2023-11-08', '1.500.000$',2,2),
//                                                                          ('CS:GO – BLAST Paris Major 2023', '1v1', DATE_FORMAT(NOW(),'%Y-%m-%d'), '1.000.000$ and RedBull for life',3,3),
//                                                                          ('Incoming event', '1v1', DATE_FORMAT(NOW(),'%Y-%m-%d'), '1.000.000$',null,null);

// -- Insert Tournament-Sponsor relationship
// INSERT INTO tournament_sponsor (tournament_id, sponsor_id) VALUES
//                                                                (1, 1),
//                                                                (1, 2),
//                                                                (2, 2),
//                                                                (3, 3);

// -- Insert Tournament-Team relationship
// INSERT INTO tournament_team (tournament_id, team_id) VALUES
//                                                          (1, 1),
//                                                          (1, 2),
//                                                          (2, 1),
//                                                          (2, 3),
//                                                          (3, 1),
//                                                          (3, 4);