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


  Future<void> _deleteAllMatchCards() async {
    try {
      // Get all match cards
      final matchCardsSnapshot = await FirebaseFirestore.instance.collection('matchCards').get();
      final batch = FirebaseFirestore.instance.batch();

      // Prepare a list to hold user selection deletions
      final List<Future<void>> userSelectionDeletions = [];

      for (var doc in matchCardsSnapshot.docs) {
        // Add the deletion of the match card to the batch
        batch.delete(doc.reference);

        // Assuming user selections are stored in a separate collection named 'userSelections'
        // Here we construct the query to find user selections based on the matchId
        final matchId = doc.id; // Assuming the document ID is the matchId
        userSelectionDeletions.add(
          FirebaseFirestore.instance
              .collection('userSelections')
              .where('matchId', isEqualTo: matchId)
              .get()
              .then((userSelectionsSnapshot) {
            for (var userDoc in userSelectionsSnapshot.docs) {
              batch.delete(userDoc.reference); // Delete each user selection
            }
          }),
        );
      }

      // Wait for all user selection deletions to complete before committing the batch
      await Future.wait(userSelectionDeletions);
      await batch.commit();

      _showSuccessSnackbar('Tutti i match e le rispettive selezioni degli utenti sono stati eliminati con successo!');

      // Update the Future after deleting all matches
      setState(() {
        _matchCardsFuture = _fetchMatchCards();
      });
    } catch (e) {
      _showErrorSnackbar('Errore durante l\'eliminazione dei match e delle selezioni degli utenti!');
    }
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

  void _confirmDeleteAllMatchCards() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          title: const Row(
            children: [
              Icon(Icons.warning, color: Colors.red, size: 30),
              SizedBox(width: 10),
              Expanded(child: Text('Elimina tutti i match')),
            ],
          ),
          content: const Text(
            'Sei sicuro di voler eliminare tutti i match? Questa azione non può essere annullata.',
            style: TextStyle(fontSize: 16),
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey,
                backgroundColor: Colors.grey[200],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: const Text('Annulla', style: TextStyle(color: ColorsBets.blackHD)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: const Text('Elimina', style: TextStyle(color: ColorsBets.whiteHD)),
              onPressed: () async {
                Navigator.of(context).pop();
                await _deleteAllMatchCards();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double horizontalPadding = MediaQuery.of(context).size.width * 0.04;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever, color: ColorsBets.whiteHD),
            onPressed: _confirmDeleteAllMatchCards,
          ),
        ],
        title: FutureBuilder<List<QueryDocumentSnapshot>>(
          future: _matchCardsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return  Text('Prossimi Match', style: MemoText.createMatchCardButton); // Placeholder text while loading
            }

            final matchCardsCount = snapshot.data?.length ?? 0; // Get match card count
            return Text(
              'Prossimi Match: $matchCardsCount',
              style: MemoText.createMatchCardButton, // Use the same text style as before
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
