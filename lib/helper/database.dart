import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class LocalStorage {
  static Database? _database;

  static final LocalStorage instance = LocalStorage._privateConstructor();

  LocalStorage._privateConstructor();

  Future<Database?> get database async {
    if (_database != null) {
      return _database;
    }

    _database = await _initDatabase();
    return _database;
  }

  Future<Database> _initDatabase() async {
    // buat database dan tabel
    final dbPath = await getDatabasesPath();
    return await openDatabase(
      join(dbPath, 'my_database.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE my_table(id INTEGER PRIMARY KEY AUTOINCREMENT, key TEXT, value TEXT)',
        );
      },
      version: 1,
    );
  }

  // tambahkan data ke tabel
  Future<int> save(String key, String value) async {
    final db = await database;
    final insertionData = {
      'key': key,
      'value': value,
    };

    // return kalo db gak ke init
    if (db == null) return 0;
    List prevData = await db.query(
      'my_table',
      where: 'key  = ?',
      whereArgs: [key],
    );

    // kalo data dengan key yang dikasih sudah ada
    // update data di db instead of insert data
    if (prevData.isNotEmpty) {
      return await db.update(
        'my_table',
        insertionData,
        where: 'key  = ?',
        whereArgs: [key],
      );
    }

    // insert data ke db
    return await db.insert('my_table', insertionData);
  }

  // ambil data dari tabel
  Future<String> get(String key) async {
    final db = await database;
    // return kalo db gak ke init
    if (db == null) return '';
    final result = await db.query(
      'my_table',
      columns: ['key', 'value'],
      where: 'key = ?',
      whereArgs: [key],
    );
    if (result.isEmpty) return '';
    return result[0]['value'].toString();
  }

  // hapus data dari tabel
  Future<int> remove(String key) async {
    final db = await database;

    // return kalo db gak ke init
    if (db == null) return 0;
    List prevData = await db.query(
      'my_table',
      where: 'key  = ?',
      whereArgs: [key],
    );

    // kalo data dengan key yang dikasih ada
    // delete data dari db
    if (prevData.isNotEmpty) {
      return await db.delete(
        'my_table',
        where: 'key  = ?',
        whereArgs: [key],
      );
    }

    // ga lakuin apa-apa karena data nya gak exist
    return 0;
  }
}
