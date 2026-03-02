import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../repositories/user_repository.dart';
import '../routes/routes.dart';
import '../style/color_style.dart';
import '../style/text_style.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userRepository = UserRepository();
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

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Header(user: user),
                      const SizedBox(height: 16),
                      Expanded(
                        child: ListView(
                          padding: EdgeInsets.zero,
                          children: [
                            _StatsSection(
                              title: 'Globale',
                              tiles: [
                                _StatTileData(label: 'Punti', value: '${user.points}'),
                                _StatTileData(label: 'Streak', value: '${user.streak}'),
                                _StatTileData(label: 'Accuracy', value: '${(user.accuracy * 100).toStringAsFixed(1)}%'),
                                _StatTileData(label: 'Corretti', value: '${user.correctPredictions}'),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _StatsSection(
                              title: 'Stagione',
                              tiles: [
                                _StatTileData(label: 'Punti', value: '${user.seasonPoints}'),
                                _StatTileData(label: 'Streak', value: '${user.seasonStreak}'),
                                _StatTileData(
                                  label: 'Accuracy',
                                  value: '${(user.seasonAccuracy * 100).toStringAsFixed(1)}%',
                                ),
                                _StatTileData(label: 'Corretti', value: '${user.seasonCorrectPredictions}'),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
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

class _Header extends StatelessWidget {
  const _Header({required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 32,
          backgroundColor: ColorsBets.whiteHD,
          backgroundImage: user.photo.isNotEmpty ? NetworkImage(user.photo) : null,
          child: user.photo.isEmpty
              ? const Icon(
                  Icons.person,
                  color: ColorsBets.blackHD,
                  size: 32,
                )
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.name,
                style: MemoText.createInputMainText,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatsSection extends StatelessWidget {
  const _StatsSection({required this.title, required this.tiles});

  final String title;
  final List<_StatTileData> tiles;

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
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: MemoText.createInputMainText.copyWith(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: ColorsBets.whiteHD.withValues(alpha: isSeason ? 0.14 : 0.10),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: ColorsBets.whiteHD.withValues(alpha: isSeason ? 0.35 : 0.22)),
                ),
                child: Text(
                  isSeason ? 'SEASON' : 'GLOBAL',
                  style: MemoText.thirdRowMatchInfo.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _StatTile(tile: tiles[0], isSeason: isSeason)),
              const SizedBox(width: 10),
              Expanded(child: _StatTile(tile: tiles[1], isSeason: isSeason)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _StatTile(tile: tiles[2], isSeason: isSeason)),
              const SizedBox(width: 10),
              Expanded(child: _StatTile(tile: tiles[3], isSeason: isSeason)),
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

class _StatTile extends StatelessWidget {
  const _StatTile({required this.tile, required this.isSeason});

  final _StatTileData tile;
  final bool isSeason;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ColorsBets.whiteHD.withValues(alpha: isSeason ? 0.10 : 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: ColorsBets.whiteHD.withValues(alpha: isSeason ? 0.24 : 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tile.label,
            style: MemoText.thirdRowMatchInfo.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 6),
          Text(
            tile.value,
            style: MemoText.createInputMainText.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
