// lib/widgets/create_match_card/title_checkbox.dart
import 'package:flutter/material.dart';

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
      mainAxisAlignment: MainAxisAlignment.spaceBetween, // Distribuisce lo spazio tra i widget
      children: [
        const Text('Titolo in palio'), // Etichetta a sinistra
        Checkbox(
          value: isChecked,
          onChanged: onChanged,
        ), // Checkbox a destra
      ],
    );
  }
}
