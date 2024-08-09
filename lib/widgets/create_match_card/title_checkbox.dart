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
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Titolo in palio',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        Checkbox(
          hoverColor: Colors.transparent,
          activeColor: Colors.transparent,
          value: isChecked,
          onChanged: onChanged,
          checkColor: Colors.black,
          fillColor: WidgetStateProperty.all(Colors.white),
        ), // Checkbox a destra
      ],
    );
  }
}
