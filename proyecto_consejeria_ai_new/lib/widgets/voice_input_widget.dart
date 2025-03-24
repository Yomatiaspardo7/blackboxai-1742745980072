import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/voice_service.dart';

class VoiceInputWidget extends StatefulWidget {
  final Function(String) onVoiceResult;
  final bool enabled;

  const VoiceInputWidget({
    super.key,
    required this.onVoiceResult,
    this.enabled = true,
  });

  @override
  State<VoiceInputWidget> createState() => _VoiceInputWidgetState();
}

class _VoiceInputWidgetState extends State<VoiceInputWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  void _onPressStart() {
    if (!widget.enabled) return;
    
    setState(() => _isPressed = true);
    _animationController.forward();
    
    final voiceService = context.read<VoiceService>();
    voiceService.startListening();
  }

  void _onPressEnd() {
    if (!widget.enabled || !_isPressed) return;
    
    setState(() => _isPressed = false);
    _animationController.reverse();
    
    final voiceService = context.read<VoiceService>();
    voiceService.stopListening();
    
    if (voiceService.transcription.isNotEmpty) {
      widget.onVoiceResult(voiceService.transcription);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<VoiceService>(
      builder: (context, voiceService, child) {
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (voiceService.transcription.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      voiceService.transcription,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.color
                                ?.withOpacity(0.7),
                          ),
                    ),
                  ),
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: GestureDetector(
                    onTapDown: (_) => _onPressStart(),
                    onTapUp: (_) => _onPressEnd(),
                    onTapCancel: _onPressEnd,
                    child: Container(
                      height: 64,
                      decoration: BoxDecoration(
                        color: _isPressed
                            ? Colors.red
                            : Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(32),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_isPressed) ...[
                            _buildWaveform(),
                            const SizedBox(width: 12),
                            const Text(
                              'Suelta para enviar',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ] else ...[
                            const Icon(
                              Icons.mic,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Mantén presionado para hablar',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                if (voiceService.lastError.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      voiceService.lastError,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWaveform() {
    return SizedBox(
      width: 60,
      height: 32,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(
          4,
          (index) => _buildWaveBar(index),
        ),
      ),
    );
  }

  Widget _buildWaveBar(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.3, end: 1.0),
      duration: Duration(milliseconds: 300 + (index * 100)),
      builder: (context, value, child) {
        return Container(
          width: 3,
          height: 32 * value,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(2),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}