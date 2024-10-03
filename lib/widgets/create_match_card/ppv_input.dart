import 'package:flutter/material.dart';
import '../common/input_decoration.dart';

class PPVInput extends StatelessWidget {
  final TextEditingController ppvController;

  const PPVInput({
    required this.ppvController,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: ppvController,
      decoration: InputDecorations.standard('Inserisci il PPV..'),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Inserisci il PPV.';
        }
        return null;
      },
    );
  }
}
