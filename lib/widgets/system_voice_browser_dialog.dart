import 'package:flutter/material.dart';
import '../services/tts_service.dart';

class SystemVoiceBrowserDialog extends StatefulWidget {
  final TtsService ttsService;

  const SystemVoiceBrowserDialog({
    super.key,
    required this.ttsService,
  });

  @override
  State<SystemVoiceBrowserDialog> createState() => _SystemVoiceBrowserDialogState();
}

class _SystemVoiceBrowserDialogState extends State<SystemVoiceBrowserDialog> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, String>> _filterVoices(List<Map<String, String>> voices) {
    if (_searchQuery.trim().isEmpty) return voices;
    final q = _searchQuery.toLowerCase();
    return voices.where((v) {
      final name = v['name']?.toLowerCase() ?? '';
      final locale = v['locale']?.toLowerCase() ?? '';
      return name.contains(q) || locale.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final all = _filterVoices(widget.ttsService.allVoices);
    final men = _filterVoices(widget.ttsService.maleVoices);
    final women = _filterVoices(widget.ttsService.femaleVoices);

    return Dialog(
      backgroundColor: isDark ? const Color(0xFF161B26) : Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 580, maxHeight: 680),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.record_voice_over_rounded, color: theme.colorScheme.primary),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Device System Voices',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            'Select from installed synthetic voices',
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Search bar
              TextField(
                controller: _searchController,
                onChanged: (val) => setState(() => _searchQuery = val),
                decoration: InputDecoration(
                  hintText: 'Search voice name or locale (e.g. David, Zira, en-US)...',
                  hintStyle: const TextStyle(fontSize: 13),
                  prefixIcon: const Icon(Icons.search_rounded, size: 20),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: isDark ? const Color(0xFF1E2433) : Colors.grey.shade100,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Filter Tabs
              Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E2433) : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  indicator: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  tabs: [
                    Tab(text: 'All (${all.length})'),
                    Tab(text: '👨 Men (${men.length})'),
                    Tab(text: '👩 Women (${women.length})'),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Tab contents
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildVoiceList(all),
                    _buildVoiceList(men),
                    _buildVoiceList(women),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVoiceList(List<Map<String, String>> voices) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (voices.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.mic_off_rounded, size: 40, color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
            const SizedBox(height: 8),
            Text(
              'No matching voices found',
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      );
    }

    final currentVoiceName = widget.ttsService.selectedSystemVoice?['name'] ?? '';

    return ListView.separated(
      itemCount: voices.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final voice = voices[index];
        final name = voice['name'] ?? 'Unnamed Voice';
        final locale = voice['locale'] ?? '';
        final isCurrent = currentVoiceName == name;

        // Determine icon based on name
        final nameLower = name.toLowerCase();
        final isFemale = nameLower.contains('female') ||
            nameLower.contains('woman') ||
            nameLower.contains('zira') ||
            nameLower.contains('jenny') ||
            nameLower.contains('susan') ||
            nameLower.contains('samantha');

        return Container(
          decoration: BoxDecoration(
            color: isCurrent
                ? theme.colorScheme.primary.withValues(alpha: 0.12)
                : (isDark ? const Color(0xFF1E2433) : Colors.grey.shade50),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isCurrent
                  ? theme.colorScheme.primary
                  : (isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.05)),
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            leading: CircleAvatar(
              backgroundColor: isFemale
                  ? Colors.pink.withValues(alpha: 0.18)
                  : Colors.blue.withValues(alpha: 0.18),
              child: Icon(
                isFemale ? Icons.face_3_rounded : Icons.record_voice_over_rounded,
                size: 20,
                color: isFemale ? Colors.pink.shade400 : Colors.blue.shade400,
              ),
            ),
            title: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                fontSize: 14,
                color: isCurrent ? theme.colorScheme.primary : theme.colorScheme.onSurface,
              ),
            ),
            subtitle: Text(
              locale.isNotEmpty ? 'Locale: $locale' : 'System voice',
              style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withValues(alpha: 0.55)),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Preview sound button
                IconButton(
                  tooltip: 'Preview this voice',
                  icon: const Icon(Icons.play_circle_outline_rounded, size: 24),
                  onPressed: () async {
                    await widget.ttsService.setSystemVoice(voice);
                    await widget.ttsService.speak("Hello! This is how I sound.");
                  },
                ),
                // Select button
                ElevatedButton(
                  onPressed: () async {
                    final navigator = Navigator.of(context);
                    await widget.ttsService.setSystemVoice(voice);
                    navigator.pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isCurrent ? theme.colorScheme.primary : null,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    minimumSize: Size.zero,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(
                    isCurrent ? 'Selected' : 'Use',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isCurrent ? Colors.white : null,
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
}
