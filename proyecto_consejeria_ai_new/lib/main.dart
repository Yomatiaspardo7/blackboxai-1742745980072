import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'config/app_config.dart';
import 'config/theme_config.dart';
import 'config/routes.dart';
import 'services/payment_service.dart';
import 'services/chat_service.dart';
import 'services/voice_service.dart';
import 'services/health_service.dart';
import 'services/mindfulness_service.dart';
import 'services/notification_service.dart';
import 'services/personality_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Firebase
  await Firebase.initializeApp(
    options: FirebaseOptions.fromMap(AppConfig.firebaseConfig),
  );

  // Configurar Crashlytics
  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

  // Inicializar SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  runApp(
    MultiProvider(
      providers: [
        Provider<SharedPreferences>.value(value: prefs),
        Provider<FirebaseAnalytics>(
          create: (_) => FirebaseAnalytics.instance,
        ),
        ChangeNotifierProvider(
          create: (context) => PaymentService(prefs),
        ),
        ChangeNotifierProxyProvider<PaymentService, ChatService>(
          create: (context) => ChatService(),
          update: (context, paymentService, previous) =>
              previous!..updateSubscriptionStatus(paymentService.isSubscribed),
        ),
        ChangeNotifierProxyProvider<PaymentService, VoiceService>(
          create: (context) => VoiceService(),
          update: (context, paymentService, previous) =>
              previous!..updateSubscriptionStatus(paymentService.isSubscribed),
        ),
        ChangeNotifierProxyProvider<PaymentService, HealthService>(
          create: (context) => HealthService(),
          update: (context, paymentService, previous) =>
              previous!..updateSubscriptionStatus(paymentService.isSubscribed),
        ),
        ChangeNotifierProxyProvider<PaymentService, MindfulnessService>(
          create: (context) => MindfulnessService(),
          update: (context, paymentService, previous) =>
              previous!..updateSubscriptionStatus(paymentService.isSubscribed),
        ),
        ChangeNotifierProvider(
          create: (context) => NotificationService(),
        ),
        ChangeNotifierProvider(
          create: (context) => PersonalityService(),
        ),
      ],
      child: const AveliaApp(),
    ),
  );
}

class AveliaApp extends StatelessWidget {
  const AveliaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConfig.appName,
      theme: ThemeConfig.lightTheme,
      darkTheme: ThemeConfig.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        // Aplicar configuraciones globales de UI
        return MediaQuery(
          // Forzar el modo de color del sistema
          data: MediaQuery.of(context).copyWith(
            platformBrightness: Theme.of(context).brightness,
          ),
          child: child!,
        );
      },
      localizationsDelegates: const [
        // TODO: Agregar delegados de localización
      ],
      supportedLocales: const [
        Locale('es', 'ES'),
        Locale('en', 'US'),
      ],
    );
  }
}

// Extensión para facilitar el acceso a los servicios
extension BuildContextExtensions on BuildContext {
  PaymentService get paymentService => read<PaymentService>();
  ChatService get chatService => read<ChatService>();
  VoiceService get voiceService => read<VoiceService>();
  HealthService get healthService => read<HealthService>();
  MindfulnessService get mindfulnessService => read<MindfulnessService>();
  NotificationService get notificationService => read<NotificationService>();
  PersonalityService get personalityService => read<PersonalityService>();
  FirebaseAnalytics get analytics => read<FirebaseAnalytics>();
  SharedPreferences get prefs => read<SharedPreferences>();

  // Métodos de utilidad
  void showLoadingDialog() {
    showDialog(
      context: this,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  void showErrorSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(this).colorScheme.error,
      ),
    );
  }

  void showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(this).colorScheme.primary,
      ),
    );
  }

  Future<bool> showConfirmationDialog({
    required String title,
    required String message,
    String? confirmText,
    String? cancelText,
  }) async {
    final result = await showDialog<bool>(
      context: this,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText ?? 'Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmText ?? 'Confirmar'),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}