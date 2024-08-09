import 'package:flutter/material.dart';

class PPVInput extends StatelessWidget {
  final String? selectedPPV;
  final ValueChanged<String?> onChanged;

  const PPVInput({
    required this.selectedPPV,
    required this.onChanged,
    super.key,
  });

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      hintStyle: const TextStyle(color: Colors.black),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.black),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.black),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.black),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: selectedPPV,
      decoration: _inputDecoration('Inserisci il PPV..'),
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
