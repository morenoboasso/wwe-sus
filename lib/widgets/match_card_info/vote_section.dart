import 'package:flutter/material.dart';

import '../../style/color_style.dart';
import '../../style/text_style.dart';

class VoteSection extends StatelessWidget {
  final bool isMatchCompleted;
  final String? matchWinner;
  final String? userSelection;
  final bool isSubmitted;
  final List<String> selectableWrestlers;
  final String? selectedWrestler;
  final ValueChanged<String?> onSelectionChanged;
  final VoidCallback onVoteConfirmed;
  final VoidCallback onShowWinnerSelectionDialog;

  const VoteSection({
    required this.isMatchCompleted,
    required this.matchWinner,
    required this.userSelection,
    required this.isSubmitted,
    required this.selectableWrestlers,
    required this.selectedWrestler,
    required this.onSelectionChanged,
    required this.onVoteConfirmed,
    required this.onShowWinnerSelectionDialog,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return isMatchCompleted
        ? Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text('Vincitore:', style: MemoText.secondRowMatchInfo.copyWith(color: Colors.white)),
        Text(matchWinner ?? '', style: MemoText.thirdRowMatchInfo),
        const SizedBox(height: 10.0),
        Text('Hai votato:', style: MemoText.secondRowMatchInfo.copyWith(color: Colors.white)),
        Text(userSelection ?? 'Nessun voto', style: MemoText.thirdRowMatchInfo),
      ],
    )
        : Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
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
                value: selectedWrestler,
                items: selectableWrestlers.map<DropdownMenuItem<String>>((String wrestler) {
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
                onChanged: isSubmitted ? null : onSelectionChanged,
                hint: Text('Seleziona il vincitore', style: MemoText.thirdRowMatchInfo),
              ),
              const Divider(color: Colors.black26, thickness: 2),
              const SizedBox(height: 12.0),
              ElevatedButton(
                onPressed: isSubmitted ? null : onVoteConfirmed,
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
              Text(userSelection ?? '', style: const TextStyle(color: Colors.white)),
              const SizedBox(height: 15),
              const Divider(color: Colors.black26, thickness: 2),

              const SizedBox(height: 12.0),
              ElevatedButton(
                onPressed: onShowWinnerSelectionDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
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
    );
  }
}
