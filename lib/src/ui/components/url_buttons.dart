import 'package:flutter/material.dart';
import 'package:my_mangas/src/data/manga_repository.dart';
import 'package:my_mangas/src/data/models/fonts_model.dart';
import 'package:my_mangas/src/data/models/manga_model.dart';
import 'package:my_mangas/src/ui/components/confirm_delete_alert.dart';
import 'package:my_mangas/src/ui/components/show_custom_alert.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class UrlButtons extends StatelessWidget {
  final WebViewController controller;
  final ConfirmDeleteAlert _confirmDeleteAlert = ConfirmDeleteAlert();
  final MangaModel? mangaModel;
  final repository = MangaRepository();
  final FontsModel? fontsModel;
  final VoidCallback reloadState;

  UrlButtons({
    super.key,
    required this.controller,
    required this.reloadState,
    this.mangaModel,
    this.fontsModel,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
      child: Card(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: _buildSaveUrlBottun(context),
                ),
                Expanded(child: _buildOpenGoogleChomeButton(context)),
              ],
            ),
            _buildGoogleButton(context),
          ],
        ),
      ),
    );
  }

  ListTile _buildSaveUrlBottun(BuildContext context) {
    return ListTile(
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
    );
  }

  Container _buildOpenGoogleChomeButton(context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
              width: 4, color: Theme.of(context).colorScheme.secondary),
        ),
      ),
      child: SizedBox(
        height: 80,
        child: InkWell(
          child: Icon(Icons.public),
          onTap: () async {
            final url = await controller.currentUrl();
            _openUrlInChome(url);
          },
        ),
      ),
    );
  }

  Container _buildGoogleButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
              width: 4, color: Theme.of(context).colorScheme.secondary),
        ),
      ),
      child: ListTile(
        title: const Center(child: Text('Google')),
        onTap: () {
          controller.loadRequest(Uri.parse('https://www.google.com.br/'));
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

  Future<void> _openUrlInChome(String? url) async {
    if (url != null) {
      final Uri? uri = Uri.tryParse(url);
      if (uri == null) {
        print('URL inválida: $url');
        return;
      }
      if (await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      )) {
        print('URL valida: $url');
        return;
      }
    }
    // se for erro
  }
}
