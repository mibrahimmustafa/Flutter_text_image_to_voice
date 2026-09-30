import 'package:flutter/material.dart';
import '../models/app_strings.dart';
import '../models/speech_history_item.dart';
import '../models/voice_persona.dart';
import '../services/tts_service.dart';
import '../widgets/history_bottom_sheet.dart';
import '../widgets/system_voice_browser_dialog.dart';
import '../widgets/voice_player_bar.dart';
import 'photo_ocr_tab.dart';
import 'text_input_tab.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final bool isDarkMode;

  const HomeScreen({
    super.key,
    required this.onToggleTheme,
    required this.isDarkMode,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _photoTextController = TextEditingController();
  final TextEditingController _manualTextController = TextEditingController();
  final TtsService _ttsService = TtsService();

  final List<SpeechHistoryItem> _history = [];
  bool _isArabic = false;

  AppStrings get strings => AppStrings(isArabic: _isArabic);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _ttsService.initialize();
    _ttsService.addListener(_onTtsUpdated);
  }

  void _onTtsUpdated() {
    if (mounted) setState(() {});
  }

  void _toggleLanguage() {
    setState(() {
      _isArabic = !_isArabic;
      _ttsService.setArabicMode(_isArabic);
    });
  }

  @override
  void dispose() {
    _ttsService.removeListener(_onTtsUpdated);
    _tabController.dispose();
    _photoTextController.dispose();
    _manualTextController.dispose();
    super.dispose();
  }

  String get _currentActiveText {
    if (_tabController.index == 0) {
      return _photoTextController.text;
    } else {
      return _manualTextController.text;
    }
  }

  Future<void> _speakCurrentText({HistorySourceType source = HistorySourceType.textInput}) async {
    final text = _currentActiveText.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(strings.enterTextAlert),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    final personaName = _isArabic
        ? '${_ttsService.currentPersona.nameArabic} (${_ttsService.currentPersona.gender == VoiceGender.male ? strings.man : strings.woman})'
        : '${_ttsService.currentPersona.name} (${_ttsService.currentPersona.gender == VoiceGender.male ? "Man" : "Woman"})';

    // Save to history
    final historyItem = SpeechHistoryItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      source: _tabController.index == 0 ? HistorySourceType.photo : HistorySourceType.textInput,
      timestamp: DateTime.now(),
      voicePersonaName: personaName,
    );

    setState(() {
      _history.insert(0, historyItem);
      if (_history.length > 50) _history.removeLast();
    });

    await _ttsService.speak(text);
  }

  void _openHistorySheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => HistoryBottomSheet(
        items: _history,
        onClearAll: () => setState(() => _history.clear()),
        onSelect: (item) {
          if (_tabController.index == 0) {
            _photoTextController.text = item.text;
          } else {
            _manualTextController.text = item.text;
          }
          setState(() {});
          _speakCurrentText();
        },
      ),
    );
  }

  void _openSystemVoicesDialog() {
    showDialog(
      context: context,
      builder: (context) => SystemVoiceBrowserDialog(ttsService: _ttsService),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Directionality(
      textDirection: _isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: isDark ? const Color(0xFF131722) : Colors.white,
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFFEC4899)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.record_voice_over_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            strings.appTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            strings.aiBadge,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      strings.appSubtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            // Language Switcher Toggle Pill [EN | عربي]
            InkWell(
              onTap: _toggleLanguage,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E2433) : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_isArabic ? '🇸🇦' : '🇺🇸', style: const TextStyle(fontSize: 13)),
                    const SizedBox(width: 4),
                    Text(
                      _isArabic ? 'عربي' : 'EN',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 6),

            // Device voices browser
            IconButton(
              tooltip: strings.deviceVoices,
              icon: const Icon(Icons.settings_voice_rounded, size: 21),
              onPressed: _openSystemVoicesDialog,
            ),
            // History
            Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  tooltip: strings.history,
                  icon: const Icon(Icons.history_rounded, size: 22),
                  onPressed: _openHistorySheet,
                ),
                if (_history.isNotEmpty)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFFEC4899),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${_history.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            // Dark/Light toggle
            IconButton(
              tooltip: widget.isDarkMode ? 'Light Mode' : 'Dark Mode',
              icon: Icon(widget.isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded, size: 21),
              onPressed: widget.onToggleTheme,
            ),
            const SizedBox(width: 4),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(56),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E2433) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: TabBar(
                controller: _tabController,
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                indicator: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6366F1).withValues(alpha: 0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                labelColor: Colors.white,
                unselectedLabelColor: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                tabs: [
                  Tab(
                    icon: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.camera_alt_rounded, size: 16),
                        const SizedBox(width: 6),
                        Text(strings.tabPhoto),
                      ],
                    ),
                  ),
                  Tab(
                    icon: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.edit_note_rounded, size: 18),
                        const SizedBox(width: 6),
                        Text(strings.tabText),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: Stack(
          children: [
            TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: Photo OCR to Speech
                PhotoOcrTab(
                  textController: _photoTextController,
                  ttsService: _ttsService,
                  isArabic: _isArabic,
                  onTextUpdated: (text) => setState(() {}),
                  onTriggerSpeak: () => _speakCurrentText(source: HistorySourceType.photo),
                ),

                // Tab 2: Direct Text to Speech
                TextInputTab(
                  textController: _manualTextController,
                  ttsService: _ttsService,
                  isArabic: _isArabic,
                  onTextUpdated: (text) => setState(() {}),
                  onTriggerSpeak: () => _speakCurrentText(source: HistorySourceType.textInput),
                ),
              ],
            ),

            // Sticky Bottom Voice Player Bar
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: VoicePlayerBar(
                ttsService: _ttsService,
                textToSpeak: _currentActiveText,
                isArabic: _isArabic,
                onSpeakRequested: _speakCurrentText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
