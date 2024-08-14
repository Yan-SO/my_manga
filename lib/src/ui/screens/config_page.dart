import 'package:flutter/material.dart';
import 'package:my_mangas/src/data/backup_manager.dart';
import 'package:my_mangas/src/ui/components/show_custom_alert.dart';

class ConfigPage extends StatelessWidget {
  const ConfigPage({super.key});

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
        ],
      ),
    );
  }

  Padding _buildElementTitle({required String text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
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
      child: Text(text),
    );
  }

  AppBar _buildAppBar(BuildContext context, ColorScheme colorScheme) {
    return AppBar(
      title: const Text('Configurações'),
      backgroundColor: colorScheme.secondary,
    );
  }
}
