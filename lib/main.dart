import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mindloop/app/app.dart';
import 'package:mindloop/app/di/injection.dart';
import 'package:mindloop/modules/reminder/core/utils/reminder_sound_player.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ReminderSoundPlayer.ensureConfigured();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  await Hive.initFlutter();
  await setupDependencies();

  runApp(const MindLoopApp());
}
