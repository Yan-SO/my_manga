import 'package:flutter/material.dart';
import 'package:my_mangas/src/data/manga_repository.dart';
import 'package:my_mangas/src/data/models/fonts_model.dart';
import 'package:my_mangas/src/data/models/manga_model.dart';
import 'package:my_mangas/src/ui/components/confirm_delete_alert.dart';
import 'package:my_mangas/src/ui/components/show_custom_alert.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SaveUrlButton extends StatelessWidget {
  final WebViewController controller;
  final ConfirmDeleteAlert _confirmDeleteAlert = ConfirmDeleteAlert();
  final MangaModel? mangaModel;
  final repository = MangaRepository();
  final FontsModel? fontsModel;
  final VoidCallback reloadState;
  SaveUrlButton({
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
        onTap: () async {
          if ((mangaModel?.isUrlNull() ?? false) ||
              (fontsModel?.isUrlNull() ?? false)) {
            _saveUrl(context);
          } else {
            bool? replace = await showCustomAlert(
              context,
              title: 'Atualizar',
              message: 'Deseja atualizar o Url?',
            );
            if (replace ?? false) {
              _saveUrl(context);
            }
          }
        },
        onLongPress: () async {
          if (mangaModel != null) {
            await _confirmDeleteAlert.cleanURLMangaOrFont(
              context,
              manga: mangaModel,
            );
          }
          if (fontsModel != null) {
            await _confirmDeleteAlert.cleanURLMangaOrFont(
              context,
              font: fontsModel,
            );
          }
          reloadState();
        },
      ),
    );
  }

  void _saveUrl(BuildContext context) {
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
