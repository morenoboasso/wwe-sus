import 'package:flutter/material.dart';

import '../controllers/match_list_controller.dart';
import '../models/match_list_item.dart';
import '../models/match_model.dart';
import '../models/ppv_finalize_result.dart';
import '../models/user_model.dart';
import '../repositories/match_repository.dart';
import '../repositories/season_repository.dart';
import '../repositories/user_repository.dart';
import '../style/text_style.dart';
import '../widgets/common/app_shimmer.dart';
import '../widgets/common/custom_snackbar.dart';
import '../widgets/common/ppv_celebration_overlay.dart';
import '../widgets/match_card_item.dart';

class MatchCardListPage extends StatefulWidget {
  const MatchCardListPage({super.key});

  @override
  MatchCardListPageState createState() => MatchCardListPageState();
}

class MatchCardListPageState extends State<MatchCardListPage> {
  final MatchListController _controller = MatchListController();
  final MatchRepository _matchRepository = MatchRepository();
  final SeasonRepository _seasonRepository = SeasonRepository();
  final UserRepository _userRepository = UserRepository();
  List<MatchListItem> _items = [];
  bool _isLoading = true;
  bool _hasError = false;
  String? _seasonTitle;
  bool _isAdmin = false;
  PpvUserOutcome _ppvOutcome = PpvUserOutcome.none;

  @override
  void initState() {
    super.initState();
    _loadInitial();
    _loadCurrentUser();
  }

  Future<void> _loadInitial() async {
    await Future.wait([
      _loadSeasonTitle(),
      _loadMatches(),
    ]);
  }

  Future<void> _loadSeasonTitle() async {
    try {
      final season = await _seasonRepository.fetchLatestOpenSeason();
      if (!mounted) return;
      setState(() {
        _seasonTitle = season?.name.isNotEmpty == true ? season!.name : null;
      });
    } catch (_) {
      // ignore
    }
  }

  Future<void> _loadCurrentUser() async {
    try {
      final currentUser = await _userRepository.getCurrentUserOnce();
      if (!mounted) return;
      setState(() {
        _isAdmin = currentUser?.role == AppUserRole.admin;
      });
    } catch (_) {
      // ignore
    }
  }

  Future<void> _finalizePpv(String ppvName) async {
    try {
      final result = await _controller.finalizePpv(ppvName);
      if (result.executed) {
        _showSuccessSnackbar('PPV terminato e bonus calcolato');
        if (mounted && result.outcome != PpvUserOutcome.none) {
          setState(() {
            _ppvOutcome = result.outcome;
          });
        }
        _refreshMatches();
      } else {
        _showErrorSnackbar('PPV non terminato: già processato o match non pronti');
      }
    } catch (e) {
      _showErrorSnackbar('Errore nel terminare il PPV: ${e.toString()}');
    }
  }

  Future<void> _loadMatches() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final items = await _controller.fetchMatchItems();
      if (!mounted) return;
      setState(() {
        _items = items;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  void _refreshMatches() {
    _loadMatches();
  }

  void _deleteMatchCard(String matchId) async {
    try {
      await _matchRepository.deleteMatch(matchId);
      _showSuccessSnackbar('Match eliminato con successo!');
      _refreshMatches();
    } catch (e) {
      _showErrorSnackbar('Errore durante l\'eliminazione del match!');
    }
  }

  void _showSuccessSnackbar(String message) {
    CustomSnackbar(
      color: Colors.green,
      context: context,
      message: message,
      icon: Icons.check_circle,
    ).show();
  }

  void _showErrorSnackbar(String message) {
    CustomSnackbar(
      color: Colors.red,
      context: context,
      message: message,
      icon: Icons.error,
    ).show();
  }

  Widget _buildTabWithBadge(String title, int count) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Tab(text: title),
        if (count > 0)
          Positioned(
            right: -18,
            top: 2,
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: const BoxDecoration(
                color: Colors.redAccent,
                shape: BoxShape.circle,
              ),
              child: Text(
                count.toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final double horizontalPadding = MediaQuery.of(context).size.width * 0.04;
    final sections = _controller.splitSections(_items);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        body: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/bg.jpeg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SafeArea(
              child: _hasError
                  ? Center(
                      child: Text(
                        'Qualcosa è andato storto!',
                        style: MemoText.noMatches,
                      ),
                    )
                  : Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              if (_seasonTitle != null) ...[
                                Text(
                                  _seasonTitle!,
                                  style: MemoText.secondRowMatchInfo.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.8,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 6),
                              ] else if (_isLoading) ...[
                                AppShimmer(
                                  child: Container(
                                    width: 180,
                                    height: 18,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                              ],
                              TabBar(
                                indicatorColor: Colors.white,
                                labelColor: Colors.white,
                                unselectedLabelColor: Colors.grey,
                                tabs: [
                                  _buildTabWithBadge(
                                    'Nuovi',
                                    _isLoading ? 0 : sections.nonVotati.length,
                                  ),
                                  _buildTabWithBadge(
                                    'Votati',
                                    _isLoading ? 0 : sections.votatiNonConclusi.length,
                                  ),
                                  _buildTabWithBadge(
                                    'Completati',
                                    _isLoading ? 0 : sections.completati.length,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                            child: TabBarView(
                              children: [
                                _isLoading
                                    ? _buildMatchListShell()
                                    : _buildMatchList(sections.nonVotati),
                                _isLoading
                                    ? _buildMatchListShell()
                                    : _buildMatchList(sections.votatiNonConclusi),
                                _isLoading
                                    ? _buildMatchListShell()
                                    : _buildMatchList(sections.completati),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
            PpvCelebrationOverlay(
              outcome: _ppvOutcome,
              onCompleted: () {
                if (!mounted) return;
                setState(() {
                  _ppvOutcome = PpvUserOutcome.none;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchList(List<MatchListItem> matches) {
    if (matches.isEmpty) {
      return Center(
        child: Text(
          'Nessun Match disponibile',
          style: MemoText.noMatches,
        ),
      );
    }

    return _buildGroupedMatchList(matches);
  }

  Widget _buildMatchListShell() {
    return ListView.builder(
      itemCount: 4,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: AppShimmer(
            child: Container(
              height: 140,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGroupedMatchList(List<MatchListItem> matches) {
    final grouped = <String, List<MatchListItem>>{};

    for (final item in matches) {
      final key = (item.match.ppvName.isNotEmpty ? item.match.ppvName : 'PPV Sconosciuto').trim();
      grouped.putIfAbsent(key, () => []).add(item);
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: grouped.entries.map((entry) {
          final ppvNameOriginal = entry.key;
          final ppvName = ppvNameOriginal.toUpperCase();
          final items = entry.value;
          final canFinalize = _isAdmin &&
              items.isNotEmpty &&
              items.every((item) => item.match.status == MatchStatus.closed);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (canFinalize)
                Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 6),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: Colors.white, width: 1.4),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () => _finalizePpv(ppvNameOriginal),
                    child: const Text(
                      'Termina PPV (calcola bonus)',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 6),
                child: Text(
                  ppvName,
                  style: MemoText.secondRowMatchInfo.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              Divider(
                color: Colors.white.withValues(alpha: 0.3),
                thickness: 1.2,
              ),
              ...items.map(
                (item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: MatchCardItem(
                    item: item,
                    onVoteSubmitted: _refreshMatches,
                    onDelete: () => _deleteMatchCard(item.match.id),
                    canCloseMatch: _isAdmin,
                  ),
                ),
              ),
              Divider(
                color: Colors.white.withValues(alpha: 0.2),
                thickness: 1,
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
