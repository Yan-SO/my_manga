import 'dart:io';

import 'package:flutter/material.dart';
import 'package:my_mangas/src/data/manga_repository.dart';
import 'package:my_mangas/src/models/fonts_model.dart';
import 'package:my_mangas/src/models/manga_model.dart';
import 'package:my_mangas/src/ui/components/update_fields_dialog.dart';
import 'package:my_mangas/src/ui/components/web_drawer_menu_header.dart';
import 'package:webview_flutter/webview_flutter.dart';

class FontsWebPage extends StatefulWidget {
  final FontsModel font;
  const FontsWebPage({super.key, required this.font});

  @override
  State<FontsWebPage> createState() => _FontsWebPageState();
}

class _FontsWebPageState extends State<FontsWebPage> {
  late final WebViewController _controller;
  final MangaRepository _repository = MangaRepository();
  final List<MangaModel> _mangas = [];

  @override
  void initState() {
    super.initState();
    _loadMangas();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(
        Uri.parse(widget.font.urlFont ?? "https://www.google.com.br/"),
      );
  }

  void _loadMangas() async {
    final resp = await _repository.getAllMangas();
    setState(() {
      _mangas.addAll(resp);
    });

    // fazer as relaçoes dos mangas com as fontes
  }

  Widget _webFontMenu(double width, BuildContext context) {
    return SizedBox(
      width: (width * (2 / 3)),
      child: Container(
        color: Theme.of(context).colorScheme.secondary,
        child: Column(
          children: [
            WebDrawerMenuHeader(
              title: widget.font.fontName,
              controller: _controller,
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _mangas.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      onTap: () {
                        _showUpdateFieldsDialog(context, _mangas[index]);
                      },
                      title: _tilte(index),
                      subtitle:
                          Text('total atual: ${_mangas[index].totalChapters}'),
                      leading: _mangas[index].imgUrl != null
                          ? CircleAvatar(
                              backgroundImage:
                                  FileImage(File(_mangas[index].imgUrl!)))
                          : const CircleAvatar(
                              backgroundColor: Colors.black,
                            ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showUpdateFieldsDialog(BuildContext context, MangaModel mangaModel) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return UpdateFieldsDialog(
          reads: false,
          mangaModel: mangaModel,
          repository: _repository,
          onUpdate: (updatedManga) {
            setState(() {
              mangaModel = updatedManga;
            });
          },
        );
      },
    );
  }

  Text _tilte(int index) => Text(_mangas[index].title, maxLines: 2);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      endDrawer: _webFontMenu(width, context),
      appBar: AppBar(title: Text(widget.font.fontName)),
      body: WebViewWidget(controller: _controller),
    );
  }
}
