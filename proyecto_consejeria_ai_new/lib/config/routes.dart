import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../services/payment_service.dart';
import '../screens/onboarding_screen.dart';
import '../screens/home_screen.dart';
import '../screens/text_chat_screen.dart';
import '../screens/voice_chat_screen.dart';
import '../screens/mindfulness_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/payment_screen.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/chat',
      builder: (context, state) {
        final paymentService = context.read<PaymentService>();
        if (!paymentService.isSubscribed) {
          return const PaymentScreen();
        }
        return const TextChatScreen();
      },
    ),
    GoRoute(
      path: '/voice',
      builder: (context, state) {
        final paymentService = context.read<PaymentService>();
        if (!paymentService.isSubscribed) {
          return const PaymentScreen();
        }
        return const VoiceChatScreen();
      },
    ),
    GoRoute(
      path: '/mindfulness',
      builder: (context, state) {
        final paymentService = context.read<PaymentService>();
        if (!paymentService.isSubscribed) {
          return const PaymentScreen();
        }
        return const MindfulnessScreen();
      },
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/payment',
      builder: (context, state) => const PaymentScreen(),
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            'Página no encontrada',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => context.go('/'),
            child: const Text('Volver al inicio'),
          ),
        ],
      ),
    ),
  ),
  redirect: (BuildContext context, GoRouterState state) {
    final paymentService = context.read<PaymentService>();
    final isOnboarding = state.location == '/';
    final isPaymentScreen = state.location == '/payment';
    final isSettingsScreen = state.location == '/settings';

    // Si está en onboarding y tiene suscripción activa, redirigir a home
    if (isOnboarding && paymentService.isSubscribed) {
      return '/home';
    }

    // Si no está en onboarding, payment o settings y no tiene suscripción activa,
    // mostrar pantalla de pago
    if (!isOnboarding && !isPaymentScreen && !isSettingsScreen && 
        !paymentService.isSubscribed) {
      return '/payment';
    }

    // No redirigir
    return null;
  },
);

// Middleware para verificar suscripción
Widget requireSubscription(BuildContext context, Widget child) {
  return Consumer<PaymentService>(
    builder: (context, paymentService, _) {
      if (!paymentService.isSubscribed) {
        return const PaymentScreen();
      }
      return child;
    },
  );
}