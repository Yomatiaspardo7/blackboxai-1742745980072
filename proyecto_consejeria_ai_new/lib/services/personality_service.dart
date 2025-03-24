import 'package:flutter/foundation.dart';
import '../models/user_profile.dart';

class PersonalityQuestion {
  final String id;
  final String question;
  final List<String> options;
  final Map<String, int> scoring;
  final String category;

  PersonalityQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.scoring,
    required this.category,
  });
}

class PersonalityService extends ChangeNotifier {
  final List<PersonalityQuestion> _questions = [
    PersonalityQuestion(
      id: 'q1',
      question: '¿Cómo prefieres recargar tu energía?',
      options: [
        'Pasando tiempo a solas',
        'Socializando con otros',
        'Una mezcla de ambos',
      ],
      scoring: {
        'introversion': 3,
        'extroversion': 0,
        'ambiversion': 1,
      },
      category: 'socialización',
    ),
    PersonalityQuestion(
      id: 'q2',
      question: '¿Cómo manejas situaciones estresantes?',
      options: [
        'Prefiero procesarlo internamente',
        'Busco apoyo y consejo de otros',
        'Depende de la situación',
      ],
      scoring: {
        'resilience': 2,
        'support_seeking': 3,
        'adaptability': 4,
      },
      category: 'estrés',
    ),
    PersonalityQuestion(
      id: 'q3',
      question: '¿Qué te ayuda más a relajarte?',
      options: [
        'Meditación y ejercicios de respiración',
        'Actividad física',
        'Conversación con amigos',
        'Actividades creativas',
      ],
      scoring: {
        'mindfulness': 4,
        'physical': 3,
        'social': 2,
        'creative': 3,
      },
      category: 'relajación',
    ),
    // Añadir más preguntas según sea necesario
  ];

  Map<String, dynamic> _currentAnswers = {};
  int _currentQuestionIndex = 0;
  bool _testCompleted = false;

  // Getters
  List<PersonalityQuestion> get questions => List.unmodifiable(_questions);
  int get currentQuestionIndex => _currentQuestionIndex;
  bool get testCompleted => _testCompleted;
  PersonalityQuestion get currentQuestion => _questions[_currentQuestionIndex];

  void answerQuestion(String questionId, String answer) {
    _currentAnswers[questionId] = answer;
    
    if (_currentQuestionIndex < _questions.length - 1) {
      _currentQuestionIndex++;
    } else {
      _testCompleted = true;
    }
    
    notifyListeners();
  }

  void resetTest() {
    _currentAnswers = {};
    _currentQuestionIndex = 0;
    _testCompleted = false;
    notifyListeners();
  }

  Map<String, dynamic> analyzePersonality() {
    if (!_testCompleted) {
      throw Exception('El test no ha sido completado');
    }

    Map<String, int> scores = {};
    Map<String, List<String>> traits = {
      'introversion': [],
      'extroversion': [],
      'ambiversion': [],
      'resilience': [],
      'support_seeking': [],
      'adaptability': [],
      'mindfulness': [],
      'physical': [],
      'social': [],
      'creative': [],
    };

    // Calcular puntuaciones
    _currentAnswers.forEach((questionId, answer) {
      final question = _questions.firstWhere((q) => q.id == questionId);
      question.scoring.forEach((trait, score) {
        scores[trait] = (scores[trait] ?? 0) + score;
      });
    });

    // Determinar tipo de personalidad dominante
    PersonalityType dominantType = _determineDominantType(scores);

    // Generar recomendaciones basadas en el análisis
    List<String> recommendations = _generateRecommendations(scores, dominantType);

    return {
      'personalityType': dominantType,
      'scores': scores,
      'traits': traits,
      'recommendations': recommendations,
    };
  }

  PersonalityType _determineDominantType(Map<String, int> scores) {
    int introversion = scores['introversion'] ?? 0;
    int extroversion = scores['extroversion'] ?? 0;
    int ambiversion = scores['ambiversion'] ?? 0;

    if (ambiversion > introversion && ambiversion > extroversion) {
      return PersonalityType.ambivert;
    } else if (introversion > extroversion) {
      return PersonalityType.introvert;
    } else {
      return PersonalityType.extrovert;
    }
  }

  List<String> _generateRecommendations(
    Map<String, int> scores,
    PersonalityType type,
  ) {
    List<String> recommendations = [];

    switch (type) {
      case PersonalityType.introvert:
        recommendations.addAll([
          'Practica meditación en solitario',
          'Establece límites claros en tus interacciones sociales',
          'Dedica tiempo a actividades que te permitan recargar energía',
        ]);
        break;
      case PersonalityType.extrovert:
        recommendations.addAll([
          'Participa en ejercicios de mindfulness grupales',
          'Busca apoyo social activamente',
          'Combina actividad física con socialización',
        ]);
        break;
      case PersonalityType.ambivert:
        recommendations.addAll([
          'Alterna entre actividades sociales y momentos de soledad',
          'Practica técnicas de respiración adaptativas',
          'Mantén un equilibrio entre diferentes tipos de actividades',
        ]);
        break;
      default:
        recommendations.add('Comienza con ejercicios básicos de mindfulness');
    }

    // Añadir recomendaciones basadas en puntuaciones específicas
    if (scores['mindfulness'] ?? 0 > 3) {
      recommendations.add(
        'Profundiza en prácticas de meditación y atención plena',
      );
    }
    if (scores['physical'] ?? 0 > 3) {
      recommendations.add(
        'Incorpora ejercicios de yoga o tai chi a tu rutina',
      );
    }

    return recommendations;
  }

  Map<String, List<String>> getExerciseRecommendations(
    PersonalityType type,
    int stressLevel,
  ) {
    Map<String, List<String>> recommendations = {
      'respiración': [],
      'meditación': [],
      'actividad': [],
    };

    // Recomendaciones base según tipo de personalidad
    switch (type) {
      case PersonalityType.introvert:
        recommendations['respiración'] = [
          'Respiración 4-7-8',
          'Respiración diafragmática',
        ];
        recommendations['meditación'] = [
          'Meditación en silencio',
          'Escaneo corporal',
        ];
        recommendations['actividad'] = [
          'Caminata consciente',
          'Journaling',
        ];
        break;
      case PersonalityType.extrovert:
        recommendations['respiración'] = [
          'Respiración energizante',
          'Respiración alternada',
        ];
        recommendations['meditación'] = [
          'Meditación guiada',
          'Meditación en movimiento',
        ];
        recommendations['actividad'] = [
          'Yoga dinámico',
          'Ejercicios de grupo',
        ];
        break;
      case PersonalityType.ambivert:
        recommendations['respiración'] = [
          'Respiración equilibrada',
          'Técnica 4-4-4',
        ];
        recommendations['meditación'] = [
          'Meditación adaptativa',
          'Mindfulness situacional',
        ];
        recommendations['actividad'] = [
          'Ejercicios flexibles',
          'Actividades mixtas',
        ];
        break;
      default:
        // Recomendaciones generales
        recommendations['respiración'] = [
          'Respiración consciente',
          'Respiración profunda',
        ];
        recommendations['meditación'] = [
          'Meditación básica',
          'Atención plena',
        ];
        recommendations['actividad'] = [
          'Estiramientos suaves',
          'Caminata tranquila',
        ];
    }

    // Ajustar según nivel de estrés
    if (stressLevel > 7) {
      recommendations['respiración'].add('Técnica de calma rápida');
      recommendations['meditación'].add('Meditación de emergencia');
      recommendations['actividad'].add('Ejercicios de grounding');
    }

    return recommendations;
  }
}