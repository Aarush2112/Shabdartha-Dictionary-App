import 'package:flutter/material.dart';
import 'app.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storageService = await StorageService.initialize();

  runApp(GarudaLexiconApp(
    storageService: storageService,
  ));
}
