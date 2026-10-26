import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';

import '../database/database_service.dart';

class BackupResult {
  final bool success;
  final String message;
  final DateTime? timestamp;

  const BackupResult({
    required this.success,
    required this.message,
    this.timestamp,
  });

  factory BackupResult.ok(String message) => BackupResult(
        success: true,
        message: message,
        timestamp: DateTime.now(),
      );

  factory BackupResult.error(String message) => BackupResult(
        success: false,
        message: message,
      );
}

class GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();

  GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _client.send(request..headers.addAll(_headers));
  }
}

class BackupService {
  static final BackupService instance = BackupService._internal();
  BackupService._internal();

  GoogleSignInAccount? _currentUser;
  GoogleSignInAccount? get currentUser => _currentUser;
  bool _googleSignInInitialized = false;

  Future<void> _initGoogleSignIn() async {
    if (_googleSignInInitialized) return;
    try {
      await GoogleSignIn.instance.initialize();
      _googleSignInInitialized = true;
    } catch (e) {
      debugPrint('GoogleSignIn.initialize exception: $e');
    }
  }

  // =========================================================================
  // LOCAL JSON FILE EXPORT & IMPORT
  // =========================================================================

  Future<BackupResult> exportToFile() async {
    try {
      final payload = await DatabaseService.instance.exportBackupPayload();
      final jsonString = const JsonEncoder.withIndent('  ').convert(payload);
      final bytes = utf8.encode(jsonString);
      final filename = 'haven_backup_${DateTime.now().toIso8601String().split('T').first}.json';

      final file = XFile.fromData(
        Uint8List.fromList(bytes),
        name: filename,
        mimeType: 'application/json',
      );

      await SharePlus.instance.share(ShareParams(files: [file]));
      return BackupResult.ok('Backup exported as $filename');
    } catch (e) {
      debugPrint('Export to file failed: $e');
      return BackupResult.error('Failed to export backup: $e');
    }
  }

  Future<BackupResult> importFromFile({bool merge = false}) async {
    try {
      final files = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (files.isEmpty) {
        return BackupResult.error('No backup file selected');
      }

      final file = files.first;
      final bytes = await file.readAsBytes();
      final content = utf8.decode(bytes);

      final decoded = jsonDecode(content) as Map<String, dynamic>;
      final success = await DatabaseService.instance.restoreFromPayload(decoded, merge: merge);

      if (success) {
        return BackupResult.ok('Haven restored successfully from file');
      } else {
        return BackupResult.error('The selected file is not a valid Haven backup archive');
      }
    } catch (e) {
      debugPrint('Import from file failed: $e');
      return BackupResult.error('Import failed: $e');
    }
  }

  // =========================================================================
  // GOOGLE DRIVE BACKUP & RESTORE
  // =========================================================================

  Future<BackupResult> signInGoogle() async {
    try {
      await _initGoogleSignIn();
      if (!GoogleSignIn.instance.supportsAuthenticate()) {
        return BackupResult.error('Google Sign-In is not supported on this platform');
      }

      _currentUser = await GoogleSignIn.instance.authenticate(
        scopeHint: [
          drive.DriveApi.driveAppdataScope,
        ],
      );

      if (_currentUser == null) {
        return BackupResult.error('Google Sign-In was cancelled by user');
      }
      return BackupResult.ok('Connected as ${_currentUser!.email}');
    } catch (e) {
      debugPrint('Google Sign-In error: $e');
      return BackupResult.error(
        'Google authentication is not yet configured for this build. '
        'Set up a Google Cloud OAuth Client ID in your Google Developer Console (see README.md).',
      );
    }
  }

  Future<void> signOutGoogle() async {
    try {
      await GoogleSignIn.instance.disconnect();
      _currentUser = null;
    } catch (_) {}
  }

  Future<BackupResult> backupToGoogleDrive() async {
    try {
      if (_currentUser == null) {
        final signInRes = await signInGoogle();
        if (!signInRes.success) return signInRes;
      }

      final clientAuth = await _currentUser!.authorizationClient.authorizeScopes([
        drive.DriveApi.driveAppdataScope,
      ]);

      final authHeaders = {'Authorization': 'Bearer ${clientAuth.accessToken}'};
      final authenticateClient = GoogleAuthClient(authHeaders);
      final driveApi = drive.DriveApi(authenticateClient);

      final payload = await DatabaseService.instance.exportBackupPayload();
      final jsonString = jsonEncode(payload);
      final bytes = utf8.encode(jsonString);

      final driveFile = drive.File()
        ..name = 'haven_backup_latest.json'
        ..parents = ['appDataFolder']
        ..mimeType = 'application/json';

      final media = drive.Media(
        Stream.value(bytes),
        bytes.length,
        contentType: 'application/json',
      );

      // Check if file already exists in appDataFolder
      final fileList = await driveApi.files.list(
        spaces: 'appDataFolder',
        q: "name = 'haven_backup_latest.json'",
      );

      if (fileList.files != null && fileList.files!.isNotEmpty) {
        final existingFileId = fileList.files!.first.id!;
        await driveApi.files.update(
          drive.File(),
          existingFileId,
          uploadMedia: media,
        );
      } else {
        await driveApi.files.create(
          driveFile,
          uploadMedia: media,
        );
      }

      // Update settings with last backup time
      final settings = await DatabaseService.instance.getSettings();
      await DatabaseService.instance.saveSettings(
        settings.copyWith(lastBackupDate: DateTime.now(), googleAccountEmail: _currentUser!.email),
      );

      return BackupResult.ok('Backup saved to Google Drive (app data folder)');
    } catch (e) {
      debugPrint('Google Drive backup error: $e');
      return BackupResult.error('Drive backup failed: $e');
    }
  }

  Future<BackupResult> restoreFromGoogleDrive({bool merge = false}) async {
    try {
      if (_currentUser == null) {
        final signInRes = await signInGoogle();
        if (!signInRes.success) return signInRes;
      }

      final clientAuth = await _currentUser!.authorizationClient.authorizeScopes([
        drive.DriveApi.driveAppdataScope,
      ]);

      final authHeaders = {'Authorization': 'Bearer ${clientAuth.accessToken}'};
      final authenticateClient = GoogleAuthClient(authHeaders);
      final driveApi = drive.DriveApi(authenticateClient);

      final fileList = await driveApi.files.list(
        spaces: 'appDataFolder',
        q: "name = 'haven_backup_latest.json'",
      );

      if (fileList.files == null || fileList.files!.isEmpty) {
        return BackupResult.error('No Haven backup found in your Google Drive app data');
      }

      final fileId = fileList.files!.first.id!;
      final media = await driveApi.files.get(
        fileId,
        downloadOptions: drive.DownloadOptions.fullMedia,
      ) as drive.Media;

      final List<int> dataStore = [];
      await for (final data in media.stream) {
        dataStore.addAll(data);
      }

      final jsonString = utf8.decode(dataStore);
      final decoded = jsonDecode(jsonString) as Map<String, dynamic>;

      final success = await DatabaseService.instance.restoreFromPayload(decoded, merge: merge);
      if (success) {
        return BackupResult.ok('Restored latest backup from Google Drive');
      } else {
        return BackupResult.error('The backup in Google Drive is corrupted or invalid');
      }
    } catch (e) {
      debugPrint('Google Drive restore error: $e');
      return BackupResult.error('Drive restore failed: $e');
    }
  }
}
