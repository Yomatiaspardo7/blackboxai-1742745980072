import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/user_profile.dart';

class HealthService extends ChangeNotifier {
  final HealthFactory _health = HealthFactory();
  Timer? _monitoringTimer;
  bool _isMonitoring = false;
  HealthMetrics _lastMetrics = HealthMetrics();
  
  // Stream para emitir actualizaciones de métricas en tiempo real
  final _metricsController = StreamController<HealthMetrics>.broadcast();
  Stream<HealthMetrics> get metricsStream => _metricsController.stream;

  // Getters
  HealthMetrics get lastMetrics => _lastMetrics;
  bool get isMonitoring => _isMonitoring;

  // Tipos de datos que vamos a solicitar
  static const List<HealthDataType> _dataTypes = [
    HealthDataType.HEART_RATE,
    HealthDataType.BLOOD_OXYGEN,
    HealthDataType.STEPS,
    HealthDataType.SLEEP_ASLEEP,
    HealthDataType.SLEEP_AWAKE,
  ];

  Future<bool> requestPermissions() async {
    // Solicitar permisos para sensores y salud
    final permissions = await [
      Permission.sensors,
      Permission.activityRecognition,
      Permission.location,
    ].request();

    // Verificar si todos los permisos fueron concedidos
    bool allGranted = permissions.values.every((status) => status.isGranted);

    if (!allGranted) return false;

    // Solicitar permisos específicos de HealthKit/Google Fit
    try {
      return await _health.requestAuthorization(_dataTypes);
    } catch (e) {
      debugPrint('Error solicitando permisos de salud: $e');
      return false;
    }
  }

  Future<void> startMonitoring() async {
    if (_isMonitoring) return;

    final permissionsGranted = await requestPermissions();
    if (!permissionsGranted) {
      throw Exception('Se requieren permisos para monitorear la salud');
    }

    _isMonitoring = true;
    notifyListeners();

    // Iniciar monitoreo periódico
    _monitoringTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => _updateHealthMetrics(),
    );

    // Obtener métricas iniciales
    await _updateHealthMetrics();
  }

  Future<void> stopMonitoring() async {
    _monitoringTimer?.cancel();
    _isMonitoring = false;
    notifyListeners();
  }

  Future<void> _updateHealthMetrics() async {
    try {
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 1));

      // Obtener datos de ritmo cardíaco
      final heartRateData = await _health.getHealthDataFromType(
        yesterday,
        now,
        HealthDataType.HEART_RATE,
      );

      // Obtener datos de oxigenación
      final oxygenData = await _health.getHealthDataFromType(
        yesterday,
        now,
        HealthDataType.BLOOD_OXYGEN,
      );

      // Calcular métricas
      final heartRate = _calculateAverageHeartRate(heartRateData);
      final oxygenLevel = _calculateAverageOxygenLevel(oxygenData);
      final stressLevel = _estimateStressLevel(heartRate, oxygenLevel);

      // Crear nueva lectura
      final reading = HealthReading(
        timestamp: now,
        heartRate: heartRate.round(),
        oxygenLevel: oxygenLevel,
        stressLevel: stressLevel,
      );

      // Actualizar métricas
      _lastMetrics = HealthMetrics(
        heartRate: heartRate.round(),
        oxygenLevel: oxygenLevel,
        stressLevel: stressLevel,
        lastUpdated: now,
        readings: [..._lastMetrics.readings, reading],
      );

      // Emitir actualización
      _metricsController.add(_lastMetrics);
      notifyListeners();
    } catch (e) {
      debugPrint('Error actualizando métricas de salud: $e');
    }
  }

  double _calculateAverageHeartRate(List<HealthDataPoint> data) {
    if (data.isEmpty) return 0;
    final values = data.map((e) => e.value.toDouble()).toList();
    return values.reduce((a, b) => a + b) / values.length;
  }

  double _calculateAverageOxygenLevel(List<HealthDataPoint> data) {
    if (data.isEmpty) return 0;
    final values = data.map((e) => e.value.toDouble()).toList();
    return values.reduce((a, b) => a + b) / values.length;
  }

  int _estimateStressLevel(double heartRate, double oxygenLevel) {
    // Algoritmo simple para estimar nivel de estrés
    // Basado en variaciones de ritmo cardíaco y niveles de oxígeno
    int stressScore = 0;

    // Evaluar ritmo cardíaco
    if (heartRate > 100) stressScore += 3;
    else if (heartRate > 85) stressScore += 2;
    else if (heartRate > 70) stressScore += 1;

    // Evaluar oxigenación
    if (oxygenLevel < 95) stressScore += 2;
    else if (oxygenLevel < 97) stressScore += 1;

    return stressScore.clamp(0, 10); // Normalizar entre 0 y 10
  }

  Future<Map<String, dynamic>> getHealthSummary() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);

    try {
      final steps = await _health.getTotalStepsInInterval(startOfDay, now) ?? 0;
      
      return {
        'heartRate': _lastMetrics.heartRate,
        'oxygenLevel': _lastMetrics.oxygenLevel,
        'stressLevel': _lastMetrics.stressLevel,
        'steps': steps,
        'lastUpdated': _lastMetrics.lastUpdated,
      };
    } catch (e) {
      debugPrint('Error obteniendo resumen de salud: $e');
      return {};
    }
  }

  void dispose() {
    _monitoringTimer?.cancel();
    _metricsController.close();
    super.dispose();
  }
}