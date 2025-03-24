import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/payment_service.dart';
import '../config/theme_config.dart';
import 'package:provider/provider.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    const OnboardingPage(
      title: 'Bienvenido a Avelia',
      description: 'Tu compañero de bienestar emocional con IA personalizada',
      icon: Icons.psychology,
    ),
    const OnboardingPage(
      title: 'Mindfulness Personalizado',
      description: 'Ejercicios y técnicas adaptadas a tus necesidades específicas',
      icon: Icons.self_improvement,
    ),
    const OnboardingPage(
      title: 'Monitoreo de Salud',
      description: 'Seguimiento de tu bienestar emocional y físico en tiempo real',
      icon: Icons.favorite,
    ),
    const OnboardingPage(
      title: 'Chat con IA',
      description: 'Apoyo emocional disponible 24/7 con nuestra IA especializada',
      icon: Icons.chat_bubble,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _showSubscriptionDialog();
    }
  }

  void _showSubscriptionDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const SubscriptionBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                itemBuilder: (context, index) => _pages[index],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 8,
                        width: _currentPage == index ? 24 : 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? theme.colorScheme.primary
                              : theme.colorScheme.primary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _nextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 48,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      _currentPage < _pages.length - 1 ? 'Siguiente' : 'Comenzar',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingPage extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;

  const OnboardingPage({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 120,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 48),
          Text(
            title,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onBackground,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onBackground.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class SubscriptionBottomSheet extends StatelessWidget {
  const SubscriptionBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final paymentService = context.watch<PaymentService>();

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurface.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Prueba Gratuita de 7 Días',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Disfruta de acceso completo a todas las funciones premium',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.8),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              _SubscriptionOption(
                title: 'Mensual',
                price: '9.99',
                isRecommended: false,
                onTap: () => _startSubscription(context, SubscriptionPeriod.monthly),
              ),
              const SizedBox(height: 16),
              _SubscriptionOption(
                title: 'Anual',
                price: '99.99',
                savings: 'Ahorra más de \$19',
                isRecommended: true,
                onTap: () => _startSubscription(context, SubscriptionPeriod.yearly),
              ),
              const SizedBox(height: 24),
              Text(
                'Se requiere método de pago para comenzar la prueba gratuita. Se realizará el cargo automáticamente al finalizar el período de prueba.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  // TODO: Mostrar términos y condiciones
                },
                child: const Text('Ver términos y condiciones'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startSubscription(BuildContext context, SubscriptionPeriod period) async {
    final paymentService = context.read<PaymentService>();
    final plan = SubscriptionPlan.availablePlans.firstWhere(
      (p) => p.period == period,
    );
    
    try {
      await paymentService.startTrial();
      if (context.mounted) {
        context.go('/home');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al iniciar la suscripción: $e'),
          ),
        );
      }
    }
  }
}

class _SubscriptionOption extends StatelessWidget {
  final String title;
  final String price;
  final String? savings;
  final bool isRecommended;
  final VoidCallback onTap;

  const _SubscriptionOption({
    required this.title,
    required this.price,
    this.savings,
    this.isRecommended = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isRecommended
              ? theme.colorScheme.primary.withOpacity(0.1)
              : theme.colorScheme.surface,
          border: Border.all(
            color: isRecommended
                ? theme.colorScheme.primary
                : theme.colorScheme.outline,
            width: isRecommended ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            if (isRecommended)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Recomendado',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (savings != null)
                      Text(
                        savings!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
                Text(
                  '\$$price',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}