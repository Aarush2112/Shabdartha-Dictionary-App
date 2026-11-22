import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../models/chat_message.dart';
import '../../../services/ai_service.dart';
import '../../../services/storage_service.dart';
import '../widgets/ai_settings_dialog.dart';

/// Exhibition UI implementation for Ask Garuda (The AI Language Companion).
/// Matches the exact white exhibition canvas, high-contrast serif headlines,
/// and black capsule message dock from the reference design.
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
          text:
              'Encountered an issue consulting Ask Garuda: ${e.toString().replaceAll("Exception: ", "")}\n\n*Tap retry below or verify API settings.*',
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

  void _retryLastPrompt() {
    for (int i = _messages.length - 1; i >= 0; i--) {
      if (_messages[i].isUser) {
        final lastUserPrompt = _messages[i].text;
        setState(() {
          _messages.removeWhere((m) => m.isError);
        });
        _handleSendMessage(lastUserPrompt);
        return;
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
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Clear Salon Dialogue?', style: AppTypography.serifHeading(fontSize: 18)),
        content: const Text(
          'This will clear your conversation history with Ask Garuda.',
          style: TextStyle(fontSize: 14, color: Color(0xFF8E8E93)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF8E8E93))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
        backgroundColor: Colors.black,
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Top Bar (Screen 2 exhibition top bar with NO person icon)
            Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 14.0, 20.0, 12.0),
              child: _buildTopBar(),
            ),

            const Divider(height: 1, color: Color(0xFFEEEEF2)),

            // 2. Conversation Body
            Expanded(
              child: _messages.isEmpty ? _buildWelcomeView() : _buildMessageList(),
            ),

            // 3. Generation Indicator
            if (_isGenerating)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                alignment: Alignment.centerLeft,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Ask Garuda is formulating linguistic insight...',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF8E8E93),
                      ),
                    ),
                  ],
                ),
              ),

            // 4. Bottom Input Field
            _buildInputBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    final isDemo = _aiService.isDemoMode;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Left: Black circular icon
        Container(
          width: 44,
          height: 44,
          decoration: const BoxDecoration(
            color: Colors.black,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.auto_awesome_rounded,
            size: 20,
            color: Colors.white,
          ),
        ),

        // Center: App Name & Edition
        Column(
          children: [
            Text(
              'SHABDARTHA',
              style: AppTypography.editorialHeadline(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Colors.black,
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: 2),
            const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'शब्दार्थ • Ask Garuda',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF8E8E93),
                  ),
                ),
              ],
            ),
          ],
        ),

        // Right: Mode Badge & Config Action (NO person icon!)
        Row(
          children: [
            InkWell(
              onTap: _showSettings,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isDemo ? const Color(0xFFF2F2F5) : const Color(0xFFEDF5EF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isDemo ? Icons.bolt_rounded : Icons.check_circle_rounded,
                      size: 13,
                      color: isDemo ? Colors.black : AppColors.sageGreen,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isDemo ? 'Demo' : 'Live',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isDemo ? Colors.black : AppColors.sageGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_messages.isNotEmpty) ...[
              const SizedBox(width: 6),
              InkWell(
                onTap: _clearChat,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF2F2F5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.delete_outline_rounded, size: 16, color: Color(0xFF8E8E93)),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildWelcomeView() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 100.0),
      children: [
        // Headline
        Text(
          'The Literary\nSalon...',
          style: AppTypography.editorialHeadline(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: Colors.black,
            height: 1.15,
          ),
        ),

        const SizedBox(height: 10),

        const Text(
          '“Words are only the beginning.”\nInquire about semantic subtleties, authentic Sanskrit and Hindi cognates, or refine your prose cadence with your dedicated language mentor.',
          style: TextStyle(
            fontSize: 13.5,
            color: Color(0xFF8E8E93),
            height: 1.45,
          ),
        ),

        const SizedBox(height: 28),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Curated Inquiries',
              style: AppTypography.serifHeading(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            const Text(
              'Tap to ask',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF8E8E93),
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        ..._starterPrompts.map((prompt) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: InkWell(
              onTap: () => _handleSendMessage(prompt),
              borderRadius: BorderRadius.circular(18),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9F9FB),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFEEEEF2)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.auto_awesome_rounded,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        prompt,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                          height: 1.35,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      size: 15,
                      color: Color(0xFF8E8E93),
                    ),
                  ],
                ),
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
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        return _buildMessageBubble(message);
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage msg) {
    if (msg.isUser) {
      // User bubble: Solid black capsule matching the exhibition aesthetic
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(bottom: 14, left: 48),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(22).copyWith(bottomRight: const Radius.circular(4)),
          ),
          child: Text(
            msg.text,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
              height: 1.35,
            ),
          ),
        ),
      );
    }

    // Assistant response bubble: Pure exhibition card
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 18, right: 32),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFFF9F9FB),
          borderRadius: BorderRadius.circular(22).copyWith(bottomLeft: const Radius.circular(4)),
          border: Border.all(
            color: msg.isError ? Colors.red.shade200 : const Color(0xFFEEEEF2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top header with copy button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.auto_awesome_rounded, size: 14, color: Colors.black),
                    const SizedBox(width: 6),
                    const Text(
                      'GARUDA',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                        letterSpacing: 1.0,
                      ),
                    ),
                    if (msg.isDemo) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2F2F5),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Demo',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF8E8E93),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                InkWell(
                  onTap: () => _copyToClipboard(msg.text),
                  child: const Padding(
                    padding: EdgeInsets.all(4.0),
                    child: Icon(Icons.copy_rounded, size: 14, color: Color(0xFF8E8E93)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Markdown rendered body
            MarkdownBody(
              data: msg.text,
              selectable: true,
              styleSheet: MarkdownStyleSheet(
                p: const TextStyle(fontSize: 14, color: Color(0xFF111111), height: 1.5),
                h3: AppTypography.editorialHeadline(fontSize: 16, fontWeight: FontWeight.w700),
                listBullet: const TextStyle(fontSize: 14, color: Colors.black),
                strong: const TextStyle(fontWeight: FontWeight.w700, color: Colors.black),
                em: const TextStyle(fontStyle: FontStyle.italic, color: Color(0xFF3C3C43)),
              ),
            ),

            // Retry action if this is an error message
            if (msg.isError) ...[
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _isGenerating ? null : _retryLastPrompt,
                icon: const Icon(Icons.refresh_rounded, size: 14),
                label: const Text('Retry Prompt'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  visualDensity: VisualDensity.compact,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
              ),
            ],

            // Quick Follow-up Chips (if any)
            if (msg.quickFollowUps.isNotEmpty) ...[
              const SizedBox(height: 14),
              const Divider(height: 1, color: Color(0xFFEEEEF2)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: msg.quickFollowUps.map((action) {
                  return InkWell(
                    onTap: () => _handleSendMessage(action),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F2F5),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        action,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                    ),
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
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final hasKeyboard = bottomInset > 0;

    return Container(
      padding: EdgeInsets.fromLTRB(16, 8, 16, hasKeyboard ? 12 : 88),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFEEEEF2))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF2F2F5),
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _textController,
                focusNode: _focusNode,
                maxLines: 4,
                minLines: 1,
                textInputAction: TextInputAction.send,
                onSubmitted: (t) => _handleSendMessage(t),
                style: const TextStyle(fontSize: 14, color: Colors.black),
                decoration: const InputDecoration(
                  hintText: 'Inquire about a word, Sanskrit root, or prose...',
                  hintStyle: TextStyle(fontSize: 13, color: Color(0xFF8E8E93)),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _isGenerating ? const Color(0xFF8E8E93) : Colors.black,
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
