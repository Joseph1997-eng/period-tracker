import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../security/presentation/controllers/lock_controller.dart';
import '../controllers/settings_controller.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsControllerProvider);
    final lockState = ref.watch(lockControllerProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        Card(
          child: Column(
            children: <Widget>[
              SwitchListTile(
                title: const Text('Dark mode'),
                subtitle: const Text('Persist app appearance preference'),
                value: settings.isDarkMode,
                onChanged: (bool enabled) {
                  ref
                      .read(settingsControllerProvider.notifier)
                      .setDarkMode(enabled);
                },
              ),
              const Divider(height: 1),
              SwitchListTile(
                title: const Text('Privacy lock'),
                subtitle: const Text('Require biometric or PIN unlock'),
                value: settings.privacyLockEnabled,
                onChanged: (bool enabled) {
                  ref
                      .read(settingsControllerProvider.notifier)
                      .setPrivacyLockEnabled(enabled);
                },
              ),
              const Divider(height: 1),
              SwitchListTile(
                title: const Text('Biometric unlock'),
                subtitle: const Text('Face/Fingerprint authentication'),
                value: settings.biometricEnabled,
                onChanged: settings.privacyLockEnabled
                    ? (bool enabled) {
                        ref
                            .read(settingsControllerProvider.notifier)
                            .setBiometricEnabled(enabled);
                      }
                    : null,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'PIN Management',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  lockState.hasPinConfigured
                      ? 'A PIN is configured for this app.'
                      : 'Set a 4-digit PIN for fallback unlock.',
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: <Widget>[
                    FilledButton.icon(
                      onPressed: _upsertPin,
                      icon: const Icon(Icons.pin_outlined),
                      label: Text(
                        lockState.hasPinConfigured ? 'Change PIN' : 'Set PIN',
                      ),
                    ),
                    if (lockState.hasPinConfigured)
                      OutlinedButton.icon(
                        onPressed: _removePin,
                        icon: const Icon(Icons.delete_outline),
                        label: const Text('Remove PIN'),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _upsertPin() async {
    final String? pin = await _showPinDialog();
    if (pin == null) {
      return;
    }

    await ref.read(lockControllerProvider.notifier).setPin(pin);
    await ref
        .read(settingsControllerProvider.notifier)
        .setPrivacyLockEnabled(true);

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('PIN saved successfully.')));
  }

  Future<void> _removePin() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Remove PIN?'),
          content: const Text('This disables PIN fallback unlock.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    await ref.read(lockControllerProvider.notifier).clearPin();
    await ref
        .read(settingsControllerProvider.notifier)
        .setPrivacyLockEnabled(false);

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('PIN removed. Privacy lock disabled.')),
    );
  }

  Future<String?> _showPinDialog() async {
    final TextEditingController pinController = TextEditingController();
    final TextEditingController confirmController = TextEditingController();
    String? error;

    final String? pin = await showDialog<String>(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder:
              (BuildContext context, void Function(void Function()) setState) {
                return AlertDialog(
                  title: const Text('Set 4-digit PIN'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      TextField(
                        controller: pinController,
                        obscureText: true,
                        maxLength: 4,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'PIN'),
                      ),
                      TextField(
                        controller: confirmController,
                        obscureText: true,
                        maxLength: 4,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Confirm PIN',
                          errorText: error,
                        ),
                      ),
                    ],
                  ),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      onPressed: () {
                        final String pinValue = pinController.text.trim();
                        final String confirmValue = confirmController.text
                            .trim();
                        final RegExp pinRegex = RegExp(r'^\d{4}$');

                        if (!pinRegex.hasMatch(pinValue)) {
                          setState(() {
                            error = 'PIN must be exactly 4 digits';
                          });
                          return;
                        }

                        if (pinValue != confirmValue) {
                          setState(() {
                            error = 'PINs do not match';
                          });
                          return;
                        }

                        Navigator.of(dialogContext).pop(pinValue);
                      },
                      child: const Text('Save'),
                    ),
                  ],
                );
              },
        );
      },
    );

    pinController.dispose();
    confirmController.dispose();

    return pin;
  }
}
