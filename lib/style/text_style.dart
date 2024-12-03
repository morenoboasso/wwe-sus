import 'package:flutter/material.dart';

import 'color_style.dart';

class MemoText {
  //login
  static TextStyle get loginText => const TextStyle(
      fontWeight: FontWeight.bold, color: ColorsBets.whiteHD, fontSize: 26);
  static TextStyle get loginHint => const TextStyle(color: ColorsBets.blackHD);

  //create match card
  static TextStyle get createInputMainText => const TextStyle(
      color: ColorsBets.whiteHD, fontWeight: FontWeight.bold, fontSize: 18);
  static TextStyle get createHintInput => TextStyle(
      color: ColorsBets.blackHD.withOpacity(0.6),
      fontWeight: FontWeight.w200,
      fontSize: 14);
  static TextStyle get createMatchCardButton => const TextStyle(
      color: ColorsBets.whiteHD, fontWeight: FontWeight.bold, fontSize: 28);
  static TextStyle get addWrestlerButton =>
      const TextStyle(color: ColorsBets.whiteHD, fontSize: 12);

  //match card items
  static TextStyle get ppvText => const TextStyle(
      color: ColorsBets.whiteHD, fontSize: 20, fontWeight: FontWeight.bold
  );
  static TextStyle get secondRowMatchInfo => const TextStyle(
      color: ColorsBets.whiteHD, fontSize: 18, fontWeight: FontWeight.bold
  );
  static TextStyle get thirdRowMatchInfo => const TextStyle(
      color: ColorsBets.whiteHD, fontSize: 14
  );
  static TextStyle get noMatches => const TextStyle(color: ColorsBets.whiteHD,fontSize: 14);
}
