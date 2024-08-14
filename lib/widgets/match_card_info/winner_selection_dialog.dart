import 'package:flutter/material.dart';
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
      backgroundColor: Colors.transparent, // Set transparent background to see the shadow
      child: Container(
        decoration: BoxDecoration(
          color: Colors.lightBlueAccent,
          borderRadius: BorderRadius.circular(20.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 15,
              offset: const Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const Text(
                'Seleziona Vincitore',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
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
                          const Text("• ", style: TextStyle(color: Colors.white)),
                          Text(
                            wrestler,
                            style: const TextStyle(color: Colors.white),
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
                hint: const Text(
                  'Seleziona il vincitore',
                  style: TextStyle(color: Colors.white),
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
                    child: const Text(
                      'Annulla',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (_selectedWrestler != null) {
                        try {
                          await widget.dbService.updateMatchResult(widget.matchId, _selectedWrestler!);
                          await widget.dbService.updateUserScore(widget.matchId, _selectedWrestler!);
                          widget.onSelectionSaved(widget.matchId, _selectedWrestler!); // Richiama il callback per ricaricare i dati
                          Navigator.of(context).pop();
                        } catch (e) {
                          // Gestisci errori di salvataggio
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Errore nel salvataggio della selezione.'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent, // Background color of the button
                        side: const BorderSide(color: Colors.black, width: 2.0), // Border color and width
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0), // Border radius
                        ),
                        elevation: 0
                    ),
                    child: const Text(
                      'Conferma',
                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
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
