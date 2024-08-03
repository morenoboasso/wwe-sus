import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:wwe_bets/pages/login_page.dart';
import 'package:wwe_bets/pages/main_bottombar.dart';

class AppRoutes {
  static const String login = '/login';
  static const String mainScreen = '/mainScreen';

  static final routes = [
    GetPage(name: login, page: () => const LoginPage()),
    GetPage(name: mainScreen, page: () => const BottomNavigationBarWidget()),
  ];
}
