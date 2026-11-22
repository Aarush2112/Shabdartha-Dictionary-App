import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../models/word_model.dart';
import '../../../services/audio_service.dart';
import '../../../services/dictionary_service.dart';
import '../../../services/storage_service.dart';
import '../../../widgets/error_state_view.dart';
import '../../../widgets/loading_view.dart';
import '../widgets/audio_pronunciation_button.dart';
import '../widgets/etymology_card.dart';
import '../widgets/indian_connection_card.dart';

class WordDetailsScreen extends StatefulWidget {
  final WordEntry? initialEntry;
  final String? wordQuery;
  final DictionaryService dictionaryService;
  final StorageService storageService;
  final AudioService audioService;
  final Function(String query)? onAskAi;
  final Function(String word)? onSelectWord;

  const WordDetailsScreen({
    super.key,
    this.initialEntry,
    this.wordQuery,
    required this.dictionaryService,
    required this.storageService,
    required this.audioService,
    this.onAskAi,
    this.onSelectWord,
  }) : assert(initialEntry != null || wordQuery != null);

  @override
  State<WordDetailsScreen> createState() => _WordDetailsScreenState();
}

class _WordDetailsScreenState extends State<WordDetailsScreen> {
  WordEntry? _entry;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialEntry != null) {
      _entry = widget.initialEntry;
      _isSaved = widget.storageService.isWordSaved(_entry!.word);
    } else if (widget.wordQuery != null) {
      _fetchWord(widget.wordQuery!);
    }
  }

  Future<void> _fetchWord(String word) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final res = await widget.dictionaryService.lookupWord(word);
      if (mounted) {
        setState(() {
          _entry = res;
          _isLoading = false;
          _isSaved = widget.storageService.isWordSaved(res.word);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString().replaceAll('Exception: ', '');
        });
      }
    }
  }

  Future<void> _toggleSave() async {
    if (_entry == null) return;

    if (_isSaved) {
      await widget.storageService.removeSavedWord(_entry!.word);
      if (mounted) {
        setState(() => _isSaved = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Removed "${_entry!.word}" from saved vocabulary.'),
            duration: const Duration(seconds: 1),
            backgroundColor: AppColors.deepInk,
          ),
        );
      }
    } else {
      await widget.storageService.saveWord(_entry!);
      if (mounted) {
        setState(() => _isSaved = true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Saved "${_entry!.word}" to vocabulary notebook.'),
            duration: const Duration(seconds: 1),
            backgroundColor: AppColors.sageGreen,
          ),
        );
      }
    }
  }

  Future<void> _shareWord() async {
    if (_entry == null) return;
    final shareText = '''
${_entry!.word.toUpperCase()} ${_entry!.phonetic ?? ''}
[${_entry!.primaryPartOfSpeech}] ${_entry!.primaryDefinition}

Discovered on Garuda Lexicon — The Dictionary & Language Companion.
''';

    try {
      await SharePlus.instance.share(
        ShareParams(
          text: shareText,
          subject: 'Word Discovery: ${_entry!.word}',
        ),
      );
    } catch (_) {
      await Clipboard.setData(ClipboardData(text: shareText));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Word definition copied to clipboard.'),
            backgroundColor: AppColors.deepInk,
          ),
        );
      }
    }
  }

  void _triggerAskAi() {
    if (_entry == null) return;
    final prompt = 'Explain the historical roots and nuanced usage of "${_entry!.word}".';
    if (widget.onAskAi != null) {
      Navigator.of(context).pop();
      widget.onAskAi!(prompt);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.parchment,
      appBar: AppBar(
        title: Text(
          _entry?.word ?? 'Lexicon Entry',
          style: AppTypography.serifHeading(fontSize: 20),
        ),
        actions: [
          if (_entry != null) ...[
            IconButton(
              icon: Icon(
                _isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                color: _isSaved ? AppColors.terracotta : AppColors.deepInk,
              ),
              tooltip: _isSaved ? 'Remove Bookmark' : 'Save Word',
              onPressed: _toggleSave,
            ),
            IconButton(
              icon: const Icon(Icons.share_outlined, color: AppColors.deepInk),
              tooltip: 'Share',
              onPressed: _shareWord,
            ),
          ],
        ],
      ),
      body: _buildBody(),
      floatingActionButton: _entry != null && widget.onAskAi != null
          ? FloatingActionButton.extended(
              onPressed: _triggerAskAi,
              backgroundColor: AppColors.terracotta,
              foregroundColor: Colors.white,
              elevation: 2,
              icon: const Icon(Icons.auto_awesome_rounded, size: 18),
              label: Text(
                'Ask Garuda',
                style: AppTypography.sansLabel(
                  fontSize: 13,
                  color: Colors.white,
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const LoadingView(message: 'Consulting authoritative sources...');
    }

    if (_errorMessage != null) {
      return ErrorStateView(
        message: _errorMessage!,
        onRetry: () => _fetchWord(widget.wordQuery ?? _entry?.word ?? ''),
      );
    }

    if (_entry == null) {
      return const SizedBox.shrink();
    }

    final entry = _entry!;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Word Hero & Pronunciation Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.word,
                      style: AppTypography.heroWord(fontSize: 36),
                    ),
                    if (entry.phonetic != null && entry.phonetic!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        entry.phonetic!,
                        style: AppTypography.phonetic(fontSize: 16),
                      ),
                    ],
                  ],
                ),
              ),
              if (entry.audioUrl != null)
                AudioPronunciationButton(
                  audioUrl: entry.audioUrl,
                  audioService: widget.audioService,
                ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),

          // Editorial Insight (if present)
          if (entry.editorialInsight != null && entry.editorialInsight!.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceSand.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(10),
                border: const Border(
                  left: BorderSide(color: AppColors.terracotta, width: 3.5),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.lightbulb_outline_rounded,
                        size: 15,
                        color: AppColors.terracotta,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'EDITORIAL INSIGHT',
                        style: AppTypography.sansLabel(
                          fontSize: 11,
                          color: AppColors.terracottaDark,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    entry.editorialInsight!,
                    style: AppTypography.sansBody(
                      fontSize: 14,
                      color: AppColors.deepInk,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Indian Language Heritage (if present)
          if (entry.indianConnections.isNotEmpty) ...[
            IndianConnectionCard(connections: entry.indianConnections),
            const SizedBox(height: 20),
          ],

          // Etymology and Origin Card (if present)
          if ((entry.etymology != null && entry.etymology!.isNotEmpty) ||
              (entry.origin != null && entry.origin!.isNotEmpty)) ...[
            EtymologyCard(
              etymology: entry.etymology,
              origin: entry.origin,
            ),
            const SizedBox(height: 20),
          ],

          // Definitions Section
          Text(
            'Definitions',
            style: AppTypography.serifHeading(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),

          ...entry.meanings.map((meaning) => _buildMeaningSection(meaning)),

          const SizedBox(height: 48), // Padding for floating action button
        ],
      ),
    );
  }

  Widget _buildMeaningSection(WordMeaning meaning) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Part of Speech Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.surfaceSand,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              meaning.partOfSpeech.toUpperCase(),
              style: AppTypography.sansLabel(
                fontSize: 11,
                color: AppColors.deepInk,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Definitions list
          ...meaning.definitions.asMap().entries.map((entry) {
            final idx = entry.key + 1;
            final def = entry.value;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$idx. ',
                        style: AppTypography.sansLabel(
                          fontSize: 14,
                          color: AppColors.warmGray,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          def.definition,
                          style: AppTypography.sansBody(
                            fontSize: 14.5,
                            color: AppColors.deepInk,
                            height: 1.45,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (def.example != null && def.example!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Padding(
                      padding: const EdgeInsets.only(left: 18.0),
                      child: Text(
                        '“${def.example!}”',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          fontSize: 13.5,
                          color: AppColors.inkLight.withValues(alpha: 0.85),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                  if (def.synonyms.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.only(left: 18.0),
                      child: Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          Text(
                            'Synonyms: ',
                            style: AppTypography.sansLabel(
                              fontSize: 11,
                              color: AppColors.warmGray,
                            ),
                          ),
                          ...def.synonyms.map(
                            (s) => InkWell(
                              onTap: () {
                                if (widget.onSelectWord != null) {
                                  widget.onSelectWord!(s);
                                } else {
                                  _fetchWord(s);
                                }
                              },
                              borderRadius: BorderRadius.circular(4),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceSand,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  s,
                                  style: AppTypography.sansBody(
                                    fontSize: 12,
                                    color: AppColors.terracotta,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
