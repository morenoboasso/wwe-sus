import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wwe_bets/services/db_service.dart';
import 'package:wwe_bets/style/color_style.dart';
import 'package:wwe_bets/style/text_style.dart';
import 'package:wwe_bets/widgets/common/custom_snackbar.dart';

import '../widgets/match_card_item.dart';

class MatchCardListPage extends StatefulWidget {
  const MatchCardListPage({super.key});

  @override
  _MatchCardListPageState createState() => _MatchCardListPageState();
}

class _MatchCardListPageState extends State<MatchCardListPage> {
  final DbService dbService = DbService();
  Map<String, String> selectedWrestlers = {};
  Map<String, bool> isVoteSubmitted = {};

  @override
  Widget build(BuildContext context) {
    // Calculate the padding dynamically based on screen size
    final double horizontalPadding = MediaQuery.of(context).size.width * 0.04;

    return Scaffold(
      appBar: AppBar(
        title: Text('Prossimi Match', style: MemoText.createMatchCardButton),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/bg.jpeg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('matchCards').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Qualcosa è andato storto!',
                        style: MemoText.noMatches,
                      ),
                    );
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: ColorsBets.whiteHD,
                      ),
                    );
                  }

                  final matchCards = snapshot.data!.docs;

                  if (matchCards.isEmpty) {
                    return Center(
                      child: Text(
                        'Nessun Match disponibile, creane uno!',
                        style: MemoText.noMatches,
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: matchCards.length,
                    itemBuilder: (context, index) {
                      final matchCard = matchCards[index];
                      final matchId = matchCard.id;
                      final payperview = matchCard['payperview'] as String;
                      final title = matchCard['title'] as String;
                      final type = matchCard['type'] as String;
                      final wrestlers = List<String>.from(matchCard['wrestlers']);

                      final selectableWrestlers = List<String>.from(wrestlers);
                      selectableWrestlers.add('No Contest');

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: MatchCardItem(
                          matchId: matchId,
                          payperview: payperview,
                          title: title,
                          type: type,
                          wrestlers: wrestlers,
                          selectableWrestlers: selectableWrestlers,
                          dbService: dbService,
                          isVoteSubmitted: isVoteSubmitted,
                          onSelectionSaved: _onSelectionSaved,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onSelectionSaved(String matchId, String selectedWrestler) {
    setState(() {
      isVoteSubmitted[matchId] = true;
    });
    _showSuccessSnackbar('Hai votato $selectedWrestler con successo!');
  }

  void _showSuccessSnackbar(String message) {
    CustomSnackbar(
      color: Colors.green,
      context: context,
      message: message,
      icon: Icons.check_circle,
    ).show();
  }
}
