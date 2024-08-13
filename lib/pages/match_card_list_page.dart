import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wwe_bets/services/db_service.dart';
import 'package:wwe_bets/style/color_style.dart';
import 'package:wwe_bets/style/text_style.dart';
import 'package:wwe_bets/widgets/common/custom_snackbar.dart';

class MatchCardListPage extends StatefulWidget {
  const MatchCardListPage({super.key});

  @override
  _MatchCardListPageState createState() => _MatchCardListPageState();
}

class _MatchCardListPageState extends State<MatchCardListPage> {
  final DbService dbService = DbService();
  Map<String, String> selectedWrestlers = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Match Cards', style: MemoText.createMatchCardButton),
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
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('matchCards').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Qualcosa è andato storto!'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: ColorsBets.whiteHD,));
                }

                final matchCards = snapshot.data!.docs;

                if (matchCards.isEmpty) {
                  return const Center(child: Text('Nessuna Match Card disponibile.'));
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

                    // Crea una lista separata per il DropdownButton con l'opzione "No Contest / Pareggio"
                    final selectableWrestlers = List<String>.from(wrestlers);
                    selectableWrestlers.add('No Contest / Pareggio');

                    // Controlla se l'utente ha già votato per questo match
                    return FutureBuilder<String?>(
                      future: dbService.getUserSelection(matchId),
                      builder: (context, userSelectionSnapshot) {
                        if (userSelectionSnapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        final userSelection = userSelectionSnapshot.data;

                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text('PPV: $payperview'),
                                if (title.isNotEmpty) Text('Titolo: $title'),
                                Text('Tipo di Match: $type'),
                                const SizedBox(height: 8.0),
                                Text('Partecipanti:'),
                                // Mostra solo i partecipanti reali, senza l'opzione "No Contest / Pareggio"
                                for (var wrestler in wrestlers) Text(wrestler),
                                const SizedBox(height: 8.0),
                                if (userSelection == null)
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Scegli il Vincitore:'),
                                      DropdownButton<String>(
                                        value: selectedWrestlers[matchId],
                                        items: selectableWrestlers.map<DropdownMenuItem<String>>((String wrestler) {
                                          return DropdownMenuItem<String>(
                                            value: wrestler,
                                            child: Text(wrestler),
                                          );
                                        }).toList(),
                                        onChanged: (String? newValue) {
                                          setState(() {
                                            selectedWrestlers[matchId] = newValue!;
                                          });
                                        },
                                        hint: Text('Seleziona il vincitore'),
                                        isExpanded: true,
                                      ),
                                      const SizedBox(height: 8.0),
                                      ElevatedButton(
                                        onPressed: () => _saveSelection(matchId),
                                        child: Text('Salva Selezione'),
                                      ),
                                    ],
                                  )
                                else
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Hai votato per:'),
                                      Text(userSelection, style: TextStyle(fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _saveSelection(String matchId) async {
    final selectedWrestler = selectedWrestlers[matchId];
    if (selectedWrestler != null) {
      try {
        await dbService.saveUserSelection(matchId, selectedWrestler);
        _showSuccessSnackbar('Selezione salvata con successo!');
      } catch (e) {
        _showErrorSnackbar('Errore nel salvare la selezione.');
      }
    } else {
      _showErrorSnackbar('Seleziona un vincitore prima di salvare.');
    }
  }

  void _showErrorSnackbar(String message) {
    CustomSnackbar(
      color: Colors.red,
      context: context,
      message: message,
      icon: Icons.report_gmailerrorred,
    ).show();
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
