import 'package:flutter/material.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'features/ai_companion/screens/ai_companion_screen.dart';
import 'features/home/screens/home_screen.dart';
import 'features/saved_words/screens/saved_words_screen.dart';
import 'features/word_explorer/screens/explorer_screen.dart';
import 'services/audio_service.dart';
import 'services/dictionary_service.dart';
import 'services/storage_service.dart';
import 'widgets/app_bottom_navigation.dart';

class GarudaLexiconApp extends StatefulWidget {
  final StorageService storageService;

  const GarudaLexiconApp({
    super.key,
    required this.storageService,
  });

  @override
  State<GarudaLexiconApp> createState() => _GarudaLexiconAppState();
}

class _GarudaLexiconAppState extends State<GarudaLexiconApp> {
  int _currentTabIndex = 0;
  late final DictionaryService _dictionaryService;
  late final AudioService _audioService;
  final GlobalKey<AiCompanionScreenState> _aiKey = GlobalKey<AiCompanionScreenState>();

  @override
  void initState() {
    super.initState();
    _dictionaryService = DictionaryService();
    _audioService = AudioService();
  }

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }

  void _onTabSelected(int index) {
    setState(() {
      _currentTabIndex = index;
    });
  }

  void _askAiWithPrompt(String prompt) {
    setState(() {
      _currentTabIndex = 3; // Switch to Ask Garuda tab
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _aiKey.currentState?.sendPromptExternally(prompt);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SHABDARTHA',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: Scaffold(
        backgroundColor: AppColors.parchment,
        extendBody: true,
        body: IndexedStack(
          index: _currentTabIndex,
          children: [
            HomeScreen(
              dictionaryService: _dictionaryService,
              storageService: widget.storageService,
              audioService: _audioService,
              onNavigateToTab: _onTabSelected,
              onAskAi: _askAiWithPrompt,
            ),
            ExplorerScreen(
              dictionaryService: _dictionaryService,
              storageService: widget.storageService,
              audioService: _audioService,
              onAskAi: _askAiWithPrompt,
            ),
            SavedWordsScreen(
              storageService: widget.storageService,
              dictionaryService: _dictionaryService,
              audioService: _audioService,
              onAskAi: _askAiWithPrompt,
              onNavigateToTab: _onTabSelected,
            ),
            AiCompanionScreen(
              key: _aiKey,
              storageService: widget.storageService,
            ),
          ],
        ),
        bottomNavigationBar: MediaQuery.of(context).viewInsets.bottom > 0
            ? null
            : AppBottomNavigation(
                currentIndex: _currentTabIndex,
                onTap: _onTabSelected,
              ),
      ),
    );
  }
}
