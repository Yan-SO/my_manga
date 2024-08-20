import 'package:flutter/material.dart';
import 'package:my_mangas/src/data/manga_repository.dart';
import 'package:my_mangas/src/data/models/fonts_model.dart';
import 'package:my_mangas/src/data/models/manga_model.dart';
import 'package:my_mangas/src/ui/components/show_custom_alert.dart';

Future<void> confirmDeleteAlert(
  BuildContext context, {
  Function(MangaModel)? saveMangaState,
  MangaModel? mangaUrl,
  MangaModel? manga,
  FontsModel? font,
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
    if (mangaUrl != null && saveMangaState != null) {
      final newMangaUrlState = mangaUrl.updateUrlManga(null);
      await repository.updateManga(newMangaUrlState);
      saveMangaState(newMangaUrlState);
    }
    if (font != null && manga == null) {
      await repository.deletefonts(font.id!);
    }
    if (manga != null && font != null) {
      await repository.unlinkFontInManga(manga, font);
    }
  }
}
