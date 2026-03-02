import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/user_model.dart';
import '../models/season_model.dart';
import '../repositories/season_repository.dart';
import '../repositories/user_repository.dart';
import '../routes/routes.dart';
import '../style/color_style.dart';
import '../style/text_style.dart';
import 'dart:io';

import '../services/imgbb_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userRepository = UserRepository();
    final seasonRepository = SeasonRepository();
    final imgBBService = ImgBBService();
    final Stream<AppUser?> userStream = userRepository.watchCurrentUser();

    return Scaffold(
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
            child: StreamBuilder<AppUser?>(
              stream: userStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final user = snapshot.data;
                if (user == null) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (!context.mounted) return;
                    Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
                  });
                  return const SizedBox.shrink();
                }

                return DefaultTabController(
                  length: 2,
                  initialIndex: 0,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _Header(user: user),
                        const SizedBox(height: 8),
                        _EditProfileButton(
                          user: user,
                          userRepository: userRepository,
                          imgBBService: imgBBService,
                        ),
                        const SizedBox(height: 10),
                        FutureBuilder<Season?>(
                          future: seasonRepository.fetchLatestOpenSeason(),
                          builder: (context, seasonSnapshot) {
                            if (seasonSnapshot.connectionState == ConnectionState.waiting) {
                              return const SizedBox(height: 6);
                            }
                            final season = seasonSnapshot.data;
                            final now = DateTime.now();
                            final isActive = season != null &&
                                !season.isClosed &&
                                !now.isBefore(season.startAt) &&
                                !now.isAfter(season.endAt);
                            if (!isActive) return const SizedBox.shrink();

                            return _SeasonBadge(seasonName: season.name.isNotEmpty ? season.name : 'Stagione attiva');
                          },
                        ),
                        const SizedBox(height: 16),
                        Container(
                          decoration: BoxDecoration(
                            color: ColorsBets.whiteHD.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(0),
                            border: Border.all(color: ColorsBets.whiteHD.withValues(alpha: 0.18)),
                          ),
                          child: const TabBar(
                            indicatorColor: Colors.white,
                            labelColor: Colors.white,
                            unselectedLabelColor: Colors.white70,
                            tabs: [
                              Tab(text: 'Stagione'),
                              Tab(text: 'Globale'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: TabBarView(
                            children: [
                              ListView(
                                padding: EdgeInsets.zero,
                                children: [
                                  _StatsSection(
                                    title: 'Stagione',
                                    showTitle: false,
                                    tiles: [
                                      _StatTileData(label: 'Punti', value: '${user.seasonPoints}'),
                                      _StatTileData(label: 'Streak', value: '${user.seasonStreak}'),
                                      _StatTileData(
                                        label: 'Accuracy',
                                        value: '${(user.seasonAccuracy * 100).toStringAsFixed(1)}%',
                                      ),
                                      _StatTileData(label: 'Corretti', value: '${user.seasonCorrectPredictions}'),
                                      _StatTileData(label: 'Sbagliati', value: '${user.seasonWrongPredictions}'),
                                    ],
                                  ),
                                ],
                              ),
                              ListView(
                                padding: EdgeInsets.zero,
                                children: [
                                  _StatsSection(
                                    title: 'Globale',
                                    showTitle: false,
                                    tiles: [
                                      _StatTileData(label: 'Punti', value: '${user.points}'),
                                      _StatTileData(label: 'Streak', value: '${user.streak}'),
                                      _StatTileData(
                                        label: 'Accuracy',
                                        value: '${(user.accuracy * 100).toStringAsFixed(1)}%',
                                      ),
                                      _StatTileData(label: 'Corretti', value: '${user.correctPredictions}'),
                                      _StatTileData(label: 'Sbagliati', value: '${user.wrongPredictions}'),
                                    ],
                                  ),
                                ],
                              ),
                            ],
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

class _EditProfileButton extends StatelessWidget {
  const _EditProfileButton({required this.user, required this.userRepository, required this.imgBBService});

  final AppUser user;
  final UserRepository userRepository;
  final ImgBBService imgBBService;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => _openDialog(context),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: BorderSide(color: ColorsBets.whiteHD.withValues(alpha: 0.4)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      icon: const Icon(Icons.edit, size: 18),
      label: const Text('Modifica profilo'),
    );
  }

  void _openDialog(BuildContext context) {
    final nameCtrl = TextEditingController(text: user.name);
    final photoCtrl = TextEditingController(text: user.photo);
    bool saving = false;
    bool uploading = false;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            return AlertDialog(
              backgroundColor: Colors.black87,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              title: const Text('Modifica profilo', style: TextStyle(color: Colors.white)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameCtrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Nome',
                      labelStyle: TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.08),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: uploading
                          ? null
                          : () async {
                              final picker = ImagePicker();
                              final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 90);
                              if (picked == null) return;

                              final filePath = picked.path;
                              setState(() => uploading = true);
                              try {
                                final url = await imgBBService.uploadImage(File(filePath));
                                if (url != null) {
                                  photoCtrl.text = url;
                                }
                              } finally {
                                setState(() => uploading = false);
                              }
                            },
                      icon: uploading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.cloud_upload, color: Colors.white),
                      label: Text(
                        uploading ? 'Caricamento...' : 'Carica foto profilo',
                        style: const TextStyle(color: Colors.white),
                      ),
                      style: TextButton.styleFrom(foregroundColor: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Seleziona dalla galleria, la foto viene caricata su ImgBB e applicata al profilo.',
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: saving ? null : () => Navigator.of(ctx).pop(),
                  child: const Text('Annulla'),
                ),
                ElevatedButton(
                  onPressed: saving
                      ? null
                      : () async {
                          setState(() => saving = true);
                          final updated = user.copyWith(
                            name: nameCtrl.text.trim(),
                            photo: photoCtrl.text.trim(),
                          );
                          await userRepository.upsertUser(updated);
                          if (ctx.mounted) Navigator.of(ctx).pop();
                        },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black),
                  child: Text(saving ? 'Salvataggio...' : 'Salva'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.35), width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 12,
                spreadRadius: 1,
              ),
            ],
            gradient: LinearGradient(
              colors: [
                Colors.white.withValues(alpha: 0.18),
                Colors.white.withValues(alpha: 0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: CircleAvatar(
            radius: 52,
            backgroundColor: ColorsBets.whiteHD,
            backgroundImage: user.photo.isNotEmpty ? NetworkImage(user.photo) : null,
            child: user.photo.isEmpty
                ? const Icon(
                    Icons.person,
                    color: ColorsBets.blackHD,
                    size: 52,
                  )
                : null,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          user.name,
          style: MemoText.createInputMainText.copyWith(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _StatsSection extends StatelessWidget {
  const _StatsSection({required this.title, required this.tiles, this.showTitle = true});

  final String title;
  final List<_StatTileData> tiles;
  final bool showTitle;

  @override
  Widget build(BuildContext context) {
    final isSeason = title.toLowerCase().contains('stagione');
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: (isSeason ? ColorsBets.whiteHD.withValues(alpha: 0.14) : ColorsBets.whiteHD.withValues(alpha: 0.10)),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (isSeason
              ? ColorsBets.whiteHD.withValues(alpha: 0.28)
              : ColorsBets.whiteHD.withValues(alpha: 0.18)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showTitle) ...[
            Text(
              title,
              style: MemoText.createInputMainText.copyWith(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 10),
          ],
          _StatTile(
            tile: tiles[0],
            isSeason: isSeason,
            isWide: true,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _StatTile(tile: tiles[1], isSeason: isSeason)),
              const SizedBox(width: 10),
              Expanded(child: _StatTile(tile: tiles[2], isSeason: isSeason)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _StatTile(tile: tiles[3], isSeason: isSeason)),
              const SizedBox(width: 10),
              Expanded(child: _StatTile(tile: tiles[4], isSeason: isSeason)),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatTileData {
  const _StatTileData({required this.label, required this.value});

  final String label;
  final String value;
}

class _SeasonBadge extends StatelessWidget {
  const _SeasonBadge({required this.seasonName});

  final String seasonName;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: ColorsBets.whiteHD.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: ColorsBets.whiteHD.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.emoji_events, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text(
            seasonName,
            style: MemoText.thirdRowMatchInfo.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.tile, required this.isSeason, this.isWide = false});

  final _StatTileData tile;
  final bool isSeason;
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ColorsBets.whiteHD.withValues(alpha: isSeason ? 0.10 : 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: ColorsBets.whiteHD.withValues(alpha: isSeason ? 0.24 : 0.18)),
      ),
      child: Column(
        crossAxisAlignment: isWide ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          Text(
            tile.label,
            style: MemoText.thirdRowMatchInfo.copyWith(
              color: Colors.white70,
              fontWeight: isWide ? FontWeight.w800 : null,
            ),
            textAlign: isWide ? TextAlign.center : TextAlign.left,
          ),
          const SizedBox(height: 6),
          Text(
            tile.value,
            style: MemoText.createInputMainText.copyWith(
              color: Colors.white,
              fontSize: isWide ? 28 : null,
            ),
            textAlign: isWide ? TextAlign.center : TextAlign.left,
          ),
        ],
      ),
    );
  }
}
