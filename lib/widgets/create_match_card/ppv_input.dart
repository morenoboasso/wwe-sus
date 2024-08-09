import 'package:flutter/material.dart';

import '../common/input_decoration.dart';

class PPVInput extends StatelessWidget {
  final String? selectedPPV;
  final ValueChanged<String?> onChanged;

  const PPVInput({
    required this.selectedPPV,
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: selectedPPV,
      decoration: InputDecorations.standard('Inserisci il PPV..'),
      onChanged: onChanged,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Inserisci il PPV.';
        }
        return null;
      },
    );
  }
}
