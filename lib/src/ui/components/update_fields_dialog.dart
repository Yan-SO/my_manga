import 'package:flutter/material.dart';
import 'package:my_mangas/src/data/manga_repository.dart';
import 'package:my_mangas/src/models/manga_model.dart';

class UpdateFieldsDialog extends StatefulWidget {
  final MangaModel mangaModel;
  final MangaRepository repository;
  final Function(MangaModel) onUpdate;

  const UpdateFieldsDialog({
    super.key,
    required this.mangaModel,
    required this.repository,
    required this.onUpdate,
  });

  @override
  _UpdateFieldsDialogState createState() => _UpdateFieldsDialogState();
}

class _UpdateFieldsDialogState extends State<UpdateFieldsDialog> {
  late TextEditingController _tcharContr;
  late TextEditingController _rchatContr;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _tcharContr =
        TextEditingController(text: widget.mangaModel.totalChapters.toString());
    _rchatContr =
        TextEditingController(text: widget.mangaModel.chaptersRead.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: AlertDialog(
        title: const Text('Atualizar'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              decoration:
                  const InputDecoration(labelText: "Total de Capitulos"),
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
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () {
                var totalNum = double.tryParse(_tcharContr.text);
                if (totalNum != null) {
                  totalNum++;
                  _tcharContr.text = totalNum.toString();
                }
              },
              child: const Card(
                color: Color.fromARGB(255, 24, 24, 24),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                  child: Text('Aumetar Totais'),
                ),
              ),
            ),
            const SizedBox(height: 32),
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
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () {
                var readNum = double.tryParse(_rchatContr.text);
                if (readNum != null) {
                  readNum++;
                  _rchatContr.text = readNum.toString();
                }
              },
              child: const Card(
                color: Color.fromARGB(255, 24, 24, 24),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                  child: Text('Aumetar Lidos'),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                final newManga = widget.mangaModel.copyWith(
                  totalChapters: double.parse(_tcharContr.text),
                  chaptersRead: double.parse(_rchatContr.text),
                  lastRead: DateTime.now(),
                );
                widget.repository.updateManga(newManga).then((_) {
                  widget.onUpdate(newManga);
                  Navigator.of(context).pop();
                });
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tcharContr.dispose();
    _rchatContr.dispose();
    super.dispose();
  }
}
