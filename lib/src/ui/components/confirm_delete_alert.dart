import 'package:flutter/material.dart';
import 'package:my_mangas/src/data/manga_repository.dart';
import 'package:my_mangas/src/data/models/fonts_model.dart';
import 'package:my_mangas/src/data/models/manga_model.dart';
import 'package:my_mangas/src/ui/components/show_custom_alert.dart';

Future<void> confirmDeleteAlert(
  BuildContext context, {
  MangaModel? mangaUrl,
  MangaModel? manga,
  FontsModel? font,
  FontsModel? fontUrl,
  String? title,
  required String message,
}) async {
  final resp = await showCustomAlert(
    context,
    title: title ?? 'Deletar',
    message: message,
  );
  if (resp != null && resp) {
    MangaRepository repository = MangaRepository();
    if (mangaUrl != null) {
      await repository.updateManga(mangaUrl.updateUrlManga(null));
    }
    if (font != null && manga == null) {
      await repository.deletefonts(font.id!);
    }
    if (manga != null && font != null) {
      await repository.unlinkFontInManga(manga, font);
    }
    if (fontUrl != null) {
      await repository.updateFont(fontUrl.updateUrlFont(null));
    }
  }
}
