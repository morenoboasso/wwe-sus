import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

import '../controllers/create_match_controller.dart';
import '../models/match_model.dart';
import '../style/text_style.dart';
import '../widgets/bottom_navigation_bar_widget.dart';
import '../widgets/common/custom_snackbar.dart';
import '../widgets/common/input_decoration.dart';
import '../widgets/create_match_card/title_checkbox.dart';
import '../widgets/create_match_card/wrestler_input_row.dart';

part 'create_match_card_page_state.dart';

class CreateMatchCardPage extends StatefulWidget {
  const CreateMatchCardPage({super.key});

  @override
  CreateMatchCardPageState createState() => CreateMatchCardPageState();
}
