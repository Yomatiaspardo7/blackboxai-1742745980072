import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../services/health_service.dart';
import '../services/mindfulness_service.dart';
import '../services/personality_service.dart';
import '../widgets/health_metrics_chart.dart';
import '../widgets/breathing_exercise.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 120,
              floating: true,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  'Avelia',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.headlineMedium?.color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                centerTitle: false,
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () {
                    // TODO: Implementar notificaciones
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.settings_outlined),
                  onPressed: () => context.push('/settings'),
                ),
                IconButton(
                  icon: const Icon(Icons.person_outline),
                  onPressed: () {
                    // TODO: Implementar perfil
                  },
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    _WelcomeCard(),
                    SizedBox(height: 16),
                    _HealthMetricsOverview(),
                    SizedBox(height: 16),
                    _QuickActions(),
                    SizedBox(height: 16),
                    _RecommendedExercises(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/mindfulness'),
        icon: const Icon(Icons.self_improvement),
        label: const Text('Mindfulness'),
      ),
    );
  }
}

// Resto del código del HomeScreen permanece igual...
// (Mantener todas las clases _WelcomeCard, _HealthMetricsOverview, _QuickActions, 
// _RecommendedExercises y sus componentes relacionados como estaban antes)