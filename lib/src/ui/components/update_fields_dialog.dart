import 'package:flutter/material.dart';
import 'package:my_mangas/src/data/manga_repository.dart';
import 'package:my_mangas/src/data/models/manga_model.dart';

class UpdateFieldsDialog extends StatefulWidget {
  final MangaModel mangaModel;
  final MangaRepository repository;
  final bool total;
  final bool reads;
  final Function(MangaModel) onUpdate;

  const UpdateFieldsDialog({
    super.key,
    required this.mangaModel,
    required this.repository,
    required this.onUpdate,
    this.total = true,
    this.reads = true,
  });

  @override
  _UpdateFieldsDialogState createState() => _UpdateFieldsDialogState();
}

class _UpdateFieldsDialogState extends State<UpdateFieldsDialog> {
  late TextEditingController _totalChaptersController;
  late TextEditingController _chaptersReadController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _totalChaptersController = TextEditingController(
      text: _formatNumber(widget.mangaModel.totalChapters),
    );
    _chaptersReadController = TextEditingController(
      text: _formatNumber(widget.mangaModel.chaptersRead),
    );
  }

  @override
  void dispose() {
    _totalChaptersController.dispose();
    _chaptersReadController.dispose();
    super.dispose();
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
            if (widget.total) _buildTotalChaptersField(),
            if (widget.reads) _buildChaptersReadField(),
            const SizedBox(height: 32),
          ],
        ),
        actions: [
          TextButton(
            onPressed: _saveMangaUpdates,
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalChaptersField() {
    return Column(
      children: [
        TextFormField(
          style: const TextStyle(fontSize: 24),
          decoration: const InputDecoration(labelText: "Total de Capitulos"),
          keyboardType: TextInputType.number,
          controller: _totalChaptersController,
          validator: _validateNumber,
        ),
        const SizedBox(height: 16),
        _buildIncrementButton("Aumentar Totais",
            () => _incrementControllerValue(_totalChaptersController)),
      ],
    );
  }

  Widget _buildChaptersReadField() {
    return Column(
      children: [
        const SizedBox(height: 32),
        TextFormField(
          style: const TextStyle(fontSize: 24),
          decoration:
              const InputDecoration(labelText: "Total de Capitulos Lidos"),
          keyboardType: TextInputType.number,
          controller: _chaptersReadController,
          validator: _validateNumber,
        ),
        const SizedBox(height: 16),
        _buildIncrementButton("Aumentar Lidos",
            () => _incrementControllerValue(_chaptersReadController)),
      ],
    );
  }

  Widget _buildIncrementButton(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: Color.fromARGB(255, 24, 24, 24),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          child: Text(label),
        ),
      ),
    );
  }

  String? _validateNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira um número';
    }
    if (double.tryParse(value) == null) {
      return 'Por favor, insira um número válido';
    }
    return null;
  }

  void _incrementControllerValue(TextEditingController controller) {
    final currentValue = double.tryParse(controller.text);
    if (currentValue != null) {
      controller.text = (currentValue + 1).toString();
    }
  }

  void _saveMangaUpdates() {
    if (_formKey.currentState!.validate()) {
      final updatedManga = widget.mangaModel.copyWith(
        totalChapters: double.parse(_totalChaptersController.text),
        chaptersRead: double.parse(_chaptersReadController.text),
        lastRead: DateTime.now(),
      );
      widget.repository.updateManga(updatedManga).then((_) {
        widget.onUpdate(updatedManga);
        Navigator.of(context).pop();
      });
    }
  }

  String _formatNumber(double number) {
    return number % 1 == 0 ? number.toInt().toString() : number.toString();
  }
}
