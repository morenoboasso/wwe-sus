import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:wwe_bets/style/color_style.dart';
import 'package:wwe_bets/style/text_style.dart';

import '../common/input_decoration.dart';

class WrestlerInputRow extends StatelessWidget {
  final int index1;
  final int index2;
  final TextEditingController controller1;
  final TextEditingController? controller2;
  final List<String> wrestlers;
  final void Function(int, String) onWrestlerChanged;
  final void Function(int) onRemoveWrestler;
  final VoidCallback addWrestlerCallback;
  final Future<List<String>> Function(String) suggestionsCallback;
  final SuggestionsBoxDecoration suggestionsBoxDecoration;
  final bool canAddWrestler;

  const WrestlerInputRow({
    required this.index1,
    required this.index2,
    required this.controller1,
    required this.controller2,
    required this.wrestlers,
    required this.onWrestlerChanged,
    required this.onRemoveWrestler,
    required this.addWrestlerCallback,
    required this.suggestionsCallback,
    required this.suggestionsBoxDecoration,
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
              child: TypeAheadFormField<String>(
                textFieldConfiguration: TextFieldConfiguration(
                  controller: controller1,
                  decoration: InputDecorations.standard(),
                  onChanged: (value) => onWrestlerChanged(index1, value),
                ),
                suggestionsCallback: suggestionsCallback,
                suggestionsBoxDecoration: suggestionsBoxDecoration,
                direction: AxisDirection.down,
                autoFlipDirection: true,
                autoFlipListDirection: true,
                autoFlipMinHeight: 80,
                minCharsForSuggestions: 1,
                loadingBuilder: (context) => const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: CircularProgressIndicator(),
                ),
                hideOnEmpty: true,
                hideOnLoading: true,
                hideOnError: true,
                itemBuilder: (context, suggestion) {
                  return ListTile(
                    title: Text(
                      suggestion,
                      style: const TextStyle(color: Colors.black),
                    ),
                  );
                },
                onSuggestionSelected: (suggestion) {
                  controller1.text = suggestion;
                  onWrestlerChanged(index1, suggestion);
                },
                validator: (index1 < 2)
                    ? (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Inserisci wrestler.';
                        }
                        return null;
                      }
                    : null,
              ),
            ),
            if (index2 < wrestlers.length) ...[
              const SizedBox(width: 16),
              Expanded(
                child: TypeAheadFormField<String>(
                  textFieldConfiguration: TextFieldConfiguration(
                    controller: controller2,
                    decoration: InputDecorations.standard(),
                    onChanged: (value) => onWrestlerChanged(index2, value),
                  ),
                  suggestionsCallback: suggestionsCallback,
                  suggestionsBoxDecoration: suggestionsBoxDecoration,
                  direction: AxisDirection.down,
                  autoFlipDirection: true,
                  autoFlipListDirection: true,
                  autoFlipMinHeight: 80,
                  minCharsForSuggestions: 1,
                  loadingBuilder: (context) => const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: CircularProgressIndicator(),
                  ),
                  hideOnEmpty: true,
                  hideOnLoading: true,
                  hideOnError: true,
                  itemBuilder: (context, suggestion) {
                    return ListTile(
                      title: Text(
                        suggestion,
                        style: const TextStyle(color: Colors.black),
                      ),
                    );
                  },
                  onSuggestionSelected: (suggestion) {
                    if (controller2 == null) return;
                    controller2!.text = suggestion;
                    onWrestlerChanged(index2, suggestion);
                  },
                  validator: (index2 < 2)
                      ? (value) {
                          if (value == null || value.isEmpty) {
                            return 'Inserisci wrestler.';
                          }
                          return null;
                        }
                      : null,
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
