import 'package:flutter/material.dart';
import 'package:my_mangas/src/data/manga_repository.dart';
import 'package:my_mangas/src/data/models/fonts_model.dart';
import 'package:my_mangas/src/data/models/manga_model.dart';
import 'package:my_mangas/src/ui/components/show_custom_alert.dart';

class ConfirmDeleteAlert {
  MangaRepository _repository = MangaRepository();

  Future<void> deletefont(FontsModel font, BuildContext context) async {
    final resp = await showCustomAlert(
      context,
      title: 'Deletar',
      message: "Tem certeza em Deletar essa Fonte?",
    );
    if (resp == true) {
      await _repository.safeDeletefonts(font);
    }
  }

  Future<void> cleanURLMangaOrFont(
    BuildContext context, {
    MangaModel? manga,
    FontsModel? font,
  }) async {
    final resp = await showCustomAlert(
      context,
      title: 'Deletar',
      message: 'Deseja apagar a URL salva?',
    );
    if (resp == true) {
      if (manga != null) {
        await _repository.updateManga(manga.updateUrlManga(null));
      }
      if (font != null) {
        await _repository.updateFont(font.updateUrlFont(null));
      }
    }
  }

  Future<void> unlinkFontInManga(
    BuildContext context, {
    required FontsModel font,
    required MangaModel manga,
  }) async {
    final resp = await showCustomAlert(
      context,
      title: 'Remover',
      message: 'Deseja desatribuir essa fonte desse manga?',
    );
    if (resp == true) {
      await _repository.unlinkFontInManga(manga, font);
    }
  }
}
