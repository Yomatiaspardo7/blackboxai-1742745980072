import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/chat_message.dart';

class ChatService {
  final List<ChatMessage> _messages = [];
  List<ChatMessage> get messages => List.unmodifiable(_messages);

  final _messageController = StreamController<ChatMessage>.broadcast();
  Stream<ChatMessage> get messageStream => _messageController.stream;

  final _typingController = StreamController<bool>.broadcast();
  Stream<bool> get typingStream => _typingController.stream;

  bool _isTyping = false;
  bool get isTyping => _isTyping;

  Future<void> sendMessage(String content, {bool isVoice = false}) async {
    if (content.trim().isEmpty) return;

    final userMessage = ChatMessage.text(
      content: content,
      isUser: true,
    );

    _messages.add(userMessage);
    _messageController.add(userMessage);

    _setTyping(true);

    try {
      final response = await _getAIResponse(content);
      final aiMessage = ChatMessage.text(
        content: response,
        isUser: false,
      );

      _messages.add(aiMessage);
      _messageController.add(aiMessage);
    } catch (e) {
      final errorMessage = ChatMessage.error(
        content: 'Lo siento, hubo un error al procesar tu mensaje. Por favor, intenta de nuevo.',
      );

      _messages.add(errorMessage);
      _messageController.add(errorMessage);
    } finally {
      _setTyping(false);
    }
  }

  Future<String> _getAIResponse(String userMessage) async {
    try {
      // Simular delay de red y procesamiento de IA
      await Future.delayed(AppConfig.aiResponseDelay);

      // TODO: Implementar llamada real a la API de IA
      // Por ahora, devolvemos respuestas simuladas basadas en palabras clave
      if (userMessage.toLowerCase().contains('relación') || 
          userMessage.toLowerCase().contains('pareja')) {
        return _getRelationshipAdvice();
      } else if (userMessage.toLowerCase().contains('trabajo') || 
                 userMessage.toLowerCase().contains('empleo')) {
        return _getWorkAdvice();
      } else if (userMessage.toLowerCase().contains('familia') || 
                 userMessage.toLowerCase().contains('padres')) {
        return _getFamilyAdvice();
      } else {
        return _getGeneralAdvice();
      }
    } catch (e) {
      throw Exception('Error al obtener respuesta de la IA');
    }
  }

  void _setTyping(bool typing) {
    _isTyping = typing;
    _typingController.add(typing);
  }

  List<String> getQuickReplies(String lastMessage) {
    // Generar sugerencias de respuesta basadas en el último mensaje
    if (lastMessage.toLowerCase().contains('relación')) {
      return [
        '¿Cómo puedo mejorar la comunicación?',
        '¿Qué hago si no me siento valorado/a?',
        '¿Cómo manejar los conflictos?'
      ];
    } else if (lastMessage.toLowerCase().contains('trabajo')) {
      return [
        '¿Cómo manejar el estrés laboral?',
        '¿Cómo pedir un aumento?',
        '¿Cómo mejorar mi productividad?'
      ];
    }
    return [
      '¿Puedes darme más detalles?',
      '¿Qué me recomiendas hacer?',
      '¿Cómo puedo mejorar la situación?'
    ];
  }

  String _getRelationshipAdvice() {
    final advices = [
      'La comunicación abierta y honesta es fundamental en cualquier relación. Te sugiero establecer momentos específicos para dialogar sobre sus preocupaciones y expectativas.',
      'Es importante mantener un equilibrio entre la independencia personal y la vida en pareja. Dedica tiempo a tus propios intereses y permite que tu pareja haga lo mismo.',
      'Los conflictos son normales, lo importante es cómo los manejamos. Intenta expresar tus sentimientos sin acusar y escucha activamente a tu pareja.',
    ];
    return advices[DateTime.now().millisecond % advices.length];
  }

  String _getWorkAdvice() {
    final advices = [
      'Establece límites claros entre tu vida laboral y personal. Define horarios específicos y aprende a desconectar.',
      'La comunicación efectiva con tus colegas y superiores es clave. Sé claro en tus necesidades y expectativas.',
      'Desarrolla un plan de crecimiento profesional. Identifica las habilidades que necesitas mejorar y busca oportunidades de aprendizaje.',
    ];
    return advices[DateTime.now().millisecond % advices.length];
  }

  String _getFamilyAdvice() {
    final advices = [
      'Las relaciones familiares requieren paciencia y comprensión. Trata de ver las situaciones desde diferentes perspectivas.',
      'Establece límites saludables mientras mantienes el respeto y el amor. Es posible ser firme y amable al mismo tiempo.',
      'Dedica tiempo de calidad a tu familia. Crea momentos especiales y tradiciones que fortalezcan sus vínculos.',
    ];
    return advices[DateTime.now().millisecond % advices.length];
  }

  String _getGeneralAdvice() {
    final advices = [
      'Tómate un momento para reflexionar sobre tus sentimientos y necesidades. La autoconciencia es el primer paso para el cambio positivo.',
      'A veces, dar pequeños pasos consistentes es mejor que buscar cambios dramáticos. ¿Qué pequeña acción podrías tomar hoy?',
      'Recuerda ser compasivo contigo mismo mientras trabajas en tus objetivos. El cambio lleva tiempo y está bien cometer errores en el proceso.',
    ];
    return advices[DateTime.now().millisecond % advices.length];
  }

  void dispose() {
    _messageController.close();
    _typingController.close();
  }
}