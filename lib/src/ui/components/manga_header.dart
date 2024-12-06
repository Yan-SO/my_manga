import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_mangas/src/data/manga_repository.dart';
import 'package:my_mangas/src/data/models/manga_model.dart';
import 'package:my_mangas/src/ui/components/piker_image.dart';

class MangaHeader extends StatefulWidget {
  final int mangaId;
  const MangaHeader({super.key, required this.mangaId});

  @override
  State<MangaHeader> createState() => _MangaHeaderState();
}

class _MangaHeaderState extends State<MangaHeader> {
  final _formKey = GlobalKey<FormState>();
  final MangaRepository _repository = MangaRepository();
  final TextEditingController _controller = TextEditingController();
  MangaModel? _manga;
  bool _nameEdit = false;

  @override
  void initState() {
    super.initState();
    _loudManga();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _setEditTextField() {
    if (_manga != null) {
      _controller.text = _manga!.title;
      setState(() {
        _nameEdit = true;
      });
    }
  }

  void _loudManga() async {
    try {
      final fetchedManga = await _repository.getMangaForId(widget.mangaId);
      if (fetchedManga != null) {
        setState(() {
          _manga = fetchedManga;
        });
      }
    } catch (e) {
      print('Erro ao carregar o manga: $e');
    }
  }

  void _setImage(File image) {
    _repository.updateManga(_manga!.copyWith(imgUrl: image.path));
  }

  @override
  Widget build(BuildContext context) {
    final widthScreen = MediaQuery.of(context).size.width;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: widthScreen * 2 / 3,
          width: widthScreen * 2 / 5,
          child: PikerImage(
            onImagePicked: _setImage,
            imageManga: _manga?.imgUrl,
          ),
        ),
        SizedBox(
          height: widthScreen * 2 / 3,
          width: (widthScreen * 3 / 5) - 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              IconButton(
                  onPressed: () {
                    _setEditTextField();
                  },
                  icon: const Icon(Icons.edit)),
              const Spacer(),
              GestureDetector(
                onLongPress: () async {
                  await Clipboard.setData(
                    ClipboardData(text: _manga?.title ?? ''),
                  );
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Texto copiado!'),
                      ),
                    );
                  }
                },
                child: SizedBox(
                    width: (widthScreen * 3 / 5) - 16,
                    child: _buildTitleComponent()),
              ),
              const Spacer(flex: 2)
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTitleComponent() {
    if (!_nameEdit) {
      return Text(
        textAlign: TextAlign.center,
        _manga?.title ?? '',
        maxLines: 6,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      );
    }
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            maxLines: null,
            controller: _controller,
            decoration: const InputDecoration(label: Text('Título do Manga')),
            validator: (value) => value == null || value.isEmpty
                ? 'Por favor, insira o título'
                : null,
          ),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                MangaModel temp = _manga!.copyWith(title: _controller.text);
                await _repository.updateManga(temp);
                setState(() {
                  _manga = temp;
                  _nameEdit = false;
                });
              }
            },
            child: Text(
              "Salvar",
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSecondary,
                fontSize: 24,
              ),
            ),
          )
        ],
      ),
    );
  }
}
