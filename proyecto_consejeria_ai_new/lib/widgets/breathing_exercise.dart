import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

enum BreathingPhase {
  inhale,
  hold,
  exhale,
  rest,
}

class BreathingExercise extends StatefulWidget {
  final int inhaleSeconds;
  final int holdSeconds;
  final int exhaleSeconds;
  final int restSeconds;
  final int cycles;
  final VoidCallback? onComplete;

  const BreathingExercise({
    super.key,
    this.inhaleSeconds = 4,
    this.holdSeconds = 7,
    this.exhaleSeconds = 8,
    this.restSeconds = 2,
    this.cycles = 4,
    this.onComplete,
  });

  @override
  State<BreathingExercise> createState() => _BreathingExerciseState();
}

class _BreathingExerciseState extends State<BreathingExercise> {
  late Timer _timer;
  BreathingPhase _currentPhase = BreathingPhase.inhale;
  int _currentCycle = 1;
  int _secondsRemaining = 0;
  bool _isActive = false;
  double _animationValue = 0.0;

  @override
  void initState() {
    super.initState();
    _secondsRemaining = widget.inhaleSeconds;
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void startExercise() {
    setState(() {
      _isActive = true;
      _currentPhase = BreathingPhase.inhale;
      _currentCycle = 1;
      _secondsRemaining = widget.inhaleSeconds;
    });

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      _onTick,
    );
  }

  void pauseExercise() {
    setState(() {
      _isActive = false;
    });
    _timer.cancel();
  }

  void resumeExercise() {
    setState(() {
      _isActive = true;
    });
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      _onTick,
    );
  }

  void _onTick(Timer timer) {
    if (_secondsRemaining > 0) {
      setState(() {
        _secondsRemaining--;
        _updateAnimationValue();
      });
    } else {
      _moveToNextPhase();
    }
  }

  void _moveToNextPhase() {
    switch (_currentPhase) {
      case BreathingPhase.inhale:
        setState(() {
          _currentPhase = BreathingPhase.hold;
          _secondsRemaining = widget.holdSeconds;
        });
        break;
      case BreathingPhase.hold:
        setState(() {
          _currentPhase = BreathingPhase.exhale;
          _secondsRemaining = widget.exhaleSeconds;
        });
        break;
      case BreathingPhase.exhale:
        if (_currentCycle < widget.cycles) {
          setState(() {
            _currentPhase = BreathingPhase.rest;
            _secondsRemaining = widget.restSeconds;
          });
        } else {
          _completeExercise();
        }
        break;
      case BreathingPhase.rest:
        setState(() {
          _currentPhase = BreathingPhase.inhale;
          _secondsRemaining = widget.inhaleSeconds;
          _currentCycle++;
        });
        break;
    }
    _updateAnimationValue();
  }

  void _completeExercise() {
    _timer.cancel();
    setState(() {
      _isActive = false;
    });
    widget.onComplete?.call();
  }

  void _updateAnimationValue() {
    switch (_currentPhase) {
      case BreathingPhase.inhale:
        _animationValue = 1 - (_secondsRemaining / widget.inhaleSeconds);
        break;
      case BreathingPhase.hold:
        _animationValue = 1.0;
        break;
      case BreathingPhase.exhale:
        _animationValue = _secondsRemaining / widget.exhaleSeconds;
        break;
      case BreathingPhase.rest:
        _animationValue = 0.0;
        break;
    }
  }

  String get _phaseText {
    switch (_currentPhase) {
      case BreathingPhase.inhale:
        return 'Inhala';
      case BreathingPhase.hold:
        return 'Mantén';
      case BreathingPhase.exhale:
        return 'Exhala';
      case BreathingPhase.rest:
        return 'Descansa';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Ciclo $_currentCycle de ${widget.cycles}',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 32),
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 200,
              height: 200,
              child: CircularProgressIndicator(
                value: _animationValue,
                strokeWidth: 12,
                backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(
                  theme.colorScheme.primary,
                ),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _phaseText,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$_secondsRemaining',
                  style: theme.textTheme.displayMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ).animate(
              effects: [
                FadeEffect(
                  duration: 300.ms,
                  curve: Curves.easeInOut,
                ),
                ScaleEffect(
                  begin: const Offset(0.8, 0.8),
                  end: const Offset(1.0, 1.0),
                  duration: 300.ms,
                  curve: Curves.easeInOut,
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!_isActive && _currentCycle == 1)
              ElevatedButton(
                onPressed: startExercise,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
                child: const Text('Comenzar'),
              )
            else if (_isActive)
              ElevatedButton(
                onPressed: pauseExercise,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
                child: const Text('Pausar'),
              )
            else
              ElevatedButton(
                onPressed: resumeExercise,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
                child: const Text('Continuar'),
              ),
          ],
        ),
      ],
    );
  }
}

class BreathingGuide extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback onStart;

  const BreathingGuide({
    super.key,
    required this.title,
    required this.description,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _GuideStep(
                  number: '1',
                  text: 'Inhala\n4 seg',
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                _GuideStep(
                  number: '2',
                  text: 'Mantén\n7 seg',
                  color: theme.colorScheme.secondary,
                ),
                const SizedBox(width: 8),
                _GuideStep(
                  number: '3',
                  text: 'Exhala\n8 seg',
                  color: theme.colorScheme.tertiary,
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onStart,
                child: const Text('Comenzar Ejercicio'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GuideStep extends StatelessWidget {
  final String number;
  final String text;
  final Color color;

  const _GuideStep({
    required this.number,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  number,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              text,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}