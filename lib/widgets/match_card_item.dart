import 'package:flutter/material.dart';

import '../controllers/match_close_controller.dart';
import '../controllers/vote_controller.dart';
import '../models/match_list_item.dart';
import '../models/match_model.dart';
import '../models/vote_model.dart';
import '../style/color_style.dart';
import '../style/text_style.dart';
import 'common/custom_snackbar.dart';
import 'match_card_info/match_info_row.dart';
import 'match_card_info/wrestler_list.dart';

class MatchCardItem extends StatefulWidget {
  const MatchCardItem({
    required this.item,
    required this.onVoteSubmitted,
    required this.onDelete,
    super.key,
  });

  final MatchListItem item;
  final VoidCallback onVoteSubmitted;
  final VoidCallback onDelete;

  @override
  MatchCardItemState createState() => MatchCardItemState();
}

class MatchCardItemState extends State<MatchCardItem> {
  bool _isExpanded = false;
  final MatchCloseController _closeController = MatchCloseController();
  final VoteController _voteController = VoteController();
  final TextEditingController _freeTextController = TextEditingController();
  String? _selectedWinner;
  String? _selectedResult;

  @override
  void dispose() {
    _freeTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMatchCompleted = widget.item.isCompleted;
    final userSelection = widget.item.userSelection;
    final matchWinner = widget.item.matchResult;
    final predictionType = widget.item.match.predictionType;
    final isOpen = widget.item.match.status == MatchStatus.open;

    if (_freeTextController.text.isEmpty && widget.item.userVote?.winnerText != null) {
      _freeTextController.text = widget.item.userVote!.winnerText!;
    }

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
            gradient: isMatchCompleted
                ? LinearGradient(
              colors: [
                Colors.amberAccent.shade700,
                Colors.amberAccent.shade200,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
                : (userSelection != null
                ? LinearGradient(
              colors: [
                Colors.blue.withValues(alpha: 0.7),
                Colors.lightBlueAccent.withValues(alpha: 0.7)
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
                : LinearGradient(
              colors: [
                Colors.black.withValues(alpha: 0.6),
                Colors.black.withValues(alpha: 0.3)
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )),
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
                    if (isMatchCompleted)
                      Icon(
                        userSelection == matchWinner
                            ? Icons.emoji_events
                            : Icons.sentiment_dissatisfied,
                        color: userSelection == matchWinner ? Colors.yellow : Colors.red,
                        size: 28,
                      )
                    else
                      (userSelection == null
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
                      )),
                    Icon(
                      _isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: Colors.white,
                    ),
                  ],
                ),

                if (_isExpanded) ...[
                  MatchInfoRow(
                    title: widget.item.match.title,
                    type: widget.item.match.type,
                  ),
                  const SizedBox(height: 20.0),
                ],
                if (_isExpanded && predictionType != PredictionType.freeText)
                  WrestlerList(wrestlers: widget.item.match.wrestlers)
                else if (!_isExpanded && predictionType == PredictionType.freeText)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    child: Text(
                      widget.item.match.type,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                else if (!_isExpanded)
                  WrestlerList(wrestlers: widget.item.match.wrestlers),
                if (_isExpanded) ...[
                  const SizedBox(height: 20.0),
                  if (userSelection != null) ...[
                    const Divider(color: Colors.black26, thickness: 2),
                    const SizedBox(height: 20),
                    Text(
                      'Hai votato: $userSelection',
                      style: const TextStyle(color: Colors.white),
                    ),
                    if (matchWinner != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Vincitore: $matchWinner',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                  if (!isMatchCompleted && userSelection == null)
                    _buildVoteSection(
                      predictionType: predictionType,
                      isOpen: isOpen,
                      hasVoted: widget.item.hasVoted,
                    ),
                  if (_isExpanded && isOpen && userSelection != null)
                    _buildAdminCloseSection(predictionType: predictionType),
                  TextButton.icon(
                    icon: const Icon(Icons.delete, color: Colors.black, size: 16),
                    onPressed: widget.onDelete,
                    label: const Text(
                      'Elimina Match',
                      style: TextStyle(
                        color: Colors.black,
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.black,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAdminCloseSection({required PredictionType predictionType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 16),
        const Divider(color: Colors.black26, thickness: 2),
        const SizedBox(height: 10),
        Text(
          'Chiudi Match:',
          style: MemoText.secondRowMatchInfo.copyWith(color: Colors.white),
        ),
        const SizedBox(height: 10),
        if (predictionType == PredictionType.standard)
          _buildAdminStandardClose()
        else
          _buildAdminFreeTextClose(),
      ],
    );
  }

  Widget _buildAdminStandardClose() {
    final selectable = widget.item.selectableWrestlers;
    final selectedResult = _selectedResult ?? widget.item.match.result;

    return Column(
      children: [
        DropdownButton<String>(
          dropdownColor: ColorsBets.blackHD,
          iconEnabledColor: ColorsBets.whiteHD,
          style: const TextStyle(color: ColorsBets.whiteHD),
          value: selectedResult,
          items: selectable.map((wrestler) {
            return DropdownMenuItem<String>(
              value: wrestler,
              child: Text(
                wrestler,
                style: const TextStyle(
                  color: ColorsBets.whiteHD,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedResult = value;
            });
          },
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: _confirmCloseStandard,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber,
            side: const BorderSide(color: Colors.black, width: 2.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            elevation: 0,
          ),
          child: const Text(
            'Conferma Risultato',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildAdminFreeTextClose() {
    return Column(
      children: [
        ElevatedButton(
          onPressed: _openFreeTextWinnersDialog,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber,
            side: const BorderSide(color: Colors.black, width: 2.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            elevation: 0,
          ),
          child: const Text(
            'Seleziona Vincitori',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildVoteSection({
    required PredictionType predictionType,
    required bool isOpen,
    required bool hasVoted,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Divider(color: Colors.black26, thickness: 2),
        const SizedBox(height: 10.0),
        if (predictionType == PredictionType.standard)
          _buildStandardVote(isOpen: isOpen, hasVoted: hasVoted)
        else
          _buildFreeTextVote(isOpen: isOpen, hasVoted: hasVoted),
      ],
    );
  }

  Widget _buildStandardVote({required bool isOpen, required bool hasVoted}) {
    final selectable = widget.item.selectableWrestlers;
    final selectedWinner = _selectedWinner ?? widget.item.userVote?.winnerId;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Scegli il Vincitore:',
          style: MemoText.secondRowMatchInfo.copyWith(color: Colors.white),
        ),
        const SizedBox(height: 10),
        DropdownButton<String>(
          dropdownColor: ColorsBets.blackHD,
          iconEnabledColor: ColorsBets.whiteHD,
          style: const TextStyle(color: ColorsBets.whiteHD),
          value: selectedWinner,
          items: selectable.map((wrestler) {
            return DropdownMenuItem<String>(
              value: wrestler,
              child: Text(
                wrestler,
                style: const TextStyle(
                  color: ColorsBets.whiteHD,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
            );
          }).toList(),
          onChanged: (isOpen && !hasVoted)
              ? (value) {
                  setState(() {
                    _selectedWinner = value;
                  });
                }
              : null,
          hint: Text('Seleziona il vincitore', style: MemoText.thirdRowMatchInfo),
        ),
        if (hasVoted)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              'Hai già votato',
              style: MemoText.thirdRowMatchInfo.copyWith(color: Colors.white),
            ),
          ),
        const SizedBox(height: 12.0),
        ElevatedButton(
          onPressed: (isOpen && !hasVoted) ? _confirmStandardVote : null,
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
    );
  }

  Widget _buildFreeTextVote({required bool isOpen, required bool hasVoted}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Scrivi il tuo pronostico:',
          style: MemoText.secondRowMatchInfo.copyWith(color: Colors.white),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _freeTextController,
          maxLines: 3,
          enabled: isOpen && !hasVoted,
          decoration: InputDecoration(
            filled: true,
            fillColor: ColorsBets.whiteHD.withValues(alpha: 0.9),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            hintText: 'Es. Cody Rhodes',
          ),
        ),
        if (hasVoted)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              'Hai già votato',
              style: MemoText.thirdRowMatchInfo.copyWith(color: Colors.white),
            ),
          ),
        const SizedBox(height: 12.0),
        ElevatedButton(
          onPressed: (isOpen && !hasVoted) ? _confirmFreeTextVote : null,
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
    );
  }

  Future<void> _confirmStandardVote() async {
    if (widget.item.hasVoted) {
      _showError('Hai già votato.');
      return;
    }
    final winnerId = _selectedWinner;
    if (winnerId == null || winnerId.isEmpty) {
      _showError('Seleziona un vincitore.');
      return;
    }

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      await _voteController.submitStandardVote(
        matchId: widget.item.match.id,
        winnerId: winnerId,
      );
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Pronostico salvato!')),
      );
      widget.onVoteSubmitted();
    } catch (e) {
      _showError('Errore durante il salvataggio.');
    }
  }

  Future<void> _confirmCloseStandard() async {
    final result = _selectedResult;
    if (result == null || result.isEmpty) {
      _showError('Seleziona un risultato.');
      return;
    }

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      await _closeController.closeStandardMatch(
        matchId: widget.item.match.id,
        result: result,
      );
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Match chiuso!')),
      );
      widget.onVoteSubmitted();
    } catch (e) {
      _showError('Errore durante la chiusura.');
    }
  }

  Future<void> _openFreeTextWinnersDialog() async {
    final selected = await showDialog<Set<String>>(
      context: context,
      builder: (context) {
        final initialSelection = widget.item.match.resultTexts ??
            (widget.item.match.resultText != null
                ? [widget.item.match.resultText!]
                : <String>[]);
        final selectedTexts = <String>{...initialSelection};

        return FutureBuilder<List<Vote>>(
          future: _voteController.fetchMatchVotes(matchId: widget.item.match.id),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const AlertDialog(
                content: SizedBox(
                  height: 120,
                  child: Center(
                    child: CircularProgressIndicator(color: ColorsBets.whiteHD),
                  ),
                ),
              );
            }

            if (snapshot.hasError) {
              return AlertDialog(
                title: const Text('Errore'),
                content: const Text('Impossibile caricare i voti.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Chiudi'),
                  ),
                ],
              );
            }

            final votes = snapshot.data ?? [];
            final counts = <String, int>{};
            for (final vote in votes) {
              final text = vote.winnerText?.trim();
              if (text == null || text.isEmpty) continue;
              counts[text] = (counts[text] ?? 0) + 1;
            }
            final entries = counts.entries.toList()
              ..sort((a, b) => a.key.toLowerCase().compareTo(b.key.toLowerCase()));

            return StatefulBuilder(
              builder: (context, setDialogState) {
                return AlertDialog(
                  title: const Text('Seleziona Vincitori'),
                  content: SizedBox(
                    width: double.maxFinite,
                    child: entries.isEmpty
                        ? const Text('Nessun voto disponibile.')
                        : ListView.builder(
                            shrinkWrap: true,
                            itemCount: entries.length,
                            itemBuilder: (context, index) {
                              final entry = entries[index];
                              final isSelected = selectedTexts.contains(entry.key);
                              return CheckboxListTile(
                                value: isSelected,
                                title: Text('${entry.key} (${entry.value})'),
                                controlAffinity: ListTileControlAffinity.leading,
                                onChanged: (value) {
                                  setDialogState(() {
                                    if (value == true) {
                                      selectedTexts.add(entry.key);
                                    } else {
                                      selectedTexts.remove(entry.key);
                                    }
                                  });
                                },
                              );
                            },
                          ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Annulla'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(selectedTexts),
                      child: const Text('Conferma'),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );

    if (!mounted) return;

    if (selected == null) return;
    if (selected.isEmpty) {
      _showError('Seleziona almeno un vincitore.');
      return;
    }

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      await _closeController.closeFreeTextMatchWithResults(
        matchId: widget.item.match.id,
        resultTexts: selected.toList(),
      );
      if (!mounted) return;
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Match chiuso!')),
      );
      widget.onVoteSubmitted();
    } catch (e) {
      if (!mounted) return;
      _showError('Errore durante la chiusura.');
    }
  }

  Future<void> _confirmFreeTextVote() async {
    if (widget.item.hasVoted) {
      _showError('Hai già votato.');
      return;
    }
    final text = _freeTextController.text.trim();
    if (text.isEmpty) {
      _showError('Scrivi il tuo pronostico.');
      return;
    }

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      await _voteController.submitFreeTextVote(
        matchId: widget.item.match.id,
        winnerText: text,
      );
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Pronostico salvato!')),
      );
      widget.onVoteSubmitted();
    } catch (e) {
      _showError('Errore durante il salvataggio.');
    }
  }

  void _showError(String message) {
    CustomSnackbar(
      color: Colors.red,
      context: context,
      message: message,
      icon: Icons.error,
    ).show();
  }
}
