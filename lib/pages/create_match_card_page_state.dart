part of 'create_match_card_page.dart';

class CreateMatchCardPageState extends State<CreateMatchCardPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _ppvController = TextEditingController();
  final CreateMatchController _controller = CreateMatchController();

  bool _isTitleMatch = false;
  bool _isMainEvent = false;
  PredictionType _predictionType = PredictionType.standard;
  List<String> _wrestlers = ['', ''];
  bool _isLoading = false;

  @override
  void dispose() {
    _typeController.dispose();
    _ppvController.dispose();
    super.dispose();
  }

  bool get _canSubmit => _controller.canSubmit(
        type: _typeController.text,
        ppvName: _ppvController.text,
        predictionType: _predictionType,
        wrestlers: _wrestlers,
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          GestureDetector(
            onTap: (_isLoading || !_canSubmit) ? null : _submitMatch,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : AutoSizeText(
                          'Crea',
                          style: MemoText.createMatchCardButton.copyWith(
                            color: _canSubmit ? Colors.white : Colors.grey,
                          ),
                          minFontSize: 16,
                          maxLines: 1,
                        ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward,
                    color: _canSubmit ? Colors.white : Colors.grey,
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
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    const SizedBox(height: 22),
                    Text('Tipo di Match*', style: MemoText.createInputMainText),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _typeController,
                      decoration: InputDecorations.standard('Inserisci il tipo di match...'),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 22),
                    Text('PPV*', style: MemoText.createInputMainText),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _ppvController,
                      decoration: InputDecorations.standard('Inserisci il nome del PPV...'),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 22),
                    TitleCheckbox(
                      isChecked: _isTitleMatch,
                      onChanged: (value) {
                        setState(() {
                          _isTitleMatch = value ?? false;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Main Event',
                          style: MemoText.createInputMainText,
                        ),
                        Checkbox(
                          value: _isMainEvent,
                          onChanged: (value) {
                            setState(() {
                              _isMainEvent = value ?? false;
                            });
                          },
                          checkColor: Colors.black,
                          fillColor: WidgetStateProperty.all(Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text('Tipo di previsione*', style: MemoText.createInputMainText),
                    const SizedBox(height: 8),
                    SegmentedButton<PredictionType>(
                      segments: const [
                        ButtonSegment<PredictionType>(
                          value: PredictionType.standard,
                          label: Text('Preimpostati', style: TextStyle(color: Colors.white)),
                        ),
                        ButtonSegment<PredictionType>(
                          value: PredictionType.freeText,
                          label: Text('Campo Libero', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                      selected: <PredictionType>{_predictionType},
                      onSelectionChanged: (selection) {
                        if (selection.isEmpty) return;
                        setState(() {
                          _predictionType = selection.first;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    if (_predictionType == PredictionType.standard) ...[
                      Text('Inserisci Partecipanti*', style: MemoText.createInputMainText),
                      const SizedBox(height: 8),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: (_wrestlers.length / 2).ceil(),
                        itemBuilder: (context, rowIndex) {
                          final index1 = rowIndex * 2;
                          final index2 = index1 + 1;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: WrestlerInputRow(
                              index1: index1,
                              index2: index2,
                              wrestlers: _wrestlers,
                              onWrestlerChanged: _onWrestlerChanged,
                              onRemoveWrestler: _removeWrestler,
                              addWrestlerCallback: _addWrestler,
                              canAddWrestler: _wrestlers.length < 20 &&
                                  rowIndex == (_wrestlers.length / 2).ceil() - 1,
                            ),
                          );
                        },
                      ),
                    ],
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _addWrestler() {
    setState(() {
      _wrestlers = [..._wrestlers, ''];
    });
  }

  void _removeWrestler(int index) {
    if (_wrestlers.length <= 2) {
      _showErrorSnackbar('Devi avere almeno due partecipanti.');
      return;
    }
    setState(() {
      _wrestlers = [..._wrestlers]..removeAt(index);
    });
  }

  void _onWrestlerChanged(int index, String name) {
    setState(() {
      final updated = [..._wrestlers];
      updated[index] = name;
      _wrestlers = updated;
    });
  }

  Future<void> _submitMatch() async {
    if (!_canSubmit) return;

    setState(() {
      _isLoading = true;
    });

    final navigator = Navigator.of(context);
    try {
      await _controller.createMatch(
        type: _typeController.text,
        ppvName: _ppvController.text,
        isTitleMatch: _isTitleMatch,
        isMainEvent: _isMainEvent,
        predictionType: _predictionType,
        wrestlers: _wrestlers,
      );

      if (!mounted) return;
      _showSuccessSnackbar('Match creato con successo!');
      navigator.pushReplacement(
        MaterialPageRoute(
          builder: (context) => const BottomNavigationBarWidget(),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      _showErrorSnackbar('Errore durante il salvataggio. Riprova.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
