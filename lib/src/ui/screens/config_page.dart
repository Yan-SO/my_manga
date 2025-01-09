import 'package:flutter/material.dart';
import 'package:my_mangas/src/data/backup_manager.dart';
import 'package:my_mangas/src/data/manga_repository.dart';
import 'package:my_mangas/src/ui/components/show_custom_alert.dart';

class ConfigPage extends StatefulWidget {
  const ConfigPage({super.key});

  @override
  State<ConfigPage> createState() => _ConfigPageState();
}

class _ConfigPageState extends State<ConfigPage> {
  bool showNavigationQuest = true;
  final MangaRepository _repository = MangaRepository();

  @override
  void initState() {
    super.initState();
    _getShowNavigationQuest();
  }

  void _getShowNavigationQuest() async {
    final temp = await _repository.getSetting('showNavigationQuest');
    if (temp == 'false') {
      showNavigationQuest = false;
    } else {
      showNavigationQuest = true;
    }
    print('$showNavigationQuest - $temp');
  }

  Future<void> _setShowNavigationQuest(bool newValue) async {
    await _repository.saveSetting('showNavigationQuest', "$newValue");
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: _buildAppBar(context, colorScheme),
      body: ListView(
        children: [
          _buildElementTitle(text: 'Banco de dados'),
          _buildButtonConfig(
            colorScheme: colorScheme,
            text: 'Cria um backup do Banco de dados',
            onPressed: () async {
              final resp = await BackupManager().backupDatabase();
              showCustomAlert(
                context,
                title: 'Status do backup',
                message: resp,
                showConfirm: false,
                showOk: true,
              );
            },
          ),
          _buildButtonConfig(
            colorScheme: colorScheme,
            text: 'Carregar um backup do Banco de dados',
            onPressed: () async {
              final resp = await BackupManager().pickAndRestoreBackup();
              showCustomAlert(
                context,
                title: 'Status do backup',
                message: resp,
                showConfirm: false,
                showOk: true,
              );
            },
          ),
          _buildElementTitle(text: "Navegação web"),
          _buildCheckbox(
              text: 'Perguntar se deseja trocar de site',
              onChanged: (temp) async {
                if (temp != null) {
                  await _setShowNavigationQuest(temp);
                  setState(() {
                    showNavigationQuest = temp;
                  });
                }
              },
              checkboxValue: showNavigationQuest)
        ],
      ),
    );
  }

  Padding _buildElementTitle({required String text}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 22, 8, 8),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
    );
  }

  Widget _buildCheckbox({
    required String text,
    required void Function(bool?)? onChanged,
    required bool? checkboxValue,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Text(
            text,
            style: const TextStyle(fontSize: 15),
          ),
          const Spacer(),
          Checkbox(
            value: checkboxValue,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  ElevatedButton _buildButtonConfig({
    required ColorScheme colorScheme,
    required String text,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      style: ButtonStyle(
        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        backgroundColor: WidgetStateProperty.all<Color>(colorScheme.secondary),
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: const TextStyle(fontSize: 15),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context, ColorScheme colorScheme) {
    return AppBar(
      title: const Text('Configurações'),
      backgroundColor: colorScheme.secondary,
    );
  }
}
