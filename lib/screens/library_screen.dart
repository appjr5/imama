import 'package:flutter/material.dart';
import '../models/content_category.dart';
import '../widgets/bold_text.dart';

class InfoArticle {
  final String title;
  final String body;
  const InfoArticle({required this.title, required this.body});
}

/// Static starter content — worth having reviewed by someone with a
/// medical background before real users see it, since this touches
/// pregnancy safety and family planning.
class LibraryContent {
  static const Map<ContentCategory, List<InfoArticle>> articles = {
    ContentCategory.lishe: [
      InfoArticle(
        title: 'Vyakula vyenye Madini ya Chuma',
        body: 'Kama unahisi uchovu au kizunguzungu mara kwa mara, huenda unahitaji madini ya chuma zaidi. '
            'Jumuisha maharage, mchicha, nyama nyekundu, na matunda makavu kwenye mlo wako.',
      ),
      InfoArticle(
        title: 'Kalisi kwa Ajili ya Mifupa',
        body: 'Mtoto anayekua anahitaji kalisi kwa ajili ya mifupa na meno. Kunywa maziwa, mtindi, na kula '
            'mboga za majani kama sukuma wiki.',
      ),
    ],
    ContentCategory.usingizi: [
      InfoArticle(
        title: 'Kulala Upande wa Kushoto',
        body: 'Kuanzia trimester ya pili, kulala upande wa kushoto husaidia damu kutiririka vizuri kwa mtoto na figo.',
      ),
      InfoArticle(
        title: 'Kupata Usingizi wa Kutosha',
        body: 'Lenga angalau saa 7-9 za usingizi kila usiku. Epuka simu dakika 30 kabla ya kulala.',
      ),
    ],
    ContentCategory.mazoezi: [
      InfoArticle(
        title: 'Kutembea kwa Dakika 20-30',
        body: 'Kutembea kwa mwendo wa taratibu kila siku husaidia mzunguko wa damu na huandaa mwili kwa kujifungua.',
      ),
      InfoArticle(
        title: 'Mazoezi ya Nyonga',
        body: 'Mazoezi haya rahisi husaidia kupunguza maumivu ya mgongo wa chini yanayotokana na ujauzito.',
      ),
    ],
    ContentCategory.usalama: [
      InfoArticle(
        title: 'Dalili za Hatari Zinazohitaji Daktari Haraka',
        body: 'Nenda hospitali mara moja ikiwa una: kutokwa damu nyingi, maumivu makali ya tumbo, kichwa kuuma sana, '
            'au mtoto kuacha kucheza tumboni.',
      ),
      InfoArticle(
        title: 'Vipimo vya Mara kwa Mara',
        body: 'Hakikisha unahudhuria kliniki ya wajawazito kama ilivyoratibiwa.',
      ),
    ],
    ContentCategory.uzaziWaMpango: [
      InfoArticle(
        title: 'Kupanga Kipindi Baada ya Kujifungua',
        body: 'Ni vizuri kuzungumza na mtoa huduma wa afya kuhusu njia za uzazi wa mpango kabla ya kujifungua.',
      ),
      InfoArticle(
        title: 'Njia Mbalimbali Zinazopatikana',
        body: 'Kuna njia za muda mfupi na za muda mrefu za uzazi wa mpango. Muulize daktari wako kuhusu chaguo bora.',
      ),
    ],
  };
}

class LibraryScreen extends StatefulWidget {
  final ContentCategory? initialCategory;
  const LibraryScreen({super.key, this.initialCategory});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> with SingleTickerProviderStateMixin {
  static const _tabs = [
    ContentCategory.lishe,
    ContentCategory.usingizi,
    ContentCategory.mazoezi,
    ContentCategory.usalama,
    ContentCategory.uzaziWaMpango,
  ];
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    final startIndex = widget.initialCategory != null ? _tabs.indexOf(widget.initialCategory!) : 0;
    _tabController = TabController(length: _tabs.length, vsync: this, initialIndex: startIndex < 0 ? 0 : startIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Maktaba'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: _tabs.map((c) => Tab(text: c.label)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _tabs.map((category) {
          final articles = LibraryContent.articles[category] ?? [];
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: articles.length,
            itemBuilder: (context, i) => _ArticleCard(article: articles[i]),
          );
        }).toList(),
      ),
    );
  }
}

class _ArticleCard extends StatelessWidget {
  final InfoArticle article;
  const _ArticleCard({required this.article});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(article.title,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: theme.colorScheme.primary)),
            const SizedBox(height: 8),
            BoldText(article.body,
                style: TextStyle(fontSize: 13, height: 1.4, color: isDark ? Colors.white70 : Colors.black87)),
          ],
        ),
      ),
    );
  }
}
