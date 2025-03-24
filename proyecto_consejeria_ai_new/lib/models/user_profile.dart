import 'package:flutter/foundation.dart';

enum PersonalityType {
  introvert,
  extrovert,
  ambivert,
  unknown,
}

enum AnxietyLevel {
  low,
  moderate,
  high,
  severe,
}

class UserProfile {
  final String id;
  final String name;
  final DateTime birthDate;
  PersonalityType personalityType;
  List<String> interests;
  List<String> stressors;
  Map<String, dynamic> personalityTraits;
  bool hasCompletedInitialTest;
  
  // Métricas de salud
  HealthMetrics healthMetrics;
  
  // Preferencias de mindfulness
  MindfulnessPreferences mindfulnessPreferences;
  
  // Historial de ejercicios y progreso
  List<ExerciseSession> exerciseHistory;
  
  UserProfile({
    required this.id,
    required this.name,
    required this.birthDate,
    this.personalityType = PersonalityType.unknown,
    List<String>? interests,
    List<String>? stressors,
    Map<String, dynamic>? personalityTraits,
    this.hasCompletedInitialTest = false,
    HealthMetrics? healthMetrics,
    MindfulnessPreferences? mindfulnessPreferences,
    List<ExerciseSession>? exerciseHistory,
  })  : interests = interests ?? [],
        stressors = stressors ?? [],
        personalityTraits = personalityTraits ?? {},
        healthMetrics = healthMetrics ?? HealthMetrics(),
        mindfulnessPreferences = mindfulnessPreferences ?? MindfulnessPreferences(),
        exerciseHistory = exerciseHistory ?? [];

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'birthDate': birthDate.toIso8601String(),
        'personalityType': personalityType.toString(),
        'interests': interests,
        'stressors': stressors,
        'personalityTraits': personalityTraits,
        'hasCompletedInitialTest': hasCompletedInitialTest,
        'healthMetrics': healthMetrics.toJson(),
        'mindfulnessPreferences': mindfulnessPreferences.toJson(),
        'exerciseHistory': exerciseHistory.map((e) => e.toJson()).toList(),
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        id: json['id'] as String,
        name: json['name'] as String,
        birthDate: DateTime.parse(json['birthDate'] as String),
        personalityType: PersonalityType.values.firstWhere(
          (e) => e.toString() == json['personalityType'],
          orElse: () => PersonalityType.unknown,
        ),
        interests: List<String>.from(json['interests'] as List),
        stressors: List<String>.from(json['stressors'] as List),
        personalityTraits: json['personalityTraits'] as Map<String, dynamic>,
        hasCompletedInitialTest: json['hasCompletedInitialTest'] as bool,
        healthMetrics: HealthMetrics.fromJson(json['healthMetrics']),
        mindfulnessPreferences: MindfulnessPreferences.fromJson(
          json['mindfulnessPreferences'],
        ),
        exerciseHistory: (json['exerciseHistory'] as List)
            .map((e) => ExerciseSession.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class HealthMetrics {
  int heartRate;
  double oxygenLevel;
  int stressLevel;
  DateTime lastUpdated;
  List<HealthReading> readings;

  HealthMetrics({
    this.heartRate = 0,
    this.oxygenLevel = 0.0,
    this.stressLevel = 0,
    DateTime? lastUpdated,
    List<HealthReading>? readings,
  })  : lastUpdated = lastUpdated ?? DateTime.now(),
        readings = readings ?? [];

  Map<String, dynamic> toJson() => {
        'heartRate': heartRate,
        'oxygenLevel': oxygenLevel,
        'stressLevel': stressLevel,
        'lastUpdated': lastUpdated.toIso8601String(),
        'readings': readings.map((r) => r.toJson()).toList(),
      };

  factory HealthMetrics.fromJson(Map<String, dynamic> json) => HealthMetrics(
        heartRate: json['heartRate'] as int,
        oxygenLevel: json['oxygenLevel'] as double,
        stressLevel: json['stressLevel'] as int,
        lastUpdated: DateTime.parse(json['lastUpdated'] as String),
        readings: (json['readings'] as List)
            .map((e) => HealthReading.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class HealthReading {
  final DateTime timestamp;
  final int heartRate;
  final double oxygenLevel;
  final int stressLevel;

  HealthReading({
    required this.timestamp,
    required this.heartRate,
    required this.oxygenLevel,
    required this.stressLevel,
  });

  Map<String, dynamic> toJson() => {
        'timestamp': timestamp.toIso8601String(),
        'heartRate': heartRate,
        'oxygenLevel': oxygenLevel,
        'stressLevel': stressLevel,
      };

  factory HealthReading.fromJson(Map<String, dynamic> json) => HealthReading(
        timestamp: DateTime.parse(json['timestamp'] as String),
        heartRate: json['heartRate'] as int,
        oxygenLevel: json['oxygenLevel'] as double,
        stressLevel: json['stressLevel'] as int,
      );
}

class MindfulnessPreferences {
  int preferredDuration; // en minutos
  String preferredVoice;
  bool withBackgroundMusic;
  List<String> favoriteExercises;
  Map<String, bool> notifications;

  MindfulnessPreferences({
    this.preferredDuration = 10,
    this.preferredVoice = 'default',
    this.withBackgroundMusic = true,
    List<String>? favoriteExercises,
    Map<String, bool>? notifications,
  })  : favoriteExercises = favoriteExercises ?? [],
        notifications = notifications ?? {
          'daily': true,
          'exercise': true,
          'stress': true,
        };

  Map<String, dynamic> toJson() => {
        'preferredDuration': preferredDuration,
        'preferredVoice': preferredVoice,
        'withBackgroundMusic': withBackgroundMusic,
        'favoriteExercises': favoriteExercises,
        'notifications': notifications,
      };

  factory MindfulnessPreferences.fromJson(Map<String, dynamic> json) =>
      MindfulnessPreferences(
        preferredDuration: json['preferredDuration'] as int,
        preferredVoice: json['preferredVoice'] as String,
        withBackgroundMusic: json['withBackgroundMusic'] as bool,
        favoriteExercises: List<String>.from(json['favoriteExercises'] as List),
        notifications: Map<String, bool>.from(json['notifications'] as Map),
      );
}

class ExerciseSession {
  final String id;
  final DateTime timestamp;
  final String exerciseType;
  final int duration;
  final Map<String, dynamic> metrics;
  final String notes;

  ExerciseSession({
    required this.id,
    required this.timestamp,
    required this.exerciseType,
    required this.duration,
    Map<String, dynamic>? metrics,
    this.notes = '',
  }) : metrics = metrics ?? {};

  Map<String, dynamic> toJson() => {
        'id': id,
        'timestamp': timestamp.toIso8601String(),
        'exerciseType': exerciseType,
        'duration': duration,
        'metrics': metrics,
        'notes': notes,
      };

  factory ExerciseSession.fromJson(Map<String, dynamic> json) => ExerciseSession(
        id: json['id'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
        exerciseType: json['exerciseType'] as String,
        duration: json['duration'] as int,
        metrics: json['metrics'] as Map<String, dynamic>,
        notes: json['notes'] as String,
      );
}