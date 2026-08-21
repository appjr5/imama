import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../services/gemma_service.dart';
import '../theme/app_theme.dart';
import '../theme/strings_sw.dart';
import '../widgets/bold_text.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    // Start loading the model as soon as the chat screen opens.
    GemmaService.ensureModelReady().catchError((_) {});
    GemmaService.state.addListener(_onStateChange);
    GemmaService.installProgress.addListener(_onStateChange);
  }

  @override
  void dispose() {
    GemmaService.state.removeListener(_onStateChange);
    GemmaService.installProgress.removeListener(_onStateChange);
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onStateChange() {
    if (mounted) setState(() {});
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || !GemmaService.isReady || _isSending) return;

    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _isSending = true;
      _controller.clear();
    });
    _scrollToBottom();

    try {
      final reply = await GemmaService.sendChatMessage(message: text);
      if (mounted) setState(() => _messages.add(ChatMessage(text: reply, isUser: false)));
    } catch (e) {
      if (mounted) {
        setState(() => _messages.add(ChatMessage(
            text: 'Samahani, imeshindikana kupata jibu. Jaribu tena.', isUser: false)));
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark ? AppTheme.accentPink : AppTheme.primaryPurple;
    final modelState = GemmaService.state.value;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset('assets/images/chatbot_avatar.jpg',
                  width: 32, height: 32, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(Icons.smart_toy_outlined, size: 28)),
            ),
            const SizedBox(width: 10),
            const Text(StringsSw.chatTitle),
          ],
        ),
        actions: [
          _StatusDot(state: modelState),
          const SizedBox(width: 12),
        ],
      ),
      body: Column(
        children: [
          // Model loading banner
          if (modelState == GemmaState.installing) _LoadingBanner(accentColor: accentColor),
          if (modelState == GemmaState.error) _ErrorBanner(
            error: GemmaService.lastError ?? '',
            onRetry: () {
              GemmaService.state.value = GemmaState.idle;
              GemmaService.ensureModelReady().catchError((_) {});
            },
          ),

          // Messages
          Expanded(
            child: _messages.isEmpty
                ? _EmptyState(modelState: modelState, accentColor: accentColor, isDark: isDark)
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(12),
                    itemCount: _messages.length,
                    itemBuilder: (context, i) => _MessageBubble(
                      message: _messages[i],
                      accentColor: accentColor,
                      isDark: isDark,
                    ),
                  ),
          ),

          if (_isSending) LinearProgressIndicator(color: accentColor, minHeight: 2),

          // Input bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      enabled: modelState == GemmaState.ready,
                      decoration: InputDecoration(
                        hintText: modelState == GemmaState.installing
                            ? 'Inaandaa mfano wa AI...'
                            : modelState == GemmaState.error
                                ? 'Hitilafu — bonyeza kurudia'
                                : StringsSw.chatInputHint,
                      ),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    style: IconButton.styleFrom(backgroundColor: accentColor),
                    icon: _isSending
                        ? const SizedBox(
                            width: 18, height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.send, color: Colors.white),
                    onPressed: (modelState == GemmaState.ready && !_isSending) ? _send : null,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingBanner extends StatelessWidget {
  final Color accentColor;
  const _LoadingBanner({required this.accentColor});

  @override
  Widget build(BuildContext context) {
    final progress = GemmaService.installProgress.value;
    return Container(
      width: double.infinity,
      color: accentColor.withValues(alpha: 0.1),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 14, height: 14,
                child: CircularProgressIndicator(strokeWidth: 2, color: accentColor),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  progress == 0
                      ? 'Inaandaa mfano wa AI (mara ya kwanza inachukua dakika 2–4)…'
                      : 'Inasakinisha mfano wa AI… $progress%',
                  style: TextStyle(fontSize: 13, color: accentColor, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress == 0 ? null : progress / 100,
              color: accentColor,
              backgroundColor: accentColor.withValues(alpha: 0.2),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  const _ErrorBanner({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.red.shade50,
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 18),
              const SizedBox(width: 8),
              const Expanded(
                child: Text('Mfano haukuweza kupakia.',
                    style: TextStyle(color: Colors.red, fontSize: 13, fontWeight: FontWeight.w600)),
              ),
              TextButton(onPressed: onRetry, child: const Text('Jaribu Tena')),
            ],
          ),
          if (error.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: SelectableText(
                error,
                style: const TextStyle(color: Colors.red, fontSize: 11, fontFamily: 'monospace'),
              ),
            ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final GemmaState modelState;
  final Color accentColor;
  final bool isDark;
  const _EmptyState({required this.modelState, required this.accentColor, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? Colors.white54 : Colors.black45;
    if (modelState == GemmaState.installing) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.smart_toy_outlined, size: 56, color: accentColor.withValues(alpha: 0.4)),
              const SizedBox(height: 16),
              Text('Msaidizi anajiandaa…', style: TextStyle(color: accentColor, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Text('Mara ya kwanza inachukua dakika 2–4.\nSubiri kidogo — itakuwa haraka zaidi mara zijazo.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: textColor, fontSize: 13, height: 1.5)),
            ],
          ),
        ),
      );
    }
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(StringsSw.chatEmptyState,
            textAlign: TextAlign.center, style: TextStyle(color: textColor)),
      ),
    );
  }
}

class _StatusDot extends StatelessWidget {
  final GemmaState state;
  const _StatusDot({required this.state});

  @override
  Widget build(BuildContext context) {
    final color = switch (state) {
      GemmaState.ready     => Colors.green,
      GemmaState.installing => Colors.orange,
      GemmaState.error     => Colors.red,
      GemmaState.idle      => Colors.grey,
    };
    final label = switch (state) {
      GemmaState.ready     => 'Tayari',
      GemmaState.installing => 'Inapakia',
      GemmaState.error     => 'Hitilafu',
      GemmaState.idle      => '',
    };
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        if (label.isNotEmpty) ...[
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: color, fontSize: 11)),
        ],
      ],
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final Color accentColor;
  final bool isDark;
  const _MessageBubble({required this.message, required this.accentColor, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final bubbleColor = isUser
        ? accentColor
        : (isDark ? Colors.white12 : AppTheme.lightPurple.withValues(alpha: 0.4));
    final textColor = isUser ? Colors.white : (isDark ? Colors.white : Colors.black87);

    final bubble = Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.68),
      decoration: BoxDecoration(color: bubbleColor, borderRadius: BorderRadius.circular(14)),
      child: BoldText(message.text, style: TextStyle(color: textColor)),
    );

    if (!isUser) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset('assets/images/chatbot_avatar.jpg', width: 32, height: 32,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(Icons.smart_toy_outlined, size: 28)),
            ),
            const SizedBox(width: 6),
            Flexible(child: bubble),
          ],
        ),
      );
    }
    return Align(alignment: Alignment.centerRight, child: bubble);
  }
}
