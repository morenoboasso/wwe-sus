import 'package:flutter/material.dart';

import '../controllers/match_close_controller.dart';
import '../controllers/vote_controller.dart';
import '../models/match_list_item.dart';
import '../models/match_model.dart';
import '../models/vote_model.dart';
import '../style/color_style.dart';
import '../style/text_style.dart';
import 'common/custom_snackbar.dart';

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
    final importanceLabel = _importanceLabel(widget.item.match);

    if (_freeTextController.text.isEmpty && widget.item.userVote?.winnerText != null) {
      _freeTextController.text = widget.item.userVote!.winnerText!;
    }

    return Padding(
      padding: EdgeInsets.only(top: importanceLabel != null ? 12 : 0),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _isExpanded = !_isExpanded;
          });
        },
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            Card(
              elevation: 0,
              color: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isMatchCompleted
                        ? [
                            Colors.amberAccent.withValues(alpha: 0.28),
                            Colors.amberAccent.withValues(alpha: 0.16),
                          ]
                        : (userSelection != null
                            ? [
                                Colors.blue.withValues(alpha: 0.26),
                                Colors.lightBlueAccent.withValues(alpha: 0.14),
                              ]
                            : [
                                Colors.black.withValues(alpha: 0.22),
                                Colors.black.withValues(alpha: 0.12),
                              ]),
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(15.0),
                  border: Border.all(
                    color: ColorsBets.whiteHD.withValues(alpha: 0.2),
                  ),
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
                const SizedBox(height: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Match: ${widget.item.match.title}',
                      style: MemoText.secondRowMatchInfo.copyWith(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.item.match.type,
                      style: MemoText.thirdRowMatchInfo.copyWith(color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                if (isOpen)
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: _buildVoteProgress(predictionType),
                  ),

                if (_isExpanded) ...[
                  const Divider(color: Colors.black26, thickness: 2),
                  const SizedBox(height: 12),
                  if (userSelection != null) ...[
                    Text(
                      'Hai votato: $userSelection',
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                  ],
                  if (matchWinner != null && isMatchCompleted && userSelection != null) ...[
                    const Divider(color: Colors.black26, thickness: 2),
                    const SizedBox(height: 10),
                  ],
                  if (matchWinner != null && isMatchCompleted) ...[
                    Text(
                      'Vincitore: $matchWinner',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                  if (!isMatchCompleted && userSelection == null)
                    _buildVoteSection(
                      predictionType: predictionType,
                      isOpen: isOpen,
                      hasVoted: widget.item.hasVoted,
                    ),
                  if (isOpen && userSelection != null)
                    _buildAdminCloseSection(predictionType: predictionType),
                  const SizedBox(height: 16),
                  TextButton.icon(
                    icon: const Icon(Icons.delete, color: Colors.white, size: 16),
                    onPressed: _showDeleteConfirmation,
                    label: const Text(
                      'Elimina Match',
                      style: TextStyle(
                        color: Colors.white,
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.white,
                      ),
                    ),
                  ),
                ],
                    ],
                  ),
                ),
              ),
            ),
            if (importanceLabel != null)
              Positioned(
                top: -6,
                child: _buildImportanceBadge(importanceLabel),
              ),
          ],
        ),
      ),
    );
  }

  String? _importanceLabel(Match match) {
    if (match.isMainEvent && match.isTitleMatch) {
      return 'MAIN EVENT + TITLE MATCH';
    }
    if (match.isMainEvent) {
      return 'MAIN EVENT';
    }
    if (match.isTitleMatch) {
      return 'TITLE MATCH';
    }
    return null;
  }

  Widget _buildImportanceBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: ColorsBets.whiteHD,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: ColorsBets.blackHD, width: 1.5),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: ColorsBets.blackHD,
          fontWeight: FontWeight.w800,
          fontSize: 11,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildVoteProgress(PredictionType predictionType) {
    final stats = widget.item.voteStats;
    final totalLabel = '${stats.totalVotes} ${stats.totalVotes == 1 ? 'utente ha votato' : 'utenti hanno votato'}';

    if (predictionType == PredictionType.freeText) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            totalLabel,
            style: MemoText.thirdRowMatchInfo.copyWith(color: Colors.white),
          ),
        ],
      );
    }

    final wrestlers = widget.item.match.wrestlers;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          totalLabel,
          style: MemoText.thirdRowMatchInfo.copyWith(color: Colors.white),
        ),
        const SizedBox(height: 8),
        ...wrestlers.map((wrestler) {
          final percentValue = stats.percentageFor(wrestler);
          final percentLabel = (percentValue * 100).toStringAsFixed(0);

          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        wrestler,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '$percentLabel%',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    minHeight: 8,
                    value: percentValue,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildAdminCloseSection({required PredictionType predictionType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 8),
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
              child: Container
                (
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: ColorsBets.whiteHD.withValues(alpha: 0.16),
                      width: 1,
                    ),
                  ),
                ),
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  wrestler,
                  style: const TextStyle(
                    color: ColorsBets.whiteHD,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
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
            backgroundColor: Colors.white,
            side: const BorderSide(color: Colors.white, width: 2.0),
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
            backgroundColor: Colors.white,
            side: const BorderSide(color: Colors.white, width: 2.0),
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

            const noneOptionLabel = 'Nessuno dei precedenti';
            final votes = snapshot.data ?? [];
            final counts = <String, int>{};
            for (final vote in votes) {
              final text = vote.winnerText?.trim();
              if (text == null || text.isEmpty) continue;
              counts[text] = (counts[text] ?? 0) + 1;
            }

            final entries = counts.entries.toList()
              ..sort((a, b) => a.key.toLowerCase().compareTo(b.key.toLowerCase()));

            final hasNoneOption = entries.any((entry) => entry.key == noneOptionLabel);
            if (hasNoneOption) {
              entries.removeWhere((entry) => entry.key == noneOptionLabel);
            }
            entries.add(MapEntry(noneOptionLabel, counts[noneOptionLabel] ?? 0));

            return StatefulBuilder(
              builder: (context, setDialogState) {
                return AlertDialog(
                  backgroundColor: ColorsBets.blackHD,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                    side: const BorderSide(color: ColorsBets.whiteHD, width: 1.4),
                  ),
                  title: const Text(
                    'Seleziona Vincitori',
                    style: TextStyle(
                      color: ColorsBets.whiteHD,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                    ),
                  ),
                  content: SizedBox(
                    width: double.maxFinite,
                    child: entries.isEmpty
                        ? const Text(
                            'Nessun voto disponibile.',
                            style: TextStyle(color: ColorsBets.whiteHD),
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            itemCount: entries.length,
                            separatorBuilder: (_, __) => Divider(
                              color: Colors.white.withValues(alpha: 0.12),
                              height: 10,
                            ),
                            itemBuilder: (context, index) {
                              final entry = entries[index];
                              final isSelected = selectedTexts.contains(entry.key);

                              return CheckboxListTile(
                                value: isSelected,
                                dense: true,
                                activeColor: Colors.amber,
                                checkColor: ColorsBets.blackHD,
                                contentPadding: EdgeInsets.zero,
                                title: Text(
                                  '${entry.key} (${entry.value})',
                                  style: const TextStyle(
                                    color: ColorsBets.whiteHD,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
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
                  actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(
                        'Annulla',
                        style: TextStyle(color: ColorsBets.whiteHD, fontWeight: FontWeight.w600),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorsBets.whiteHD,
                        foregroundColor: ColorsBets.blackHD,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () => Navigator.of(context).pop(selectedTexts),
                      child: const Text(
                        'Conferma',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
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

  Future<void> _showDeleteConfirmation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: ColorsBets.blackHD,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(color: ColorsBets.whiteHD, width: 1.4),
          ),
          title: const Text(
            'Eliminare il match?',
            style: TextStyle(
              color: ColorsBets.whiteHD,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
            ),
          ),
          content: const Text(
            'Questa azione rimuoverà il match e i pronostici associati.',
            style: TextStyle(color: ColorsBets.whiteHD),
          ),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'Annulla',
                style: TextStyle(color: ColorsBets.whiteHD, fontWeight: FontWeight.w600),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorsBets.whiteHD,
                foregroundColor: ColorsBets.blackHD,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                'Elimina',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      widget.onDelete();
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
