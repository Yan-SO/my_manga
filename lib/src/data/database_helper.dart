import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'app_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE manga (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        imgUrl TEXT,
        urlManga TEXT,
        chaptersRead REAL,
        totalChapters REAL,
        lastRead TEXT
      )
    ''');
    await db.execute('''
    CREATE TABLE tegs (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      tegName TEXT,
      children INTEGER
    )
    ''');
    await db.execute('''
      CREATE TABLE manga_tegs (
        mangaId INTEGER,
        tegId INTEGER,
        FOREIGN KEY (mangaId) REFERENCES manga (id),
        FOREIGN KEY (tegId) REFERENCES tegs (id)
      )
    ''');
  }
}
