import 'package:flutter/foundation.dart';

enum SubscriptionTier {
  free,
  premium,
}

enum SubscriptionPeriod {
  monthly,
  yearly,
}

enum SubscriptionStatus {
  active,
  cancelled,
  expired,
}

class Subscription {
  final String id;
  final SubscriptionTier tier;
  final SubscriptionPeriod period;
  final SubscriptionStatus status;
  final DateTime startDate;
  final DateTime endDate;
  final double price;
  final bool autoRenew;
  final bool isTrialPeriod;

  const Subscription({
    required this.id,
    required this.tier,
    required this.period,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.price,
    required this.autoRenew,
    required this.isTrialPeriod,
  });

  factory Subscription.trial() {
    final now = DateTime.now();
    return Subscription(
      id: 'trial',
      tier: SubscriptionTier.premium,
      period: SubscriptionPeriod.monthly,
      status: SubscriptionStatus.active,
      startDate: now,
      endDate: now.add(const Duration(days: 7)),
      price: 0,
      autoRenew: false,
      isTrialPeriod: true,
    );
  }

  bool get isActive => status == SubscriptionStatus.active;
  bool get isCancelled => status == SubscriptionStatus.cancelled;
  bool get isExpired => status == SubscriptionStatus.expired;

  bool get isExpiringSoon {
    if (!isActive) return false;
    final daysUntilExpiry = endDate.difference(DateTime.now()).inDays;
    return daysUntilExpiry <= 3;
  }

  bool get hasTrialExpired {
    if (!isTrialPeriod) return false;
    return DateTime.now().isAfter(endDate);
  }

  Subscription copyWith({
    String? id,
    SubscriptionTier? tier,
    SubscriptionPeriod? period,
    SubscriptionStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    double? price,
    bool? autoRenew,
    bool? isTrialPeriod,
  }) {
    return Subscription(
      id: id ?? this.id,
      tier: tier ?? this.tier,
      period: period ?? this.period,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      price: price ?? this.price,
      autoRenew: autoRenew ?? this.autoRenew,
      isTrialPeriod: isTrialPeriod ?? this.isTrialPeriod,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tier': tier.toString(),
      'period': period.toString(),
      'status': status.toString(),
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'price': price,
      'autoRenew': autoRenew,
      'isTrialPeriod': isTrialPeriod,
    };
  }

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id'] as String,
      tier: SubscriptionTier.values.firstWhere(
        (e) => e.toString() == json['tier'],
      ),
      period: SubscriptionPeriod.values.firstWhere(
        (e) => e.toString() == json['period'],
      ),
      status: SubscriptionStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
      ),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      price: json['price'] as double,
      autoRenew: json['autoRenew'] as bool,
      isTrialPeriod: json['isTrialPeriod'] as bool,
    );
  }
}

class SubscriptionPlan {
  final String id;
  final String name;
  final SubscriptionPeriod period;
  final double price;
  final double? originalPrice;
  final List<String> features;

  const SubscriptionPlan({
    required this.id,
    required this.name,
    required this.period,
    required this.price,
    this.originalPrice,
    required this.features,
  });

  String get periodText => period == SubscriptionPeriod.monthly ? 'mes' : 'año';

  bool get hasDiscount => originalPrice != null && originalPrice! > price;

  int get discountPercentage {
    if (!hasDiscount) return 0;
    return ((originalPrice! - price) / originalPrice! * 100).round();
  }

  static List<SubscriptionPlan> get availablePlans => [
    SubscriptionPlan(
      id: 'premium_monthly_subscription',
      name: 'Mensual',
      period: SubscriptionPeriod.monthly,
      price: 9.99,
      features: [
        'Chat ilimitado con IA',
        'Ejercicios avanzados de mindfulness',
        'Monitoreo detallado de salud',
        'Sin anuncios',
      ],
    ),
    SubscriptionPlan(
      id: 'premium_yearly_subscription',
      name: 'Anual',
      period: SubscriptionPeriod.yearly,
      price: 99.99,
      originalPrice: 119.88, // 12 meses a 9.99
      features: [
        'Todo lo del plan mensual',
        'Ahorro de más de \$19',
        'Acceso anticipado a nuevas funciones',
        'Soporte prioritario',
      ],
    ),
  ];
}

class SubscriptionFeature {
  final String id;
  final String name;
  final String description;
  final SubscriptionTier requiredTier;
  final bool isEnabled;

  const SubscriptionFeature({
    required this.id,
    required this.name,
    required this.description,
    required this.requiredTier,
    this.isEnabled = true,
  });

  static List<SubscriptionFeature> get premiumFeatures => [
    const SubscriptionFeature(
      id: 'unlimited_chat',
      name: 'Chat Ilimitado con IA',
      description: 'Conversaciones ilimitadas con nuestra IA especializada',
      requiredTier: SubscriptionTier.premium,
    ),
    const SubscriptionFeature(
      id: 'advanced_mindfulness',
      name: 'Ejercicios Avanzados',
      description: 'Acceso a ejercicios y técnicas de mindfulness avanzadas',
      requiredTier: SubscriptionTier.premium,
    ),
    const SubscriptionFeature(
      id: 'detailed_health',
      name: 'Monitoreo Detallado',
      description: 'Análisis detallado de métricas de salud y bienestar',
      requiredTier: SubscriptionTier.premium,
    ),
    const SubscriptionFeature(
      id: 'personalized_insights',
      name: 'Insights Personalizados',
      description: 'Recomendaciones basadas en tu progreso y necesidades',
      requiredTier: SubscriptionTier.premium,
    ),
    const SubscriptionFeature(
      id: 'ad_free',
      name: 'Sin Anuncios',
      description: 'Experiencia completamente libre de publicidad',
      requiredTier: SubscriptionTier.premium,
    ),
    const SubscriptionFeature(
      id: 'priority_support',
      name: 'Soporte Prioritario',
      description: 'Acceso a soporte técnico prioritario',
      requiredTier: SubscriptionTier.premium,
    ),
  ];
}