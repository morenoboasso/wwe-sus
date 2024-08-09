import 'package:flutter/material.dart';
import 'package:wwe_bets/style/text_style.dart';
import '../../style/color_style.dart';

class LoginTextField extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const LoginTextField({super.key, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextSelectionTheme(
      data: TextSelectionThemeData(
        selectionColor: ColorsBets.blackHD.withOpacity(0.5),
        cursorColor: ColorsBets.blackHD.withOpacity(0.9),
      ),
      child: TextField(
        // cursor
        cursorOpacityAnimates: true,
        cursorRadius: const Radius.circular(20),
        cursorWidth: 2.5,
        // text
        enableSuggestions: true,
        keyboardType: TextInputType.text,
        textAlign: TextAlign.left,
        textCapitalization: TextCapitalization.words,
        // forma + hint
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
    );
  }
}
