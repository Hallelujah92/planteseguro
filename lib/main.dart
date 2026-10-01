import 'package:flutter/material.dart';

import 'app.dart';
import 'data/local/local_storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorageService.instance.init();
  runApp(const PlanteSeguroApp());
}
