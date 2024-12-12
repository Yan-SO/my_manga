import 'dart:async';

import 'package:my_mangas/src/data/database_helper.dart';
import 'package:my_mangas/src/data/models/fonts_model.dart';
import 'package:my_mangas/src/data/models/manga_model.dart';
import 'package:my_mangas/src/data/models/tegs_model.dart';
import 'package:sqflite/sqflite.dart';

class MangaRepository {
  MangaRepository._privateConstructor();
  static final MangaRepository _instance =
      MangaRepository._privateConstructor();

  factory MangaRepository() {
    return _instance;
  }

  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final StreamController<void> _dbChangeController =
      StreamController.broadcast();
  Stream<void> get dbChanges => _dbChangeController.stream;

  // Métodos para manga

  Future<int> insertManga(MangaModel manga) async {
    final db = await _databaseHelper.database;
    _dbChangeController.add(null);
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

  Future<List<MangaModel>> getMangasByTitle(String title) async {
    final db = await _databaseHelper.database;
    final resp = await db.query(
      'manga',
      where: 'title = ?',
      whereArgs: [title],
    );
    return List.generate(resp.length, (i) {
      return MangaModel.fromJson(resp[i]);
    });
  }

  Future<void> updateManga(MangaModel manga) async {
    final db = await _databaseHelper.database;
    db.update(
      'manga',
      manga.toJson(),
      where: 'id = ?',
      whereArgs: [manga.id],
    );
    print('object ${manga.title}');
    _dbChangeController.add(null);
  }

  Future<void> deleteManga(int id) async {
    final db = await _databaseHelper.database;
    db.delete(
      'manga',
      where: 'id = ?',
      whereArgs: [id],
    );
    _dbChangeController.add(null);
  }

  //  Métodos para FontsModel

  Future<int> insertFont(FontsModel font) async {
    final db = await _databaseHelper.database;
    _dbChangeController.add(null);
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
    _dbChangeController.add(null);
  }

  Future<void> _deletefonts(int id) async {
    final db = await _databaseHelper.database;
    await db.delete('fonts', where: 'id = ?', whereArgs: [id]);
    _dbChangeController.add(null);
  }

  //  Métodos para TegsModel

  Future<int> insertTeg(TegsModel teg) async {
    final db = await _databaseHelper.database;
    _dbChangeController.add(null);
    return db.insert(
      'tegs',
      teg.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateTeg(TegsModel teg) async {
    final db = await _databaseHelper.database;
    await db.update('tegs', teg.toJson(), where: 'id = ?', whereArgs: [teg.id]);
    _dbChangeController.add(null);
  }

  Future<void> deleteTeg(int id) async {
    final db = await _databaseHelper.database;
    await db.delete('tegs', where: 'id = ?', whereArgs: [id]);
    _dbChangeController.add(null);
  }

  // Métodos para gerenciar a relação entre Manga e Tegs

  Future<void> insertMangaTeg(int mangaId, int tegId) async {
    final db = await _databaseHelper.database;
    db.insert(
      "manga_tegs",
      {'mangaId': mangaId, 'tegId': tegId},
    );
    _dbChangeController.add(null);
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

// metodos relaçoes entre mangas e fontes

  Future<List<MangaModel>> getMangasbyIdfromFont(int id) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'manga',
      where: 'fontsModelId = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) {
      return [];
    }

    return List<MangaModel>.from(maps.map((map) => MangaModel.fromJson(map)));
  }

  Future<void> linkFontInManga(MangaModel manga, FontsModel font) async {
    final updateMangaFuture = updateManga(
      manga.copyWith(fontsModelId: font.id),
    );
    final updateFontFuture = updateFont(font.copyWith(
      children: (font.children + 1),
    ));

    await Future.wait([updateMangaFuture, updateFontFuture]);
  }

  Future<void> unlinkFontInManga(MangaModel manga, FontsModel font) async {
    final updateMangaFuture = updateManga(manga.updateFonts(null));
    final updateFontFuture = updateFont(font.copyWith(
      children: (font.children - 1),
    ));

    await Future.wait([updateMangaFuture, updateFontFuture]);
  }

  Future<void> safeDeletefonts(FontsModel font) async {
    final mangaList = await getMangasbyIdfromFont(font.id!);

    await Future.forEach(mangaList, (manga) async {
      await unlinkFontInManga(manga, font);
    });

    await _deletefonts(font.id!);
  }
}
