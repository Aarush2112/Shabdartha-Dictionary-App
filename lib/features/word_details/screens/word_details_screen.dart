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

/// Screen 3 implementation: Museum Showcase & Cathedral Arched Detail View.
/// Exactly mirrors the rightmost phone in the uploaded exhibition mockup.
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
  final ScrollController _scrollController = ScrollController();
  WordEntry? _entry;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isSaved = false;

  final String _museumHallBackground =
      'https://images.unsplash.com/photo-1582561424760-0321d75e81fa?w=800';

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

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String _getArtworkForWord(String word) {
    final w = word.toLowerCase();
    if (w.contains('jugger')) {
      return 'https://images.unsplash.com/photo-1579783900882-c0d3dad7b119?w=800';
    } else if (w.contains('avatar') || w.contains('guru') || w.contains('pandit')) {
      return 'https://images.unsplash.com/photo-1578301978693-85fa9c0320b9?w=800';
    } else if (w.contains('brother') || w.contains('mother') || w.contains('name')) {
      return 'https://images.unsplash.com/photo-1577083552431-6e5fd01aa342?w=800';
    } else if (w.contains('petrichor') || w.contains('solitude') || w.contains('ineffable')) {
      return 'https://images.unsplash.com/photo-1580136579312-94651dfd596d?w=800';
    } else {
      return 'https://images.unsplash.com/photo-1579783900882-c0d3dad7b119?w=800';
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

Discovered on Shabdartha — The Dictionary & Language Companion.
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
    final queryWord = _entry?.word ?? widget.wordQuery ?? '';
    if (queryWord.isEmpty) return;
    final prompt = 'Explain the historical roots and nuanced usage of "$queryWord".';
    if (widget.onAskAi != null) {
      Navigator.of(context).popUntil((route) => route.isFirst);
      widget.onAskAi!(prompt);
    }
  }

  void _triggerAskAiWithCustomPrompt(String prompt) {
    if (widget.onAskAi != null) {
      Navigator.of(context).popUntil((route) => route.isFirst);
      widget.onAskAi!(prompt);
    }
  }

  void _scrollToDetails() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        540,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(widget.wordQuery ?? 'Lexicon Entry'),
        ),
        body: const LoadingView(message: 'Consulting authoritative sources...'),
      );
    }

    if (_errorMessage != null) {
      final queryWord = widget.wordQuery ?? _entry?.word ?? 'this word';
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(title: Text(queryWord)),
        body: ErrorStateView(
          title: _errorMessage!.contains('No formal definition')
              ? 'Term Not in Dictionary'
              : 'Lookup Unavailable',
          message: _errorMessage!,
          retryLabel: 'Retry Search',
          onRetry: () => _fetchWord(widget.wordQuery ?? _entry?.word ?? ''),
          secondaryActionTitle: widget.onAskAi != null ? 'Ask Garuda about "$queryWord"' : null,
          onSecondaryAction: widget.onAskAi != null
              ? () => _triggerAskAiWithCustomPrompt(
                  'Can you explain the meaning, origin, or usage of the term "$queryWord"?')
              : null,
        ),
      );
    }

    if (_entry == null) {
      return const Scaffold(backgroundColor: Colors.white, body: SizedBox.shrink());
    }

    final entry = _entry!;
    final artworkUrl = _getArtworkForWord(entry.word);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.only(bottom: 100.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==========================================
            // SCREEN 3: MASTERPIECE ARCHED SHOWCASE HERO
            // ==========================================
            _buildCathedralArchHero(entry, artworkUrl),

            // ==========================================
            // DEEP LEXICAL BREAKDOWN FOLIO
            // ==========================================
            Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 24.0, 20.0, 0.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Editorial Insight (if present)
                  if (entry.editorialInsight != null && entry.editorialInsight!.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9F9FB),
                        borderRadius: BorderRadius.circular(14),
                        border: const Border(
                          left: BorderSide(color: Colors.black, width: 3.5),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.auto_awesome_rounded,
                                size: 15,
                                color: Colors.black,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'EDITORIAL PERSPECTIVE',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            entry.editorialInsight!,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF2C2C2E),
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Indian Language Heritage (if present)
                  if (entry.indianConnections.isNotEmpty) ...[
                    IndianConnectionCard(connections: entry.indianConnections),
                    const SizedBox(height: 24),
                  ],

                  // Etymology and Origin Card (if present)
                  if ((entry.etymology != null && entry.etymology!.isNotEmpty) ||
                      (entry.origin != null && entry.origin!.isNotEmpty)) ...[
                    EtymologyCard(
                      etymology: entry.etymology,
                      origin: entry.origin,
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Definitions Section
                  Text(
                    'Meanings & Context',
                    style: AppTypography.editorialHeadline(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 14),

                  ...entry.meanings.map((meaning) => _buildMeaningSection(meaning)),

                  const SizedBox(height: 16),

                  // Ask Garuda Callout
                  _buildAskGarudaCallout(entry.word),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Screen 3 exact visual match: Museum hall background, cathedral arched frame, serif title, details pill
  Widget _buildCathedralArchHero(WordEntry entry, String artworkUrl) {
    return SizedBox(
      height: 580,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Background: Classical museum interior
          Image.network(
            _museumHallBackground,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: const Color(0xFF1E1E24),
            ),
          ),

          // 2. Ambient dark overlay vignette
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withValues(alpha: 0.35),
                  Colors.black.withValues(alpha: 0.25),
                  Colors.black.withValues(alpha: 0.75),
                  Colors.black.withValues(alpha: 0.95),
                ],
                stops: const [0.0, 0.35, 0.70, 1.0],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // 3. Top Action Controls (Back, Bookmark, Share)
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Back Button
                InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  borderRadius: BorderRadius.circular(22),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.45),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                    ),
                    child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
                  ),
                ),

                // Right actions
                Row(
                  children: [
                    // Bookmark Button
                    InkWell(
                      onTap: _toggleSave,
                      borderRadius: BorderRadius.circular(22),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.45),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                        ),
                        child: Icon(
                          _isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                          color: _isSaved ? AppColors.antiqueGoldLight : Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Share Button
                    InkWell(
                      onTap: _shareWord,
                      borderRadius: BorderRadius.circular(22),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.45),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                        ),
                        child: const Icon(Icons.share_outlined, color: Colors.white, size: 18),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 4. Center Cathedral Arched Card (Screen 3's distinct design hallmark)
          Positioned(
            top: 100,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 200,
                height: 260,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(85),
                    topRight: Radius.circular(85),
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.85),
                    width: 2.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 20,
                      spreadRadius: 2,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(83),
                    topRight: Radius.circular(83),
                    bottomLeft: Radius.circular(14),
                    bottomRight: Radius.circular(14),
                  ),
                  child: Image.network(
                    artworkUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: const Color(0xFF2C241E),
                      child: const Center(
                        child: Icon(Icons.palette_outlined, size: 40, color: Colors.white54),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 5. Typography & Action Controls Below Arched Frame
          Positioned(
            left: 24,
            right: 24,
            bottom: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Hero Word Title ("Interior of a Mansion" serif style)
                Text(
                  entry.word,
                  textAlign: TextAlign.center,
                  style: AppTypography.editorialHeadline(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.15,
                  ),
                ),

                const SizedBox(height: 4),

                // Phonetic and Native Script subtitle
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (entry.phonetic != null && entry.phonetic!.isNotEmpty)
                      Text(
                        entry.phonetic!,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withValues(alpha: 0.75),
                        ),
                      ),
                    if (entry.indianConnections.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Text(
                        '•  ${entry.indianConnections.first.nativeScript}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.antiqueGoldLight.withValues(alpha: 0.95),
                        ),
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 8),

                // Subtitle description quote
                Text(
                  entry.editorialInsight ?? entry.primaryDefinition,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: Colors.white.withValues(alpha: 0.7),
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 16),

                // Specifications Badges (matching Screen 3 dark mode pills)
                Wrap(
                  spacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    _buildSpecBadge(entry.primaryPartOfSpeech.toUpperCase()),
                    if (entry.indianConnections.isNotEmpty)
                      _buildSpecBadge(entry.indianConnections.first.language.toUpperCase()),
                    if (entry.origin != null && entry.origin!.isNotEmpty)
                      _buildSpecBadge('HISTORIC ETYMOLOGY'),
                  ],
                ),

                const SizedBox(height: 18),

                // Action Pill Buttons: Details -> and Ask Garuda ->
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Black Pill Button: Details ->
                    InkWell(
                      onTap: _scrollToDetails,
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Details',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 6),
                            Icon(Icons.arrow_downward_rounded, size: 14, color: Colors.white),
                          ],
                        ),
                      ),
                    ),

                    if (entry.audioUrl != null) ...[
                      const SizedBox(width: 12),
                      AudioPronunciationButton(
                        audioUrl: entry.audioUrl,
                        audioService: widget.audioService,
                      ),
                    ],

                    if (widget.onAskAi != null) ...[
                      const SizedBox(width: 12),
                      InkWell(
                        onTap: _triggerAskAi,
                        borderRadius: BorderRadius.circular(24),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.auto_awesome_rounded, size: 14, color: Colors.white),
                              SizedBox(width: 6),
                              Text(
                                'Ask Garuda',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildMeaningSection(WordMeaning meaning) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9FB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEEEF2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Part of Speech Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              meaning.partOfSpeech.toUpperCase(),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Definitions list
          ...meaning.definitions.asMap().entries.map((item) {
            final idx = item.key + 1;
            final def = item.value;

            return Padding(
              padding: const EdgeInsets.only(bottom: 14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$idx. ',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF8E8E93),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          def.definition,
                          style: const TextStyle(
                            fontSize: 14.5,
                            color: Color(0xFF111111),
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
                        style: const TextStyle(
                          fontStyle: FontStyle.italic,
                          fontSize: 13.5,
                          color: Color(0xFF3C3C43),
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
                          const Text(
                            'Synonyms: ',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF8E8E93),
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
                              borderRadius: BorderRadius.circular(6),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF2F2F5),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  s,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
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

  Widget _buildAskGarudaCallout(String word) {
    if (widget.onAskAi == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text(
                'Inquire with Ask Garuda',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Explore philosophical origins, sentence crafting, or linguistic family trees with your AI language companion.',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white70,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          InkWell(
            onTap: _triggerAskAi,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Ask About This Word',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(width: 6),
                  Icon(Icons.arrow_forward_rounded, size: 14, color: Colors.black),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
