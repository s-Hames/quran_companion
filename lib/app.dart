import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'features/bookmarks/bookmarks_screen.dart';
import 'features/home/home_screen.dart';
import 'features/journey/journey_screen.dart';
import 'features/settings/settings_screen.dart';
import 'providers/app_providers.dart';
import 'services/appwrite_service.dart';

class QuranCompanionApp extends ConsumerWidget {
  final ThemeData? theme;
  final ThemeData? darkTheme;
  final ThemeMode? themeMode;

  const QuranCompanionApp({
    super.key,
    this.theme,
    this.darkTheme,
    this.themeMode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeThemeMode = themeMode ?? ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'Quran Companion',
      theme: theme ?? AppTheme.lightTheme,
      darkTheme: darkTheme ?? AppTheme.darkTheme,
      themeMode: activeThemeMode,
      debugShowCheckedModeBanner: false,
      home: const MainNavigationShell(),
    );
  }
}

class MainNavigationShell extends ConsumerStatefulWidget {
  const MainNavigationShell({super.key});

  @override
  ConsumerState<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends ConsumerState<MainNavigationShell> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appwrite = ref.read(appwriteServiceProvider);
      appwrite.syncStateNotifier.addListener(_onSyncStateChanged);
    });
  }

  void _onSyncStateChanged() {
    final appwrite = ref.read(appwriteServiceProvider);
    if (appwrite.syncStateNotifier.value == SyncState.success) {
      ref.read(sessionRefreshProvider.notifier).trigger();
      ref.read(profilesListProvider.notifier).loadProfiles();
    }
  }

  @override
  void dispose() {
    try {
      ref.read(appwriteServiceProvider).syncStateNotifier.removeListener(_onSyncStateChanged);
    } catch (_) {}
    super.dispose();
  }

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(onNavigateTab: _onTabSelected),
      const JourneyScreen(),
      const BookmarksScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onTabSelected,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month_rounded),
            label: 'My Journey',
          ),
          NavigationDestination(
            icon: Icon(Icons.bookmark_outline_rounded),
            selectedIcon: Icon(Icons.bookmark_rounded),
            label: 'Bookmarks',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings_rounded),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
