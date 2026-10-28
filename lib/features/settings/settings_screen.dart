import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/profile.dart';
import '../../providers/app_providers.dart';
import '../../services/appwrite_service.dart';
import '../../shared/widgets/responsive_layout.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final TextEditingController _apiKeyController = TextEditingController();
  bool _isTestingKey = false;
  String? _testKeyResult;

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  void _showEditProfileDialog(Profile profile) {
    final controller = TextEditingController(text: profile.name);
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Edit Your Name'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Display Name',
              hintText: 'e.g. Hamid',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final newName = controller.text.trim();
                if (newName.isNotEmpty) {
                  await ref.read(profilesListProvider.notifier).updateName(profile.id, newName);
                }
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showApiKeyDialog() {
    final settingsService = ref.read(settingsServiceProvider);
    final currentKey = settingsService.getGeminiApiKey();
    _apiKeyController.text = currentKey;
    _testKeyResult = null;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: const Text('Configure Gemini API Key'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Get your personal Gemini API key from Google AI Studio (https://aistudio.google.com).',
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondaryOf(context)),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _apiKeyController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Gemini API Key',
                        hintText: 'AIzaSy...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        OutlinedButton.icon(
                          icon: const Icon(Icons.network_check_rounded, size: 16),
                          label: const Text('Test Connection'),
                          onPressed: _isTestingKey
                              ? null
                              : () async {
                                  final tempKey = _apiKeyController.text.trim();
                                  if (tempKey.isEmpty) {
                                    setDialogState(() {
                                      _testKeyResult = 'Please enter an API key first.';
                                    });
                                    return;
                                  }
                                  setDialogState(() {
                                    _isTestingKey = true;
                                    _testKeyResult = null;
                                  });
                                  await settingsService.setCustomApiKey(tempKey);
                                  try {
                                    final gemini = ref.read(geminiServiceProvider);
                                    await gemini.generateExplanation(
                                      surahNumber: 1,
                                      surahName: 'Al-Fatihah',
                                      startVerse: 1,
                                      endVerse: 2,
                                    );
                                    setDialogState(() {
                                      _isTestingKey = false;
                                      _testKeyResult = 'Success: Connected to Gemini API!';
                                    });
                                  } catch (e) {
                                    setDialogState(() {
                                      _isTestingKey = false;
                                      _testKeyResult = 'Test error: $e';
                                    });
                                  }
                                },
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (_isTestingKey) ...[
                      const Row(
                        children: [
                          SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                          SizedBox(width: 8),
                          Text('Testing key connection...', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ] else if (_testKeyResult != null) ...[
                      Text(
                        _testKeyResult!,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _testKeyResult!.startsWith('Success') ? AppColors.success : AppColors.error,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                if (currentKey.isNotEmpty)
                  TextButton(
                    onPressed: () async {
                      await settingsService.clearCustomApiKey();
                      setDialogState(() {
                        _apiKeyController.clear();
                        _testKeyResult = 'Key cleared. App in demo mode.';
                      });
                      setState(() {});
                    },
                    child: const Text('Clear Key', style: TextStyle(color: AppColors.error)),
                  ),
                ElevatedButton(
                  onPressed: () async {
                    final key = _apiKeyController.text.trim();
                    if (key.isNotEmpty) {
                      await settingsService.setCustomApiKey(key);
                    }
                    if (ctx.mounted) Navigator.pop(ctx);
                    setState(() {});
                  },
                  child: const Text('Save Key'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _exportReadingHistory() async {
    final activeProfile = ref.read(activeProfileProvider);
    final readingRepo = ref.read(readingRepositoryProvider);
    final sessions = await readingRepo.getAllSessionsForProfile(activeProfile.id);

    if (sessions.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No reading history to export.')),
        );
      }
      return;
    }

    final buffer = StringBuffer();
    buffer.writeln('=== Quran Companion Reading History ===');
    buffer.writeln('Reader: ${activeProfile.name}');
    buffer.writeln('Exported: ${DateTime.now().toString()}');
    buffer.writeln('Total Sessions: ${sessions.length}');
    buffer.writeln('---------------------------------------');

    for (final s in sessions) {
      buffer.writeln('\n${s.passageReference}');
      buffer.writeln('Date: ${s.readAt}');
      if (s.notes != null && s.notes!.isNotEmpty) {
        buffer.writeln('Note: ${s.notes}');
      }
    }

    await Clipboard.setData(ClipboardData(text: buffer.toString()));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reading history copied to clipboard!'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Future<void> _clearCachedExplanations() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear Cached Explanations?'),
        content: const Text('This will delete saved offline AI responses. Reading sessions, bookmarks, and notes will be preserved.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Clear Cache'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final readingRepo = ref.read(readingRepositoryProvider);
      await readingRepo.clearAllCachedExplanations();
      ref.read(sessionRefreshProvider.notifier).trigger();
    ref.read(profilesListProvider.notifier).loadProfiles();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cached explanations cleared.')),
        );
      }
    }
  }

  Future<void> _performManualSync() async {
    final appwrite = ref.read(appwriteServiceProvider);
    final readingRepo = ref.read(readingRepositoryProvider);
    final profileRepo = ref.read(profileRepositoryProvider);
    final bookmarkRepo = ref.read(bookmarkRepositoryProvider);

    await appwrite.performFullSync(
      readingRepo: readingRepo,
      profileRepo: profileRepo,
      bookmarkRepo: bookmarkRepo,
    );

    ref.read(sessionRefreshProvider.notifier).trigger();
    ref.read(profilesListProvider.notifier).loadProfiles();

    if (mounted) {
      final msg = appwrite.syncMessageNotifier.value ?? 'Sync completed!';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: appwrite.syncStateNotifier.value == SyncState.error
              ? AppColors.secondary
              : AppColors.success,
        ),
      );
    }
  }

  Future<void> _signInGoogle() async {
    final appwrite = ref.read(appwriteServiceProvider);
    try {
      await appwrite.signInWithGoogle();
      await _performManualSync();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign-in cancelled or failed: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeProfile = ref.watch(activeProfileProvider);
    final themeMode = ref.watch(themeModeProvider);
    final textScale = ref.watch(textScaleProvider);
    final geminiService = ref.watch(geminiServiceProvider);
    final isConfigured = geminiService.isConfigured;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings & Preferences'),
      ),
      body: Center(
        child: ResponsiveContainer(
          maxWidth: 680,
          child: ListView(
            padding: ResponsiveLayout.defaultPadding(context),
            children: [
              // Section 1: Your Personal Profile
              _sectionHeader('Your Profile'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: isDark ? AppColors.darkPrimaryContainer : AppColors.primaryContainer,
                        child: Text(
                          activeProfile.name.isNotEmpty ? activeProfile.name[0] : 'R',
                          style: TextStyle(
                            color: isDark ? AppColors.darkOnPrimaryContainer : AppColors.primaryDark,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              activeProfile.name,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Personal device reader',
                              style: TextStyle(color: AppColors.textSecondaryOf(context), fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.edit_rounded, size: 16),
                        label: const Text('Edit Name'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          minimumSize: Size.zero,
                        ),
                        onPressed: () => _showEditProfileDialog(activeProfile),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Section 2: Appearance & Dark Mode
              _sectionHeader('Appearance'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Choose your preferred appearance mode for day and night Quran study.',
                        style: TextStyle(color: AppColors.textSecondaryOf(context), fontSize: 13),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _themeOption(
                            mode: ThemeMode.system,
                            currentMode: themeMode,
                            icon: Icons.brightness_auto_rounded,
                            label: 'System',
                          ),
                          const SizedBox(width: 10),
                          _themeOption(
                            mode: ThemeMode.light,
                            currentMode: themeMode,
                            icon: Icons.light_mode_rounded,
                            label: 'Light',
                          ),
                          const SizedBox(width: 10),
                          _themeOption(
                            mode: ThemeMode.dark,
                            currentMode: themeMode,
                            icon: Icons.dark_mode_rounded,
                            label: 'Dark',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Section 3: Reading Accessibility (Text Size)
              _sectionHeader('Reading Text Size'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Adjust font size for comfortable reading of explanations, translations, and notes.',
                        style: TextStyle(color: AppColors.textSecondaryOf(context), fontSize: 13),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _textSizeChip('Standard', 1.0, textScale),
                          _textSizeChip('Comfortable', 1.15, textScale),
                          _textSizeChip('Large', 1.30, textScale),
                          _textSizeChip('Extra Large', 1.45, textScale),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isDark ? AppColors.darkBorder : AppColors.border,
                          ),
                        ),
                        child: Text(
                          'Preview: "All praise is due to Allah, Lord of the worlds."',
                          style: TextStyle(
                            fontSize: 14 * textScale,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Section 4: Gemini API Configuration
              _sectionHeader('Gemini AI Configuration'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isConfigured
                                  ? (isDark ? AppColors.darkPrimaryContainer : AppColors.primaryContainer)
                                  : (isDark ? const Color(0xFF2C2210) : const Color(0xFFFFF7E6)),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              isConfigured ? Icons.check_circle_rounded : Icons.info_outline_rounded,
                              color: isConfigured
                                  ? (isDark ? AppColors.darkPrimary : AppColors.success)
                                  : (isDark ? const Color(0xFFFFB24D) : const Color(0xFFD46B08)),
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isConfigured ? 'Gemini API Configured' : 'Demo / Sample Mode',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isConfigured
                                        ? (isDark ? AppColors.darkPrimary : AppColors.primaryDark)
                                        : (isDark ? const Color(0xFFFFB24D) : const Color(0xFFD46B08)),
                                  ),
                                ),
                                Text(
                                  isConfigured
                                      ? 'Active key detected. Live vision & study features ready.'
                                      : 'No API key provided. Using built-in sample guides.',
                                  style: TextStyle(fontSize: 12, color: AppColors.textSecondaryOf(context)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.key_rounded, size: 18),
                          label: Text(isConfigured ? 'Change / Manage API Key' : 'Enter Gemini API Key'),
                          onPressed: _showApiKeyDialog,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Section 5: Cloud Sync & Backup (Appwrite)
              _sectionHeader('Cloud Sync & Backup'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Consumer(
                    builder: (context, ref, _) {
                      final appwriteService = ref.watch(appwriteServiceProvider);
                      return ValueListenableBuilder(
                        valueListenable: appwriteService.userNotifier,
                        builder: (context, user, _) {
                          final isSignedIn = user != null;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: isSignedIn
                                          ? (isDark ? AppColors.darkPrimaryContainer : AppColors.primaryContainer)
                                          : (isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      isSignedIn ? Icons.cloud_done_rounded : Icons.cloud_outlined,
                                      color: isSignedIn
                                          ? (isDark ? AppColors.darkPrimary : AppColors.primaryDark)
                                          : AppColors.textSecondaryOf(context),
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          isSignedIn
                                              ? (user.name.isNotEmpty ? user.name : 'Account Connected')
                                              : 'Cloud Backup & Sync',
                                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          isSignedIn
                                              ? user.email
                                              : 'Sign in with Google to sync across family devices.',
                                          style: TextStyle(
                                            color: AppColors.textSecondaryOf(context),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isSignedIn)
                                    ValueListenableBuilder<SyncState>(
                                      valueListenable: appwriteService.syncStateNotifier,
                                      builder: (context, syncState, _) {
                                        if (syncState == SyncState.syncing) {
                                          return const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(strokeWidth: 2),
                                          );
                                        }
                                        return IconButton(
                                          icon: const Icon(Icons.sync_rounded),
                                          tooltip: 'Sync Now',
                                          onPressed: _performManualSync,
                                        );
                                      },
                                    ),
                                ],
                              ),
                              if (isSignedIn) ...[
                                const SizedBox(height: 14),
                                ValueListenableBuilder<String?>(
                                  valueListenable: appwriteService.syncMessageNotifier,
                                  builder: (context, syncMsg, _) {
                                    if (syncMsg == null || syncMsg.isEmpty) {
                                      return const SizedBox.shrink();
                                    }
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 12),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.info_outline_rounded, size: 14, color: AppColors.accentGold),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              syncMsg,
                                              style: TextStyle(fontSize: 12, color: AppColors.textSecondaryOf(context)),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ] else
                                const SizedBox(height: 16),
                              if (!isSignedIn)
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    icon: const Icon(Icons.login_rounded, size: 18),
                                    label: const Text('Sign in with Google'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isDark ? AppColors.darkPrimary : AppColors.primary,
                                      foregroundColor: Colors.white,
                                    ),
                                    onPressed: _signInGoogle,
                                  ),
                                )
                              else ...[
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton.icon(
                                    icon: const Icon(Icons.cloud_sync_rounded, size: 18),
                                    label: const Text('Sync with Cloud Now'),
                                    onPressed: _performManualSync,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton.icon(
                                    icon: const Icon(Icons.logout_rounded, size: 16),
                                    label: const Text('Sign Out'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppColors.error,
                                    ),
                                    onPressed: () async {
                                      await appwriteService.signOut();
                                    },
                                  ),
                                ),
                              ],
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Section 6: Data & Storage Management
              _sectionHeader('Data & Storage'),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.file_download_rounded, color: isDark ? AppColors.darkPrimary : AppColors.primary),
                      title: const Text('Export Reading History'),
                      subtitle: Text('Copy reading log and notes as text', style: TextStyle(color: AppColors.textSecondaryOf(context))),
                      onTap: _exportReadingHistory,
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: Icon(Icons.cleaning_services_rounded, color: isDark ? AppColors.darkSecondary : AppColors.secondary),
                      title: const Text('Clear Cached Explanations'),
                      subtitle: Text('Free up local storage space', style: TextStyle(color: AppColors.textSecondaryOf(context))),
                      onTap: _clearCachedExplanations,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Section 6: Privacy & Personal Use
              _sectionHeader('Privacy & Data Handling'),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCardBg : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.lock_outline_rounded, color: isDark ? AppColors.darkPrimary : AppColors.primary, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Private Personal Application',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.primaryDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '• Your reading history, calendars, bookmarks, and personal notes are stored strictly locally on this device in SQLite.\n'
                      '• No accounts, passwords, analytics, or trackers are used.\n'
                      '• When you upload a page or request an explanation, only that specific image or passage text is sent to Google\'s Gemini API for processing.\n'
                      '• AI explanations are educational study aids and not formal Islamic rulings (fatwas).',
                      style: TextStyle(fontSize: 13, height: 1.5, color: AppColors.textSecondaryOf(context)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _themeOption({
    required ThemeMode mode,
    required ThemeMode currentMode,
    required IconData icon,
    required String label,
  }) {
    final isSelected = mode == currentMode;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: InkWell(
        onTap: () {
          ref.read(themeModeProvider.notifier).setThemeMode(mode);
        },
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? AppColors.darkPrimaryContainer : AppColors.primaryContainer)
                : (isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? (isDark ? AppColors.darkPrimary : AppColors.primary)
                  : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected
                    ? (isDark ? AppColors.darkOnPrimaryContainer : AppColors.primaryDark)
                    : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                size: 22,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected
                      ? (isDark ? AppColors.darkOnPrimaryContainer : AppColors.primaryDark)
                      : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: isDark ? AppColors.darkPrimary : AppColors.primaryDark,
        ),
      ),
    );
  }

  Widget _textSizeChip(String label, double scale, double currentScale) {
    final isSelected = (currentScale - scale).abs() < 0.05;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ChoiceChip(
      selected: isSelected,
      label: Text(label, style: const TextStyle(fontSize: 12)),
      selectedColor: isDark ? AppColors.darkPrimaryContainer : AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected
            ? (isDark ? AppColors.darkOnPrimaryContainer : Colors.white)
            : AppColors.textPrimaryOf(context),
        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
      ),
      backgroundColor: isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant,
      side: BorderSide(
        color: isSelected
            ? (isDark ? AppColors.darkPrimary : AppColors.primary)
            : (isDark ? AppColors.darkBorder : AppColors.border),
      ),
      onSelected: (_) {
        ref.read(textScaleProvider.notifier).setScale(scale);
      },
    );
  }
}
