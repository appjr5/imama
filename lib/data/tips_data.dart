import '../models/blog_post.dart';
import '../models/content_category.dart';

// ~60 pre-seeded Swahili maternal health tips, shown 3 per day rotating by day-of-year.
const List<Map<String, String>> _rawTips = [
  // Lishe
  {'cat': 'lishe', 'title': 'Vyakula vyenye Asidi Foliki', 'body': 'Kula **maharage, mchicha, na nafaka zilizoimarishwa** kila siku. Asidi foliki husaidia kuzuia kasoro za ubongo wa mtoto.'},
  {'cat': 'lishe', 'title': 'Madini ya Chuma', 'body': '**Nyama nyekundu, mchicha, na dengu** ni vyanzo vizuri vya chuma. Chuma husaidia damu kubeba oksijeni kwa mtoto.'},
  {'cat': 'lishe', 'title': 'Kalisi kwa Mifupa', 'body': 'Kunywa **maziwa, mtindi, au uji wa soya** kila siku. Kalisi hujenga mifupa na meno ya mtoto anayekua.'},
  {'cat': 'lishe', 'title': 'Vitamini D', 'body': 'Kaa **juani asubuhi mapema** kwa dakika 15-20. Vitamini D husaidia mwili kufyonza kalisi vizuri.'},
  {'cat': 'lishe', 'title': 'Maji ya Kutosha', 'body': 'Kunywa **glasi 8-10 za maji** kila siku. Maji husaidia usafirishaji wa virutubisho kwa mtoto na kupunguza uvimbe.'},
  {'cat': 'lishe', 'title': 'Omega-3 kwa Ubongo', 'body': 'Kula **samaki kama tilapia au sardini** mara mbili kwa wiki. Omega-3 husaidia ukuaji wa ubongo wa mtoto.'},
  {'cat': 'lishe', 'title': 'Epuka Vyakula vya Hatari', 'body': 'Epuka **samaki wa bahari wenye zebaki nyingi, mayai ghafi, na nyama isiyopikwa vizuri**. Vinaweza kudhuru mtoto.'},
  {'cat': 'lishe', 'title': 'Matunda kila Siku', 'body': 'Kula **embe, papai iliyoiva, au ndizi** kila siku. Matunda yana vitamini muhimu kwa mama na mtoto.'},
  {'cat': 'lishe', 'title': 'Mboga za Majani', 'body': '**Sukuma wiki, spinachi, na saga** ni muhimu sana. Zina madini ya chuma, kalisi, na vitamini A.'},
  {'cat': 'lishe', 'title': 'Usile Kidogo Lakini Mara Nyingi', 'body': 'Badala ya milo **3 mikubwa**, kula milo **5-6 midogo** kwa siku. Husaidia kupunguza kichefuchefu na kutoa nguvu ya kutosha.'},
  {'cat': 'lishe', 'title': 'Virutubisho vya Ujauzito', 'body': 'Chukua **vidonge vya ujauzito** kila siku kama daktari alivyoagiza. Vinasaidia kujaza pengo la lishe.'},
  {'cat': 'lishe', 'title': 'Protini za Kutosha', 'body': 'Kula **mayai, maharage, nyama ya kuku, au samaki** kila siku. Protini hujenga tishu za mtoto anayekua.'},

  // Usingizi
  {'cat': 'usingizi', 'title': 'Lala Upande wa Kushoto', 'body': 'Kuanzia wiki ya 20, **lala upande wa kushoto**. Husaidia damu kutiririka vizuri kwenye placenta na figo.'},
  {'cat': 'usingizi', 'title': 'Mito ya Kusaidia', 'body': 'Weka **mto kati ya magoti** na mwingine chini ya tumbo. Hupunguza maumivu ya mgongo na kukusaidia kulala vizuri.'},
  {'cat': 'usingizi', 'title': 'Saa za Usingizi', 'body': 'Lenge angalau **saa 8-9 za usingizi** kila usiku. Mwili unahitaji muda wa kupumzika na kujitengeneza.'},
  {'cat': 'usingizi', 'title': 'Pumzika Mchana', 'body': '**Pumzika kwa dakika 20-30** mchana iwapo unajisikia uchovu. Usingizi mfupi hupoza akili na mwili.'},
  {'cat': 'usingizi', 'title': 'Epuka Simu Usiku', 'body': 'Zima au weka chini simu **dakika 30 kabla ya kulala**. Mwanga wa skrini unazuia mwili kuzalisha melatonin.'},
  {'cat': 'usingizi', 'title': 'Chumba Baridi na Giza', 'body': 'Lala katika chumba **chenye ubaridi kidogo na giza**. Mazingira bora ya kulala husaidia usingizi mzuri.'},
  {'cat': 'usingizi', 'title': 'Epuka Caffeine Usiku', 'body': 'Usinywe **chai, kahawa, au soda** baada ya saa 6 jioni. Caffeine inaweza kukuzuia kulala.'},
  {'cat': 'usingizi', 'title': 'Zoea Wakati Mmoja wa Kulala', 'body': '**Lala na amka wakati mmoja** kila siku. Mwili unajifunza mzunguko huu na usingizi unakuwa rahisi.'},

  // Mazoezi
  {'cat': 'mazoezi', 'title': 'Tembea kila Siku', 'body': '**Tembea kwa dakika 20-30** kwa mwendo wa taratibu kila siku. Husaidia mzunguko wa damu na huandaa mwili kwa kujifungua.'},
  {'cat': 'mazoezi', 'title': 'Mazoezi ya Kupumua', 'body': 'Fanya **mazoezi ya kupumua kwa kina** mara 10 kila asubuhi. Husaidia kupunguza msongo wa mawazo na kuleta utulivu.'},
  {'cat': 'mazoezi', 'title': 'Kuogelea', 'body': '**Kuogelea au mazoezi ndani ya maji** ni salama sana wakati wa ujauzito. Maji yanasaidia uzito na kupunguza mzigo kwenye viungo.'},
  {'cat': 'mazoezi', 'title': 'Yoga ya Ujauzito', 'body': 'Yoga iliyoundwa kwa **wajawazito** husaidia nguvu, kunyumbulika, na kupumzika. Tafuta darasa la mama wajawazito.'},
  {'cat': 'mazoezi', 'title': 'Mazoezi ya Nyonga', 'body': 'Fanya **mzunguko wa nyonga polepole** kwa dakika 5 kila siku. Hupunguza maumivu ya mgongo wa chini na kuandaa kuzaa.'},
  {'cat': 'mazoezi', 'title': 'Mazoezi ya Kegel', 'body': 'Funga **misuli ya nyonga** kwa sekunde 5, pumzika, rudia mara 10. Husaidia kupona haraka baada ya kujifungua.'},
  {'cat': 'mazoezi', 'title': 'Simama Mara kwa Mara', 'body': 'Ikiwa unakaa kwa muda mrefu, **simama na tembea dakika 5** kila saa. Huzuia uvimbe na maumivu ya mgongo.'},
  {'cat': 'mazoezi', 'title': 'Epuka Mazoezi Magumu', 'body': 'Epuka **kuruka, kugongana, au mazoezi yanayohitaji kulala chali** baada ya miezi 3. Muulize daktari wako kwa ushauri.'},

  // Usalama
  {'cat': 'usalama', 'title': 'Dalili za Kutafuta Msaada wa Haraka', 'body': 'Nenda hospitali mara moja ukipata: **kutokwa damu nyingi, maumivu makali ya tumbo, au kichwa kuuma kupita kiasi**.'},
  {'cat': 'usalama', 'title': 'Mtoto Kuacha Kucheza', 'body': 'Ikiwa **mtoto hajacheza tumboni kwa zaidi ya masaa 12**, wasiliana na daktari wako haraka. Ni ishara muhimu.'},
  {'cat': 'usalama', 'title': 'Uvimbe wa Ghafla', 'body': '**Uvimbe mkubwa wa miguu, mikono, au uso** unaweza kuwa ishara ya preeclampsia. Wasiliana na daktari mara moja.'},
  {'cat': 'usalama', 'title': 'Maono Yaliyobadilika', 'body': '**Kuona vitu vya kuchanganya, moshi, au kupoteza maono** wakati wa ujauzito ni dalili ya hatari. Tafuta msaada wa haraka.'},
  {'cat': 'usalama', 'title': 'Vipimo vya Mara kwa Mara', 'body': 'Hudhuria **kliniki ya wajawazito kama ilivyopangwa**. Vipimo vya kawaida hugundua matatizo mapema kabla hayajawa makubwa.'},
  {'cat': 'usalama', 'title': 'Dawa za Ujauzito', 'body': 'Usitumie dawa yoyote **bila ruhusa ya daktari**. Dawa nyingi zinaweza kudhuru mtoto hata zikionekana salama.'},
  {'cat': 'usalama', 'title': 'Epuka Pombe na Sigara', 'body': '**Hakuna kiasi salama cha pombe** wakati wa ujauzito. Sigara pia hudhuru mtoto — tafuta msaada wa kuacha.'},
  {'cat': 'usalama', 'title': 'Chanjo za Ujauzito', 'body': 'Pata **chanjo ya pepopunda** kama ilivyoshauriwa. Inakusaidia wewe na mtoto wako kupigana na maradhi.'},
  {'cat': 'usalama', 'title': 'Mbu na Malaria', 'body': 'Lala chini ya **chandarua chenye dawa** kila usiku. Malaria ni hatari sana wakati wa ujauzito.'},
  {'cat': 'usalama', 'title': 'Mimba ya Nje ya Tumbo', 'body': 'Maumivu makali ya tumbo katika **miezi 2-3 ya kwanza** yanaweza kuwa ishara ya mimba ya nje. Nenda hospitali mara moja.'},
  {'cat': 'usalama', 'title': 'Hali ya Hewa ya Moto', 'body': 'Epuka kukaa **kwenye jua kali kwa muda mrefu**. Joto kupita kiasi linaweza kusababisha kizunguzungu na kupoteza maji.'},

  // Uzazi wa Mpango
  {'cat': 'uzaziWaMpango', 'title': 'Zungumza na Daktari Mapema', 'body': 'Ni vizuri kuzungumza na daktari kuhusu **uzazi wa mpango kabla ya kujifungua**. Mwili unahitaji muda wa kupumzika.'},
  {'cat': 'uzaziWaMpango', 'title': 'Kipindi cha Kupumzika', 'body': 'Wataalamu wanashauri **miaka 2-3 kati ya mimba**. Hii humpa mwili wako muda wa kurejea nguvu kamili.'},
  {'cat': 'uzaziWaMpango', 'title': 'Njia za Muda Mfupi', 'body': 'Kondomu, vidonge, na sindano ni **njia za muda mfupi** za uzazi wa mpango. Kila moja ina faida na hasara zake.'},
  {'cat': 'uzaziWaMpango', 'title': 'Njia za Muda Mrefu', 'body': 'IUD (kifaa cha ndani ya mji wa uzazi) na implant ni **njia za muda mrefu** zinazoweza kudumu miaka 3-10.'},
  {'cat': 'uzaziWaMpango', 'title': 'Kunyonyesha na Uzazi wa Mpango', 'body': '**Kunyonyesha peke yake hakuhakikishi uzazi wa mpango**. Tumia njia nyingine kwa usalama zaidi.'},
  {'cat': 'uzaziWaMpango', 'title': 'Umuhimu wa Muungano wa Familia', 'body': 'Zungumza na **mwenzi wako** kuhusu mipango ya familia. Maamuzi mazuri yanafanywa pamoja.'},

  // Jumla (general tips)
  {'cat': 'jumla', 'title': 'Pumzika Akili Yako', 'body': 'Msongo wa mawazo una athari kwa mtoto. **Fanya shughuli unazozipenda** kila siku — soma, sikiliza muziki, au zungumza na rafiki.'},
  {'cat': 'jumla', 'title': 'Kikundi cha Wajawazito', 'body': 'Jiunge na **kikundi cha mama wajawazito** katika kliniki yako. Kushiriki uzoefu husaidia kupunguza wasiwasi.'},
  {'cat': 'jumla', 'title': 'Mazingira ya Nyumbani', 'body': 'Epuka **vifaa vya kusafishia vyenye sumu**, rangi za gari, au mafuta ya dawa. Vitu hivi vinaweza kudhuru mtoto.'},
  {'cat': 'jumla', 'title': 'Usafiri Salama', 'body': 'Wakati wa safari ndefu, **simama kila masaa 2** na tembea kidogo. Huzuia uvimbe wa miguu na mgando wa damu.'},
  {'cat': 'jumla', 'title': 'Maandalizi ya Kujifungua', 'body': 'Andaa **mfuko wa hospitali** mapema — nguo za mtoto, kitambaa, na vitu vyako. Kujua uko tayari hupunguza wasiwasi.'},
  {'cat': 'jumla', 'title': 'Nguvu za Kiakili', 'body': 'Ni kawaida kuhisi **wasiwasi au huzuni** wakati wa ujauzito. Ongea na mtu unayemwamini au muulize daktari msaada.'},
  {'cat': 'jumla', 'title': 'Msaada wa Familia', 'body': '**Omba msaada** unapohitajika. Familia na marafiki wanaweza kusaidia kwa kazi za nyumbani ili upate kupumzika.'},
  {'cat': 'jumla', 'title': 'Usafishaji wa Meno', 'body': 'Ujauzito unaweza kusababisha **ufizi kutokwa damu**. Safisha meno mara mbili kwa siku na tembelea daktari wa meno.'},
  {'cat': 'jumla', 'title': 'Kuvaa Vizuri', 'body': 'Vaa **nguo zilizo na nafasi** na viatu vya chini. Nguo zinazobana zinaweza kuzuia mzunguko wa damu na kukufanya usijisikie vizuri.'},
  {'cat': 'jumla', 'title': 'Mapigo ya Moyo wa Mtoto', 'body': 'Kupata kusikia **mapigo ya moyo wa mtoto** katika vipimo vya kliniki ni furaha na ushahidi wa afya njema.'},
  {'cat': 'jumla', 'title': 'Ripoti Mabadiliko Yoyote', 'body': '**Hakuna kitu kidogo mno** cha kuripoti kwa daktari wako. Wewe ndiye unayemjua mwili wako vizuri zaidi.'},
];

class TipsData {
  static List<BlogPost> getTodaysTips({int count = 3}) {
    final dayOfYear = _dayOfYear(DateTime.now());
    final start = (dayOfYear * count) % _rawTips.length;
    final tips = <BlogPost>[];
    for (int i = 0; i < count; i++) {
      final raw = _rawTips[(start + i) % _rawTips.length];
      final cat = ContentCategory.values.firstWhere(
        (c) => c.name == raw['cat'],
        orElse: () => ContentCategory.jumla,
      );
      tips.add(BlogPost(
        date: _formatDate(DateTime.now()),
        title: raw['title']!,
        body: raw['body']!,
        category: cat,
      ));
    }
    return tips;
  }

  static int _dayOfYear(DateTime d) {
    return d.difference(DateTime(d.year, 1, 1)).inDays;
  }

  static String _formatDate(DateTime d) {
    const months = [
      '', 'Januari', 'Februari', 'Machi', 'Aprili', 'Mei', 'Juni',
      'Julai', 'Agosti', 'Septemba', 'Oktoba', 'Novemba', 'Desemba',
    ];
    return '${d.day} ${months[d.month]} ${d.year}';
  }
}
