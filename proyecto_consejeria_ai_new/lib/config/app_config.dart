import 'package:flutter/foundation.dart';

class AppConfig {
  static const String appName = 'Avelia';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';
  static const String appPackageName = 'ai.avelia.app';

  // Configuración de Firebase
  static const firebaseConfig = {
    'apiKey': 'your-api-key',
    'authDomain': 'avelia-app.firebaseapp.com',
    'projectId': 'avelia-app',
    'storageBucket': 'avelia-app.appspot.com',
    'messagingSenderId': 'your-sender-id',
    'appId': 'your-app-id',
    'measurementId': 'your-measurement-id',
  };

  // Configuración de compras in-app
  static const iapConfig = {
    'android': {
      'licenseKey': 'your-android-license-key',
    },
    'ios': {
      'sharedSecret': 'your-ios-shared-secret',
    },
  };

  // IDs de productos para compras in-app
  static const subscriptionProducts = {
    'monthly': {
      'android': 'avelia_premium_monthly',
      'ios': 'ai.avelia.app.premium.monthly',
    },
    'yearly': {
      'android': 'avelia_premium_yearly',
      'ios': 'ai.avelia.app.premium.yearly',
    },
  };

  // Configuración de la prueba gratuita
  static const trialConfig = {
    'durationDays': 7,
    'requiresPaymentMethod': true,
    'features': [
      'Chat ilimitado con IA',
      'Ejercicios avanzados de mindfulness',
      'Monitoreo detallado de salud',
      'Sin anuncios',
    ],
  };

  // Configuración de precios
  static const priceConfig = {
    'monthly': {
      'amount': 9.99,
      'currency': 'USD',
    },
    'yearly': {
      'amount': 99.99,
      'currency': 'USD',
      'savings': 19.89,
      'monthlyEquivalent': 8.33,
    },
  };

  // Configuración de API
  static const apiConfig = {
    'baseUrl': kDebugMode
        ? 'https://api.staging.avelia.ai/v1'
        : 'https://api.avelia.ai/v1',
    'timeout': Duration(seconds: 30),
    'retryAttempts': 3,
  };

  // Configuración de análisis y monitoreo
  static const analyticsConfig = {
    'enabled': true,
    'sessionTimeout': Duration(minutes: 30),
    'userProperties': [
      'subscription_status',
      'subscription_type',
      'trial_status',
      'last_activity',
    ],
  };

  // Configuración de caché
  static const cacheConfig = {
    'enabled': true,
    'maxSize': 100 * 1024 * 1024, // 100 MB
    'maxAge': Duration(days: 7),
    'cleanupInterval': Duration(hours: 24),
  };

  // Configuración de notificaciones
  static const notificationConfig = {
    'enabled': true,
    'channelId': 'avelia_notifications',
    'channelName': 'Notificaciones de Avelia',
    'channelDescription': 'Recibe notificaciones importantes de Avelia',
    'defaultIcon': 'notification_icon',
    'soundEnabled': true,
    'vibrationEnabled': true,
  };

  // Configuración de ejercicios de mindfulness
  static const mindfulnessConfig = {
    'minDuration': Duration(minutes: 5),
    'maxDuration': Duration(minutes: 60),
    'defaultDuration': Duration(minutes: 10),
    'intervalOptions': [5, 10, 15, 20, 30, 45, 60],
    'backgroundSounds': [
      'rain',
      'ocean',
      'forest',
      'white_noise',
    ],
  };

  // Configuración de monitoreo de salud
  static const healthConfig = {
    'updateInterval': Duration(minutes: 5),
    'metrics': [
      'heart_rate',
      'stress_level',
      'sleep_quality',
      'activity_level',
    ],
    'thresholds': {
      'highStressLevel': 7,
      'highHeartRate': 100,
      'lowOxygenLevel': 95,
    },
  };

  // URLs importantes
  static const urls = {
    'privacyPolicy': 'https://avelia.ai/privacy',
    'termsOfService': 'https://avelia.ai/terms',
    'support': 'https://avelia.ai/support',
    'faq': 'https://avelia.ai/faq',
  };

  // Configuración de errores y logs
  static const errorConfig = {
    'reportErrors': true,
    'logLevel': kDebugMode ? 'debug' : 'error',
    'excludedErrors': [
      'network_error',
      'canceled_by_user',
    ],
  };

  // Configuración de seguridad
  static const securityConfig = {
    'requireBiometric': true,
    'sessionTimeout': Duration(minutes: 30),
    'maxLoginAttempts': 5,
    'lockoutDuration': Duration(minutes: 15),
  };

  // Configuración de recursos
  static const resourceConfig = {
    'preloadAssets': true,
    'cacheImages': true,
    'cacheAudio': true,
    'maxConcurrentDownloads': 3,
  };

  // Configuración de la interfaz de usuario
  static const uiConfig = {
    'animationsEnabled': true,
    'hapticFeedback': true,
    'defaultTransitionDuration': Duration(milliseconds: 300),
    'minimumInteractionTime': Duration(milliseconds: 500),
  };
}