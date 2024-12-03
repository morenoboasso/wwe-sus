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
        Wrap(
          spacing: 20.0,
          children: wrestlers
              .map((wrestler) => Text(
              '• $wrestler',
              style: MemoText.thirdRowMatchInfo,
              overflow: TextOverflow.fade,
          ))
              .toList(),
        ),
      ],
    );
  }
}
