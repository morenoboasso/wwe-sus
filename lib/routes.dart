import 'package:get/get.dart';
import 'package:wwe_bets/pages/main_bottombar.dart';

import 'main.dart';

class AppRoutes {
  static const String login = '/login';
  static const String mainScreen = '/mainScreen';

  static final routes = [
    GetPage(name: login, page: () => const LoginPage()),
    GetPage(name: mainScreen, page: () =>  const BottomNavigationBarWidget()),
  ];
}