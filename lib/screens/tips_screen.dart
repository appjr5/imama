import 'package:flutter/material.dart';
import '../theme/strings_sw.dart';

class TipsScreen extends StatelessWidget {
  const TipsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tips = [
      'Kunywa maji ya kutosha kila siku.',
      'Hakikisha unapata madini ya chuma na foliki asidi.',
      'Fanya mazoezi mepesi kama kutembea.',
      'Pumzika vya kutosha na epuka mkazo.',
    ];

    return Scaffold(
      appBar: AppBar(title: const Text(StringsSw.tipsCardTitle)),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: tips.length,
        itemBuilder: (context, i) => Card(
          child: ListTile(
            leading: const Icon(Icons.check_circle_outline),
            title: Text(tips[i]),
          ),
        ),
      ),
    );
  }
}
