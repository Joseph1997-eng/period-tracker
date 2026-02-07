import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../home/presentation/screens/home_shell.dart';
import '../../../settings/domain/entities/app_settings.dart';
import '../../../settings/presentation/controllers/settings_controller.dart';
import '../controllers/lock_controller.dart' as lock_feature;

class LockGateScreen extends ConsumerStatefulWidget {
  const LockGateScreen({super.key});

  @override
  ConsumerState<LockGateScreen> createState() => _LockGateScreenState();
}

class _LockGateScreenState extends ConsumerState<LockGateScreen>
    with WidgetsBindingObserver {
  final TextEditingController _pinController = TextEditingController();
  ProviderSubscription<AppSettings>? _settingsSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _settingsSubscription = ref.listenManual<AppSettings>(
      settingsControllerProvider,
      (AppSettings? previous, AppSettings next) {
        final bool shouldInitialize =
            previous == null ||
            previous.privacyLockEnabled != next.privacyLockEnabled ||
            previous.biometricEnabled != next.biometricEnabled;

        if (!shouldInitialize) {
          return;
        }

        ref
            .read(lock_feature.lockControllerProvider.notifier)
            .initialize(
              lockEnabled: next.privacyLockEnabled,
              biometricEnabled: next.biometricEnabled,
            );
      },
      fireImmediately: true,
    );
  }

  @override
  void dispose() {
    _settingsSubscription?.close();
    WidgetsBinding.instance.removeObserver(this);
    _pinController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      final AppSettings settings = ref.read(settingsControllerProvider);
      ref
          .read(lock_feature.lockControllerProvider.notifier)
          .lockIfNeeded(lockEnabled: settings.privacyLockEnabled);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppSettings settings = ref.watch(settingsControllerProvider);
    final lock_feature.LockState lockState = ref.watch(
      lock_feature.lockControllerProvider,
    );

    if (!settings.privacyLockEnabled) {
      return const HomeShell();
    }

    if (lockState.isInitializing) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (lockState.isUnlocked) {
      return const HomeShell();
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Icon(
                        Icons.lock_outline,
                        size: 44,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Privacy Lock',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Unlock to access your cycle data.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 18),
                      TextField(
                        controller: _pinController,
                        obscureText: true,
                        maxLength: 4,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        decoration: const InputDecoration(
                          labelText: 'PIN',
                          counterText: '',
                        ),
                        onSubmitted: (_) => _unlockWithPin(),
                      ),
                      const SizedBox(height: 8),
                      FilledButton(
                        onPressed: _unlockWithPin,
                        child: const Text('Unlock with PIN'),
                      ),
                      if (settings.biometricEnabled &&
                          lockState.biometricsAvailable)
                        TextButton.icon(
                          onPressed: () {
                            ref
                                .read(
                                  lock_feature.lockControllerProvider.notifier,
                                )
                                .authenticateWithBiometrics();
                          },
                          icon: const Icon(Icons.fingerprint),
                          label: const Text('Use Biometrics'),
                        ),
                      if (lockState.errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            lockState.errorMessage!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ),
                      if (!lockState.hasPinConfigured)
                        const Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Text(
                            'No PIN configured yet. Open Settings to set one.',
                            textAlign: TextAlign.center,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _unlockWithPin() async {
    final String pin = _pinController.text.trim();
    await ref
        .read(lock_feature.lockControllerProvider.notifier)
        .unlockWithPin(pin);
    _pinController.clear();
  }
}
