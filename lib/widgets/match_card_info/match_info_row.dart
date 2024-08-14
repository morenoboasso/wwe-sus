import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart'; // Aggiungi questa importazione
import '../../style/text_style.dart';

class MatchInfoRow extends StatelessWidget {
  final String title;
  final String type;

  const MatchInfoRow({
    required this.title,
    required this.type,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    bool isTitleEmpty = title.isEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: isTitleEmpty ? MainAxisAlignment.center : MainAxisAlignment.spaceBetween,
        children: [
          if (!isTitleEmpty)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  AutoSizeText(
                    'Titolo:',
                    style: MemoText.secondRowMatchInfo.copyWith(color: Colors.white),
                    minFontSize: 14,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.0),
                  AutoSizeText(
                    title,
                    style: MemoText.thirdRowMatchInfo,
                    minFontSize: 14,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AutoSizeText(
                  'Match:',
                  style: MemoText.secondRowMatchInfo,
                  minFontSize: 14,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.0),
                AutoSizeText(
                  type,
                  style: MemoText.thirdRowMatchInfo,
                  minFontSize: 14,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
