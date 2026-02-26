import 'package:flutter/material.dart';

import '../controllers/match_list_controller.dart';
import '../models/match_list_item.dart';
import '../repositories/match_repository.dart';
import '../style/text_style.dart';
import '../widgets/common/custom_snackbar.dart';
import '../widgets/match_card_item.dart';

part 'match_card_list_page_state.dart';

class MatchCardListPage extends StatefulWidget {
  const MatchCardListPage({super.key});

  @override
  MatchCardListPageState createState() => MatchCardListPageState();
}
