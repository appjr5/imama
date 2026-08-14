import 'package:flutter/material.dart';
import '../models/content_category.dart';
import '../widgets/bold_text.dart';

class InfoArticle {
  final String title;
  final String body;
  const InfoArticle({required this.title, required this.body});
}

/// Starter content — written statically rather than model-generated,
/// since this is health-adjacent info (nutrition/safety/family planning)
/// that's worth having reviewed by a professional before shipping.
/// Treat this as a scaffold: edit/expand freely, and consider having
/// someone with a medical background review it before release.
class LibraryContent {
  static const Map<ContentCategory, List<InfoArticle>> articles = {
    ContentCategory.lishe: [
      InfoArticle(
        title: 'Vyakula vyenye Madini ya Chuma',
        body: 'Kama unahisi uchovu au kizunguzungu mara kwa mara, huenda '
            'unahitaji madini ya chuma zaidi. Jumuisha maharage, mchicha, '
            'nyama nyekundu, na matunda makavu kwenye mlo wako. Kunywa '
            'maji ya machungwa pamoja na chakula chenye chuma husaidia '
            'mwili kunyonya madini hayo vizuri zaidi.',
      ),
      InfoArticle(
        title: 'Kalisi kwa Ajili ya Mifupa',
        body: 'Mtoto anayekua anahitaji kalisi kwa ajili ya mifupa na meno. '
            'Kunywa maziwa, mtindi, na kula mboga za majani kama sukuma '
            'wiki husaidia kutosheleza mahitaji haya bila dawa za ziada.',
      ),
    ],
    ContentCategory.usingizi: [
      InfoArticle(
        title: 'Kulala Upande wa Kushoto',
        body: 'Kuanzia trimester ya pili, kulala upande wa kushoto husaidia '
            'damu kutiririka vizuri kwa mtoto na figo. Tumia mto kati ya '
            'magoti kwa faraja zaidi.',
      ),
      InfoArticle(
        title: 'Kupata Usingizi wa Kutosha',
        body: 'Lenga angalau saa 7-9 za usingizi kila usiku. Epuka simu au '
            'runinga dakika 30 kabla ya kulala, na jaribu ratiba ya kulala '
            'na kuamka wakati uleule kila siku.',
      ),
    ],
    ContentCategory.mazoezi: [
      InfoArticle(
        title: 'Kutembea kwa Dakika 20-30',
        body: 'Kutembea kwa mwendo wa taratibu kila siku husaidia mzunguko '
            'wa damu, hupunguza msongo, na huandaa mwili kwa kujifungua. '
            'Simama na pumzika ikiwa unahisi uchovu au kupumua kwa shida.',
      ),
      InfoArticle(
        title: 'Mazoezi ya Nyonga (Pelvic Tilts)',
        body: 'Mazoezi haya rahisi husaidia kupunguza maumivu ya mgongo wa '
            'chini yanayotokana na ujauzito. Fanya kwa uangalifu na acha '
            'ikiwa unahisi maumivu makali.',
      ),
    ],
    ContentCategory.usalama: [
      InfoArticle(
        title: 'Dalili za Hatari Zinazohitaji Daktari Haraka',
        body: 'Nenda hospitali mara moja ikiwa una: kutokwa damu nyingi, '
            'maumivu makali ya tumbo, kichwa kuuma sana bila kupona, '
            'kuvimba ghafla kwa uso au mikono, au mtoto kuacha kucheza '
            'tumboni. Usisubiri — afya yako na ya mtoto ni muhimu zaidi.',
      ),
      InfoArticle(
        title: 'Vipimo vya Mara kwa Mara',
        body: 'Hakikisha unahudhuria kliniki ya wajawazito kama ilivyoratibiwa '
            'ili kufuatilia shinikizo la damu, uzito, na maendeleo ya mtoto.',
      ),
    ],
    ContentCategory.uzaziWaMpango: [
      InfoArticle(
        title: 'Kupanga Kipindi Baada ya Kujifungua',
        body: 'Ni vizuri kuzungumza na mtoa huduma wa afya kuhusu njia za '
            'uzazi wa mpango kabla ya kujifungua, ili uwe na taarifa sahihi '
            'za kuchagua njia inayofaa mwili wako baada ya kujifungua.',
      ),
      InfoArticle(
        title: 'Njia Mbalimbali Zinazopatikana',
        body: 'Kuna njia za muda mfupi na za muda mrefu za uzazi wa mpango. '
            'Muulize daktari wako kuhusu chaguo zinazofaa hali yako ya '
            'kiafya na malengo yako ya familia.',
      ),
    ],
  };
}

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  static const _tabs = [
    ContentCategory.lishe,
    ContentCategory.usingizi,
    ContentCategory.mazoezi,
    ContentCategory.usalama,
    ContentCategory.uzaziWaMpango,
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Maktaba'),
          bottom: TabBar(
            isScrollable: true,
            tabs: _tabs.map((c) => Tab(text: c.label)).toList(),
          ),
        ),
        body: TabBarView(
          children: _tabs.map((category) {
            final articles = LibraryContent.articles[category] ?? [];
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: articles.length,
              itemBuilder: (context, i) => _ArticleCard(article: articles[i]),
            );
          }).toList(),
        ),
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
            Text(
              article.title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            BoldText(
              article.body,
              style: TextStyle(
                fontSize: 13,
                height: 1.4,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
