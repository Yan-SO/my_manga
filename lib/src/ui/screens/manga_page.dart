// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:my_mangas/src/data/manga_repository.dart';
import 'package:my_mangas/src/models/fonts_model.dart';
import 'package:my_mangas/src/models/manga_model.dart';
import 'package:my_mangas/src/ui/components/piker_image.dart';
import 'package:my_mangas/src/ui/screens/fonts_web_page.dart';

import 'package:my_mangas/src/ui/screens/manga_web_page.dart';

class MangaPage extends StatefulWidget {
  final DateTime nowDate;
  final int mangaId;
  const MangaPage({super.key, required this.mangaId, required this.nowDate});

  @override
  State<MangaPage> createState() => _MangaPageState();
}

class _MangaPageState extends State<MangaPage> {
  final MangaRepository _repository = MangaRepository();
  FontsModel? _fontsModel;
  MangaModel? manga;

  @override
  void initState() {
    super.initState();
    _loadMangaAndFont();
  }

  Future<void> _loadFonts() async {
    FontsModel? resp;
    if (manga?.fontsModelId != null) {
      resp = await _repository.getFontById(manga!.fontsModelId!);
    }
    setState(() {
      _fontsModel = resp;
    });
  }

  Future<void> _loadMangaAndFont() async {
    try {
      final fetchedManga = await _repository.getMangaForId(widget.mangaId);
      if (fetchedManga != null) {
        setState(() {
          manga = fetchedManga;
        });
        await _loadFonts();
      }
    } catch (e) {
      AlertDialog(
        content: Text('Erro ao carregar o manga: $e'),
      );
    }
  }

  void updateMangaForId(int mangaId) async {
    var newManga = await _repository.getMangaForId(mangaId);
    setState(() {
      if (newManga != null) {
        manga = newManga;
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return const AlertDialog(
              title: Text('Erro em achar o manga'),
            );
          },
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (manga == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('manga Null'),
        ),
        body: const Center(
          child: Text('manga Null'),
        ),
      );
    }

    final widthScreen = MediaQuery.of(context).size.width;
    final days = widget.nowDate.difference(manga!.lastRead).inDays;
    final toRead = manga!.totalChapters - manga!.chaptersRead;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.secondary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            _mangaHeader(widthScreen),
            const Spacer(flex: 1),
            _mangaInfo(context, toRead, days),
            const Spacer(flex: 4),
            _readButton(context),
            Text("URL atual :${manga!.urlManga}", maxLines: 2),
          ],
        ),
      ),
    );
  }

  ElevatedButton _readButton(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      onPressed: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MangaWebPage(
              manga: manga!,
            ),
          ),
        );
        updateMangaForId(manga!.id!);
      },
      child: Text(
        "Ler Manga",
        style: TextStyle(
          color: Theme.of(context).colorScheme.onPrimary,
          fontSize: 24,
        ),
      ),
    );
  }

  Card _mangaInfo(BuildContext context, double toRead, int days) {
    return Card(
      color: Theme.of(context).colorScheme.secondary,
      elevation: 16,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDataRow("Lidos", manga!.chaptersRead.toString()),
            _buildDataRow("Total", manga!.totalChapters.toString()),
            _buildDataRow("Falta ler", '$toRead'),
            _buildDataRow("Tempo sem ler: ", '$days dias'),
            const SizedBox(height: 8),
            _fontIten(context),
          ],
        ),
      ),
    );
  }

  Widget _fontIten(BuildContext context) {
    final sizeScreen = MediaQuery.of(context).size;

    if (_fontsModel == null) {
      return ListTile(
        title: const Text('Atribuida uma fonte para o manga'),
        onTap: () async {
          final fontsList = await _repository.getAllFonts();
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return _showDialogContent(fontsList, sizeScreen);
            },
          );
        },
      );
    }

    return ListTile(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FontsWebPage(
              font: _fontsModel!,
            ),
          ),
        );
      },
      trailing: IconButton(
        icon: const Icon(Icons.delete_outlined),
        onPressed: () async {
          if (_fontsModel!.id != null) {
            await _repository.updateManga(manga!.updateFonts(null));
            var children = _fontsModel!.children;
            await _repository.updateFont(
              _fontsModel!.copyWith(children: children - 1),
            );
            setState(() {
              _fontsModel = null;
            });
          } else {
            AlertDialog(
              title: Text('o ${_fontsModel!.fontName} não tem um id'),
            );
          }
        },
      ),
      leading: _fontsModel!.imgUrl != null
          ? CircleAvatar(backgroundImage: FileImage(File(_fontsModel!.imgUrl!)))
          : const CircleAvatar(
              backgroundColor: Colors.black,
            ),
      title: Text(_fontsModel!.fontName),
    );
  }

  AlertDialog _showDialogContent(List<FontsModel> fontsList, Size sizeScreen) {
    return AlertDialog(
      content: fontsList.isEmpty
          ? const Text('Não existe fontes')
          : Flexible(
              fit: FlexFit.loose,
              child: SizedBox(
                width: (sizeScreen.width * (3 / 4)),
                height: (sizeScreen.height * (2 / 3)),
                child: ListView.builder(
                  itemCount: fontsList.length,
                  itemBuilder: (context, index) {
                    return Card(
                      child: ListTile(
                        onTap: () async {
                          await _repository.updateManga(manga!.copyWith(
                            fontsModelId: fontsList[index].id!,
                          ));
                          var children = fontsList[index].children;
                          await _repository.updateFont(
                            fontsList[index].copyWith(children: children + 1),
                          );
                          setState(() {
                            _fontsModel = fontsList[index];
                          });

                          Navigator.pop(context);
                        },
                        title: Text(fontsList[index].fontName, maxLines: 2),
                        leading: fontsList[index].imgUrl != null
                            ? CircleAvatar(
                                backgroundImage: FileImage(
                                  File(fontsList[index].imgUrl!),
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
            ),
    );
  }

  Row _mangaHeader(double widthScreen) {
    return Row(
      children: [
        // Imagem
        SizedBox(
          height: (widthScreen * (4 / 6)),
          width: (widthScreen * (2 / 5)),
          child: PikerImage(
            onImagePicked: _setImage,
            imageManga: manga?.imgUrl,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            manga!.title,
            maxLines: 7,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  void _setImage(File image) {
    _repository.updateManga(manga!.copyWith(imgUrl: image.path));
  }

  Widget _buildDataRow(String description, String value) {
    const style = TextStyle(fontSize: 16);
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 4, 0, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            description,
            style: style,
          ),
          Text(
            value,
            style: style,
          ),
        ],
      ),
    );
  }
}
