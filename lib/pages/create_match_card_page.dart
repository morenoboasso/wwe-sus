import 'package:flutter/material.dart';
import 'package:wwe_bets/services/db_service.dart';
import 'package:wwe_bets/style/text_style.dart';
import 'package:wwe_bets/widgets/create_match_card/ppv_input.dart';
import 'package:wwe_bets/widgets/create_match_card/title_checkbox.dart';
import 'package:wwe_bets/widgets/create_match_card/wrestler_input_row.dart';
import '../widgets/common/input_decoration.dart';
import '../widgets/common/custom_snackbar.dart';  // Importa il widget

class CreateMatchCardPage extends StatefulWidget {
  const CreateMatchCardPage({super.key});

  @override
  _CreateMatchCardPageState createState() => _CreateMatchCardPageState();
}

class _CreateMatchCardPageState extends State<CreateMatchCardPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();
  final DbService dbService = DbService();

  String? _selectedPPV;
  bool _showTitleField = false;
  List<String> wrestlers = ['', ''];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          GestureDetector(
            onTap: _saveMatchCard,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    "Crea",
                    style: MemoText.createMatchCardButton,
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
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
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: Form(
                      key: _formKey,
                      child: ListView(
                        children: <Widget>[
                          Text('Nome PPV *', style: MemoText.createInputMainText),
                          const SizedBox(height: 8),
                          PPVInput(
                            selectedPPV: _selectedPPV,
                            onChanged: (value) {
                              setState(() {
                                _selectedPPV = value;
                              });
                            },
                          ),
                          const SizedBox(height: 22),
                          TitleCheckbox(
                            isChecked: _showTitleField,
                            onChanged: (value) {
                              setState(() {
                                _showTitleField = value!;
                              });
                            },
                          ),
                          if (_showTitleField)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: TextFormField(
                                controller: _titleController,
                                decoration: InputDecorations.standard('Inserisci il titolo..'),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Inserisci il titolo.';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          const SizedBox(height: 22),
                          Text('Tipo di Match *', style: MemoText.createInputMainText),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _typeController,
                            decoration: InputDecorations.standard('Inserisci il tipo di match..'),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Inserisci tipo di match.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 22),
                          Text('Inserisci Partecipanti *', style: MemoText.createInputMainText),
                          const SizedBox(height: 8),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: (wrestlers.length / 2).ceil(),
                            itemBuilder: (context, rowIndex) {
                              int index1 = rowIndex * 2;
                              int index2 = index1 + 1;

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: WrestlerInputRow(
                                  index1: index1,
                                  index2: index2,
                                  wrestlers: wrestlers,
                                  onWrestlerChanged: _onWrestlerChanged,
                                  onRemoveWrestler: _removeWrestler,
                                  addWrestlerCallback: _addWrestler,
                                  canAddWrestler: wrestlers.length < 20 && rowIndex == (wrestlers.length / 2).ceil() - 1,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _addWrestler() {
    setState(() {
      wrestlers.add('');
    });
  }

  void _removeWrestler(int index) {
    if (wrestlers.length > 2) {
      setState(() {
        wrestlers.removeAt(index);
      });
    }
  }

  void _onWrestlerChanged(int index, String name) {
    setState(() {
      wrestlers[index] = name;
    });
  }

  List<String> _getValidWrestlers() {
    return wrestlers
        .map((wrestler) => wrestler.trim())
        .where((wrestler) => wrestler.isNotEmpty)
        .toList();
  }

  void _saveMatchCard() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedPPV == null || _selectedPPV!.isEmpty) {
        _showErrorSnackbar('Seleziona un PPV.');
        return;
      }

      List<String> validWrestlers = _getValidWrestlers();
      if (validWrestlers.isEmpty) {
        _showErrorSnackbar('Inserisci almeno un partecipante.');
        return;
      }

      final payperview = _selectedPPV!;
      final title = _showTitleField ? _titleController.text : '';
      final type = _typeController.text;

      await dbService.createMatchCard(payperview, title, type, validWrestlers);
    } else {
      _showErrorSnackbar('Compila tutti i campi obbligatori.');
    }
  }

  void _showErrorSnackbar(String message) {
    CustomSnackbar(
      context: context,
      message: message,
      icon: Icons.report_gmailerrorred,
    ).show();
  }
}
