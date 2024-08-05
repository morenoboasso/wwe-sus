import 'package:flutter/material.dart';
import '../../types/ppv_options.dart';

class PPVDropdown extends StatelessWidget {
  final String? selectedPPV;
  final ValueChanged<String?> onChanged;

  const PPVDropdown({
    required this.selectedPPV,
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      hint: const Text('Scegli un PPV'),
      value: selectedPPV,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
      ),
      items: ppvOptions.map((ppv) {
        return DropdownMenuItem(
          value: ppv,
          child: Text(ppv),
        );
      }).toList(),
      onChanged: onChanged,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Seleziona il PPV.';
        }
        return null;
      },
    );
  }
}
