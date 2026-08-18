import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../database/isar_service.dart';
import '../../repositories/backup_repository.dart';
import '../app_locker/app_lock_provider.dart';

class BackupService {
  final IsarService _isarService;
  BackupService(this._isarService);

  // Returns the save path on success, null if the user cancelled.
  Future<String?> exportBackup() async {
    final isar = await _isarService.db;
    final repo = BackupRepository(isar);
    final json = await repo.exportToJson();

    final now = DateTime.now();
    final stamp =
        "${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_"
        "${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}";

    return FilePicker.platform.saveFile(
      dialogTitle: 'Save reFine Backup',
      fileName: 'refine_backup_$stamp.json',
      type: FileType.custom,
      allowedExtensions: ['json'],
      bytes: Uint8List.fromList(utf8.encode(json)),
    );
  }

  // Returns true if a backup was picked and successfully restored, false if
  // the user cancelled. Throws on a malformed/unreadable file so the caller
  // can show a real error rather than silently doing nothing.
  Future<bool> importBackup() async {
    final result = await FilePicker.platform.pickFiles(
      dialogTitle: 'Select reFine Backup',
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (result == null || result.files.single.path == null) return false;

    final file = File(result.files.single.path!);
    final jsonStr = await file.readAsString();

    final isar = await _isarService.db;
    final repo = BackupRepository(isar);
    await repo.importFromJson(jsonStr);
    return true;
  }
}

final backupServiceProvider = Provider<BackupService>((ref) {
  final isarService = ref.watch(isarServiceProvider);
  return BackupService(isarService);
});
