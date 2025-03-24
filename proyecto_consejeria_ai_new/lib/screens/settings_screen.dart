import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/notification_service.dart';
import '../services/health_service.dart';
import '../services/mindfulness_service.dart';
import '../models/user_profile.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
        centerTitle: true,
      ),
      body: ListView(
        children: const [
          _NotificationSettings(),
          _HealthMonitoringSettings(),
          _MindfulnessSettings(),
          _AccountSettings(),
          _AboutSection(),
        ],
      ),
    );
  }
}

class _NotificationSettings extends StatelessWidget {
  const _NotificationSettings();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final notificationService = context.watch<NotificationService>();
    final mindfulnessService = context.watch<MindfulnessService>();
    
    return Card(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Notificaciones',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _SettingsSwitch(
            title: 'Recordatorios Diarios',
            subtitle: 'Recibe recordatorios para tus ejercicios',
            value: mindfulnessService.exercises.first.settings['preferences']?.notifications['daily'] ?? true,
            onChanged: (value) async {
              // Actualizar preferencias
              final prefs = mindfulnessService.exercises.first.settings['preferences'] as MindfulnessPreferences;
              prefs.notifications['daily'] = value;
              
              // Actualizar recordatorios
              if (value) {
                await notificationService.setupDailyReminders(prefs);
              } else {
                await notificationService.cancelNotification(0);
              }
            },
          ),
          _SettingsSwitch(
            title: 'Alertas de Estrés',
            subtitle: 'Notificaciones cuando se detecten niveles altos de estrés',
            value: mindfulnessService.exercises.first.settings['preferences']?.notifications['stress'] ?? true,
            onChanged: (value) async {
              final prefs = mindfulnessService.exercises.first.settings['preferences'] as MindfulnessPreferences;
              prefs.notifications['stress'] = value;
              
              if (!value) {
                await notificationService.cancelNotification(3);
              }
            },
          ),
        ],
      ),
    );
  }
}

class _HealthMonitoringSettings extends StatelessWidget {
  const _HealthMonitoringSettings();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final healthService = context.watch<HealthService>();
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Monitoreo de Salud',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _SettingsSwitch(
            title: 'Monitoreo Continuo',
            subtitle: 'Mantener activo el seguimiento de métricas',
            value: healthService.isMonitoring,
            onChanged: (value) async {
              if (value) {
                await healthService.startMonitoring();
              } else {
                await healthService.stopMonitoring();
              }
            },
          ),
          ListTile(
            title: const Text('Reconectar Dispositivo'),
            subtitle: const Text('Configurar conexión con smartwatch'),
            trailing: const Icon(Icons.watch),
            onTap: () async {
              await healthService.requestPermissions();
            },
          ),
        ],
      ),
    );
  }
}

class _MindfulnessSettings extends StatelessWidget {
  const _MindfulnessSettings();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mindfulnessService = context.watch<MindfulnessService>();
    final prefs = mindfulnessService.exercises.first.settings['preferences'] as MindfulnessPreferences;
    
    return Card(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Ejercicios de Mindfulness',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            title: const Text('Duración Predeterminada'),
            subtitle: Text('${prefs.preferredDuration} minutos'),
            trailing: const Icon(Icons.timer),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => _DurationPickerDialog(
                  initialDuration: prefs.preferredDuration,
                  onDurationSelected: (duration) {
                    prefs.preferredDuration = duration;
                  },
                ),
              );
            },
          ),
          _SettingsSwitch(
            title: 'Música de Fondo',
            subtitle: 'Reproducir música durante los ejercicios',
            value: prefs.withBackgroundMusic,
            onChanged: (value) {
              prefs.withBackgroundMusic = value;
            },
          ),
        ],
      ),
    );
  }
}

class _AccountSettings extends StatelessWidget {
  const _AccountSettings();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Cuenta',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            title: const Text('Exportar Datos'),
            subtitle: const Text('Descargar historial y métricas'),
            trailing: const Icon(Icons.download),
            onTap: () {
              // TODO: Implementar exportación de datos
            },
          ),
          ListTile(
            title: const Text('Eliminar Cuenta'),
            subtitle: const Text('Eliminar todos los datos'),
            trailing: const Icon(Icons.delete_forever),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Eliminar Cuenta'),
                  content: const Text(
                    '¿Estás seguro de que deseas eliminar tu cuenta? Esta acción no se puede deshacer.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () {
                        // TODO: Implementar eliminación de cuenta
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Eliminar',
                        style: TextStyle(
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _AboutSection extends StatelessWidget {
  const _AboutSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Acerca de',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            title: const Text('Versión'),
            subtitle: const Text('1.0.0'),
          ),
          ListTile(
            title: const Text('Términos de Uso'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // TODO: Mostrar términos de uso
            },
          ),
          ListTile(
            title: const Text('Política de Privacidad'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // TODO: Mostrar política de privacidad
            },
          ),
        ],
      ),
    );
  }
}

class _SettingsSwitch extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsSwitch({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
    );
  }
}

class _DurationPickerDialog extends StatefulWidget {
  final int initialDuration;
  final ValueChanged<int> onDurationSelected;

  const _DurationPickerDialog({
    required this.initialDuration,
    required this.onDurationSelected,
  });

  @override
  State<_DurationPickerDialog> createState() => _DurationPickerDialogState();
}

class _DurationPickerDialogState extends State<_DurationPickerDialog> {
  late int _selectedDuration;

  @override
  void initState() {
    super.initState();
    _selectedDuration = widget.initialDuration;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Duración del Ejercicio'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Selecciona la duración predeterminada para los ejercicios'),
          const SizedBox(height: 16),
          DropdownButton<int>(
            value: _selectedDuration,
            items: [5, 10, 15, 20, 30].map((duration) {
              return DropdownMenuItem(
                value: duration,
                child: Text('$duration minutos'),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedDuration = value;
                });
              }
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () {
            widget.onDurationSelected(_selectedDuration);
            Navigator.pop(context);
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}