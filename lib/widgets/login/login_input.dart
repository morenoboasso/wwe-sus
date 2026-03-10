import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:wwe_bets/style/text_style.dart';
import '../../style/color_style.dart';

class LoginTextField extends StatelessWidget {
  final ValueChanged<String> onChanged;
  final Future<List<String>> Function() onSuggestionsRequested;

  const LoginTextField({super.key, required this.onChanged, required this.onSuggestionsRequested});

  @override
  Widget build(BuildContext context) {
    return TextSelectionTheme(
      data: TextSelectionThemeData(
        selectionColor: ColorsBets.blackHD.withValues(alpha: 0.5),
        cursorColor: ColorsBets.blackHD.withValues(alpha: 0.9),
      ),
      child: TypeAheadField<String>(
        hideOnLoading: true,
        hideOnEmpty: true,
        suggestionsCallback: (_) => onSuggestionsRequested(),
        textFieldConfiguration: TextFieldConfiguration(
          cursorRadius: const Radius.circular(20),
          cursorWidth: 2.5,
          enableSuggestions: true,
          keyboardType: TextInputType.text,
          textAlign: TextAlign.left,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            hintText: 'Inserisci il tuo nome...',
            hintStyle: MemoText.loginHint,
            filled: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
            fillColor: ColorsBets.whiteHD,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20.0),
              borderSide: const BorderSide(
                color: ColorsBets.blackHD,
                width: 2.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20.0),
              borderSide: const BorderSide(
                color: ColorsBets.blackHD,
                width: 2.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20.0),
              borderSide: const BorderSide(
                color: ColorsBets.blackHD,
                width: 2.5,
              ),
            ),
          ),
          onChanged: onChanged,
        ),
        itemBuilder: (context, suggestion) {
          return ListTile(
            title: Text(suggestion, style: MemoText.thirdRowMatchInfo.copyWith(color: Colors.black)),
          );
        },
        onSuggestionSelected: (suggestion) {
          onChanged(suggestion);
        },
      ),
    );
  }
}
