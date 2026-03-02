import 'package:flutter/material.dart';

import '../models/season_model.dart';
import '../models/user_model.dart';
import '../repositories/season_repository.dart';
import '../repositories/user_repository.dart';
import '../services/season_service.dart';
import '../style/color_style.dart';

class AdminSeasonSettingsPage extends StatefulWidget {
  const AdminSeasonSettingsPage({super.key});

  @override
  State<AdminSeasonSettingsPage> createState() => _AdminSeasonSettingsPageState();
}

class _AdminSeasonSettingsPageState extends State<AdminSeasonSettingsPage> {
  final UserRepository _userRepository = UserRepository();
  final SeasonRepository _seasonRepository = SeasonRepository();
  final SeasonService _seasonService = SeasonService();
  final TextEditingController _nameController = TextEditingController();

  Season? _season;
  bool _loading = true;
  bool _saving = false;
  bool _closing = false;
  bool _isAdmin = false;
  bool _isNew = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final currentUser = await _userRepository.getCurrentUserOnce();
    final isAdmin = currentUser?.role == AppUserRole.admin;
    Season? season = await _seasonRepository.fetchLatestOpenSeason();
    bool isNew = false;
    final now = DateTime.now();
    season ??= Season(
      id: 'season-${DateTime.now().millisecondsSinceEpoch}',
      name: 'Nuova stagione',
      startAt: now,
      endAt: now,
      isClosed: false,
      winners: const [],
    );
    isNew = season.winners.isEmpty && season.startAt.isAfter(DateTime(2024));

    _nameController.text = season.name;
    setState(() {
      _season = season;
      _isAdmin = isAdmin;
      _loading = false;
      _isNew = isNew;
    });
  }

  Future<void> _pickDate({required bool isStart}) async {
    if (_season == null) return;
    final now = DateTime.now();
    final initial = isStart ? (_season?.startAt ?? now) : (_season?.endAt ?? now);
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (date == null) return;
    if (!mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (!mounted) return;
    final selected = DateTime(
      date.year,
      date.month,
      date.day,
      time?.hour ?? initial.hour,
      time?.minute ?? initial.minute,
    );
    setState(() {
      _season = isStart
          ? _season!.copyWith(startAt: selected)
          : _season!.copyWith(endAt: selected);
    });
  }

  Future<void> _saveSeason() async {
    if (_season == null) return;
    setState(() => _saving = true);
    final updated = _season!.copyWith(name: _nameController.text.trim());
    await _seasonRepository.upsertSeason(updated);
    setState(() {
      _season = updated;
      _saving = false;
      _isNew = false;
    });
    _showSnack('Stagione salvata');
  }

  Future<void> _closeSeason() async {
    if (_season == null) return;
    setState(() => _closing = true);
    final closedSeason = await _seasonService.closeSeason(_season!);

    setState(() {
      _season = closedSeason;
      _closing = false;
    });
    _showSnack('Stagione conclusa e classifica salvata');
  }

  String _formatDate(DateTime date) {
    final local = date.toLocal();
    String two(int v) => v.toString().padLeft(2, '0');
    return '${two(local.day)}/${two(local.month)}/${local.year} ${two(local.hour)}:${two(local.minute)}';
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!_isAdmin) {
      return const Scaffold(
        body: Center(
          child: Text(
            'Solo gli admin possono gestire le stagioni',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    final season = _season!;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: const Text('Impostazioni Stagione'),
        elevation: 0,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/bg.jpeg',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height - kToolbarHeight - 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _nameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Nome stagione',
                        labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
                        filled: true,
                        fillColor: ColorsBets.whiteHD.withValues(alpha: 0.08),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: _InfoTile(
                            title: 'Inizio',
                            value: _formatDate(season.startAt),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _InfoTile(
                            title: 'Fine',
                            value: _formatDate(season.endAt),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _pickDate(isStart: true),
                            style: _primaryButtonStyle(),
                            child: const Text('Imposta inizio'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _pickDate(isStart: false),
                            style: _primaryButtonStyle(),
                            child: const Text('Imposta fine'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _saving ? null : _saveSeason,
                      style: _primaryButtonStyle(),
                      child: Text(_saving ? 'Salvataggio...' : (_isNew ? 'Crea stagione' : 'Salva stagione')),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: season.isClosed || _closing ? null : _closeSeason,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                      ),
                      child: Text(_closing ? 'Chiusura...' : 'Chiudi stagione e salva vincitori'),
                    ),
                    const SizedBox(height: 8),
                    if (season.isClosed)
                      const Text(
                        'Stagione chiusa: punteggi stagione azzerati, vincitori salvati.',
                        style: TextStyle(color: Colors.white70),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  ButtonStyle _primaryButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 0,
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ColorsBets.whiteHD.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: ColorsBets.whiteHD.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
