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
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
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
        lastRead TEXT,
        fontsModelId INTEGER,
        FOREIGN KEY (fontsModelId) REFERENCES fonts (id)
      )
    ''');
    await db.execute('''
      CREATE TABLE fonts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        fontName TEXT,
        children INTEGER,
        imgUrl TEXT,
        urlFont TEXT
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

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE fonts (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          fontName TEXT,
          children INTEGER,
          imgUrl TEXT,
          urlFont TEXT
        )
      ''');
      await db.execute('''
        ALTER TABLE manga ADD COLUMN fontsModelId INTEGER;
      ''');
    }
  }
}
