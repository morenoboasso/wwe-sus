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
  Map<String, bool> isVoteSubmitted = {};
  late Future<List<QueryDocumentSnapshot>> _matchCardsFuture;

  @override
  void initState() {
    super.initState();
    _matchCardsFuture = _fetchMatchCards();
  }

  // Add the delete method
  void _deleteMatchCard(String matchId) async {
    try {
      await dbService.deleteMatchCard(matchId);
      _showSuccessSnackbar('Match eliminato con successo!');
      // Reload the match cards after deletion
      setState(() {
        _matchCardsFuture = _fetchMatchCards();
      });
    } catch (e) {
      _showErrorSnackbar('Errore durante l\'eliminazione del match!');
    }
  }


  Future<List<QueryDocumentSnapshot>> _fetchMatchCards() async {
    final snapshot = await FirebaseFirestore.instance.collection('matchCards').get();
    final matchCards = snapshot.docs;

    // Ordina i match cards
    matchCards.sort((a, b) {
      final aUserSelection = isVoteSubmitted[a.id] ?? false;
      final bUserSelection = isVoteSubmitted[b.id] ?? false;
      // Metti i match non votati prima di quelli votati
      return aUserSelection == bUserSelection ? 0 : (aUserSelection ? 1 : -1);
    });

    return matchCards;
  }

  void _onSelectionSaved(String matchId, String selectedWrestler) {
    setState(() {
      isVoteSubmitted[matchId] = true; // Aggiorna lo stato di voto
    });
    _showSuccessSnackbar('Hai votato $selectedWrestler con successo!');
    // Ricarica i match cards per aggiornare l'ordinamento
    _matchCardsFuture = _fetchMatchCards();
  }

  void _showSuccessSnackbar(String message) {
    CustomSnackbar(
      color: Colors.green,
      context: context,
      message: message,
      icon: Icons.check_circle,
    ).show();
  }

  void _showErrorSnackbar(String message) {
    CustomSnackbar(
      color: Colors.red,
      context: context,
      message: message,
      icon: Icons.error,
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    final double horizontalPadding = MediaQuery.of(context).size.width * 0.04;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: FutureBuilder<List<QueryDocumentSnapshot>>(
          future: _matchCardsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return  Text('Match attivi', style: MemoText.createMatchCardButton);
            }

            final matchCardsCount = snapshot.data?.length ?? 0;
            return Text(
              'Match attivi: $matchCardsCount',
              style: MemoText.createMatchCardButton,
            );
          },
        ),
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
              child: FutureBuilder<List<QueryDocumentSnapshot>>(
                future: _matchCardsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: ColorsBets.whiteHD,
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Qualcosa è andato storto!',
                        style: MemoText.noMatches,
                      ),
                    );
                  }

                  final matchCards = snapshot.data ?? [];

                  if (matchCards.isEmpty) {
                    return Center(
                      child: Text(
                        'Nessun Match disponibile, creane uno!',
                        style: MemoText.noMatches,
                      ),
                    );
                  }

                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: ListView.builder(
                            itemCount: matchCards.length,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              final matchCard = matchCards[index];
                              final matchId = matchCard.id;
                              final title = matchCard['title'] as String;
                              final type = matchCard['type'] as String;
                              final wrestlers = List<String>.from(matchCard['wrestlers']);

                              final selectableWrestlers = List<String>.from(wrestlers)..add('No Contest');

                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: MatchCardItem(
                                  matchId: matchId,
                                  title: title,
                                  type: type,
                                  wrestlers: wrestlers,
                                  selectableWrestlers: selectableWrestlers,
                                  dbService: dbService,
                                  isVoteSubmitted: isVoteSubmitted,
                                  onSelectionSaved: _onSelectionSaved,
                                  onDelete: _deleteMatchCard,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}