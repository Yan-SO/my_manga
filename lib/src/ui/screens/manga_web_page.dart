// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:my_mangas/src/data/manga_repository.dart';
import 'package:my_mangas/src/models/manga_model.dart';
import 'package:my_mangas/src/ui/components/web_drawer_menu_header.dart';
import 'package:my_mangas/src/ui/components/update_fields_dialog.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MangaWebPage extends StatefulWidget {
  final MangaModel manga;
  const MangaWebPage({super.key, required this.manga});

  @override
  _MangaWebPageState createState() => _MangaWebPageState();
}

class _MangaWebPageState extends State<MangaWebPage> {
  late final WebViewController _controller;
  final MangaRepository _repository = MangaRepository();

  late MangaModel _mangaModel;

  @override
  void initState() {
    super.initState();
    _mangaModel = widget.manga;
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(
        Uri.parse(_mangaModel.urlManga ?? "https://www.google.com.br/"),
      );
  }

  @override
  Widget build(BuildContext context) {
    final title = _mangaModel.title;
    return Scaffold(
      endDrawer: _webViewMenu(title, _controller),
      appBar: AppBar(
        title: Text(title),
      ),
      body: WebViewWidget(
        controller: _controller,
      ),
    );
  }

  Widget _webViewMenu(String title, WebViewController controller) {
    final width = MediaQuery.of(context).size.width;
    return SizedBox(
      width: (width * (2 / 3)),
      child: Container(
        color: Theme.of(context).colorScheme.secondary,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            WebDrawerMenuHeader(
              controller: _controller,
              title: title,
            ),
            Card(
              child: ListTile(
                title: Text('Total de capitulos: ${_mangaModel.totalChapters}'),
                onTap: () {
                  _showUpdateFieldsDialog(context);
                },
              ),
            ),
            Card(
              child: ListTile(
                onTap: () {
                  _showUpdateFieldsDialog(context);
                },
                title: Text('Capitulos Lidos: ${_mangaModel.chaptersRead}'),
              ),
            ),
            Card(
              child: ListTile(
                title: Center(child: Text('Salvar URL')),
                subtitle: Text(
                  'atual: ${_mangaModel.urlManga ?? "não tem"}',
                  maxLines: 2,
                ),
                onTap: saveUrl,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showUpdateFieldsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return UpdateFieldsDialog(
          mangaModel: _mangaModel,
          repository: _repository,
          onUpdate: (updatedManga) {
            setState(() {
              _mangaModel = updatedManga;
            });
          },
        );
      },
    );
  }

  void saveUrl() {
    _controller.currentUrl().then((value) {
      if (value != null) {
        setState(() {
          _mangaModel = _mangaModel.copyWith(urlManga: value);
          _repository.updateManga(_mangaModel);
        });
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
