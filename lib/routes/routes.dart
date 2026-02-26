import 'package:get/get.dart';
import 'package:wwe_bets/pages/login_page.dart';
import '../pages/create_match_card_page.dart';
import '../pages/match_card_list_page.dart'; 
import '../pages/user_ranking_page.dart';
import '../pages/user_generator_page.dart';
import '../widgets/bottom_navigation_bar_widget.dart';

class AppRoutes {
  static const String login = '/login';
  static const String mainScreen = '/mainScreen';
  static const String createMatchCard = '/createMatchCard';
  static const String matchCardList = '/matchCardList';
  static const String userRatingPage= '/userRanking';
  static const String userGeneratorPage = '/userGenerator';

  static final routes = [
    GetPage(name: login, page: () => const LoginPage()),
    GetPage(name: mainScreen, page: () => const BottomNavigationBarWidget()),
    GetPage(name: createMatchCard, page: () => const CreateMatchCardPage()),
    GetPage(name: matchCardList, page: () => const MatchCardListPage()),
    GetPage(name: userRatingPage, page: () => const RankingPage()),
    GetPage(name: userGeneratorPage, page: () => const UserGeneratorPage()),
  ];
}
