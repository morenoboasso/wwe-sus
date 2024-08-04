import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wwe_bets/services/db_service.dart';
import '../../routes/routes.dart';
import '../../types/ppv_options.dart';
import 'add_wrestler_page.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crea Match Card'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text('PPV *'),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                hint: const Text('Scegli un PPV'),
                value: _selectedPPV,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                items: ppvOptions.map((ppv) {
                  return DropdownMenuItem(
                    value: ppv,
                    child: Text(ppv),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedPPV = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Seleziona il PPV';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: Text('Titolo in palio'),
                  ),
                  Switch(
                    value: _showTitleField,
                    onChanged: (value) {
                      setState(() {
                        _showTitleField = value;
                      });
                    },
                  ),
                ],
              ),
              if (_showTitleField)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      hintText: 'Inserisci il titolo..',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              const SizedBox(height: 16),

              const Text('Tipo di Match *'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _typeController,
                decoration: const InputDecoration(
                  hintText: 'Inserisci il tipo di match..',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Inserisci tipo di match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final payperview = _selectedPPV!;
                    final title = _showTitleField ? _titleController.text : '';
                    final type = _typeController.text;

                    // Navigate to AddWrestlersPage with parameters
                    Get.toNamed(AppRoutes.addWrestlers, parameters: {
                      'payperview': payperview,
                      'title': title,
                      'type': type,
                    });
                  }
                },
                child: const Text('Avanti'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
