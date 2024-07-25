import 'dart:io';

import 'package:flutter/material.dart';
import 'package:my_mangas/src/data/manga_repository.dart';
import 'package:my_mangas/src/models/manga_model.dart';
import 'package:my_mangas/src/ui/components/piker_image.dart';

class ManipulationPage extends StatefulWidget {
  final MangaModel? manga;
  final DateTime dateNow;

  const ManipulationPage({super.key, this.manga, required this.dateNow});

  @override
  State<ManipulationPage> createState() => _ManipulationPageState();
}

class _ManipulationPageState extends State<ManipulationPage> {
  final _styleTitle = const TextStyle(fontSize: 24);
  final MangaRepository _mangaRepository = MangaRepository();
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _tcharController;
  late TextEditingController _rchatController;
  File? _image;

  @override
  void initState() {
    super.initState();
    _checkNew(widget.manga);
  }

  @override
  Widget build(BuildContext context) {
    MangaModel? manga = widget.manga;

    return Scaffold(
      appBar: AppBar(
        title: _title(manga),
        backgroundColor: Theme.of(context).colorScheme.tertiary,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 12),
            PikerImage(
              onImagePicked: _setImage,
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(labelText: "Titulo"),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira o título';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      decoration: const InputDecoration(
                          labelText: "Total de Capitulos"),
                      keyboardType: TextInputType.number,
                      controller: _tcharController,
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
                      decoration: const InputDecoration(
                          labelText: "Total de Capitulos Lidos"),
                      keyboardType: TextInputType.number,
                      controller: _rchatController,
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
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  if (manga == null) {
                    final newManga = MangaModel(
                      title: _titleController.text,
                      chaptersRead: double.parse(_rchatController.text),
                      totalChapters: double.parse(_tcharController.text),
                      lastRead: DateTime.now(),
                      imgUrl: _image?.path,
                    );
                    _addManga(context, newManga);
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
              child: Text(
                "Salvar",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontSize: 24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _setImage(File image) {
    _image = image;
  }

  Widget _title(MangaModel? manga) {
    Widget title;
    if (manga != null) {
      title = Text(
        "Atualizar o manga",
        style: _styleTitle,
      );
    } else {
      title = Text(
        "Novo Manga",
        style: _styleTitle,
      );
    }

    return title;
  }

  Future<void> _addManga(BuildContext context, MangaModel manga) async {
    try {
      int id = await _mangaRepository.insertManga(manga);
      if (mounted) {
        // ignore: use_build_context_synchronously
        _showAlert(context, 'Success', 'Novo Manga inserido com id: $id');
      }
    } catch (e) {
      if (mounted) {
        // ignore: use_build_context_synchronously
        _showAlert(context, 'Error', 'Erro: $e');
      }
    }
  }

  void _showAlert(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _checkNew(MangaModel? manga) {
    if (manga != null) {
      _titleController = TextEditingController(text: manga.title);
      _tcharController =
          TextEditingController(text: manga.totalChapters.toString());
      _rchatController =
          TextEditingController(text: manga.chaptersRead.toString());
    } else {
      _titleController = TextEditingController();
      _tcharController = TextEditingController();
      _rchatController = TextEditingController();
    }
  }
}
