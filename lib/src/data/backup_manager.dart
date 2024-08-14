import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sqflite/sqflite.dart';

class BackupManager {
  Future<String> _getDatabasePath() async {
    final databasesPath = await getDatabasesPath();
    return join(databasesPath, 'app_database.db');
  }

  Future<String> backupDatabase() async {
    try {
      if (await Permission.storage.isGranted) {
        var status = await Permission.storage.request();
        if (!status.isGranted) return 'Permissão negada';
      }

      final dbPath = await _getDatabasePath();

      final directory = await getExternalStorageDirectory();
      final backupPath = join(directory!.path, 'my_mangas_backup_.db');

      final dbFile = File(dbPath);
      final backupFile = File(backupPath);
      await backupFile.writeAsBytes(await dbFile.readAsBytes());

      return 'Backup realizado com sucesso em: $backupPath';
    } catch (e) {
      return 'Erro ao realizar backup: $e';
    }
  }

  Future<String> pickAndRestoreBackup() async {
    try {
      // Abre o seletor de arquivos
      final result = await FilePicker.platform.pickFiles();

      if (result == null) {
        // O usuário cancelou a seleção
        return ('Nenhum arquivo selecionado');
      }

      final backupFilePath = result.files.single.path;

      if (backupFilePath == null) {
        return ('Caminho do arquivo não encontrado');
      }

      // Restaura o banco de dados com o arquivo selecionado
      return await _restoreDatabase(backupFilePath);
    } catch (e) {
      return ('Erro ao selecionar ou restaurar o arquivo: $e');
    }
  }

  Future<String> _restoreDatabase(String backupFilePath) async {
    try {
      if (await Permission.storage.isGranted) {
        var status = await Permission.storage.request();
        if (!status.isGranted) return 'Permissão negada';
      }

      final dbPath = await _getDatabasePath();

      final backupFile = File(backupFilePath);
      //final dbFile = File(dbPath);

      if (!await backupFile.exists()) {
        return 'Arquivo de backup não encontrado';
      }

      if (!await _isValidBackupFile(backupFile)) {
        return 'Arquivo selecionado não é um backup válido';
      }

      await backupFile.copy(dbPath);

      return 'Backup restaurado com sucesso';
    } catch (e) {
      return 'Erro ao restaurar backup: $e';
    }
  }

  Future<bool> _isValidBackupFile(File file) async {
    try {
      final extension = file.path.split('.').last.toLowerCase();
      if (extension != 'db') {
        return false;
      }

      final database =
          await openDatabase(file.path, readOnly: true, singleInstance: true);
      await database.close();

      return true;
    } catch (e) {
      print('Erro ao verificar a validade do arquivo de backup: $e');
      return false;
    }
  }
}
