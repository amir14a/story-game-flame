import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';

/// Entry point. Locks the game to landscape (on platforms that support it) and
/// launches the app.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(const [
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const NeonEchoApp());
}
