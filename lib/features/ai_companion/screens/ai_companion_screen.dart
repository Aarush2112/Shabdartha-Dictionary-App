import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../models/chat_message.dart';
import '../../../services/ai_service.dart';
import '../../../services/storage_service.dart';
import '../widgets/ai_settings_dialog.dart';

class AiCompanionScreen extends StatefulWidget {
  final StorageService storageService;
  final String? initialPrompt;

  const AiCompanionScreen({
    super.key,
    required this.storageService,
    this.initialPrompt,
  });

  @override
  State<AiCompanionScreen> createState() => AiCompanionScreenState();
}

class AiCompanionScreenState extends State<AiCompanionScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  late AiService _aiService;
  List<ChatMessage> _messages = [];
  bool _isGenerating = false;

  final List<String> _starterPrompts = [
    'What is the difference between melancholy, sadness, and grief?',
    'How did the Odia deity Jagannātha become the English word "juggernaut"?',
    'What is the difference between solitude and loneliness?',
    'Can you help me polish this sentence to sound more literary?',
    'Explain the Sanskrit root of the word "avatar".',
    'Give me a mnemonic to remember "ineffable".',
  ];

  @override
  void initState() {
    super.initState();
    _initAiService();
    _loadMessages();

    if (widget.initialPrompt != null && widget.initialPrompt!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleSendMessage(widget.initialPrompt!);
      });
    }
  }

  void _initAiService() {
    final apiKey = widget.storageService.getAiApiKey();
    final model = widget.storageService.getAiModel();

    if (apiKey != null && apiKey.trim().isNotEmpty) {
      _aiService = GoogleGeminiAiService(
        apiKey: apiKey.trim(),
        model: model,
      );
    } else {
      _aiService = GarudaDemoAiService();
    }
  }

  void _loadMessages() {
    final history = widget.storageService.getChatHistory();
    setState(() {
      _messages = history;
    });
  }

  Future<void> sendPromptExternally(String prompt) async {
    await _handleSendMessage(prompt);
  }

  Future<void> _handleSendMessage(String text) async {
    final prompt = text.trim();
    if (prompt.isEmpty || _isGenerating) return;

    _textController.clear();

    final userMsg = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: prompt,
      isUser: true,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMsg);
      _isGenerating = true;
    });
    _scrollToBottom();

    await widget.storageService.saveChatHistory(_messages);

    try {
      final responseMsg = await _aiService.sendMessage(
        prompt: prompt,
        conversationHistory: _messages,
      );

      if (mounted) {
        setState(() {
          _messages.add(responseMsg);
          _isGenerating = false;
        });
        _scrollToBottom();
        await widget.storageService.saveChatHistory(_messages);
      }
    } catch (e) {
      if (mounted) {
        final errorMsg = ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: 'Encountered an issue consulting Ask Garuda: ${e.toString().replaceAll("Exception: ", "")}\n\n*Tap retry below or verify API settings.*',
          isUser: false,
          timestamp: DateTime.now(),
          isError: true,
        );
        setState(() {
          _messages.add(errorMsg);
          _isGenerating = false;
        });
        _scrollToBottom();
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _clearChat() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.parchment,
        title: Text('Clear Conversation?', style: AppTypography.serifHeading(fontSize: 18)),
        content: Text(
          'This will clear your conversation history with Ask Garuda.',
          style: AppTypography.sansBody(fontSize: 14, color: AppColors.warmGray),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Cancel', style: AppTypography.sansLabel(color: AppColors.warmGray)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.terracotta,
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await widget.storageService.clearChatHistory();
      setState(() {
        _messages = [];
      });
    }
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Response copied to clipboard.'),
        backgroundColor: AppColors.deepInk,
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _showSettings() {
    showDialog(
      context: context,
      builder: (_) => AiSettingsDialog(
        storageService: widget.storageService,
        onSaved: () {
          setState(() {
            _initAiService();
          });
        },
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDemo = _aiService.isDemoMode;

    return Scaffold(
      backgroundColor: AppColors.parchment,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Ask Garuda',
                  style: AppTypography.serifHeading(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: _showSettings,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: isDemo ? AppColors.surfaceSand : AppColors.sageGreenSurface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isDemo ? AppColors.border : AppColors.sageGreenBorder,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isDemo ? Icons.info_outline_rounded : Icons.check_circle_outline_rounded,
                          size: 11,
                          color: isDemo ? AppColors.warmGray : AppColors.sageGreen,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isDemo ? 'Demo Mode' : 'Live Gemini',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: isDemo ? AppColors.warmGray : AppColors.sageGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Text(
              'Words are only the beginning.',
              style: AppTypography.sansLabel(
                fontSize: 11,
                color: AppColors.warmGray,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded, size: 20, color: AppColors.deepInk),
            tooltip: 'AI Configuration',
            onPressed: _showSettings,
          ),
          if (_messages.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, size: 20, color: AppColors.warmGray),
              tooltip: 'Clear Conversation',
              onPressed: _clearChat,
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Conversation Body
            Expanded(
              child: _messages.isEmpty ? _buildWelcomeView() : _buildMessageList(),
            ),

            // Generation Indicator
            if (_isGenerating)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.5,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.terracotta),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Ask Garuda is formulating linguistic insight...',
                      style: AppTypography.sansLabel(
                        fontSize: 11,
                        color: AppColors.warmGray,
                      ),
                    ),
                  ],
                ),
              ),

            // Bottom Input Field
            _buildInputBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeView() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.terracottaSurface,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      size: 20,
                      color: AppColors.terracotta,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Your Literary Companion',
                    style: AppTypography.serifHeading(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Unlike a generic AI assistant, Ask Garuda is specially attuned to the nuances of vocabulary, etymology, Indian linguistic connections, and refined prose writing.',
                style: AppTypography.sansBody(
                  fontSize: 13.5,
                  color: AppColors.inkLight,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),
        Text(
          'INQUIRE OR EXPLORE',
          style: AppTypography.sansLabel(
            fontSize: 11,
            color: AppColors.warmGray,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 10),

        ..._starterPrompts.map((prompt) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceSand.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: ListTile(
              onTap: () => _handleSendMessage(prompt),
              dense: true,
              leading: const Icon(
                Icons.chat_bubble_outline_rounded,
                size: 16,
                color: AppColors.terracotta,
              ),
              title: Text(
                prompt,
                style: AppTypography.sansBody(
                  fontSize: 13,
                  color: AppColors.deepInk,
                ),
              ),
              trailing: const Icon(
                Icons.arrow_forward_rounded,
                size: 14,
                color: AppColors.warmGray,
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildMessageList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        return _buildMessageBubble(message);
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage msg) {
    if (msg.isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12, left: 48),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.terracotta,
            borderRadius: BorderRadius.circular(14).copyWith(bottomRight: Radius.zero),
          ),
          child: Text(
            msg.text,
            style: AppTypography.sansBody(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
        ),
      );
    }

    // Assistant response bubble
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16, right: 32),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14).copyWith(bottomLeft: Radius.zero),
          border: Border.all(color: msg.isError ? Colors.red.shade200 : AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row with model badge and copy button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.auto_awesome, size: 14, color: AppColors.terracotta),
                    const SizedBox(width: 6),
                    Text(
                      'Ask Garuda',
                      style: AppTypography.sansLabel(
                        fontSize: 11,
                        color: AppColors.terracotta,
                        letterSpacing: 0.5,
                      ),
                    ),
                    if (msg.isDemo) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceSand,
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Text(
                          'Demo Mode',
                          style: AppTypography.sansLabel(
                            fontSize: 9,
                            color: AppColors.warmGray,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.copy_rounded, size: 14, color: AppColors.warmGray),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: 'Copy response',
                  onPressed: () => _copyToClipboard(msg.text),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Markdown rendered text
            MarkdownBody(
              data: msg.text,
              selectable: true,
              styleSheet: MarkdownStyleSheet(
                p: AppTypography.sansBody(fontSize: 14, color: AppColors.deepInk, height: 1.45),
                h3: AppTypography.serifHeading(fontSize: 16, fontWeight: FontWeight.w600),
                listBullet: AppTypography.sansBody(fontSize: 14, color: AppColors.terracotta),
                strong: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.deepInk),
                em: const TextStyle(fontStyle: FontStyle.italic, color: AppColors.inkLight),
              ),
            ),

            // Quick Follow-up Chips (if any)
            if (msg.quickFollowUps.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: msg.quickFollowUps.map((action) {
                  return ActionChip(
                    backgroundColor: AppColors.surfaceSand,
                    side: const BorderSide(color: AppColors.border),
                    label: Text(
                      action,
                      style: AppTypography.sansBody(
                        fontSize: 11.5,
                        color: AppColors.inkLight,
                      ),
                    ),
                    onPressed: () => _handleSendMessage(action),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      decoration: const BoxDecoration(
        color: AppColors.parchment,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: TextField(
                controller: _textController,
                focusNode: _focusNode,
                maxLines: 4,
                minLines: 1,
                textInputAction: TextInputAction.send,
                onSubmitted: (t) => _handleSendMessage(t),
                style: AppTypography.sansBody(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Ask about a word, comparison, or sentence...',
                  hintStyle: AppTypography.sansBody(fontSize: 13, color: AppColors.warmGray),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: const BoxDecoration(
              color: AppColors.terracotta,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_upward_rounded, color: Colors.white, size: 20),
              onPressed: _isGenerating ? null : () => _handleSendMessage(_textController.text),
            ),
          ),
        ],
      ),
    );
  }
}
