import 'package:flutter/material.dart';
import 'package:wwe_bets/widgets/create_match_card/ppv_dropdown.dart';
import '../../services/db_service.dart';
import '../../widgets/create_match_card/title_checkbox.dart';
import '../../widgets/create_match_card/wrestler_input_row.dart';

class CreateMatchCardPage extends StatefulWidget {
  const CreateMatchCardPage({super.key});

  @override
  _CreateMatchCardPageState createState() => _CreateMatchCardPageState();
}

class _CreateMatchCardPageState extends State<CreateMatchCardPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();
  DbService dbService = DbService();

  String? _selectedPPV;
  bool _showTitleField = false;
  List<String> wrestlers = ['', ''];

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      hintStyle: const TextStyle(color: Colors.black),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.black),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.black),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.black),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
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
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: Form(
                      key: _formKey,
                      child: ListView(
                        children: <Widget>[
                          const Text('PPV *', style: TextStyle(color: Colors.white)),
                          const SizedBox(height: 8),
                          PPVInput(
                            selectedPPV: _selectedPPV,
                            onChanged: (value) {
                              setState(() {
                                _selectedPPV = value;
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          TitleCheckbox(
                            isChecked: _showTitleField,
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _showTitleField = value;
                                });
                              }
                            },
                          ),
                          if (_showTitleField)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: TextFormField(
                                controller: _titleController,
                                decoration: _inputDecoration('Inserisci il titolo..'),
                              ),
                            ),
                          const SizedBox(height: 16),
                          const Text('Tipo di Match *', style: TextStyle(color: Colors.white)),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _typeController,
                            decoration: _inputDecoration('Inserisci il tipo di match..'),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Inserisci tipo di match.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          const Text('Inserisci Partecipanti *', style: TextStyle(color: Colors.white)),
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
          Positioned(
            top: 16,
            right: 16,
            child: Row(
              children: [
                GestureDetector(
                  onTap: _saveMatchCard,
                  child: Container(
                    color: Colors.transparent, // Aggiungi uno sfondo trasparente
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: const Row(
                      children: [
                        Text(
                          "Crea",
                          style: TextStyle(color: Colors.white),
                        ),
                        SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
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
      List<String> validWrestlers = _getValidWrestlers();
      final payperview = _selectedPPV!;
      final title = _showTitleField ? _titleController.text : '';
      final type = _typeController.text;

      await dbService.createMatchCard(
          payperview, title, type, validWrestlers);
    }
  }
}
