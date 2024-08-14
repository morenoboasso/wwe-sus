import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart'; // Aggiungi questa importazione
import 'package:wwe_bets/services/db_service.dart';

class WinnerSelectionDialog extends StatefulWidget {
  final String matchId;
  final List<String> selectableWrestlers;
  final DbService dbService;
  final void Function(String matchId, String winner) onSelectionSaved;

  const WinnerSelectionDialog({
    required this.matchId,
    required this.selectableWrestlers,
    required this.dbService,
    required this.onSelectionSaved,
    super.key,
  });

  @override
  _WinnerSelectionDialogState createState() => _WinnerSelectionDialogState();
}

class _WinnerSelectionDialogState extends State<WinnerSelectionDialog> {
  String? _selectedWrestler;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.lightBlueAccent,
          borderRadius: BorderRadius.circular(20.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 15,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const AutoSizeText(
                'Seleziona Vincitore',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                minFontSize: 14,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 20.0),
              DropdownButton<String>(
                isExpanded: true,
                value: _selectedWrestler,
                items: widget.selectableWrestlers.map<DropdownMenuItem<String>>((String wrestler) {
                  return DropdownMenuItem<String>(
                    value: wrestler,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const AutoSizeText("• ", style: TextStyle(color: Colors.white)),
                          AutoSizeText(
                            wrestler,
                            style: const TextStyle(color: Colors.white),
                            minFontSize: 14,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedWrestler = newValue;
                  });
                },
                hint: const AutoSizeText(
                  'Seleziona il vincitore',
                  style: TextStyle(color: Colors.white),
                  minFontSize: 14,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                dropdownColor: Colors.black,
              ),
              const SizedBox(height: 20.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const AutoSizeText(
                      'Annulla',
                      style: TextStyle(color: Colors.white),
                      minFontSize: 14,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (_selectedWrestler != null) {
                        try {
                          await widget.dbService.updateMatchResult(widget.matchId, _selectedWrestler!);
                          await widget.dbService.updateUserScore(widget.matchId, _selectedWrestler!);
                          widget.onSelectionSaved(widget.matchId, _selectedWrestler!);
                          Navigator.of(context).pop();
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: AutoSizeText(
                                'Errore nel salvataggio della selezione.',
                                minFontSize: 14,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        side: const BorderSide(color: Colors.black, width: 2.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        elevation: 0
                    ),
                    child: const AutoSizeText(
                      'Conferma',
                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                      minFontSize: 14,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
