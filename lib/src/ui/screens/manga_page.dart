import 'dart:io';

import 'package:flutter/material.dart';
import 'package:my_mangas/src/data/manga_repository.dart';
import 'package:my_mangas/src/models/manga_model.dart';
import 'package:my_mangas/src/ui/components/piker_image.dart';

import 'package:my_mangas/src/ui/screens/web_page.dart';

class MangaPage extends StatefulWidget {
  final DateTime nowDate;
  final int mangaId;
  const MangaPage({super.key, required this.mangaId, required this.nowDate});

  @override
  State<MangaPage> createState() => _MangaPageState();
}

class _MangaPageState extends State<MangaPage> {
  final MangaRepository _repository = MangaRepository();
  MangaModel? manga;

  @override
  void initState() {
    super.initState();
    _loadManga();
  }

  Future<void> _loadManga() async {
    try {
      final fetchedManga = await _repository.getMangaForId(widget.mangaId);
      if (fetchedManga != null) {
        setState(() {
          manga = fetchedManga;
        });
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
            Row(
              children: [
                // Imagem
                SizedBox(
                  height: (widthScreen * (4 / 6)),
                  width: (widthScreen * (2 / 5)),
                  child: PikerImage(
                    onImagePicked: _setImage,
                    imageManga: manga?.imgUrl,
                  ),
                ), // Imagem
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
            ),
            const Spacer(flex: 1),
            Card(
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
                  ],
                ),
              ),
            ),
            const Spacer(flex: 4),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WebPage(
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
            ),
            Text(
              "URL atual :${manga!.urlManga}",
              maxLines: 2,
            ),
          ],
        ),
      ),
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
