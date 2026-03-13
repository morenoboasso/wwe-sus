import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/season_model.dart';
import '../repositories/user_repository.dart';
import '../repositories/season_repository.dart';
import '../style/color_style.dart';
import '../widgets/common/app_shimmer.dart';

class RankingPage extends StatefulWidget {
  const RankingPage({super.key});

  @override
  State<RankingPage> createState() => _RankingPageState();
}

class _CurrentSeasonHeaderShimmer extends StatelessWidget {
  const _CurrentSeasonHeaderShimmer();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: AppShimmer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 210,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: 260,
              height: 14,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            const SizedBox(height: 6),
            Container(
              width: 200,
              height: 14,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RankingListShimmer extends StatelessWidget {
  const _RankingListShimmer();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: AppShimmer(
            child: Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: ColorsBets.whiteHD.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(color: ColorsBets.whiteHD.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: _shimmerBar(width: 32, height: 28, radius: 6),
                  ),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withValues(alpha: 0.35), width: 2),
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
                      radius: 28.0,
                      backgroundColor: Colors.white.withValues(alpha: 0.25),
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _shimmerBar(width: 160, height: 14),
                        const SizedBox(height: 6),
                        _shimmerBar(width: 120, height: 12),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _shimmerBar({required double width, required double height, double radius = 8}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.20),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

class _SeasonCardsShimmer extends StatelessWidget {
  const _SeasonCardsShimmer();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: AppShimmer(
            child: Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: ColorsBets.whiteHD.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(color: ColorsBets.whiteHD.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _shimmerBar(width: 140, height: 16),
                      _shimmerBar(width: 70, height: 14),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _shimmerBar(width: 200, height: 12),
                  const SizedBox(height: 6),
                  _shimmerBar(width: 180, height: 12),
                  const SizedBox(height: 12),
                  _shimmerBar(width: 160, height: 12),
                  const SizedBox(height: 6),
                  _shimmerBar(width: 140, height: 12),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _shimmerBar({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}

class _CurrentSeasonTab extends StatelessWidget {
  const _CurrentSeasonTab();

  String _formatStartDate(DateTime date) {
    final local = date.toLocal();
    const months = [
      'gennaio',
      'febbraio',
      'marzo',
      'aprile',
      'maggio',
      'giugno',
      'luglio',
      'agosto',
      'settembre',
      'ottobre',
      'novembre',
      'dicembre',
    ];
    String two(int v) => v.toString().padLeft(2, '0');
    return '${local.day} ${months[local.month - 1]} ${local.year} - ${two(local.hour)}:${two(local.minute)}';
  }

  String _remainingDaysLabel(DateTime endAt) {
    final diff = endAt.toLocal().difference(DateTime.now());
    if (diff.isNegative) return 'Terminata';
    final days = (diff.inSeconds / 86400).ceil();
    if (days <= 1) return '1 giorno alla fine';
    return '$days giorni alla fine';
  }

  String _countdownToStart(DateTime startAt, String seasonName) {
    final diff = startAt.toLocal().difference(DateTime.now());
    if (diff.isNegative) return '';
    final totalMinutes = diff.inMinutes;
    if (totalMinutes < 60) {
      final m = totalMinutes <= 0 ? 0 : totalMinutes;
      return '$seasonName tra $m min';
    }
    final totalHours = diff.inHours;
    if (totalHours < 24) {
      return '$seasonName tra $totalHours ore';
    }
    final days = (diff.inSeconds / 86400).ceil();
    return '$seasonName tra $days giorni';
  }

  @override
  Widget build(BuildContext context) {
    final seasonRepository = SeasonRepository();
    final userRepository = UserRepository();

    return FutureBuilder<Season?>(
      future: seasonRepository.fetchLatestOpenSeason(),
      builder: (context, seasonSnapshot) {
        if (seasonSnapshot.connectionState == ConnectionState.waiting) {
          return const _CurrentSeasonHeaderShimmer();
        }
        if (seasonSnapshot.hasError) {
          return Center(child: Text('Errore: ${seasonSnapshot.error}'));
        }
        final season = seasonSnapshot.data;
        if (season == null) {
          return const Center(child: Text('Nessuna stagione attiva',style: TextStyle(color: Colors.white),));
        }

        final now = DateTime.now();
        final notStarted = now.isBefore(season.startAt);
        final countdownLabel = notStarted ? _countdownToStart(season.startAt, season.name.isNotEmpty ? season.name : 'La stagione') : '';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    season.name.isNotEmpty ? season.name : 'Stagione in corso',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Inizio: ${_formatStartDate(season.startAt)}',
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  Text(
                    'Fine:   ${_remainingDaysLabel(season.endAt)}',
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
            if (notStarted)
              Expanded(
                child: Center(
                  child: Text(
                    countdownLabel.isNotEmpty ? countdownLabel : 'La stagione non è ancora iniziata.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              )
            else
              Expanded(
              child: FutureBuilder<List<AppUser>>(
                future: userRepository.fetchAllUsers(orderBy: 'seasonPoints', descending: true),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const _RankingListShimmer();
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Errore: ${snapshot.error}'));
                  }
                  final users = snapshot.data ?? [];
                  if (users.isEmpty) {
                    return const Center(child: Text('Nessun dato disponibile',style: TextStyle(color: Colors.white),));
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      return _RankingCard(
                        position: index,
                        totalUsers: users.length,
                        user: user,
                        valueLabel: _RankingPageState._seasonPointsLabel(user),
                        onTap: () => _showUserStatsDialog(context, user),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SeasonTab extends StatelessWidget {
  const _SeasonTab();

  String _formatDate(DateTime date) {
    final local = date.toLocal();
    return '${_two(local.day)}/${_two(local.month)}/${local.year} ${_two(local.hour)}:${_two(local.minute)}';
  }

  String _two(int v) => v.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final seasonRepository = SeasonRepository();
    return FutureBuilder<List<Season>>(
      future: seasonRepository.fetchSeasons(onlyClosed: true),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _SeasonCardsShimmer();
        }
        if (snapshot.hasError) {
          return Center(child: Text('Errore: ${snapshot.error}'));
        }
        final seasons = snapshot.data ?? [];
        if (seasons.isEmpty) {
          return const Center(child: Text('Nessuna stagione conclusa',style: TextStyle(color: Colors.white), ));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: seasons.length,
          itemBuilder: (context, index) {
            final season = seasons[index];
            return _SeasonCard(
              season: season,
              formatDate: _formatDate,
            );
          },
        );
      },
    );
  }
}

class _SeasonCard extends StatelessWidget {
  const _SeasonCard({
    required this.season,
    required this.formatDate,
  });

  final Season season;
  final String Function(DateTime) formatDate;

  @override
  Widget build(BuildContext context) {
    final winners = season.winners;
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: ColorsBets.whiteHD.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: ColorsBets.whiteHD.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                season.name.isNotEmpty ? season.name : 'Stagione',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                season.isClosed ? 'Conclusa' : 'In corso',
                style: TextStyle(
                  color: season.isClosed ? Colors.greenAccent : Colors.amber,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Inizio: ${formatDate(season.startAt)}',
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          Text(
            'Fine:   ${formatDate(season.endAt)}',
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 10),
          if (winners.isEmpty)
            const Text(
              'Nessun vincitore registrato',
              style: TextStyle(color: Colors.white70),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: winners.map((winner) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        winner.userName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${winner.points} pts',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}

class _RankingPageState extends State<RankingPage> with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 6,
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/bg.jpeg',
                fit: BoxFit.cover,
              ),
            ),
            const SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: TabBar(
                      isScrollable: true,
                      tabAlignment: TabAlignment.start,
                      indicatorColor: Colors.white,
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.grey,
                      tabs: [
                        Tab(text: 'Stagione attuale'),
                        Tab(text: 'Punti totali'),
                        Tab(text: 'Streak'),
                        Tab(text: 'Accuratezza'),
                        Tab(text: 'Peggiori'),
                        Tab(text: 'Stagioni'),
                      ],
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _CurrentSeasonTab(),
                        _RankingTab(
                          orderBy: 'points',
                          labelBuilder: _RankingPageState._pointsLabel,
                          description: 'Classifica globale per punti totali (tutte le stagioni).',
                        ),
                        _RankingTab(
                          orderBy: 'streak',
                          labelBuilder: _RankingPageState._streakLabel,
                          description: 'Serie di pronostici corretti consecutivi più lunga.',
                        ),
                        _RankingTab(
                          orderBy: 'accuracy',
                          labelBuilder: _RankingPageState._accuracyLabel,
                          description: 'Percentuale di pronostici corretti sul totale.',
                        ),
                        _RankingTab(
                          orderBy: 'wrongPredictions',
                          labelBuilder: _RankingPageState._worstLabel,
                          description: 'Classifica per numero di pronostici sbagliati.',
                        ),
                        _SeasonTab(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _pointsLabel(AppUser user) => 'Punti: ${user.points}';
  static String _seasonPointsLabel(AppUser user) => 'Punti stagione: ${user.seasonPoints}';
  static String _streakLabel(AppUser user) => 'Streak: ${user.streak}';
  static String _accuracyLabel(AppUser user) => 'Accuratezza: ${(user.accuracy * 100).toStringAsFixed(1)}%';
  static String _worstLabel(AppUser user) => 'Sbagliati: ${user.wrongPredictions}';
}

class _RankingTab extends StatelessWidget {
  const _RankingTab({
    required this.orderBy,
    required this.labelBuilder,
    this.description,
  });

  final String orderBy;
  final String Function(AppUser user) labelBuilder;
  final String? description;

  @override
  Widget build(BuildContext context) {
    final userRepository = UserRepository();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (description != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              description!,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ),
        Expanded(
          child: FutureBuilder<List<AppUser>>(
            future: userRepository.fetchAllUsers(orderBy: orderBy, descending: true),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const _RankingListShimmer();
              }
              if (snapshot.hasError) {
                return Center(child: Text('Errore: ${snapshot.error}'));
              }
              final users = snapshot.data ?? [];
              if (users.isEmpty) {
                return const Center(child: Text('Nessun dato disponibile'));
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  return _RankingCard(
                    position: index,
                    totalUsers: users.length,
                    user: user,
                    valueLabel: labelBuilder(user),
                    onTap: () => _showUserStatsDialog(context, user),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
class _RankingCard extends StatelessWidget {
  const _RankingCard({
    required this.position,
    required this.totalUsers,
    required this.user,
    required this.valueLabel,
    this.onTap,
  });

  final int position;
  final int totalUsers;
  final AppUser user;
  final String valueLabel;
  final VoidCallback? onTap;

  String getPositionEmoji() {
    if (position == 0) return '🏆';
    if (position == 1) return '🥈';
    if (position == 2) return '🥉';
    if (position == totalUsers - 1) return '💩';
    return '• ${position + 1}';
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.0),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: ColorsBets.whiteHD.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: ColorsBets.whiteHD.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: Text(
                getPositionEmoji(),
                style: const TextStyle(
                  fontSize: 28.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
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
                radius: 28.0,
                backgroundColor: ColorsBets.whiteHD,
                backgroundImage: user.photo.isNotEmpty ? NetworkImage(user.photo) : null,
                child: user.photo.isEmpty ? const Icon(Icons.person, color: ColorsBets.blackHD) : null,
              ),
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    valueLabel,
                    style: const TextStyle(
                      fontSize: 14.0,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _showUserStatsDialog(BuildContext context, AppUser user) {
  showDialog(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        backgroundColor: Colors.black.withValues(alpha: 0.92),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
        contentPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        title: Row(
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
                radius: 26,
                backgroundColor: ColorsBets.whiteHD,
                backgroundImage: user.photo.isNotEmpty ? NetworkImage(user.photo) : null,
                child: user.photo.isEmpty ? const Icon(Icons.person, color: ColorsBets.blackHD, size: 26) : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    user.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    'Globale & stagione',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 440,
          child: DefaultTabController(
            length: 2,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: ColorsBets.whiteHD.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(8),
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
                SizedBox(
                  height: 320,
                  child: TabBarView(
                    children: [
                      SingleChildScrollView(
                        child: _StatsDialogSection(
                          title: 'Stagione',
                          isSeason: true,
                          tiles: [
                            _StatDialogTileData(label: 'Punti', value: '${user.seasonPoints}'),
                            _StatDialogTileData(label: 'Streak', value: '${user.seasonStreak}'),
                            _StatDialogTileData(
                              label: 'Accuracy',
                              value: '${(user.seasonAccuracy * 100).toStringAsFixed(1)}%',
                            ),
                            _StatDialogTileData(label: 'Corretti', value: '${user.seasonCorrectPredictions}'),
                            _StatDialogTileData(label: 'Sbagliati', value: '${user.seasonWrongPredictions}'),
                          ],
                        ),
                      ),
                      SingleChildScrollView(
                        child: _StatsDialogSection(
                          title: 'Globale',
                          isSeason: false,
                          tiles: [
                            _StatDialogTileData(label: 'Punti', value: '${user.points}'),
                            _StatDialogTileData(label: 'Streak', value: '${user.streak}'),
                            _StatDialogTileData(
                              label: 'Accuracy',
                              value: '${(user.accuracy * 100).toStringAsFixed(1)}%',
                            ),
                            _StatDialogTileData(label: 'Corretti', value: '${user.correctPredictions}'),
                            _StatDialogTileData(label: 'Sbagliati', value: '${user.wrongPredictions}'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

class _StatsDialogSection extends StatelessWidget {
  const _StatsDialogSection({required this.title, required this.tiles, required this.isSeason});

  final String title;
  final List<_StatDialogTileData> tiles;
  final bool isSeason;

  @override
  Widget build(BuildContext context) {
    final color = ColorsBets.whiteHD.withValues(alpha: isSeason ? 0.14 : 0.10);
    final border = ColorsBets.whiteHD.withValues(alpha: isSeason ? 0.26 : 0.18);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16),
          ),
          const SizedBox(height: 10),
          _StatDialogTile(tile: tiles[0], isWide: true, isSeason: isSeason),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _StatDialogTile(tile: tiles[1], isSeason: isSeason)),
              const SizedBox(width: 10),
              Expanded(child: _StatDialogTile(tile: tiles[2], isSeason: isSeason)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _StatDialogTile(tile: tiles[3], isSeason: isSeason)),
              const SizedBox(width: 10),
              Expanded(child: _StatDialogTile(tile: tiles[4], isSeason: isSeason)),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatDialogTileData {
  const _StatDialogTileData({required this.label, required this.value});

  final String label;
  final String value;
}

class _StatDialogTile extends StatelessWidget {
  const _StatDialogTile({required this.tile, required this.isSeason, this.isWide = false});

  final _StatDialogTileData tile;
  final bool isSeason;
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    final tileColor = ColorsBets.whiteHD.withValues(alpha: isSeason ? 0.10 : 0.08);
    final border = ColorsBets.whiteHD.withValues(alpha: isSeason ? 0.22 : 0.16);
    return Container(
      width: isWide ? double.infinity : null,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: tileColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: isWide ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          Text(
            tile.label,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.72), fontWeight: FontWeight.w600),
            textAlign: isWide ? TextAlign.center : TextAlign.left,
          ),
          const SizedBox(height: 6),
          Text(
            tile.value,
            style: TextStyle(
              color: Colors.white,
              fontSize: isWide ? 26 : 16,
              fontWeight: FontWeight.w700,
            ),
            textAlign: isWide ? TextAlign.center : TextAlign.left,
          ),
        ],
      ),
    );
  }
}
