// lib/widgets/create_match_card/wrestler_input_row.dart
import 'package:flutter/material.dart';

class WrestlerInputRow extends StatelessWidget {
  final int index1;
  final int index2;
  final List<String> wrestlers;
  final void Function(int, String) onWrestlerChanged; // Cambia il tipo qui
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
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                initialValue: index1 < wrestlers.length
                    ? wrestlers[index1]
                    : '',
                onChanged: (value) => onWrestlerChanged(index1, value),
                validator: (index1 < 2)
                    ? (value) {
                  if (value == null || value.isEmpty) {
                    return 'Inserisci wrestler.';
                  }
                  return null;
                }
                    : null,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black, width: 1),
                  ),
                ),
              ),
            ),
            if (index2 < wrestlers.length) ...[
              SizedBox(width: 16),
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
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black, width: 1),
                    ),
                  ),
                ),
              ),
            ],
            if (wrestlers.length > 2) ...[
              IconButton(
                icon: Icon(Icons.remove_circle),
                onPressed: () => onRemoveWrestler(index1 < wrestlers.length ? index1 : index2),
              ),
            ],
          ],
        ),
        if (canAddWrestler)
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: ElevatedButton(
              onPressed: addWrestlerCallback,
              child: Text('Aggiungi Wrestler'),
            ),
          ),
      ],
    );
  }
}
