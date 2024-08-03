import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../services/db_service.dart';
import '../../services/submit_bet.dart';
import '../../style/color_style.dart';
import '../../style/text_style.dart';
import '../../widgets/create_bets/bet_descr_input.dart';
import '../../widgets/create_bets/bet_risposte_input.dart';
import '../../widgets/create_bets/bet_target_dropdown.dart';
import '../../widgets/create_bets/bet_title_input.dart';
import '../../widgets/debug_only/clear_bets.dart';

class CreateBetPage extends StatefulWidget {
  const CreateBetPage({super.key});

  @override
  _CreateBetPageState createState() => _CreateBetPageState();
}

class _CreateBetPageState extends State<CreateBetPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late String _title;
  String _description = '';
  String _answer1 = '';
  String _answer2 = '';
  String _answer3 = '';
  String _answer4 = '';
  String? _selectedUser;
  List<Map<String, String>> _usersList = [];
  bool _showThirdAnswer = false;
  bool _showFourthAnswer = false;
  DbService dbService = DbService();

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    List<Map<String, String>> usersList = await dbService.getUsersListWithAvatars();
    setState(() {
      _usersList = usersList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/bg.png"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            _submit();
                          }
                        },
                        child: Row(
                          children: [
                            Text('Crea', style: TextStyleBets.betTextTitle),
                            const SizedBox(width: 5),
                            const Icon(Icons.arrow_forward, color: ColorsBets.blueHD),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          BetTitleFormField(
                            formKey: _formKey,
                            onSaved: (newValue) {
                              _title = newValue!;
                            },
                          ),
                          BetTargetDropdownFormField(
                            usersList: _usersList,
                            selectedUser: _selectedUser,
                            onChanged: (newValue) {
                              setState(() {
                                _selectedUser = newValue;
                              });
                            },
                          ),
                          const SizedBox(height: 10),
                          BetDescriptionFormField(
                            onChanged: (value) {
                              _description = value;
                            },
                          ),
                          const SizedBox(height: 20),
                          BetAnswerFormField(
                            labelText: 'Risposta 1*',
                            hintText: "Es. Sì",
                            onSaved: (newValue) {
                              _answer1 = newValue!;
                            },
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Inserisci la prima risposta';
                              }
                              return null;
                            },
                          ),
                          BetAnswerFormField(
                            labelText: 'Risposta 2*',
                            hintText: "Es. No",
                            onSaved: (newValue) {
                              _answer2 = newValue!;
                            },
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Inserisci la seconda risposta';
                              }
                              return null;
                            },
                          ),
                          if (_showThirdAnswer)
                            Row(
                              children: [
                                Expanded(
                                  child: BetAnswerFormField(
                                    labelText: 'Risposta 3',
                                    hintText: "Es. Yes",
                                    onSaved: (newValue) {
                                      _answer3 = newValue ?? '';
                                    },
                                    validator: (value) {
                                      return null;
                                    },
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.remove_circle, color: ColorsBets.blueHD),
                                  onPressed: () {
                                    setState(() {
                                      _showThirdAnswer = false;
                                      _answer3 = '';
                                    });
                                  },
                                ),
                              ],
                            ),
                          if (_showFourthAnswer)
                            Row(
                              children: [
                                Expanded(
                                  child: BetAnswerFormField(
                                    labelText: 'Risposta 4',
                                    hintText: "Es. Nope",
                                    onSaved: (newValue) {
                                      _answer4 = newValue ?? '';
                                    },
                                    validator: (value) {
                                      return null;
                                    },
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.remove_circle, color: ColorsBets.blueHD),
                                  onPressed: () {
                                    setState(() {
                                      _showFourthAnswer = false;
                                      _answer4 = '';
                                    });
                                  },
                                ),
                              ],
                            ),
                          const SizedBox(height: 20),
                          if (!_showThirdAnswer || (_showThirdAnswer && !_showFourthAnswer))
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                OutlinedButton(
                                  onPressed: () {
                                    setState(() {
                                      if (!_showThirdAnswer) {
                                        _showThirdAnswer = true;
                                      } else {
                                        _showFourthAnswer = true;
                                      }
                                    });
                                  },
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    side: const BorderSide(color: ColorsBets.blueHD, width: 2),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text('Aggiungi altre risposte', style: TextStyle(color: ColorsBets.blueHD)),
                                ),
                              ],
                            ),
                          const SizedBox(height: 20),
                          if (kDebugMode)
                            const Padding(
                              padding: EdgeInsets.only(top: 20),
                              child: Center(
                                child: ClearButton(),
                              ),
                            ),
                        ],
                      ),
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

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    SubmitBetService submitBetService = SubmitBetService(
      context: context,
      title: _title,
      selectedUser: _selectedUser,
      description: _description,
      answer1: _answer1,
      answer2: _answer2,
      answer3: _answer3,
      answer4: _answer4,
      formKey: _formKey,
      resetForm: _resetForm,
    );
    await submitBetService.submit();
  }

  void _resetForm() {
    setState(() {
      _formKey.currentState?.reset();
      _title = '';
      _selectedUser = null;
      _description = '';
      _answer1 = '';
      _answer2 = '';
      _answer3 = '';
      _answer4 = '';
      _showThirdAnswer = false;
      _showFourthAnswer = false;
    });
    FocusScope.of(context).unfocus();
  }
}