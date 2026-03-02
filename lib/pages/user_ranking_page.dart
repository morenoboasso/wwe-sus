import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/season_model.dart';
import '../repositories/user_repository.dart';
import '../repositories/season_repository.dart';
import '../style/color_style.dart';

class RankingPage extends StatefulWidget {
  const RankingPage({super.key});

  @override
  State<RankingPage> createState() => _RankingPageState();
}

class _CurrentSeasonTab extends StatelessWidget {
  const _CurrentSeasonTab();

  String _formatDate(DateTime date) {
    final local = date.toLocal();
    String two(int v) => v.toString().padLeft(2, '0');
    return '${two(local.day)}/${two(local.month)}/${local.year} ${two(local.hour)}:${two(local.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    final seasonRepository = SeasonRepository();
    final userRepository = UserRepository();

    return FutureBuilder<Season?>(
      future: seasonRepository.fetchLatestOpenSeason(),
      builder: (context, seasonSnapshot) {
        if (seasonSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
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
                    'Inizio: ${_formatDate(season.startAt)}',
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  Text(
                    'Fine:   ${_formatDate(season.endAt)}',
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  if (notStarted)
                    const Padding(
                      padding: EdgeInsets.only(top: 6),
                      child: Text(
                        'La stagione non è ancora iniziata.',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ),
                ],
              ),
            ),
            if (notStarted)
              const Expanded(
                child: Center(
                  child: Text(
                    'Inizia quando parte la stagione.',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              )
            else
              Expanded(
              child: FutureBuilder<List<AppUser>>(
                future: userRepository.fetchAllUsers(orderBy: 'seasonPoints', descending: true),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
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
          return const Center(child: CircularProgressIndicator());
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
                return const Center(child: CircularProgressIndicator());
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
  });

  final int position;
  final int totalUsers;
  final AppUser user;
  final String valueLabel;

  String getPositionEmoji() {
    if (position == 0) return '🏆';
    if (position == 1) return '🥈';
    if (position == 2) return '🥉';
    if (position == totalUsers - 1) return '💩';
    return '• ${position + 1}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
          CircleAvatar(
            radius: 28.0,
            backgroundColor: ColorsBets.whiteHD.withValues(alpha: 0.9),
            backgroundImage: user.photo.isNotEmpty ? NetworkImage(user.photo) : null,
            child: user.photo.isEmpty ? const Icon(Icons.person, color: ColorsBets.blackHD) : null,
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
    );
  }
}
