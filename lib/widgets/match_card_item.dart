import 'package:flutter/material.dart';
import 'package:wwe_bets/services/db_service.dart';
import 'package:wwe_bets/widgets/common/custom_snackbar.dart';
import 'winner_selection_dialog.dart'; // Importa il nuovo widget

import '../style/color_style.dart';
import '../style/text_style.dart';

class MatchCardItem extends StatefulWidget {
  final String matchId;
  final String payperview;
  final String title;
  final String type;
  final List<String> wrestlers;
  final List<String> selectableWrestlers;
  final DbService dbService;
  final Map<String, bool> isVoteSubmitted;
  final void Function(String matchId, String selectedWrestler) onSelectionSaved;

  const MatchCardItem({
    required this.matchId,
    required this.payperview,
    required this.title,
    required this.type,
    required this.wrestlers,
    required this.selectableWrestlers,
    required this.dbService,
    required this.isVoteSubmitted,
    required this.onSelectionSaved,
    super.key,
  });

  @override
  _MatchCardItemState createState() => _MatchCardItemState();
}

class _MatchCardItemState extends State<MatchCardItem> {
  String? _selectedWrestler;
  String? userSelection;
  String? matchWinner;
  int? voteCount;
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final results = await Future.wait([
        widget.dbService.getUserSelection(widget.matchId),
        widget.dbService.getVoteCount(widget.matchId),
        widget.dbService.getMatchWinner(widget.matchId), // Nuovo metodo
      ]);
      setState(() {
        userSelection = results[0] as String?;
        voteCount = results[1] as int;
        matchWinner = results[2] as String?;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.white));
    }

    if (hasError) {
      return const Center(child: Text('Errore nel recupero dei dati.'));
    }

    final isSubmitted = widget.isVoteSubmitted[widget.matchId] ?? false;
    final isMatchCompleted = matchWinner != null;

    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.withOpacity(0.7), Colors.lightBlueAccent.withOpacity(0.7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Center(
                child: Text(
                  widget.payperview,
                  style: MemoText.ppvText,
                ),
              ),
              const SizedBox(height: 20.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('Match:', style: MemoText.secondRowMatchInfo),
                      Text(widget.type, style: MemoText.thirdRowMatchInfo),
                    ],
                  ),
                  if (widget.title.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('Titolo in palio:', style: MemoText.secondRowMatchInfo.copyWith(color: Colors.white)),
                        Text(widget.title, style: MemoText.thirdRowMatchInfo),
                      ],
                    ),
                  Row(
                    children: [
                      Text('Voti: ', style: MemoText.secondRowMatchInfo),
                      Text('$voteCount/2', style: MemoText.secondRowMatchInfo),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20.0),
              Text('Partecipanti:', style: MemoText.secondRowMatchInfo.copyWith(color: Colors.white)),
              const SizedBox(height: 5.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: widget.wrestlers
                        .take((widget.wrestlers.length / 2).ceil())
                        .map((wrestler) => Text('• $wrestler', style: MemoText.thirdRowMatchInfo))
                        .toList(),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: widget.wrestlers
                        .skip((widget.wrestlers.length / 2).ceil())
                        .map((wrestler) => Text('• $wrestler', style: MemoText.thirdRowMatchInfo))
                        .toList(),
                  ),
                ],
              ),
              const SizedBox(height: 20.0),
              if (isMatchCompleted) ...[
                Text('Vincitore:', style: MemoText.secondRowMatchInfo.copyWith(color: Colors.white)),
                Text(matchWinner ?? '', style: MemoText.thirdRowMatchInfo),
                const SizedBox(height: 10.0),
                Text('Hai votato:', style: MemoText.secondRowMatchInfo.copyWith(color: Colors.white)),
                Text(userSelection ?? 'Nessun voto', style: MemoText.thirdRowMatchInfo),
              ] else ...[
                const Divider(color: Colors.black26, thickness: 2),
                const SizedBox(height: 10.0),
                if (userSelection == null && !isSubmitted)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('Scegli il Vincitore:', style: MemoText.secondRowMatchInfo.copyWith(color: Colors.white)),
                      const SizedBox(width: 10),
                      DropdownButton<String>(
                        dropdownColor: ColorsBets.blackHD,
                        iconEnabledColor: ColorsBets.whiteHD,
                        style: const TextStyle(color: ColorsBets.whiteHD),
                        value: _selectedWrestler,
                        items: widget.selectableWrestlers.map<DropdownMenuItem<String>>((String wrestler) {
                          return DropdownMenuItem<String>(
                            value: wrestler,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text("• "),
                                  Text(
                                    wrestler,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: ColorsBets.whiteHD,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: isSubmitted ? null : (String? newValue) {
                          setState(() {
                            _selectedWrestler = newValue;
                          });
                        },
                        hint: Text('Seleziona il vincitore', style: MemoText.thirdRowMatchInfo),
                      ),
                      const SizedBox(height: 12.0),
                      ElevatedButton(
                        onPressed: isSubmitted ? null : () async {
                          if (_selectedWrestler != null && widget.selectableWrestlers.contains(_selectedWrestler)) {
                            try {
                              await widget.dbService.saveUserSelection(widget.matchId, _selectedWrestler!);
                              widget.onSelectionSaved(widget.matchId, _selectedWrestler!);
                              // Ricarica i dati
                              await _fetchData();
                            } catch (e) {
                              debugPrint('Error saving selection: $e');
                              CustomSnackbar(
                                color: Colors.red,
                                context: context,
                                message: 'Errore nel salvataggio della selezione.',
                                icon: Icons.report_gmailerrorred,
                              ).show();
                            }
                          } else {
                            CustomSnackbar(
                              color: Colors.red,
                              context: context,
                              message: 'Attenzione! Scegli almeno un vincitore.',
                              icon: Icons.report_gmailerrorred,
                            ).show();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          side: const BorderSide(color: Colors.black, width: 2.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Conferma Pronostico',
                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  )
                else if (userSelection != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('Hai votato:', style: MemoText.secondRowMatchInfo.copyWith(color: Colors.white)),
                      Text(userSelection ?? '', style: TextStyle(color: Colors.white)),
                      const SizedBox(height: 12.0),
                      ElevatedButton(
                        onPressed: () => _showWinnerSelectionDialog(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          side: const BorderSide(color: Colors.black, width: 2.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Seleziona Vincitore',
                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showWinnerSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return WinnerSelectionDialog(
          matchId: widget.matchId,
          selectableWrestlers: widget.selectableWrestlers,
          dbService: widget.dbService,
          onSelectionSaved: (matchId, winner) async {
            await _fetchData(); // Ricarica i dati dopo aver selezionato un vincitore
          },
        );
      },
    );
  }
}
