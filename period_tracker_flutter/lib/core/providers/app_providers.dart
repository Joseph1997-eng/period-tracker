import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import 'package:local_auth/local_auth.dart';

import '../../data/datasources/local/cycle_local_data_source.dart';
import '../../data/datasources/local/lock_local_data_source.dart';
import '../../data/datasources/local/settings_local_data_source.dart';
import '../../data/repositories/cycle_repository_impl.dart';
import '../../data/repositories/lock_repository_impl.dart';
import '../../data/repositories/settings_repository_impl.dart';
import '../../features/cycle/domain/repositories/cycle_repository.dart';
import '../../features/cycle/domain/services/cycle_analytics_engine.dart';
import '../../features/security/domain/repositories/lock_repository.dart';
import '../../features/settings/domain/repositories/settings_repository.dart';
import '../constants/storage_keys.dart';

final Provider<Box<dynamic>> cyclesBoxProvider = Provider<Box<dynamic>>(
  (Ref ref) => Hive.box<dynamic>(StorageKeys.cyclesBox),
);

final Provider<Box<dynamic>> settingsBoxProvider = Provider<Box<dynamic>>(
  (Ref ref) => Hive.box<dynamic>(StorageKeys.settingsBox),
);

final Provider<FlutterSecureStorage> secureStorageProvider =
    Provider<FlutterSecureStorage>((Ref ref) => const FlutterSecureStorage());

final Provider<LocalAuthentication> localAuthenticationProvider =
    Provider<LocalAuthentication>((Ref ref) => LocalAuthentication());

final Provider<CycleLocalDataSource> cycleLocalDataSourceProvider =
    Provider<CycleLocalDataSource>(
      (Ref ref) => CycleLocalDataSource(ref.watch(cyclesBoxProvider)),
    );

final Provider<SettingsLocalDataSource> settingsLocalDataSourceProvider =
    Provider<SettingsLocalDataSource>(
      (Ref ref) => SettingsLocalDataSource(ref.watch(settingsBoxProvider)),
    );

final Provider<LockLocalDataSource> lockLocalDataSourceProvider =
    Provider<LockLocalDataSource>(
      (Ref ref) => LockLocalDataSource(
        secureStorage: ref.watch(secureStorageProvider),
        localAuthentication: ref.watch(localAuthenticationProvider),
      ),
    );

final Provider<CycleRepository> cycleRepositoryProvider =
    Provider<CycleRepository>(
      (Ref ref) => CycleRepositoryImpl(ref.watch(cycleLocalDataSourceProvider)),
    );

final Provider<SettingsRepository> settingsRepositoryProvider =
    Provider<SettingsRepository>(
      (Ref ref) =>
          SettingsRepositoryImpl(ref.watch(settingsLocalDataSourceProvider)),
    );

final Provider<LockRepository> lockRepositoryProvider =
    Provider<LockRepository>(
      (Ref ref) => LockRepositoryImpl(ref.watch(lockLocalDataSourceProvider)),
    );

final Provider<CycleAnalyticsEngine> cycleAnalyticsEngineProvider =
    Provider<CycleAnalyticsEngine>((Ref ref) => const CycleAnalyticsEngine());
