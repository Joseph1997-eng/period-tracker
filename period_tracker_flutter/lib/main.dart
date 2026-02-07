import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'core/constants/storage_keys.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await Hive.openBox<dynamic>(StorageKeys.cyclesBox);
  await Hive.openBox<dynamic>(StorageKeys.settingsBox);

  runApp(const ProviderScope(child: PeriodTrackerApp()));
}
