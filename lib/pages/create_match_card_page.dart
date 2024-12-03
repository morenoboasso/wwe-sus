import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:wwe_bets/services/db_service.dart';
import 'package:wwe_bets/style/text_style.dart';
import 'package:wwe_bets/widgets/create_match_card/title_checkbox.dart';
import 'package:wwe_bets/widgets/create_match_card/wrestler_input_row.dart';
import '../widgets/bottom_navigation_bar_widget.dart';
import '../widgets/common/input_decoration.dart';
import '../widgets/common/custom_snackbar.dart';

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
  bool _isLoading = false;

  bool _showTitleField = false;
  List<String> wrestlers = ['', ''];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          GestureDetector(
            onTap: (_isLoading || !_canCreateMatch()) ? null : _saveMatchCard, // Disable if loading or validation fails
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _isLoading
                      ? const CircularProgressIndicator(color: Colors.white) // Show loader if loading
                      : AutoSizeText(
                    "Crea",
                    style: MemoText.createMatchCardButton.copyWith(
                      color: _canCreateMatch() ? Colors.white : Colors.grey,
                    ),
                    minFontSize: 16,
                    maxLines: 1,
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward,
                    color: _canCreateMatch() ? Colors.white : Colors.grey,
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
                              if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
                                return 'Il tipo di match può contenere solo lettere e spazi.';
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

  bool _canCreateMatch() {
    if (_typeController.text.trim().isEmpty ||
        _getValidWrestlers().length < 2 ) {
      return false;
    }
    return true;
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
    } else {
      _showErrorSnackbar('Devi avere almeno due partecipanti.');
    }
  }

  void _onWrestlerChanged(int index, String name) {
    setState(() {
      wrestlers[index] = name;
    });
  }

  List<String> _getValidWrestlers() {
    return wrestlers
        .map((wrestler) => _capitalizeFirstLetterOfEachWord(wrestler.trim()))
        .where((wrestler) => wrestler.isNotEmpty)
        .toList();
  }

  String _capitalizeFirstLetterOfEachWord(String input) {
    List<String> minorWords = ['di', 'e', 'con'];
    return input
        .split(' ')
        .map((word) => minorWords.contains(word.toLowerCase())
        ? word
        : word.isEmpty
        ? ''
        : word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  void _saveMatchCard() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      List<String> validWrestlers = _getValidWrestlers();
      final type = _capitalizeFirstLetterOfEachWord(_typeController.text);
      final title = _capitalizeFirstLetterOfEachWord(_titleController.text);
      try {
        await dbService.createMatchCard(title, type, validWrestlers);
        _showSuccessSnackbar('Match creato con successo!');

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const BottomNavigationBarWidget(),
          ),
        );
      } catch (error) {
        _showErrorSnackbar('Errore durante il salvataggio. Riprova.');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      _showErrorSnackbar('Compila tutti i campi obbligatori.');
    }
  }

  void _showErrorSnackbar(String message) {
    CustomSnackbar(
      color: Colors.red,
      context: context,
      message: message,
      icon: Icons.report_gmailerrorred,
    ).show();
  }

  void _showSuccessSnackbar(String message) {
    CustomSnackbar(
      color: Colors.green,
      context: context,
      message: message,
      icon: Icons.check_circle,
    ).show();
  }
}
