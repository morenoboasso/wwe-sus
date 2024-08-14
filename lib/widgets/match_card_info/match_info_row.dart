import 'package:flutter/material.dart';
import '../../style/text_style.dart';

class MatchInfoRow extends StatelessWidget {
  final String title;
  final String type;
  final int? voteCount;

  const MatchInfoRow({
    required this.title,
    required this.type,
    required this.voteCount,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('Match:', style: MemoText.secondRowMatchInfo),
            Text(type, style: MemoText.thirdRowMatchInfo),
          ],
        ),
        if (title.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('Titolo in palio:', style: MemoText.secondRowMatchInfo.copyWith(color: Colors.white)),
              Text(title, style: MemoText.thirdRowMatchInfo),
            ],
          ),
        Row(
          children: [
            Text('Voti: ', style: MemoText.secondRowMatchInfo),
            Text('$voteCount/2', style: MemoText.secondRowMatchInfo),
          ],
        ),
      ],
    );
  }
}
