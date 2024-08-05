import 'package:flutter/material.dart';

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
      decoration: const InputDecoration(
        hintText: 'Inserisci il PPV..',
        border: OutlineInputBorder(),
      ),
      onChanged: onChanged,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Inserisci il PPV.';
        }
        return null;
      },
    );
  }
}
