import 'package:flutter/material.dart';

import 'color_style.dart';

class TextStyleBets {
  // Titoli generali
  static TextStyle get titleBlue => const TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: ColorsBets.whiteHD,
  );

  //  --login--
  //login hint text
  static TextStyle get hintTextLogin => TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: ColorsBets.blackHD.withOpacity(0.8),
  );
  //login input text
  static TextStyle get inputTextLogin => const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: ColorsBets.blackHD,
  );
  //create bet
  //bet input form
  static TextStyle get inputTextTitle => const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: ColorsBets.blackHD,
  );
  //bet hint form
  static TextStyle get hintTextTitle =>  TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.bold,
    color: ColorsBets.blackHD.withOpacity(0.6),
  );
  //bet form text
  static TextStyle get hintTextAnswer => TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.bold,
    color: ColorsBets.blackHD.withOpacity(0.3),
  );
  //titolo schermata bet
  static TextStyle get betTextTitle => const TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: ColorsBets.whiteHD,
  );

  //bets attive
//titolo
  static TextStyle get activeBetTitle => const TextStyle(
    fontSize: 25,
    fontWeight: FontWeight.bold,
    color: ColorsBets.blackHD,
  );

  //dialog termina bet
  static TextStyle get dialogTitle => const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: ColorsBets.whiteHD,
  );

  //bet answers
//selected answer text
  static TextStyle get selectedAnswer => const TextStyle(
      fontWeight: FontWeight.bold,
      color: ColorsBets.whiteHD,
      fontSize: 18
  );

  static TextStyle get betScegliAnswer => const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: ColorsBets.whiteHD,
  );

//bet title
  static TextStyle get betsTitle => const TextStyle(
    fontSize: 20,
    color: ColorsBets.whiteHD,
    fontWeight: FontWeight.bold,
  );
  //bet description
  static TextStyle get betsDescription =>  TextStyle(
    fontWeight: FontWeight.bold,
    color: Colors.black.withOpacity(0.5),
    fontSize: 13,
  );
  //data bet
  static TextStyle get betsDate =>  const TextStyle(
    fontWeight: FontWeight.bold,
    color: ColorsBets.orangeHD,
    fontSize: 10,
  );

  //profile
//username
  static TextStyle get profileUserName =>  const TextStyle(
    fontWeight: FontWeight.bold,
    color: ColorsBets.blackHD,
    fontSize: 28,
  );

  //variabile profilo
  static TextStyle get profileVariable =>  const TextStyle(
    fontWeight: FontWeight.w700,
    color: ColorsBets.blackHD,
    fontSize: 18,
  );

  //leaderboard
//user card text
  static TextStyle get userLeaderboardText =>  const TextStyle(
    fontWeight: FontWeight.w700,
    color: ColorsBets.orangeHD,
    fontSize: 15,
  );
  static TextStyle get userSelfLeaderboardText =>  const TextStyle(
    fontWeight: FontWeight.w700,
    color: ColorsBets.whiteHD,
    fontSize: 15,
  );

  static TextStyle get userPositionLeader => const TextStyle(
      fontWeight: FontWeight.w900,
      color: ColorsBets.whiteHD,
      fontSize: 20
  );
  static TextStyle get userSelfPositionLeader => const TextStyle(
      fontWeight: FontWeight.w900,
      color: ColorsBets.whiteHD,
      fontSize: 20
  );

  //onboarding
  static TextStyle get onboardTitle => const TextStyle(
      fontWeight: FontWeight.w900,
      color: ColorsBets.whiteHD,
      fontSize: 24
  );

  static TextStyle get onboardBody => const TextStyle(
      fontWeight: FontWeight.w400,
      color: ColorsBets.blackHD,
      fontSize: 18
  );

}