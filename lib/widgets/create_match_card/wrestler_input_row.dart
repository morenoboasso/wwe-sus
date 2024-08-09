import 'package:flutter/material.dart';
import 'package:wwe_bets/style/color_style.dart';

class WrestlerInputRow extends StatelessWidget {
  final int index1;
  final int index2;
  final List<String> wrestlers;
  final void Function(int, String) onWrestlerChanged;
  final void Function(int) onRemoveWrestler;
  final VoidCallback addWrestlerCallback;
  final bool canAddWrestler;

  const WrestlerInputRow({
    required this.index1,
    required this.index2,
    required this.wrestlers,
    required this.onWrestlerChanged,
    required this.onRemoveWrestler,
    required this.addWrestlerCallback,
    required this.canAddWrestler,
    super.key,
  });

  InputDecoration _inputDecoration() {
    return InputDecoration(
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
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                initialValue: index1 < wrestlers.length ? wrestlers[index1] : '',
                onChanged: (value) => onWrestlerChanged(index1, value),
                validator: (index1 < 2)
                    ? (value) {
                  if (value == null || value.isEmpty) {
                    return 'Inserisci wrestler.';
                  }
                  return null;
                }
                    : null,
                decoration: _inputDecoration(),
              ),
            ),
            if (index2 < wrestlers.length) ...[
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  initialValue: wrestlers[index2],
                  onChanged: (value) => onWrestlerChanged(index2, value),
                  validator: (index2 < 2)
                      ? (value) {
                    if (value == null || value.isEmpty) {
                      return 'Inserisci wrestler.';
                    }
                    return null;
                  }
                      : null,
                  decoration: _inputDecoration(),
                ),
              ),
            ],
            if (wrestlers.length > 2) ...[
              IconButton(
                icon: const Icon(Icons.remove_circle, color: ColorsBets.whiteHD),
                onPressed: () => onRemoveWrestler(index1 < wrestlers.length ? index1 : index2),
              ),
            ],
          ],
        ),
        if (canAddWrestler)
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, // Text color
                backgroundColor: Colors.transparent, // Fill color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5), // Less rounded corners
                  side: const BorderSide(color: Colors.white,width: 2), // White border
                ),
                elevation: 5, // Shadow
              ),
              onPressed: addWrestlerCallback,
              child: const Text('Aggiungi Wrestler'),
            ),
          ),
      ],
    );
  }
}
