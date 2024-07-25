// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:my_mangas/src/data/manga_repository.dart';
import 'package:my_mangas/src/models/manga_model.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebPage extends StatefulWidget {
  final MangaModel manga;
  const WebPage({super.key, required this.manga});

  @override
  _WebPageState createState() => _WebPageState();
}

class _WebPageState extends State<WebPage> {
  late final WebViewController _controller;
  final MangaRepository _repository = MangaRepository();
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _tcharContr;
  late TextEditingController _rchatContr;
  late MangaModel _mangaModel;

  @override
  void initState() {
    super.initState();
    _mangaModel = widget.manga;
    _tcharContr =
        TextEditingController(text: _mangaModel.totalChapters.toString());
    _rchatContr =
        TextEditingController(text: _mangaModel.chaptersRead.toString());

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
      endDrawer: _webViewMenu(title),
      appBar: AppBar(
        title: Text(title),
      ),
      body: WebViewWidget(
        controller: _controller,
      ),
    );
  }

  Widget _webViewMenu(String title) {
    final width = MediaQuery.of(context).size.width;
    return SizedBox(
      width: (width * (2 / 3)),
      child: Container(
        color: Theme.of(context).colorScheme.tertiary,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              child: Text(title),
            ),
            Card(
              child: ListTile(
                title: Text('Total de capitulos: ${_mangaModel.totalChapters}'),
                onTap: () {
                  updateFilds(context);
                },
              ),
            ),
            Card(
              child: ListTile(
                onTap: () {
                  updateFilds(context);
                },
                title: Text('Capitulos Lidos: ${_mangaModel.chaptersRead}'),
              ),
            ),
            Card(
              child: ListTile(
                title: Center(child: Text('Salvar URL')),
                subtitle: Text(
                  'atual :${_mangaModel.urlManga ?? "não tem"}',
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

  void updateFilds(BuildContext context) {
    final form = Column(
      children: [
        TextFormField(
          decoration: const InputDecoration(labelText: "Total de Capitulos"),
          keyboardType: TextInputType.number,
          controller: _tcharContr,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor, insira o quantos capitulos tem';
            }
            if (double.tryParse(value) == null) {
              return "Por favor, insira um numero valido";
            }
            return null;
          },
        ),
        TextFormField(
          decoration:
              const InputDecoration(labelText: "Total de Capitulos Lidos"),
          keyboardType: TextInputType.number,
          controller: _rchatContr,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor, insira em qual capitulos esta';
            }
            if (double.tryParse(value) == null) {
              return "Por favor, insira um numero valido";
            }
            return null;
          },
        ),
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Form(
          key: _formKey,
          child: AlertDialog(
            title: Text('Atializar'),
            content: form,
            actions: [
              TextButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final newManga = _mangaModel.copyWith(
                        totalChapters: double.parse(_tcharContr.text),
                        chaptersRead: double.parse(_rchatContr.text),
                        lastRead: DateTime.now(),
                      );
                      _repository.updateManga(newManga).then((a) {
                        setState(() {
                          _mangaModel = newManga;
                        });
                        Navigator.of(context).pop();
                      });
                    }
                  },
                  child: Text('Salvar')),
            ],
          ),
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
          AlertDialog(
            title: Text('Url atualizado: $value'),
          );
        });
      } else {
        AlertDialog(
          title: Text('Url é null: $value'),
        );
      }
    });
  }
}
