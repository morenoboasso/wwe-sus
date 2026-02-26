part of 'match_card_list_page.dart';

class MatchCardListPageState extends State<MatchCardListPage> {
  final MatchListController _controller = MatchListController();
  final MatchRepository _matchRepository = MatchRepository();
  List<MatchListItem> _items = [];
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadMatches();
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
                          child: TabBar(
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

    return SingleChildScrollView(
      child: Column(
        children: matches.map((item) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: MatchCardItem(
              item: item,
              onVoteSubmitted: _refreshMatches,
              onDelete: () => _deleteMatchCard(item.match.id),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMatchListShell() {
    return ListView.builder(
      itemCount: 4,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Container(
            height: 140,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        );
      },
    );
  }
}
