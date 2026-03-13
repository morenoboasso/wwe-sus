import 'package:flutter/material.dart';

import '../controllers/settings_controller.dart';
import '../models/user_model.dart';
import '../routes/routes.dart';
import '../services/admin_user_service.dart';
import '../services/season_service.dart';
import '../services/firebase/firebase_auth_service.dart';
import '../style/color_style.dart';
import '../widgets/common/custom_snackbar.dart';
import 'admin_season_settings_page.dart';
import '../models/season_model.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({
    required this.user,
    super.key,
  });

  final AppUser user;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final SettingsController _settingsController = SettingsController();
  final AdminUserService _adminUserService = AdminUserService();
  final SeasonService _seasonService = SeasonService();

  late bool _startupSoundEnabled;
  bool _resettingPoints = false;
  bool _deletingSeason = false;
  Season? _selectedSeason;
  Future<List<Season>>? _seasonsFuture;

  @override
  void initState() {
    super.initState();
    _startupSoundEnabled = _settingsController.startupSoundEnabled;
    _seasonsFuture = _seasonService.fetchSeasons();
  }

  void _showSuccess(String message) {
    CustomSnackbar(
      color: Colors.green,
      context: context,
      message: message,
      icon: Icons.check_circle,
    ).show();
  }

  void _showError(String message) {
    CustomSnackbar(
      color: Colors.redAccent,
      context: context,
      message: message,
      icon: Icons.error,
    ).show();
  }

  Future<void> _logout() async {
    await FirebaseAuthService().signOut();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
  }

  Future<void> _confirmResetPoints() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: ColorsBets.blackHD,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'Azzerare punti utenti?',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Questa azione azzera punti globali e stagione, oltre alle statistiche, per TUTTI gli utenti. Non è reversibile.',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Annulla', style: TextStyle(color: Colors.white70)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Azzera', style: TextStyle(color: Colors.redAccent)),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    setState(() {
      _resettingPoints = true;
    });

    try {
      await _adminUserService.resetAllUsersPoints();
      if (!mounted) return;
      _showSuccess('Punti azzerati per tutti gli utenti');
    } catch (e) {
      if (!mounted) return;
      _showError('Errore durante reset punti: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _resettingPoints = false;
        });
      }
    }
  }

  Future<void> _confirmDeleteSeason() async {
    if (_selectedSeason == null) return;
    final season = _selectedSeason!;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: ColorsBets.blackHD,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Eliminare "${season.name}"?',
            style: const TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Questa azione cancella definitivamente la stagione e i suoi dati.',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Annulla', style: TextStyle(color: Colors.white70)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Elimina', style: TextStyle(color: Colors.redAccent)),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    setState(() {
      _deletingSeason = true;
    });

    try {
      await _seasonService.deleteSeason(season.id);
      if (!mounted) return;
      _showSuccess('Stagione "${season.name}" eliminata');
      _selectedSeason = null;
      setState(() {
        _seasonsFuture = _seasonService.fetchSeasons();
      });
    } catch (e) {
      if (!mounted) return;
      _showError('Errore durante eliminazione: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _deletingSeason = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Impostazioni'),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/bg.jpeg',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.55),
                    Colors.black.withValues(alpha: 0.35),
                    Colors.black.withValues(alpha: 0.55),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        _GlassCard(
                          title: 'Audio',
                          child: SwitchListTile.adaptive(
                            value: _startupSoundEnabled,
                            activeTrackColor: Colors.amber,
                            onChanged: (value) async {
                              setState(() {
                                _startupSoundEnabled = value;
                              });
                              await _settingsController.setStartupSoundEnabled(value);
                              if (!context.mounted) return;
                              _showSuccess(value ? 'Suono avvio attivato' : 'Suono avvio disattivato');
                            },
                            title: const Text(
                              'Suono apertura app',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                            ),
                            subtitle: const Text(
                              'Disattiva il rumore all\'avvio',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        if (widget.user.role == AppUserRole.admin) ...[
                          _GlassCard(
                            title: 'Admin',
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(builder: (_) => const AdminSeasonSettingsPage()),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.black,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  icon: const Icon(Icons.emoji_events),
                                  label: const Text(
                                    'Gestione stagione',
                                    style: TextStyle(fontWeight: FontWeight.w700),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                ElevatedButton.icon(
                                  onPressed: _resettingPoints ? null : _confirmResetPoints,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.redAccent,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  icon: const Icon(Icons.delete_forever),
                                  label: Text(
                                    _resettingPoints ? 'Reset in corso...' : 'Azzera punti di tutti gli utenti',
                                    style: const TextStyle(fontWeight: FontWeight.w700),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                FutureBuilder<List<Season>>(
                                  future: _seasonsFuture,
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      return const Center(
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(vertical: 8.0),
                                          child: CircularProgressIndicator(color: Colors.white),
                                        ),
                                      );
                                    }
                                    if (snapshot.hasError) {
                                      return Text(
                                        'Errore caricamento stagioni: ${snapshot.error}',
                                        style: const TextStyle(color: Colors.redAccent),
                                      );
                                    }
                                    final seasons = snapshot.data ?? [];
                                    if (seasons.isEmpty) {
                                      return const Text(
                                        'Nessuna stagione trovata da eliminare',
                                        style: TextStyle(color: Colors.white70),
                                      );
                                    }

                                    _selectedSeason ??= seasons.first;

                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        DropdownButtonFormField<Season>(
                                          dropdownColor: ColorsBets.blackHD,
                                          initialValue: _selectedSeason,
                                          items: seasons
                                              .map(
                                                (s) => DropdownMenuItem<Season>(
                                                  value: s,
                                                  child: Text(
                                                    '${s.name.isNotEmpty ? s.name : 'Stagione'} (${s.startAt.year})',
                                                    style: const TextStyle(color: Colors.white),
                                                  ),
                                                ),
                                              )
                                              .toList(),
                                          onChanged: (value) {
                                            setState(() {
                                              _selectedSeason = value;
                                            });
                                          },
                                          decoration: InputDecoration(
                                            labelText: 'Seleziona stagione',
                                            labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
                                            filled: true,
                                            fillColor: ColorsBets.whiteHD.withValues(alpha: 0.08),
                                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        ElevatedButton.icon(
                                          onPressed: _deletingSeason ? null : _confirmDeleteSeason,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.white12,
                                            foregroundColor: Colors.redAccent,
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                          ),
                                          icon: const Icon(Icons.delete_outline),
                                          label: Text(
                                            _deletingSeason ? 'Eliminazione...' : 'Elimina stagione selezionata',
                                            style: const TextStyle(fontWeight: FontWeight.w700),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                        ],
                        Center(
                          child: ElevatedButton.icon(
                            onPressed: _logout,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            icon: const Icon(Icons.logout),
                            label: const Text(
                              'Logout',
                              style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.5),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  const _GlassCard({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}
