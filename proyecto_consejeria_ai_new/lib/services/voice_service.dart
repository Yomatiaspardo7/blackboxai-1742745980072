import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../config/app_config.dart';

enum VoiceServiceStatus {
  idle,
  listening,
  processing,
  speaking,
  error
}

class VoiceService extends ChangeNotifier {
  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  
  bool _isInitialized = false;
  VoiceServiceStatus _status = VoiceServiceStatus.idle;
  String _transcription = '';
  String _lastError = '';
  
  bool get isInitialized => _isInitialized;
  bool get isListening => _status == VoiceServiceStatus.listening;
  bool get isSpeaking => _status == VoiceServiceStatus.speaking;
  String get transcription => _transcription;
  String get lastError => _lastError;
  VoiceServiceStatus get status => _status;

  VoiceService() {
    _initializeTts();
  }

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _isInitialized = await _speechToText.initialize(
        onError: (error) => _handleError(error.errorMsg),
        debugLogging: true,
      );
      
      await _initializeTts();
      
      notifyListeners();
    } catch (e) {
      _handleError('Error al inicializar el servicio de voz: $e');
    }
  }

  Future<void> _initializeTts() async {
    await _flutterTts.setLanguage(AppConfig.defaultLanguage);
    await _flutterTts.setSpeechRate(AppConfig.defaultSpeechRate);
    await _flutterTts.setVolume(AppConfig.defaultVolume);
    await _flutterTts.setPitch(AppConfig.defaultPitch);
    
    _flutterTts.setStartHandler(() {
      _status = VoiceServiceStatus.speaking;
      notifyListeners();
    });

    _flutterTts.setCompletionHandler(() {
      _status = VoiceServiceStatus.idle;
      notifyListeners();
    });

    _flutterTts.setErrorHandler((msg) {
      _handleError('Error en la síntesis de voz: $msg');
    });
  }

  Future<void> startListening() async {
    if (!_isInitialized) {
      await initialize();
    }

    if (!_isInitialized) {
      _handleError('No se pudo inicializar el servicio de voz');
      return;
    }

    _transcription = '';
    
    try {
      await _speechToText.listen(
        onResult: _handleSpeechResult,
        localeId: AppConfig.defaultLanguage,
        cancelOnError: true,
        partialResults: true,
      );
      
      _status = VoiceServiceStatus.listening;
      notifyListeners();
    } catch (e) {
      _handleError('Error al iniciar la escucha: $e');
    }
  }

  Future<void> stopListening() async {
    try {
      await _speechToText.stop();
      _status = VoiceServiceStatus.idle;
      notifyListeners();
    } catch (e) {
      _handleError('Error al detener la escucha: $e');
    }
  }

  Future<void> speak(String text) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      if (isSpeaking) {
        await _flutterTts.stop();
      }

      _status = VoiceServiceStatus.speaking;
      notifyListeners();
      
      await _flutterTts.speak(text);
    } catch (e) {
      _handleError('Error al sintetizar voz: $e');
    }
  }

  Future<void> stop() async {
    try {
      if (isListening) {
        await _speechToText.stop();
      }
      if (isSpeaking) {
        await _flutterTts.stop();
      }
      
      _status = VoiceServiceStatus.idle;
      notifyListeners();
    } catch (e) {
      _handleError('Error al detener el servicio de voz: $e');
    }
  }

  void _handleSpeechResult(SpeechRecognitionResult result) {
    _transcription = result.recognizedWords;
    notifyListeners();
  }

  void _handleError(String error) {
    _lastError = error;
    _status = VoiceServiceStatus.error;
    notifyListeners();
  }

  @override
  void dispose() {
    _speechToText.stop();
    _flutterTts.stop();
    super.dispose();
  }
}