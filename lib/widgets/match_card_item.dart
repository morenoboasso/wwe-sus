import 'package:flutter/material.dart';
import 'package:wwe_bets/services/db_service.dart';
import 'package:wwe_bets/widgets/common/custom_snackbar.dart';
import 'package:wwe_bets/widgets/match_card_info/winner_selection_dialog.dart';
import 'match_card_info/match_info_row.dart';
import 'match_card_info/vote_section.dart';
import 'match_card_info/wrestler_list.dart';

class MatchCardItem extends StatefulWidget {
  final String matchId;
  final String title;
  final String type;
  final List<String> wrestlers;
  final List<String> selectableWrestlers;
  final DbService dbService;
  final Map<String, bool> isVoteSubmitted;
  final void Function(String matchId, String selectedWrestler) onSelectionSaved;
  final Function(String) onDelete; 

  const MatchCardItem({
    required this.matchId,
    required this.title,
    required this.type,
    required this.wrestlers,
    required this.selectableWrestlers,
    required this.dbService,
    required this.isVoteSubmitted,
    required this.onSelectionSaved,
    required this.onDelete, 
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
  bool _isExpanded = false; 

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
        widget.dbService.getMatchWinner(widget.matchId),
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

    return GestureDetector(
      onTap: () {
        setState(() {
          _isExpanded = !_isExpanded; 
        });
      },
      child: Card(
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Container(
          decoration: BoxDecoration(
            gradient: userSelection != null
                ? LinearGradient(
              colors: [Colors.blue.withOpacity(0.7), Colors.lightBlueAccent.withOpacity(0.7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
                : LinearGradient(
              colors: [Colors.black.withOpacity(0.6), Colors.black.withOpacity(0.3)],
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    userSelection == null
                        ? Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.red,
                      ),
                    )
                        : const Icon(
                      Icons.check_circle,
                      color: Colors.white,
                    ),
                    Icon(
                      _isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: Colors.white,
                    ),
                  ],
                ),
                if (_isExpanded) ...[
                  MatchInfoRow(
                    title: widget.title,
                    type: widget.type,
                  ),
                  const SizedBox(height: 20.0),
                ],
                WrestlerList(wrestlers: widget.wrestlers),
                if (_isExpanded) ...[
                  const SizedBox(height: 20.0),
                  VoteSection(
                    isMatchCompleted: isMatchCompleted,
                    matchWinner: matchWinner,
                    userSelection: userSelection,
                    isSubmitted: isSubmitted,
                    selectableWrestlers: widget.selectableWrestlers,
                    selectedWrestler: _selectedWrestler,
                    onSelectionChanged: (String? newValue) {
                      setState(() {
                        _selectedWrestler = newValue;
                      });
                    },
                    onVoteConfirmed: () async {
                      if (_selectedWrestler != null && widget.selectableWrestlers.contains(_selectedWrestler)) {
                        try {
                          await widget.dbService.saveUserSelection(widget.matchId, _selectedWrestler!);
                          widget.onSelectionSaved(widget.matchId, _selectedWrestler!);
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
                    onShowWinnerSelectionDialog: () => _showWinnerSelectionDialog(),
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.delete, color: Colors.black,size: 16),
                    onPressed: () {
                      _showDeleteConfirmationDialog();
                    },
                    label: const Text("Elimina Match",style: TextStyle(color: Colors.black,decoration: TextDecoration.underline,decorationColor: Colors.black ),),
                  ),
                ],
              ],
            ),
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
            await _fetchData();
          },
        );
      },
    );
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          title: const Row(
            children: [
              Icon(Icons.warning, color: Colors.red, size: 30),
              SizedBox(width: 10),
              Expanded(child: Text('Elimina il match')),
            ],
          ),
          content: const Text(
            'Sei sicuro di voler eliminare questo match? Questa azione non può essere annullata.',
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
              child: const Text('Annulla'),
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
              child: const Text('Elimina', style: TextStyle(color: Colors.white)),
              onPressed: () {
                Navigator.of(context).pop();
                // Call the onDelete callback when pressed
                widget.onDelete(widget.matchId); // Using the matchId from the widget
              },
            ),
          ],
        );
      },
    );
  }
}
