import 'dart:io';
import 'package:flutter/material.dart';
import 'package:my_mangas/src/data/manga_repository.dart';
import 'package:my_mangas/src/data/models/fonts_model.dart';
import 'package:my_mangas/src/data/models/manga_model.dart';
import 'package:my_mangas/src/ui/components/save_url_button.dart';
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
  final TextEditingController _filterController = TextEditingController();
  late FontsModel _font;
  bool _checkboxValue = true;
  List<MangaModel> _allMangasList = [];
  List<MangaModel> _filteredList = [];
  int _progress = 0;

  @override
  void initState() {
    super.initState();
    _font = widget.font;
    _loadMangas();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            setState(() {
              _progress = progress;
            });
          },
        ),
      )
      ..loadRequest(
        Uri.parse(widget.font.urlFont ?? "https://www.google.com.br/"),
      );

    _filterController.addListener(() {
      _filterList(_filterController.text);
    });
  }

  @override
  void dispose() {
    _filterController.removeListener(() {
      _filterList(_filterController.text);
    });
    _filterController.dispose();
    super.dispose();
  }

  void _loadMangas() async {
    List<MangaModel> resp;
    if (_checkboxValue) {
      resp = await _repository.getMangasbyIdfromFont(widget.font.id!);
    } else {
      resp = await _repository.getAllMangas();
    }
    setState(() {
      _allMangasList = resp;
      _filteredList = _allMangasList;
    });
  }

  void _filterList(String text) {
    setState(() {
      if (text.isNotEmpty) {
        _filteredList = _allMangasList.where((manga) {
          return manga.title.toLowerCase().contains(text.toLowerCase());
        }).toList();
      } else {
        _filteredList = _allMangasList;
      }
    });
  }

  Widget _buildWebFontMenu(double width, BuildContext context) {
    return SizedBox(
      width: (width * (2 / 3)),
      child: Container(
        color: Theme.of(context).colorScheme.secondary,
        child: Column(
          children: [
            WebDrawerMenuHeader(
              title: widget.font.fontName,
              subtitle: 'Tem ${_allMangasList.length} fontes atribudas',
              controller: _controller,
            ),
            _buildCheckboxMenu(),
            _buildFilterTextField(context),
            Expanded(
              child: ListView.builder(
                itemCount: _filteredList.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      onTap: () {
                        _showUpdateFieldsDialog(context, _filteredList, index);
                      },
                      title: _buildTitle(index),
                      subtitle: Text(
                        'total atual: ${_filteredList[index].totalChapters}',
                      ),
                      leading: _filteredList[index].imgUrl != null
                          ? CircleAvatar(
                              backgroundImage: FileImage(
                                File(_filteredList[index].imgUrl!),
                              ),
                            )
                          : const CircleAvatar(
                              backgroundColor: Colors.black,
                            ),
                    ),
                  );
                },
              ),
            ),
            SaveUrlButton(
              controller: _controller,
              fontsModel: _font,
              reloadState: () async {
                final font = await _repository.getFontById(_font.id!);
                setState(() {
                  if (font != null) _font = font;
                });
              },
            )
          ],
        ),
      ),
    );
  }

  void _showUpdateFieldsDialog(
      BuildContext context, List<MangaModel> mangaModel, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return UpdateFieldsDialog(
          reads: false,
          mangaModel: mangaModel[index],
          repository: _repository,
          onUpdate: (updatedManga) {
            setState(() {
              mangaModel[index] = updatedManga;
            });
          },
        );
      },
    );
  }

  Widget _buildCheckboxMenu() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Somente fontes atribuidas '),
        Checkbox(
          value: _checkboxValue,
          onChanged: (value) {
            setState(() {
              _checkboxValue = value!;
            });
            _loadMangas();
          },
        )
      ],
    );
  }

  Widget _buildFilterTextField(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: _filterController,
        decoration: InputDecoration(
          hintText: 'Buscar...',
          hintStyle: const TextStyle(color: Colors.white54),
          enabledBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: Theme.of(context).colorScheme.onSecondary),
          ),
        ),
      ),
    );
  }

  Text _buildTitle(int index) => Text(_filteredList[index].title, maxLines: 2);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      endDrawer: _buildWebFontMenu(width, context),
      appBar: AppBar(
        title: Text(widget.font.fontName),
        bottom: _progress < 100
            ? PreferredSize(
                preferredSize: const Size.fromHeight(2.0),
                child: LinearProgressIndicator(
                  value: _progress / 100,
                  color: Colors.blue,
                  backgroundColor: Colors.grey[200],
                ),
              )
            : null,
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
