import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../repositories/user_repository.dart';
import '../style/text_style.dart';
import '../routes/routes.dart';

class RankingPage extends StatefulWidget {
  const RankingPage({super.key});

  @override
  State<RankingPage> createState() => _RankingPageState();
}

class _RankingPageState extends State<RankingPage> with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        floatingActionButton: kDebugMode
            ? FloatingActionButton.small(
                onPressed: () => Navigator.of(context).pushNamed(AppRoutes.userGeneratorPage),
                child: const Icon(Icons.bug_report_outlined),
              )
            : null,
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
                        Tab(text: 'Generale'),
                        Tab(text: 'Streak'),
                        Tab(text: 'Accuratezza'),
                        Tab(text: 'Ultimi match'),
                      ],
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _RankingTab(orderBy: 'points', labelBuilder: _RankingPageState._pointsLabel),
                        _RankingTab(orderBy: 'streak', labelBuilder: _RankingPageState._streakLabel),
                        _RankingTab(orderBy: 'accuracy', labelBuilder: _RankingPageState._accuracyLabel),
                        _LatestMatchesPlaceholder(),
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
  static String _streakLabel(AppUser user) => 'Streak: ${user.streak}';
  static String _accuracyLabel(AppUser user) => 'Accuratezza: ${(user.accuracy * 100).toStringAsFixed(1)}%';
}

class _RankingTab extends StatelessWidget {
  const _RankingTab({
    required this.orderBy,
    required this.labelBuilder,
  });

  final String orderBy;
  final String Function(AppUser user) labelBuilder;

  @override
  Widget build(BuildContext context) {
    final userRepository = UserRepository();
    return FutureBuilder<List<AppUser>>(
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
    );
  }
}

class _LatestMatchesPlaceholder extends StatelessWidget {
  const _LatestMatchesPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Classifica ultimi match in arrivo',
        style: MemoText.noMatches,
        textAlign: TextAlign.center,
      ),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 6.0,
            offset: const Offset(0, 4),
          ),
        ],
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
                color: Colors.black,
              ),
            ),
          ),
          CircleAvatar(
            radius: 28.0,
            backgroundColor: Colors.white,
            backgroundImage: user.photo.isNotEmpty ? NetworkImage(user.photo) : null,
            child: user.photo.isEmpty ? const Icon(Icons.person, color: Colors.black) : null,
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
                    color: Colors.black,
                  ),
                ),
                Text(
                  valueLabel,
                  style: const TextStyle(
                    fontSize: 14.0,
                    color: Colors.black54,
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
