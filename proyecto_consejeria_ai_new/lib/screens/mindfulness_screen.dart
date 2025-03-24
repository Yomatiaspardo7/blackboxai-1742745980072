import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/mindfulness_service.dart';
import '../services/health_service.dart';
import '../widgets/breathing_exercise.dart';

class MindfulnessScreen extends StatefulWidget {
  const MindfulnessScreen({super.key});

  @override
  State<MindfulnessScreen> createState() => _MindfulnessScreenState();
}

class _MindfulnessScreenState extends State<MindfulnessScreen> {
  bool _showExercise = false;
  MindfulnessExercise? _selectedExercise;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mindfulnessService = context.watch<MindfulnessService>();
    final healthService = context.watch<HealthService>();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mindfulness'),
        centerTitle: true,
      ),
      body: _showExercise && _selectedExercise != null
          ? _buildExerciseView()
          : _buildExercisesList(mindfulnessService, healthService),
    );
  }

  Widget _buildExercisesList(
    MindfulnessService mindfulnessService,
    HealthService healthService,
  ) {
    final theme = Theme.of(context);
    final exercises = mindfulnessService.getRecommendedExercises(
      healthService.lastMetrics,
    );

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ejercicios Recomendados',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Basados en tus niveles actuales de estrés y ansiedad',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 24),
                const _StressLevelIndicator(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16.0,
              crossAxisSpacing: 16.0,
              childAspectRatio: 0.75,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final exercise = exercises[index];
                return _ExerciseCard(
                  exercise: exercise,
                  onTap: () {
                    setState(() {
                      _selectedExercise = exercise;
                      _showExercise = true;
                    });
                  },
                );
              },
              childCount: exercises.length,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExerciseView() {
    if (_selectedExercise == null) return const SizedBox.shrink();

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                BreathingGuide(
                  title: _selectedExercise!.title,
                  description: _selectedExercise!.description,
                  onStart: () {
                    setState(() {
                      _showExercise = true;
                    });
                  },
                ),
                const SizedBox(height: 32),
                BreathingExercise(
                  inhaleSeconds: _selectedExercise!.settings['inhaleTime'] ?? 4,
                  holdSeconds: _selectedExercise!.settings['holdTime'] ?? 7,
                  exhaleSeconds: _selectedExercise!.settings['exhaleTime'] ?? 8,
                  cycles: _selectedExercise!.settings['cycles'] ?? 4,
                  onComplete: () {
                    // Mostrar diálogo de completado
                    showDialog(
                      context: context,
                      builder: (context) => _ExerciseCompletedDialog(
                        exercise: _selectedExercise!,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () {
                setState(() {
                  _showExercise = false;
                  _selectedExercise = null;
                });
              },
              child: const Text('Volver a Ejercicios'),
            ),
          ),
        ),
      ],
    );
  }
}

class _StressLevelIndicator extends StatelessWidget {
  const _StressLevelIndicator();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final healthService = context.watch<HealthService>();
    final stressLevel = healthService.lastMetrics.stressLevel;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.psychology,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Nivel de Estrés',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: stressLevel / 10,
              backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                _getStressColor(stressLevel),
              ),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _getStressText(stressLevel),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: _getStressColor(stressLevel),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$stressLevel/10',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStressColor(int level) {
    if (level <= 3) return Colors.green;
    if (level <= 6) return Colors.orange;
    return Colors.red;
  }

  String _getStressText(int level) {
    if (level <= 3) return 'Bajo';
    if (level <= 6) return 'Moderado';
    return 'Alto';
  }
}

class _ExerciseCard extends StatelessWidget {
  final MindfulnessExercise exercise;
  final VoidCallback onTap;

  const _ExerciseCard({
    required this.exercise,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                _getIconForExerciseType(exercise.type),
                color: theme.colorScheme.primary,
                size: 32,
              ),
              const SizedBox(height: 16),
              Text(
                exercise.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                exercise.description,
                style: theme.textTheme.bodySmall,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              Row(
                children: [
                  Icon(
                    Icons.timer_outlined,
                    size: 16,
                    color: theme.textTheme.bodySmall?.color,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${exercise.duration} min',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconForExerciseType(ExerciseType type) {
    switch (type) {
      case ExerciseType.breathing:
        return Icons.air;
      case ExerciseType.meditation:
        return Icons.self_improvement;
      case ExerciseType.bodyScanning:
        return Icons.accessibility_new;
      case ExerciseType.visualization:
        return Icons.remove_red_eye;
      case ExerciseType.gratitude:
        return Icons.favorite;
      case ExerciseType.grounding:
        return Icons.spa;
    }
  }
}

class _ExerciseCompletedDialog extends StatelessWidget {
  final MindfulnessExercise exercise;

  const _ExerciseCompletedDialog({
    required this.exercise,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 8),
          const Text('¡Ejercicio Completado!'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '¡Excelente trabajo! Has completado el ejercicio "${exercise.title}".',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Text(
            '¿Cómo te sientes ahora?',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _MoodButton(
                emoji: '😊',
                label: 'Mejor',
                onTap: () => Navigator.pop(context, 'better'),
              ),
              _MoodButton(
                emoji: '😐',
                label: 'Igual',
                onTap: () => Navigator.pop(context, 'same'),
              ),
              _MoodButton(
                emoji: '😔',
                label: 'Peor',
                onTap: () => Navigator.pop(context, 'worse'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MoodButton extends StatelessWidget {
  final String emoji;
  final String label;
  final VoidCallback onTap;

  const _MoodButton({
    required this.emoji,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 32),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}