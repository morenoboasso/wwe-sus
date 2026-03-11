part of 'create_match_card_page.dart';

class CreateMatchCardPageState extends State<CreateMatchCardPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _ppvController = TextEditingController();
  final CreateMatchController _controller = CreateMatchController();
  final List<TextEditingController> _wrestlerControllers = [];

  bool _isTitleMatch = false;
  bool _isMainEvent = false;
  PredictionType _predictionType = PredictionType.standard;
  List<String> _wrestlers = ['', ''];
  bool _isLoading = false;
  List<String> _ppvSuggestions = [];
  bool _ppvSuggestionsLoaded = false;
  bool _ppvSuggestionsLoading = false;
  List<String> _rosterSuggestions = [];
  bool _rosterSuggestionsLoaded = false;
  bool _rosterSuggestionsLoading = false;

  @override
  void initState() {
    super.initState();
    _syncWrestlerControllers();
    _loadPpvSuggestions();
    _loadRosterSuggestions();
  }

  @override
  void dispose() {
    _typeController.dispose();
    _ppvController.dispose();
    for (final controller in _wrestlerControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  bool get _canSubmit => _controller.canSubmit(
        type: _typeController.text,
        ppvName: _ppvController.text,
        predictionType: _predictionType,
        wrestlers: _wrestlers,
      );

  Future<void> _loadPpvSuggestions() async {
    if (_ppvSuggestionsLoading || _ppvSuggestionsLoaded) return;
    setState(() {
      _ppvSuggestionsLoading = true;
    });
    try {
      final suggestions = await _controller.fetchPpvSuggestions();
      if (!mounted) return;
      setState(() {
        _ppvSuggestions = suggestions;
        _ppvSuggestionsLoaded = true;
        _ppvSuggestionsLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _ppvSuggestionsLoading = false;
      });
    }
  }

  Future<void> _loadRosterSuggestions() async {
    if (_rosterSuggestionsLoading || _rosterSuggestionsLoaded) return;
    setState(() {
      _rosterSuggestionsLoading = true;
    });
    try {
      final suggestions = await _controller.fetchRosterSuggestions();
      if (!mounted) return;
      setState(() {
        _rosterSuggestions = suggestions;
        _rosterSuggestionsLoaded = true;
        _rosterSuggestionsLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _rosterSuggestionsLoading = false;
      });
    }
  }

  Future<List<String>> _getPpvSuggestions(String pattern) async {
    if (!_ppvSuggestionsLoaded) {
      await _loadPpvSuggestions();
    }
    final query = pattern.trim().toLowerCase();
    if (query.isEmpty) {
      return [];
    }
    final filtered = _ppvSuggestions.where((ppv) {
      return ppv.toLowerCase().contains(query);
    }).toList();
    if (filtered.length > 6) {
      return filtered.sublist(0, 6);
    }
    return filtered;
  }

  Future<List<String>> _getWrestlerSuggestions(String pattern) async {
    if (!_rosterSuggestionsLoaded) {
      await _loadRosterSuggestions();
    }
    final query = pattern.trim().toLowerCase();
    if (query.isEmpty) {
      return [];
    }
    final filtered = _rosterSuggestions.where((name) {
      return name.toLowerCase().contains(query);
    }).toList();
    if (filtered.length > 8) {
      return filtered.sublist(0, 8);
    }
    return filtered;
  }

  SuggestionsBoxDecoration _suggestionsDecoration(BuildContext context) {
    final media = MediaQuery.of(context);
    final available = media.size.height - media.viewInsets.bottom - 200;
    final maxHeight = available.clamp(120.0, media.size.height * 0.5);
    return SuggestionsBoxDecoration(
      color: Colors.white,
      elevation: 6,
      constraints: BoxConstraints(maxHeight: maxHeight.toDouble()),
    );
  }

  void _syncWrestlerControllers() {
    if (_wrestlerControllers.length < _wrestlers.length) {
      for (var i = _wrestlerControllers.length; i < _wrestlers.length; i++) {
        _wrestlerControllers.add(TextEditingController(text: _wrestlers[i]));
      }
      return;
    }
    if (_wrestlerControllers.length > _wrestlers.length) {
      for (var i = _wrestlerControllers.length - 1; i >= _wrestlers.length; i--) {
        _wrestlerControllers[i].dispose();
        _wrestlerControllers.removeAt(i);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final suggestionsDecoration = _suggestionsDecoration(context);
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
                    TypeAheadFormField<String>(
                      textFieldConfiguration: TextFieldConfiguration(
                        controller: _ppvController,
                        decoration: InputDecorations.standard('Inserisci il nome del PPV...'),
                        onChanged: (_) => setState(() {}),
                      ),
                      suggestionsCallback: (pattern) => _getPpvSuggestions(pattern),
                      suggestionsBoxDecoration: suggestionsDecoration,
                      direction: AxisDirection.down,
                      autoFlipDirection: true,
                      autoFlipListDirection: true,
                      autoFlipMinHeight: 80,
                      minCharsForSuggestions: 1,
                      loadingBuilder: (context) => const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: CircularProgressIndicator(),
                      ),
                      hideOnEmpty: true,
                      hideOnLoading: true,
                      hideOnError: true,
                      itemBuilder: (context, suggestion) {
                        return ListTile(
                          title: Text(
                            suggestion,
                            style: const TextStyle(color: Colors.black),
                          ),
                        );
                      },
                      onSuggestionSelected: (suggestion) {
                        _ppvController.text = suggestion;
                        setState(() {});
                      },
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
                      style: ButtonStyle(
                        side: WidgetStateProperty.all(
                          const BorderSide(color: Colors.white, width: 1.0),
                        ),
                        backgroundColor: WidgetStateProperty.resolveWith((states) {
                          if (states.contains(WidgetState.selected)) {
                            return Colors.white;
                          }
                          return Colors.white.withValues(alpha: 0.12);
                        }),
                        foregroundColor: WidgetStateProperty.resolveWith((states) {
                          if (states.contains(WidgetState.selected)) {
                            return Colors.black;
                          }
                          return Colors.white;
                        }),
                      ),
                      segments: const [
                        ButtonSegment<PredictionType>(
                          value: PredictionType.standard,
                          label: Text('Preimpostati'),
                        ),
                        ButtonSegment<PredictionType>(
                          value: PredictionType.freeText,
                          label: Text('Campo Libero'),
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
                              controller1: _wrestlerControllers[index1],
                              controller2: index2 < _wrestlerControllers.length
                                  ? _wrestlerControllers[index2]
                                  : null,
                              wrestlers: _wrestlers,
                              onWrestlerChanged: _onWrestlerChanged,
                              onRemoveWrestler: _removeWrestler,
                              addWrestlerCallback: _addWrestler,
                              suggestionsCallback: _getWrestlerSuggestions,
                              suggestionsBoxDecoration: suggestionsDecoration,
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
      _wrestlerControllers.add(TextEditingController());
    });
  }

  void _removeWrestler(int index) {
    if (_wrestlers.length <= 2) {
      _showErrorSnackbar('Devi avere almeno due partecipanti.');
      return;
    }
    setState(() {
      _wrestlers = [..._wrestlers]..removeAt(index);
      if (index < _wrestlerControllers.length) {
        _wrestlerControllers[index].dispose();
        _wrestlerControllers.removeAt(index);
      }
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
      await Future.delayed(const Duration(milliseconds: 500));
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
