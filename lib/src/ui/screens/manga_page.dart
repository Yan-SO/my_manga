import 'dart:io';

import 'package:flutter/material.dart';
import 'package:my_mangas/src/data/manga_repository.dart';
import 'package:my_mangas/src/data/models/fonts_model.dart';
import 'package:my_mangas/src/data/models/manga_model.dart';
import 'package:my_mangas/src/ui/components/confirm_delete_alert.dart';
import 'package:my_mangas/src/ui/components/manga_header.dart';
import 'package:my_mangas/src/ui/screens/fonts_web_page.dart';
import 'package:my_mangas/src/ui/screens/manga_web_page.dart';

class MangaPage extends StatefulWidget {
  final DateTime nowDate;
  final int mangaId;

  const MangaPage({
    super.key,
    required this.mangaId,
    required this.nowDate,
  });

  @override
  _MangaPageState createState() => _MangaPageState();
}

class _MangaPageState extends State<MangaPage> {
  final MangaRepository _repository = MangaRepository();
  final ConfirmDeleteAlert _confirmDeleteAlert = ConfirmDeleteAlert();
  FontsModel? _fontsModel;
  MangaModel? manga;

  @override
  void initState() {
    super.initState();
    _loadMangaAndFont();
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao carregar o manga'),
        ),
      );
    }
  }

  Future<void> _loadFonts() async {
    FontsModel? fetchedFont;
    if (manga?.fontsModelId != null) {
      fetchedFont = await _repository.getFontById(manga!.fontsModelId!);
    }
    setState(() {
      _fontsModel = fetchedFont;
    });
  }

  void _removeFont() async {
    if (_fontsModel != null && manga != null) {
      await _confirmDeleteAlert.unlinkFontInManga(
        context,
        font: _fontsModel!,
        manga: manga!,
      );
      _loadMangaAndFont();
    }
  }

  void _updateManga(int mangaId) async {
    final updatedManga = await _repository.getMangaForId(mangaId);
    setState(() {
      manga = updatedManga;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (manga == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Manga Null'),
        ),
        body: const Center(
          child: Text('Manga não encontrado'),
        ),
      );
    }

    final daysSinceLastRead = widget.nowDate.difference(manga!.lastRead).inDays;
    final chaptersToRead = manga!.totalChapters - manga!.chaptersRead;

    return Scaffold(
      appBar: AppBar(backgroundColor: Theme.of(context).colorScheme.secondary),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              MangaHeader(mangaId: widget.mangaId),
              const SizedBox(height: 32),
              _buildMangaInfo(chaptersToRead, daysSinceLastRead),
              const SizedBox(height: 80),
              _buildReadButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMangaInfo(double chaptersToRead, int daysSinceLastRead) {
    return Card(
      color: Theme.of(context).colorScheme.secondary,
      elevation: 16,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDataRow('Lidos', manga!.chaptersRead.toString()),
            _buildDataRow('Total', manga!.totalChapters.toString()),
            _buildDataRow('Falta ler', '$chaptersToRead'),
            _buildDataRow('Tempo sem ler', '$daysSinceLastRead dias'),
            const SizedBox(height: 8),
            _buildFontItem(),
          ],
        ),
      ),
    );
  }

  Widget _buildFontItem() {
    if (_fontsModel == null) {
      return ListTile(
        title: const Text('Atribuir uma fonte ao manga'),
        onTap: _showFontSelectionDialog,
      );
    }

    return ListTile(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FontsWebPage(font: _fontsModel!),
          ),
        );
      },
      trailing: IconButton(
        icon: const Icon(Icons.delete_outlined),
        onPressed: _removeFont,
      ),
      leading: _buildFontAvatar(),
      title: Text(_fontsModel!.fontName),
    );
  }

  Widget _buildFontAvatar() {
    return _fontsModel!.imgUrl != null
        ? CircleAvatar(backgroundImage: FileImage(File(_fontsModel!.imgUrl!)))
        : const CircleAvatar(backgroundColor: Colors.black);
  }

  Future<void> _showFontSelectionDialog() async {
    final fontsList = await _repository.getAllFonts();
    showDialog(
      context: context,
      builder: (context) => _buildFontSelectionContent(fontsList),
    );
  }

  AlertDialog _buildFontSelectionContent(List<FontsModel> fontsList) {
    final sizeScreen = MediaQuery.of(context).size;

    return AlertDialog(
      content: fontsList.isEmpty
          ? const Text('Não existem fontes disponíveis')
          : SizedBox(
              width: sizeScreen.width * 3 / 4,
              height: sizeScreen.height * 2 / 3,
              child: ListView.builder(
                itemCount: fontsList.length,
                itemBuilder: (context, index) {
                  final font = fontsList[index];
                  return Card(
                    child: ListTile(
                      onTap: () async {
                        await _repository.linkFontInManga(manga!, font);
                        setState(() {
                          _fontsModel = font;
                        });
                        Navigator.pop(context);
                      },
                      title: Text(font.fontName, maxLines: 2),
                      leading: font.imgUrl != null
                          ? CircleAvatar(
                              backgroundImage: FileImage(File(font.imgUrl!)),
                            )
                          : const CircleAvatar(backgroundColor: Colors.black),
                    ),
                  );
                },
              ),
            ),
    );
  }

  ElevatedButton _buildReadButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      onPressed: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MangaWebPage(manga: manga!),
          ),
        );
        _updateManga(manga!.id!);
      },
      child: Text(
        'Ler Manga',
        style: TextStyle(
          color: Theme.of(context).colorScheme.onPrimary,
          fontSize: 24,
        ),
      ),
    );
  }

  Widget _buildDataRow(String description, String value) {
    const style = TextStyle(fontSize: 16);
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 4, 0, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(description, style: style),
          Text(value, style: style),
        ],
      ),
    );
  }
}
