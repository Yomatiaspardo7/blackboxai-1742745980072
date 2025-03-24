import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/user_profile.dart';

enum ExerciseType {
  breathing,
  meditation,
  bodyScanning,
  visualization,
  gratitude,
  grounding,
}

class MindfulnessExercise {
  final String id;
  final String title;
  final String description;
  final ExerciseType type;
  final int duration; // en minutos
  final List<String> steps;
  final Map<String, dynamic> settings;
  final String audioUrl;

  MindfulnessExercise({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.duration,
    required this.steps,
    this.settings = const {},
    this.audioUrl = '',
  });
}

class MindfulnessService extends ChangeNotifier {
  final List<MindfulnessExercise> _exercises = [
    MindfulnessExercise(
      id: 'breathing_478',
      title: 'Respiración 4-7-8',
      description: 'Técnica de respiración para reducir la ansiedad y el estrés',
      type: ExerciseType.breathing,
      duration: 5,
      steps: [
        'Siéntate o acuéstate en una posición cómoda',
        'Inhala por la nariz durante 4 segundos',
        'Mantén la respiración durante 7 segundos',
        'Exhala completamente por la boca durante 8 segundos',
        'Repite el ciclo 4 veces',
      ],
      settings: {
        'inhaleTime': 4,
        'holdTime': 7,
        'exhaleTime': 8,
        'cycles': 4,
      },
    ),
    MindfulnessExercise(
      id: 'body_scan',
      title: 'Escaneo Corporal',
      description: 'Ejercicio de atención plena centrado en las sensaciones corporales',
      type: ExerciseType.bodyScanning,
      duration: 10,
      steps: [
        'Acuéstate boca arriba en una posición cómoda',
        'Cierra los ojos y centra tu atención en los pies',
        'Sube gradualmente tu atención por todo el cuerpo',
        'Observa las sensaciones sin juzgarlas',
        'Termina con tres respiraciones profundas',
      ],
    ),
    MindfulnessExercise(
      id: 'grounding_54321',
      title: 'Técnica 5-4-3-2-1',
      description: 'Ejercicio de enraizamiento para momentos de ansiedad',
      type: ExerciseType.grounding,
      duration: 5,
      steps: [
        'Nombra 5 cosas que puedas ver',
        'Nombra 4 cosas que puedas tocar',
        'Nombra 3 cosas que puedas oír',
        'Nombra 2 cosas que puedas oler',
        'Nombra 1 cosa que puedas saborear',
      ],
    ),
  ];

  Timer? _exerciseTimer;
  bool _isExerciseActive = false;
  int _remainingTime = 0;
  MindfulnessExercise? _currentExercise;

  // Getters
  bool get isExerciseActive => _isExerciseActive;
  int get remainingTime => _remainingTime;
  MindfulnessExercise? get currentExercise => _currentExercise;
  List<MindfulnessExercise> get exercises => List.unmodifiable(_exercises);

  // Stream para el progreso del ejercicio
  final _progressController = StreamController<int>.broadcast();
  Stream<int> get progressStream => _progressController.stream;

  Future<void> startExercise(String exerciseId) async {
    if (_isExerciseActive) {
      throw Exception('Ya hay un ejercicio en curso');
    }

    final exercise = _exercises.firstWhere(
      (e) => e.id == exerciseId,
      orElse: () => throw Exception('Ejercicio no encontrado'),
    );

    _currentExercise = exercise;
    _remainingTime = exercise.duration * 60; // Convertir a segundos
    _isExerciseActive = true;
    notifyListeners();

    _exerciseTimer = Timer.periodic(
      const Duration(seconds: 1),
      _updateExerciseProgress,
    );
  }

  void _updateExerciseProgress(Timer timer) {
    if (_remainingTime <= 0) {
      _completeExercise();
      return;
    }

    _remainingTime--;
    _progressController.add(_remainingTime);
    notifyListeners();
  }

  void pauseExercise() {
    _exerciseTimer?.cancel();
    _isExerciseActive = false;
    notifyListeners();
  }

  void resumeExercise() {
    if (_currentExercise == null) return;
    
    _isExerciseActive = true;
    _exerciseTimer = Timer.periodic(
      const Duration(seconds: 1),
      _updateExerciseProgress,
    );
    notifyListeners();
  }

  void stopExercise() {
    _exerciseTimer?.cancel();
    _isExerciseActive = false;
    _currentExercise = null;
    _remainingTime = 0;
    notifyListeners();
  }

  void _completeExercise() {
    _exerciseTimer?.cancel();
    _isExerciseActive = false;
    
    // Aquí podrías guardar el progreso o estadísticas
    final session = ExerciseSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: DateTime.now(),
      exerciseType: _currentExercise!.type.toString(),
      duration: _currentExercise!.duration,
      metrics: {
        'completed': true,
        'actualDuration': _currentExercise!.duration * 60 - _remainingTime,
      },
    );

    // Notificar completación
    _currentExercise = null;
    _remainingTime = 0;
    notifyListeners();
  }

  List<MindfulnessExercise> getRecommendedExercises(HealthMetrics healthMetrics) {
    // Lógica para recomendar ejercicios basados en métricas de salud
    if (healthMetrics.stressLevel > 7) {
      return _exercises.where((e) => e.type == ExerciseType.breathing).toList();
    } else if (healthMetrics.stressLevel > 4) {
      return _exercises.where((e) => e.type == ExerciseType.meditation).toList();
    } else {
      return _exercises.where((e) => e.type == ExerciseType.gratitude).toList();
    }
  }

  String getExerciseGuide(String exerciseId) {
    final exercise = _exercises.firstWhere(
      (e) => e.id == exerciseId,
      orElse: () => throw Exception('Ejercicio no encontrado'),
    );

    return exercise.steps.join('\n');
  }

  @override
  void dispose() {
    _exerciseTimer?.cancel();
    _progressController.close();
    super.dispose();
  }
}