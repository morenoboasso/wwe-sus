import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wwe_bets/services/db_service.dart';

import '../../routes/routes.dart';

class AddWrestlersPage extends StatefulWidget {
  final String payperview;
  final String title;
  final String type;

  const AddWrestlersPage({
    required this.payperview,
    required this.title,
    required this.type,
    super.key,
  });

  @override
  _AddWrestlersPageState createState() => _AddWrestlersPageState();
}

class _AddWrestlersPageState extends State<AddWrestlersPage> {
  List<String> wrestlers = [''];
  DbService dbService = DbService();

  @override
  void initState() {
    super.initState();

    // Verifica i parametri
    if (widget.payperview.isEmpty || widget.type.isEmpty) {
      Get.offAllNamed(AppRoutes.createMatchCard);
    }
  }

  void _addWrestler() {
    setState(() {
      wrestlers.add('');
    });
  }

  void _removeWrestler(int index) {
    setState(() {
      wrestlers.removeAt(index);
    });
  }

  void _onWrestlerChanged(int index, String name) {
    setState(() {
      wrestlers[index] = name;
    });
  }

  void _saveMatchCard() async {
    await dbService.createMatchCard(widget.payperview, widget.title, widget.type, wrestlers);
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Wrestlers per ${widget.payperview}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: wrestlers.length,
                itemBuilder: (context, index) {
                  return Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: wrestlers[index],
                          onChanged: (value) => _onWrestlerChanged(index, value),
                          decoration: InputDecoration(
                            labelText: 'Wrestler ${index + 1}',
                          ),
                        ),
                      ),
                      if (index > 0)
                        IconButton(
                          icon: Icon(Icons.remove_circle),
                          onPressed: () => _removeWrestler(index),
                        ),
                    ],
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (wrestlers.length < 30)
                  ElevatedButton(
                    onPressed: _addWrestler,
                    child: Text('Aggiungi Wrestler'),
                  ),
              ],
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveMatchCard,
              child: Text('Crea Match Card'),
            ),
          ],
        ),
      ),
    );
  }
}
