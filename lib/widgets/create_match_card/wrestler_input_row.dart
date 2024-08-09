import 'package:flutter/material.dart';
import 'package:wwe_bets/style/color_style.dart';
import 'package:wwe_bets/style/text_style.dart';

import '../common/input_decoration.dart';

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
                  if (value == null || value.trim().isEmpty) {
                    return 'Inserisci wrestler.';
                  }
                  return null;
                }
                    : null,
                decoration: InputDecorations.standard(),
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
                  decoration: InputDecorations.standard(),
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
                foregroundColor: Colors.white,
                backgroundColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                  side: const BorderSide(color: Colors.white, width: 2),
                ),
                elevation: 5,
              ),
              onPressed: addWrestlerCallback,
              child: Text(
                'Aggiungi Wrestler',
                style: MemoText.addWrestlerButton,
              ),
            ),
          ),
      ],
    );
  }
}
