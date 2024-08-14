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

  Future<List<QueryDocumentSnapshot>> _fetchMatchCards() async {
    final snapshot = await FirebaseFirestore.instance.collection('matchCards').get();
    return snapshot.docs;
  }

  Future<void> _deleteAllMatchCards() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('matchCards').get();
      final batch = FirebaseFirestore.instance.batch();

      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      _showSuccessSnackbar('Tutti i match sono stati eliminati con successo!');

      // Aggiorna il Future dopo aver eliminato tutti i match
      setState(() {
        _matchCardsFuture = _fetchMatchCards();
      });
    } catch (e) {
      _showErrorSnackbar('Errore durante l\'eliminazione dei match!');
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
          title: Row(
            children: [
              Icon(Icons.warning, color: Colors.red, size: 30),
              SizedBox(width: 10),
              Expanded(child: Text('Elimina tutti i match')),
            ],
          ),
          content: Text(
            'Sei sicuro di voler eliminare tutti i match? Questa azione non può essere annullata.',
            style: TextStyle(fontSize: 16),
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey, backgroundColor: Colors.grey[200],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: Text('Annulla', style: TextStyle(color: ColorsBets.blackHD),),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            SizedBox(width: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: Text('Elimina', style: TextStyle(color: ColorsBets.whiteHD),),
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
        title: Text('Prossimi Match', style: MemoText.createMatchCardButton),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.delete_forever,color: ColorsBets.whiteHD,),
            onPressed: _confirmDeleteAllMatchCards,
          ),
        ],
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

                  final matchCards = snapshot.data ?? [];

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

                      final selectableWrestlers = List<String>.from(wrestlers)..add('No Contest');

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
}
