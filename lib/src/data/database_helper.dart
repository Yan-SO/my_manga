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
    print('Initializing database...');
    String path = join(await getDatabasesPath(), 'app_database.db');
    final db = await openDatabase(
      path,
      version: 5,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
    final version = await db.getVersion();
    print('Current database version: $version');
    return db;
  }

  Future<void> _onCreate(Database db, int version) async {
    print('Creating database version $version');
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
    await db.execute('''
  CREATE TABLE settings (
    key TEXT PRIMARY KEY,
    value TEXT
  )
''');
    await db.insert('settings', {
      'key': 'showNavigationQuest',
      'value': 'true',
    });
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    print('Upgrading database from version $oldVersion to $newVersion');
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

    if (oldVersion < 5) {
      await db.execute('''
    CREATE TABLE settings (
      key TEXT PRIMARY KEY,
      value TEXT
    )
  ''');
      await db.insert('settings', {
        'key': 'showNavigationQuest',
        'value': 'true',
      });
    }
  }
}
