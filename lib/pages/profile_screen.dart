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

                return DefaultTabController(
                  length: 2,
                  initialIndex: 0,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _Header(user: user),
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
