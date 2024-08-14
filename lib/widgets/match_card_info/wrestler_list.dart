import 'package:flutter/material.dart';

import '../../style/text_style.dart';

class WrestlerList extends StatelessWidget {
  final List<String> wrestlers;

  const WrestlerList({
    required this.wrestlers,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Partecipanti:',
          style: MemoText.secondRowMatchInfo,
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: wrestlers
                  .take((wrestlers.length / 2).ceil())
                  .map((wrestler) => Text('• $wrestler', style: MemoText.thirdRowMatchInfo))
                  .toList(),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: wrestlers
                  .skip((wrestlers.length / 2).ceil())
                  .map((wrestler) => Text('• $wrestler', style: MemoText.thirdRowMatchInfo))
                  .toList(),
            ),
          ],
        ),
      ],
    );
  }
}
