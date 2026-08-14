import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/blog_post.dart';
import '../models/user_profile.dart';
import '../services/blog_service.dart';
import '../services/settings_service.dart';
import '../state/theme_controller.dart';
import '../theme/app_theme.dart';
import '../theme/strings_sw.dart';
import '../widgets/bold_text.dart';
import 'chat_screen.dart';
import 'appointments_screen.dart';
import 'tips_screen.dart';
import 'profile_view_screen.dart';
import 'settings_screen.dart';
import 'library_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  UserProfile? _profile;
  List<BlogPost> _posts = [];
  bool _loadingPosts = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadPosts();
  }

  Future<void> _loadProfile() async {
    final profile = await SettingsService.getProfile();
    if (mounted) setState(() => _profile = profile);
  }

  Future<void> _loadPosts() async {
    setState(() => _loadingPosts = true);
    final posts = await BlogService.getPosts();
    if (mounted) {
      setState(() {
        _posts = posts;
        _loadingPosts = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeController = context.watch<ThemeController>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    // Dark-mode-safe text colors — falls back to sensible defaults
    // instead of the hardcoded black shades that vanish on a dark bg.
    final primaryTextColor = isDark ? Colors.white : Colors.black87;
    final secondaryTextColor = isDark ? Colors.white70 : Colors.black54;
    final mutedTextColor = isDark ? Colors.white38 : Colors.black38;
    final accentColor = isDark ? AppTheme.accentPink : AppTheme.primaryPurple;

    return Scaffold(
      drawer: const _AppDrawer(),
      appBar: AppBar(
        title: const Text(StringsSw.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline),
            tooltip: StringsSw.chatCardTitle,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ChatScreen()),
            ),
          ),
          IconButton(
            icon: Icon(themeController.isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
            tooltip: 'Dark mode',
            onPressed: () => themeController.toggle(),
          ),
        ],
      ),
      body: Container(
        decoration: isDark ? null : const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              await _loadProfile();
              await _loadPosts();
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  '${StringsSw.homeGreeting}${_profile?.name.isNotEmpty == true ? ', ${_profile!.name}' : ''}!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: primaryTextColor),
                ),
                Text(StringsSw.homeSubtitle, style: TextStyle(color: secondaryTextColor)),
                const SizedBox(height: 16),
                _PregnancyWeekCard(
                  weeks: _profile?.pregnancyWeeks ?? 0,
                  accentColor: accentColor,
                  textColor: primaryTextColor,
                ),
                const SizedBox(height: 24),
                Text(
                  StringsSw.blogSectionTitle,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryTextColor),
                ),
                const SizedBox(height: 12),
                if (_loadingPosts)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_posts.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text('Hakuna vidokezo kwa sasa.', style: TextStyle(color: secondaryTextColor)),
                  )
                else
                  ..._posts.map((post) => _BlogPostCard(
                        post: post,
                        primaryTextColor: primaryTextColor,
                        secondaryTextColor: secondaryTextColor,
                        mutedTextColor: mutedTextColor,
                        accentColor: accentColor,
                      )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PregnancyWeekCard extends StatelessWidget {
  final int weeks;
  final Color accentColor;
  final Color textColor;
  const _PregnancyWeekCard({required this.weeks, required this.accentColor, required this.textColor});

  @override
  Widget build(BuildContext context) {
    final progress = (weeks.clamp(0, 40)) / 40.0;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(StringsSw.weekProgressLabel,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: textColor)),
                Text(
                  weeks == 0 ? '-' : '$weeks / 40',
                  style: TextStyle(fontWeight: FontWeight.bold, color: accentColor),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: accentColor.withValues(alpha: 0.2),
                color: accentColor,
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TipsScreen()),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(StringsSw.more, style: TextStyle(color: accentColor)),
                    Icon(Icons.chevron_right, size: 18, color: accentColor),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BlogPostCard extends StatelessWidget {
  final BlogPost post;
  final Color primaryTextColor;
  final Color secondaryTextColor;
  final Color mutedTextColor;
  final Color accentColor;

  const _BlogPostCard({
    required this.post,
    required this.primaryTextColor,
    required this.secondaryTextColor,
    required this.mutedTextColor,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Local asset only — no network image loading. Falls back to
          // a plain icon block if the file hasn't been added yet, so a
          // missing photo never crashes the UI.
          Image.asset(
            post.category.assetPath,
            height: 120,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              height: 120,
              color: accentColor.withValues(alpha: 0.15),
              child: Icon(_iconFor(post.category.iconName), color: accentColor, size: 36),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(post.title,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: primaryTextColor)),
                const SizedBox(height: 8),
                BoldText(post.body, style: TextStyle(fontSize: 13, color: secondaryTextColor)),
                const SizedBox(height: 8),
                Text(post.date, style: TextStyle(fontSize: 11, color: mutedTextColor)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconFor(String name) {
    switch (name) {
      case 'restaurant':
        return Icons.restaurant_outlined;
      case 'bedtime':
        return Icons.bedtime_outlined;
      case 'fitness_center':
        return Icons.fitness_center_outlined;
      case 'health_and_safety':
        return Icons.health_and_safety_outlined;
      case 'family_restroom':
        return Icons.family_restroom_outlined;
      default:
        return Icons.info_outline;
    }
  }
}

class _AppDrawer extends StatelessWidget {
  const _AppDrawer();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.favorite, color: Colors.white, size: 32),
                  SizedBox(height: 8),
                  Text(StringsSw.appName,
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text(StringsSw.profileCardTitle),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileViewScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.menu_book_outlined),
              title: const Text('Maktaba'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const LibraryScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text(StringsSw.settingsTitle),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.calendar_month_outlined),
              title: const Text(StringsSw.appointmentsCardTitle),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AppointmentsScreen()));
              },
            ),
          ],
        ),
      ),
    );
  }
}
