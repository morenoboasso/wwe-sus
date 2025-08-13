import 'package:flutter/material.dart';
import 'package:wwe_bets/style/text_style.dart';

class TitleCheckbox extends StatelessWidget {
  final bool isChecked;
  final ValueChanged<bool?> onChanged;

  const TitleCheckbox({
    required this.isChecked,
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Titolo in palio',
          style: MemoText.createInputMainText,
        ),
        Checkbox(
          hoverColor: Colors.transparent,
          activeColor: Colors.transparent,
          value: isChecked,
          onChanged: onChanged,
          checkColor: Colors.black,
          fillColor: MaterialStateProperty.all(Colors.white),
        ),
      ],
    );
  }
}
