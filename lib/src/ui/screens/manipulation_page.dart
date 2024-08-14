import 'dart:io';

import 'package:flutter/material.dart';
import 'package:my_mangas/src/data/manga_repository.dart';
import 'package:my_mangas/src/models/manga_model.dart';
import 'package:my_mangas/src/ui/components/piker_image.dart';
import 'package:my_mangas/src/ui/components/show_custom_alert.dart';
import 'package:my_mangas/src/ui/screens/manga_page.dart';

class ManipulationPage extends StatefulWidget {
  final MangaModel? manga;
  final DateTime dateNow;

  const ManipulationPage({super.key, this.manga, required this.dateNow});

  @override
  State<ManipulationPage> createState() => _ManipulationPageState();
}

class _ManipulationPageState extends State<ManipulationPage> {
  final _formKey = GlobalKey<FormState>();
  final MangaRepository _mangaRepository = MangaRepository();
  late final TextEditingController _titleController;
  late final TextEditingController _totalChaptersController;
  late final TextEditingController _chaptersReadController;
  File? _image;

  @override
  void initState() {
    super.initState();
    _initializeControllers(widget.manga);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _totalChaptersController.dispose();
    _chaptersReadController.dispose();
    super.dispose();
  }

  void _initializeControllers(MangaModel? manga) {
    if (manga != null) {
      _titleController = TextEditingController(text: manga.title);
      _totalChaptersController =
          TextEditingController(text: manga.totalChapters.toString());
      _chaptersReadController =
          TextEditingController(text: manga.chaptersRead.toString());
    } else {
      _titleController = TextEditingController();
      _totalChaptersController = TextEditingController();
      _chaptersReadController = TextEditingController();
    }
  }

  Future<int?> _saveManga(
      BuildContext context, MangaModel manga, bool isNew) async {
    try {
      int id;
      if (isNew) {
        final list = await _mangaRepository.getMangasByTitle(manga.title);

        if (list.isEmpty) {
          id = await _mangaRepository.insertManga(manga);
          return id;
        } else {
          if (!mounted) return null;
          bool? shouldCreate = await showCustomAlert(
            context,
            title: 'O item já existe',
            message: 'O item ${manga.title} já existe. Deseja criar mais um?',
          );

          if (shouldCreate == true) {
            id = await _mangaRepository.insertManga(manga);
            return id;
          }
          return null;
        }
      } else {
        await _mangaRepository.updateManga(manga);
        return manga.id!;
      }
    } catch (e) {
      if (!mounted) return null;
      await showCustomAlert(
        context,
        title: 'Erro',
        message: 'Erro: $e',
      );
      return null;
    }
  }

  void _setImage(File image) async {
    _image = image;
  }

  @override
  Widget build(BuildContext context) {
    final MangaModel? manga = widget.manga;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          manga != null ? "Atualizar o Manga" : "Novo Manga",
          style: const TextStyle(fontSize: 24),
        ),
        backgroundColor: Theme.of(context).colorScheme.secondary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            const SizedBox(height: 12),
            PikerImage(
              imageManga: manga?.imgUrl,
              onImagePicked: _setImage,
            ),
            const SizedBox(height: 20),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildTextFormField(
                    controller: _titleController,
                    label: "Título",
                    validator: (value) => value == null || value.isEmpty
                        ? 'Por favor, insira o título'
                        : null,
                  ),
                  _buildTextFormField(
                    controller: _totalChaptersController,
                    label: "Total de Capítulos",
                    keyboardType: TextInputType.number,
                    validator: _validateNumber,
                  ),
                  _buildTextFormField(
                    controller: _chaptersReadController,
                    label: "Capítulos Lidos",
                    keyboardType: TextInputType.number,
                    validator: _validateNumber,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  final newManga = MangaModel(
                    title: _titleController.text,
                    chaptersRead: double.parse(_chaptersReadController.text),
                    totalChapters: double.parse(_totalChaptersController.text),
                    lastRead: DateTime.now(),
                    imgUrl: _image?.path,
                  );
                  final id = await _saveManga(
                      context,
                      manga?.copyWith(
                            title: _titleController.text,
                            chaptersRead:
                                double.parse(_chaptersReadController.text),
                            totalChapters:
                                double.parse(_totalChaptersController.text),
                            imgUrl: _image?.path,
                          ) ??
                          newManga,
                      manga == null);
                  if (id != null) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MangaPage(
                          nowDate: DateTime.now(),
                          mangaId: id,
                        ),
                      ),
                    );
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

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  String? _validateNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira um valor';
    }
    if (double.tryParse(value) == null) {
      return "Por favor, insira um número válido";
    }
    return null;
  }
}
