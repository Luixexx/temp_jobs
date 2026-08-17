import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Apariencia', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          RadioGroup<ThemeMode>(
            groupValue: settings.themeMode,
            onChanged: (mode) => settings.setThemeMode(mode!),
            child: const Column(
              children: [
                RadioListTile<ThemeMode>(
                  title: Text('Seguir el sistema'),
                  value: ThemeMode.system,
                ),
                RadioListTile<ThemeMode>(
                  title: Text('Claro'),
                  value: ThemeMode.light,
                ),
                RadioListTile<ThemeMode>(
                  title: Text('Oscuro'),
                  value: ThemeMode.dark,
                ),
              ],
            ),
          ),
          const Divider(height: 32),
          Text(
            'Tamaño del texto',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('A', style: TextStyle(fontSize: 14)),
              Expanded(
                child: Slider(
                  value: settings.fontScale,
                  min: 0.85,
                  max: 1.4,
                  divisions: 11,
                  label: '${(settings.fontScale * 100).round()}%',
                  onChanged: (value) => settings.setFontScale(value),
                ),
              ),
              const Text('A', style: TextStyle(fontSize: 24)),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Así se ve un texto de ejemplo con el tamaño actual.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
