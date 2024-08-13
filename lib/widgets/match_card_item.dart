import 'package:flutter/material.dart';
import 'package:wwe_bets/services/db_service.dart';
import 'package:wwe_bets/widgets/common/custom_snackbar.dart';

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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: Future.wait([
        widget.dbService.getUserSelection(widget.matchId),
        widget.dbService.getVoteCount(widget.matchId),
      ]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.white,));
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Errore nel recupero dei dati.'));
        }

        final results = snapshot.data;
        final userSelection = results?[0] as String?;
        final voteCount = results?[1] as int;

        final isSubmitted = widget.isVoteSubmitted[widget.matchId] ?? false;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // ppv
                Center(child: Text(widget.payperview, style: MemoText.ppvText,),),
                const SizedBox(height: 20.0),
                // tipo match + titolo + vote count
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('Match:', style: MemoText.secondRowMatchInfo,),
                        Text(widget.type),
                      ],
                    ),
                    if (widget.title.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text('Titolo in palio:', style: MemoText.secondRowMatchInfo,),
                          Text(widget.title),
                        ],
                      ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('Voti:', style: MemoText.secondRowMatchInfo,),
                        Text('$voteCount/2')
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 20.0),
                Text('Partecipanti:', style: MemoText.secondRowMatchInfo,),
                const SizedBox(height: 5.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: widget.wrestlers
                          .take((widget.wrestlers.length / 2).ceil())
                          .map((wrestler) => Text('• $wrestler'))
                          .toList(),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: widget.wrestlers
                          .skip((widget.wrestlers.length / 2).ceil())
                          .map((wrestler) => Text('• $wrestler'))
                          .toList(),
                    ),
                  ],
                ),
                const SizedBox(height: 20.0),
                if (userSelection == null && !isSubmitted)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Scegli il Vincitore:', style: MemoText.secondRowMatchInfo,),
                          const SizedBox(width: 10,),
                          DropdownButton<String>(
                            value: _selectedWrestler,
                            items: widget.selectableWrestlers.map<DropdownMenuItem<String>>((String wrestler) {
                              return DropdownMenuItem<String>(
                                value: wrestler,
                                child: Text(wrestler),
                              );
                            }).toList(),
                            onChanged: isSubmitted ? null : (String? newValue) {
                              setState(() {
                                _selectedWrestler = newValue;
                              });
                            },
                            isExpanded: false,
                            hint: const Text('Seleziona il vincitore'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12.0),
                      Center(
                        child: ElevatedButton(
                          onPressed: isSubmitted ? null : () async {
                            if (_selectedWrestler != null && widget.selectableWrestlers.contains(_selectedWrestler)) {
                              try {
                                await widget.dbService.saveUserSelection(widget.matchId, _selectedWrestler!);
                                widget.onSelectionSaved(widget.matchId, _selectedWrestler!);
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
                          child: const Text('Salva Selezione'),
                        ),
                      ),
                    ],
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Hai votato:', style: MemoText.secondRowMatchInfo,),
                      const SizedBox(width: 10,),
                      Text(userSelection ?? ''),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
