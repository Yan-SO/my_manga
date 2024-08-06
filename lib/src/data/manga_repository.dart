import 'package:my_mangas/src/data/database_helper.dart';
import 'package:my_mangas/src/models/fonts_model.dart';
import 'package:my_mangas/src/models/manga_model.dart';
import 'package:my_mangas/src/models/tegs_model.dart';
import 'package:sqflite/sqflite.dart';

class MangaRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<int> insertManga(MangaModel manga) async {
    final db = await _databaseHelper.database;
    return await db.insert(
      'manga',
      manga.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<MangaModel>> getAllMangas() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query("manga");
    return List.generate(maps.length, (i) {
      return MangaModel.fromJson(maps[i]);
    });
  }

  Future<MangaModel?> getMangaForId(int id) async {
    final db = await _databaseHelper.database;
    final resp = await db.query(
      'manga',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (resp.isNotEmpty) {
      return MangaModel.fromJson(resp.first);
    } else {
      return null;
    }
  }

  Future<void> updateManga(MangaModel manga) async {
    final db = await _databaseHelper.database;
    db.update(
      'manga',
      manga.toJson(),
      where: 'id = ?',
      whereArgs: [manga.id],
    );
  }

  Future<void> deleteManga(int id) async {
    final db = await _databaseHelper.database;
    db.delete(
      'manga',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  //  Métodos para FontsModel

  Future<int> insertFont(FontsModel font) async {
    final db = await _databaseHelper.database;
    return db.insert(
      'fonts',
      font.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<FontsModel>> getAllFonts() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query("fonts");
    return List.generate(maps.length, (i) {
      return FontsModel.fromJson(maps[i]);
    });
  }

  Future<FontsModel?> getFontById(int id) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'fonts',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return FontsModel.fromJson(maps.first);
    } else {
      return null;
    }
  }

  Future<int> getFontsCount() async {
    final db = await _databaseHelper.database;
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM fonts'),
    );
    return count ?? 0;
  }

  Future<void> updateFont(FontsModel font) async {
    final db = await _databaseHelper.database;
    db.update(
      'fonts',
      font.toJson(),
      where: 'id = ?',
      whereArgs: [font.id],
    );
  }

  Future<void> deletefonts(int id) async {
    final db = await _databaseHelper.database;
    await db.delete('fonts', where: 'id = ?', whereArgs: [id]);
  }

  //  Métodos para TegsModel

  Future<int> insertTeg(TegsModel teg) async {
    final db = await _databaseHelper.database;
    return db.insert(
      'tegs',
      teg.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateTeg(TegsModel teg) async {
    final db = await _databaseHelper.database;
    await db.update('tegs', teg.toJson(), where: 'id = ?', whereArgs: [teg.id]);
  }

  Future<void> deleteTeg(int id) async {
    final db = await _databaseHelper.database;
    await db.delete('tegs', where: 'id = ?', whereArgs: [id]);
  }

  // Métodos para gerenciar a relação entre Manga e Tegs

  Future<void> insertMangaTeg(int mangaId, int tegId) async {
    final db = await _databaseHelper.database;
    db.insert(
      "manga_tegs",
      {'mangaId': mangaId, 'tegId': tegId},
    );
  }

  Future<List<TegsModel>> getTegsForManga(int mangaId) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
      SELECT t.* FROM tegs t
      INNER JOIN manga_tegs mt ON t.id = mt.tegId
      WHERE mt.mangaId = ?
      ''',
      [mangaId],
    );
    return List.generate(maps.length, (i) {
      return TegsModel.fromJson(maps[i]);
    });
  }

  Future<List<MangaModel>> getMangasForTeg(int tegId) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT m.* FROM manga m
      INNER JOIN manga_tegs mt ON m.id = mt.mangaId
      WHERE mt.tegId = ?
    ''', [tegId]);
    return List.generate(maps.length, (i) {
      return MangaModel.fromJson(maps[i]);
    });
  }
}
