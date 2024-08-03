import 'package:get/get.dart';
import 'package:wwe_bets/pages/main_bottombar.dart';
import 'package:wwe_bets/widgets/intro_screen.dart';

import 'main.dart';

class AppRoutes {
  static const String login = '/login';
  static const String mainScreen = '/mainScreen';
  static const String intro = '/intro';

  static final routes = [
    GetPage(name: login, page: () => const LoginPage()),
    GetPage(name: mainScreen, page: () =>  const BottomNavigationBarWidget()),
    GetPage(name: intro, page: () => const IntroScreen())
  ];
}