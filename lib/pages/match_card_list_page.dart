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
  late Future<List<Map<String, dynamic>>> _matchCardsFuture;

  List<Map<String, dynamic>> nonVotati = [];
  List<Map<String, dynamic>> votatiNonConclusi = [];
  List<Map<String, dynamic>> completati = [];

  @override
  void initState() {
    super.initState();
    _matchCardsFuture = _fetchMatchCardsWithDetails();
  }

  Future<List<Map<String, dynamic>>> _fetchMatchCardsWithDetails() async {
    final snapshot = await FirebaseFirestore.instance.collection('matchCards').get();

    List<Map<String, dynamic>> matchCards = [];
    for (var doc in snapshot.docs) {
      final matchId = doc.id;
      final title = doc['title'] as String;
      final type = doc['type'] as String;
      final wrestlers = List<String>.from(doc['wrestlers']);

      // Recupero info extra per filtraggio
      final userSelection = await dbService.getUserSelection(matchId);
      final matchWinner = await dbService.getMatchWinner(matchId);

      matchCards.add({
        'matchId': matchId,
        'title': title,
        'type': type,
        'wrestlers': wrestlers,
        'selectableWrestlers': [...wrestlers, 'No Contest'],
        'userSelection': userSelection,
        'matchWinner': matchWinner,
      });
    }

    // Filtra qui i match per tab
    nonVotati = matchCards.where((m) =>
    m['userSelection'] == null && m['matchWinner'] == null
    ).toList();

    votatiNonConclusi = matchCards.where((m) =>
    m['userSelection'] != null && m['matchWinner'] == null
    ).toList();

    completati = matchCards.where((m) =>
    m['matchWinner'] != null
    ).toList();

    return matchCards;
  }

  void _deleteMatchCard(String matchId) async {
    try {
      await dbService.deleteMatchCard(matchId);
      _showSuccessSnackbar('Match eliminato con successo!');
      setState(() {
        _matchCardsFuture = _fetchMatchCardsWithDetails();
      });
    } catch (e) {
      _showErrorSnackbar('Errore durante l\'eliminazione del match!');
    }
  }

  void _onSelectionSaved(String matchId, String selectedWrestler) {
    setState(() {
      isVoteSubmitted[matchId] = true;
      _matchCardsFuture = _fetchMatchCardsWithDetails();
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

  void _showErrorSnackbar(String message) {
    CustomSnackbar(
      color: Colors.red,
      context: context,
      message: message,
      icon: Icons.error,
    ).show();
  }

  Widget _buildTabWithBadge(String title, int count) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Tab(text: title),
        if (count > 0)
          Positioned(
            right: -18,
            top: 2,
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: const BoxDecoration(
                color: Colors.redAccent,
                shape: BoxShape.circle,
              ),
              child: Text(
                count.toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final double horizontalPadding = MediaQuery.of(context).size.width * 0.04;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
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
              child: FutureBuilder<List<Map<String, dynamic>>>(
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

                  return Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                        child: TabBar(
                          indicatorColor: Colors.white,
                          labelColor: Colors.white,
                          unselectedLabelColor: Colors.grey,
                          tabs: [
                            _buildTabWithBadge('Nuovi', nonVotati.length),
                            _buildTabWithBadge('Votati', votatiNonConclusi.length),
                            _buildTabWithBadge('Completati', completati.length),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                          child: TabBarView(
                            children: [
                              _buildMatchList(nonVotati),
                              _buildMatchList(votatiNonConclusi),
                              _buildMatchList(completati),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchList(List<Map<String, dynamic>> matches) {
    if (matches.isEmpty) {
      return Center(
        child: Text(
          'Nessun Match disponibile',
          style: MemoText.noMatches,
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: matches.map((match) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: MatchCardItem(
              matchId: match['matchId'],
              title: match['title'],
              type: match['type'],
              wrestlers: match['wrestlers'],
              selectableWrestlers: match['selectableWrestlers'],
              dbService: dbService,
              isVoteSubmitted: isVoteSubmitted,
              onSelectionSaved: _onSelectionSaved,
              onDelete: _deleteMatchCard,
            ),
          );
        }).toList(),
      ),
    );
  }
}
