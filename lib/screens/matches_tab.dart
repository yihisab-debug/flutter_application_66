import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/sports_provider.dart';
import '../widgets/match_card.dart';
import '../widgets/sport_tab_bar.dart';
import '../models/match.dart';

class MatchesTab extends StatefulWidget {
  const MatchesTab({super.key});

  @override
  State<MatchesTab> createState() => _MatchesTabState();
}

class _MatchesTabState extends State<MatchesTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const List<({String id, String label, IconData icon})> _sports = [
    (id: 'football', label: 'Football', icon: Icons.sports_soccer),
    (id: 'basketball', label: 'Basketball', icon: Icons.sports_basketball),
    (id: 'tennis', label: 'Tennis', icon: Icons.sports_tennis),
    (id: 'hockey', label: 'Hockey', icon: Icons.sports_hockey),
  ];

  String get _currentSport => _sports[_tabController.index].id;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _sports.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _loadCurrentSport();
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadCurrentSport());
  }

  void _loadCurrentSport() {
    context.read<SportsProvider>().loadMatches(_currentSport);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          _buildHeader(),
          SportTabBar(
            tabController: _tabController,
            sports: _sports.map((s) => (label: s.label, icon: s.icon)).toList(),
          ),
          Expanded(child: _buildTabViews()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF00C853),
              borderRadius: BorderRadius.circular(8),
            ),

            child: const Text(
              'LIVE',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w900,
                fontSize: 13,
                letterSpacing: 1,
              ),
            ),
          ),

          const SizedBox(width: 10),

          const Text(
            'ScoreBoard',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),

          const Spacer(),

          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(10),
            ),

            child: IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white70, size: 20),
              onPressed: () => context
                  .read<SportsProvider>()
                  .refreshMatches(_currentSport),
              tooltip: 'Refresh',
            ),
          ),

        ],
      ),
    );
  }

  Widget _buildTabViews() {
    return TabBarView(
      controller: _tabController,
      children: _sports
          .map((s) => _SportMatchList(sport: s.id))
          .toList(),
    );
  }
}

class _SportMatchList extends StatelessWidget {
  final String sport;

  const _SportMatchList({required this.sport});

  @override
  Widget build(BuildContext context) {
    return Consumer<SportsProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading(sport)) {
          return _buildLoading();
        }

        final error = provider.getError(sport);
        if (error != null && provider.getMatches(sport).isEmpty) {
          return _buildError(context, sport, provider);
        }

        final matches = provider.getMatches(sport);
        if (matches.isEmpty) {
          return _buildEmpty();
        }

        return _buildList(matches);
      },
    );
  }

  Widget _buildLoading() {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: 6,
      itemBuilder: (_, __) => const _ShimmerCard(),
    );
  }

  Widget _buildError(BuildContext ctx, String sport, SportsProvider provider) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          const Icon(Icons.wifi_off, color: Colors.white30, size: 48),

          const SizedBox(height: 12),

          const Text(
            'Could not load matches',
            style: TextStyle(color: Colors.white54),
          ),

          const SizedBox(height: 16),

          ElevatedButton(
            onPressed: () => provider.loadMatches(sport),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00C853),
              foregroundColor: Colors.black,
            ),
            child: const Text('Retry'),
          ),

        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          Icon(Icons.sports, color: Colors.white24, size: 56),

          SizedBox(height: 12),

          Text(
            'No matches today',
            style: TextStyle(color: Colors.white38, fontSize: 16),
          ),

        ],
      ),
    );
  }

  Widget _buildList(List<Match> matches) {

    final Map<String, List<Match>> grouped = {};
    for (final m in matches) {
      grouped.putIfAbsent(m.league, () => []).add(m);
    }

    return RefreshIndicator(
      color: const Color(0xFF00C853),
      backgroundColor: const Color(0xFF0D1220),
      onRefresh: () async {},
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),

        children: grouped.entries.map((entry) {
          return _LeagueSection(
            league: entry.key,
            matches: entry.value,
          );

        }).toList(),
      ),
    );
  }
}

class _LeagueSection extends StatelessWidget {
  final String league;
  final List<Match> matches;

  const _LeagueSection({required this.league, required this.matches});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
          child: Row(
            children: [

              Container(
                width: 3,
                height: 16,
                decoration: BoxDecoration(
                  color: const Color(0xFF00C853),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              const SizedBox(width: 8),

              Expanded(
                child: Text(
                  league,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              Text(
                '${matches.length} matches',
                style: const TextStyle(color: Colors.white38, fontSize: 11),
              ),

            ],
          ),
        ),
        
        ...matches.map((m) => MatchCard(match: m)),
        const SizedBox(height: 4),
      ],
    );
  }
}

class _ShimmerCard extends StatefulWidget {
  const _ShimmerCard();

  @override
  State<_ShimmerCard> createState() => _ShimmerCardState();
}

class _ShimmerCardState extends State<_ShimmerCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _animation = Tween<double>(begin: 0.4, end: 0.8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (_, __) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(_animation.value * 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
