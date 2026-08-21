import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/blog_post.dart';
import '../models/content_category.dart';
import '../models/user_profile.dart';
import '../services/auth_service.dart';
import '../services/blog_service.dart';
import '../services/profile_service.dart';
import '../state/theme_controller.dart';
import '../theme/app_theme.dart';
import '../theme/strings_sw.dart';
import '../widgets/bold_text.dart';
import 'chat_screen.dart';
import 'appointments_screen.dart';
import 'library_screen.dart';
import 'profile_view_screen.dart';
import 'settings_screen.dart';
import 'setup_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  UserProfile? _profile;
  List<BlogPost> _posts = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() => _loading = true);
    final profile = await ProfileService.getProfile();
    final posts = BlogService.getPosts();
    if (mounted) {
      setState(() {
        _profile = profile;
        _posts = posts;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeController = context.watch<ThemeController>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryTextColor = isDark ? Colors.white : Colors.black87;
    final secondaryTextColor = isDark ? Colors.white70 : Colors.black54;
    final accentColor = isDark ? AppTheme.accentPink : AppTheme.primaryPurple;

    return Scaffold(
      drawer: const _AppDrawer(),
      appBar: AppBar(
        title: const Text(StringsSw.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline),
            tooltip: StringsSw.chatCardTitle,
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatScreen())),
          ),
          IconButton(
            icon: Icon(themeController.isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
            onPressed: () => themeController.toggle(),
          ),
        ],
      ),
      body: Container(
        decoration: isDark ? null : const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _loadAll,
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : ListView(
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
                      Text(StringsSw.blogSectionTitle,
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryTextColor)),
                      const SizedBox(height: 12),
                      ..._posts.map((post) => _BlogPostCard(
                            post: post,
                            primaryTextColor: primaryTextColor,
                            secondaryTextColor: secondaryTextColor,
                            accentColor: accentColor,
                          )),
                      const SizedBox(height: 24),
                      Text(StringsSw.maktabaSectionTitle,
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryTextColor)),
                      const SizedBox(height: 12),
                      _MaktabaCards(accentColor: accentColor, textColor: primaryTextColor),
                      const SizedBox(height: 16),
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
                Text(weeks == 0 ? '-' : '$weeks / 40',
                    style: TextStyle(fontWeight: FontWeight.bold, color: accentColor)),
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
  final Color accentColor;

  const _BlogPostCard({
    required this.post,
    required this.primaryTextColor,
    required this.secondaryTextColor,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_iconFor(post.category.iconName), color: accentColor, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(post.title,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: primaryTextColor)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            BoldText(post.body, style: TextStyle(fontSize: 13, color: secondaryTextColor)),
            const SizedBox(height: 6),
            Text(post.date, style: TextStyle(fontSize: 11, color: secondaryTextColor.withValues(alpha: 0.6))),
          ],
        ),
      ),
    );
  }

  IconData _iconFor(String name) {
    switch (name) {
      case 'restaurant': return Icons.restaurant_outlined;
      case 'bedtime': return Icons.bedtime_outlined;
      case 'fitness_center': return Icons.fitness_center_outlined;
      case 'health_and_safety': return Icons.health_and_safety_outlined;
      case 'family_restroom': return Icons.family_restroom_outlined;
      default: return Icons.info_outline;
    }
  }
}

class _MaktabaCards extends StatelessWidget {
  final Color accentColor;
  final Color textColor;
  const _MaktabaCards({required this.accentColor, required this.textColor});

  static const _categories = [
    ContentCategory.lishe,
    ContentCategory.usingizi,
    ContentCategory.mazoezi,
    ContentCategory.usalama,
    ContentCategory.uzaziWaMpango,
  ];

  IconData _iconFor(String name) {
    switch (name) {
      case 'restaurant': return Icons.restaurant_outlined;
      case 'bedtime': return Icons.bedtime_outlined;
      case 'fitness_center': return Icons.fitness_center_outlined;
      case 'health_and_safety': return Icons.health_and_safety_outlined;
      case 'family_restroom': return Icons.family_restroom_outlined;
      default: return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: _categories.map((category) {
        return Card(
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => LibraryScreen(initialCategory: category)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(_iconFor(category.iconName), color: accentColor, size: 28),
                  const SizedBox(height: 8),
                  Text(category.label,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: textColor)),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
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
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: Image.asset('assets/images/app_logo.webp', width: 48, height: 48, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.favorite, color: Colors.white, size: 36)),
                  ),
                  const SizedBox(width: 12),
                  const Text(StringsSw.appName,
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
              title: const Text(StringsSw.maktabaSectionTitle),
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
            ListTile(
              leading: const Icon(Icons.calendar_month_outlined),
              title: const Text(StringsSw.appointmentsCardTitle),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AppointmentsScreen()));
              },
            ),
            const Spacer(),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(StringsSw.logout, style: TextStyle(color: Colors.red)),
              onTap: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Toka'),
                    content: const Text('Una uhakika unataka kufuta akaunti yako kwenye kifaa hiki? Taarifa zako zote zitafutwa.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hapana')),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Ndio, Futa', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  await AuthService.logout();
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const SetupScreen()),
                      (route) => false,
                    );
                  }
                }
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
