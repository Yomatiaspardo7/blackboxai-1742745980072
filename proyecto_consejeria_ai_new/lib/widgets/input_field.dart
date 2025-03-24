import 'package:flutter/material.dart';
import '../config/app_config.dart';

class InputField extends StatefulWidget {
  final Function(String) onSubmit;
  final List<String>? quickReplies;
  final bool enabled;
  final String? hintText;

  const InputField({
    super.key,
    required this.onSubmit,
    this.quickReplies,
    this.enabled = true,
    this.hintText,
  });

  @override
  State<InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<InputField> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _showQuickReplies = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    setState(() {
      _showQuickReplies = _controller.text.isEmpty && widget.quickReplies != null;
    });
  }

  void _handleSubmit() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      widget.onSubmit(text);
      _controller.clear();
      _focusNode.requestFocus();
    }
  }

  void _selectQuickReply(String reply) {
    _controller.text = reply;
    _handleSubmit();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_showQuickReplies && widget.quickReplies != null)
          _buildQuickReplies(),
        Container(
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
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            focusNode: _focusNode,
                            enabled: widget.enabled,
                            maxLines: 5,
                            minLines: 1,
                            textCapitalization: TextCapitalization.sentences,
                            decoration: InputDecoration(
                              hintText: widget.hintText ?? 'Escribe tu mensaje...',
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              counterText: '',
                            ),
                            maxLength: AppConfig.maxMessageLength,
                            onSubmitted: (_) => _handleSubmit(),
                          ),
                        ),
                        if (_controller.text.isNotEmpty)
                          IconButton(
                            onPressed: _controller.clear,
                            icon: const Icon(Icons.clear),
                            color: Colors.grey,
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _buildSendButton(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSendButton() {
    return Material(
      color: Theme.of(context).primaryColor,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: widget.enabled ? _handleSubmit : null,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Icon(
            Icons.send,
            color: widget.enabled ? Colors.white : Colors.white.withOpacity(0.5),
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildQuickReplies() {
    return Container(
      height: 48,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: widget.quickReplies!.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final reply = widget.quickReplies![index];
          return Material(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              onTap: () => _selectQuickReply(reply),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Center(
                  child: Text(
                    reply,
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}