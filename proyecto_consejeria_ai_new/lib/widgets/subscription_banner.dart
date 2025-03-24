import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/payment_service.dart';
import '../models/subscription.dart';
import '../screens/payment_screen.dart';

class SubscriptionBanner extends StatelessWidget {
  const SubscriptionBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final paymentService = context.watch<PaymentService>();
    final subscription = paymentService.currentSubscription;

    if (subscription == null || !_shouldShowBanner(subscription)) {
      return const SizedBox.shrink();
    }

    return _buildBanner(context, subscription);
  }

  bool _shouldShowBanner(Subscription subscription) {
    if (subscription.isTrialPeriod && !subscription.hasTrialExpired) {
      // Mostrar si quedan 2 días o menos de prueba
      final daysLeft = subscription.endDate.difference(DateTime.now()).inDays;
      return daysLeft <= 2;
    }

    // Mostrar si la suscripción está por expirar o ha expirado
    return subscription.isExpiringSoon || !subscription.isActive;
  }

  Widget _buildBanner(BuildContext context, Subscription subscription) {
    final theme = Theme.of(context);
    final isExpired = !subscription.isActive;
    final isTrialEnding = subscription.isTrialPeriod && !subscription.hasTrialExpired;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isExpired
              ? [theme.colorScheme.error, theme.colorScheme.errorContainer]
              : [theme.colorScheme.primary, theme.colorScheme.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  isExpired ? Icons.warning : Icons.access_time,
                  color: theme.colorScheme.onPrimary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getBannerTitle(subscription),
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (!isExpired) ...[
                        const SizedBox(height: 4),
                        Text(
                          _getBannerSubtitle(subscription),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onPrimary.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => _onBannerAction(context),
                  style: TextButton.styleFrom(
                    backgroundColor: theme.colorScheme.onPrimary,
                    foregroundColor: isExpired
                        ? theme.colorScheme.error
                        : theme.colorScheme.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  child: Text(
                    isExpired ? 'Renovar ahora' : 'Ver planes',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            if (isTrialEnding) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: _getTrialProgress(subscription),
                  backgroundColor: theme.colorScheme.onPrimary.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.onPrimary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getBannerTitle(Subscription subscription) {
    if (!subscription.isActive) {
      return 'Tu suscripción ha expirado';
    }

    if (subscription.isTrialPeriod) {
      final daysLeft = subscription.endDate.difference(DateTime.now()).inDays;
      return 'Tu prueba termina en $daysLeft ${daysLeft == 1 ? 'día' : 'días'}';
    }

    return 'Tu suscripción está por vencer';
  }

  String _getBannerSubtitle(Subscription subscription) {
    if (subscription.isTrialPeriod) {
      return 'Suscríbete ahora para mantener el acceso premium';
    }

    final daysLeft = subscription.endDate.difference(DateTime.now()).inDays;
    return 'Se renovará automáticamente en $daysLeft ${daysLeft == 1 ? 'día' : 'días'}';
  }

  double _getTrialProgress(Subscription subscription) {
    if (!subscription.isTrialPeriod) return 0;

    final totalDuration = subscription.endDate.difference(subscription.startDate);
    final elapsed = DateTime.now().difference(subscription.startDate);
    return elapsed.inSeconds / totalDuration.inSeconds;
  }

  void _onBannerAction(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => const PaymentScreen(),
      ),
    );
  }
}

class SubscriptionRequiredBanner extends StatelessWidget {
  final String feature;
  final VoidCallback? onSubscribe;

  const SubscriptionRequiredBanner({
    super.key,
    required this.feature,
    this.onSubscribe,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.lock,
            size: 48,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'Función Premium',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Suscríbete para acceder a $feature y todas las funciones premium',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              if (onSubscribe != null) {
                onSubscribe!();
              } else {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) => const PaymentScreen(),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 12,
              ),
            ),
            child: const Text(
              'Ver planes premium',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}