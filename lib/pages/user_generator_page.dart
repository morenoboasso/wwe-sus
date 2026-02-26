import 'package:flutter/material.dart';

import '../controllers/user_generator_controller.dart';
import '../style/text_style.dart';

class UserGeneratorPage extends StatefulWidget {
  const UserGeneratorPage({super.key});

  @override
  State<UserGeneratorPage> createState() => _UserGeneratorPageState();
}

class _UserGeneratorPageState extends State<UserGeneratorPage> {
  final TextEditingController _namesController = TextEditingController();
  final UserGeneratorController _controller = UserGeneratorController();
  bool _isSaving = false;

  @override
  void dispose() {
    _namesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final names = _namesController.text.trim();
    if (names.isEmpty) {
      _showSnackbar('Inserisci almeno un nome');
      return;
    }
    setState(() => _isSaving = true);
    try {
      final result = await _controller.createUsersFromRawNames(names);
      if (!mounted) return;
      _showSnackbar('Creati ${result.createdCount} profili');
      _namesController.clear();
    } catch (e) {
      if (!mounted) return;
      _showSnackbar('Errore: $e');
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final padding = EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.06);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Generator profilo', style: MemoText.createMatchCardButton),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/bg.jpeg',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: padding.add(const EdgeInsets.symmetric(vertical: 24)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Inserisci i nomi (uno per riga o separati da virgola). Gli ID vengono generati in automatico.',
                    style: MemoText.noMatches,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _namesController,
                    minLines: 6,
                    maxLines: null,
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'Inserisci nomi giocatori',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _isSaving ? null : _submit,
                    icon: _isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.person_add_alt),
                    label: Text(_isSaving ? 'Creazione...' : 'Crea profili'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
