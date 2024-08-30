import 'package:flutter/material.dart';
import 'package:my_mangas/src/data/manga_repository.dart';
import 'package:my_mangas/src/data/models/fonts_model.dart';
import 'package:my_mangas/src/data/models/manga_model.dart';
import 'package:my_mangas/src/ui/components/confirm_delete_alert.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SaveUrlButton extends StatelessWidget {
  final WebViewController controller;
  final MangaModel? mangaModel;
  final FontsModel? fontsModel;
  final VoidCallback reloadState;
  const SaveUrlButton({
    super.key,
    required this.controller,
    required this.reloadState,
    this.mangaModel,
    this.fontsModel,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: const Center(child: Text('Salvar URL')),
        subtitle: Text(
          'atual: ${fontsModel?.urlFont ?? mangaModel?.urlManga ?? "não tem"}',
          maxLines: 2,
        ),
        onTap: () {
          _saveUrl(context);
        },
        onLongPress: () async {
          if (mangaModel != null) {
            await confirmDeleteAlert(
              context,
              mangaUrl: mangaModel,
              message: 'Deseja apagar a URL salva?',
            );
          }
          if (fontsModel != null) {
            await confirmDeleteAlert(
              context,
              fontUrl: fontsModel,
              message: 'Deseja apagar a URL salva?',
            );
          }
          reloadState();
        },
      ),
    );
  }

  void _saveUrl(BuildContext context) {
    final repository = MangaRepository();
    controller.currentUrl().then((value) async {
      if (value != null) {
        if (mangaModel != null) {
          await repository.updateManga(mangaModel!.copyWith(urlManga: value));
        }
        if (fontsModel != null) {
          await repository.updateFont(fontsModel!.copyWith(urlFont: value));
        }
        reloadState();
      } else {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Url é null: $value'),
            );
          },
        );
      }
    });
  }
}
