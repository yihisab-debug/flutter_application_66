import 'dart:async';
import 'package:flutter/material.dart';
import '../services/football_service.dart';
import 'match_type.dart';
import 'match_card_widget.dart';
import 'match_list_widget.dart';
import 'date_selector_widget.dart';

class FootballPage extends StatefulWidget {
  const FootballPage({super.key});

  @override
  State<FootballPage> createState() => _FootballPageState();
}

class _FootballPageState extends State<FootballPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Timer? _liveTimer;

  List<Map<String, dynamic>> _pastMatches = [];
  List<Map<String, dynamic>> _liveMatches = [];
  List<Map<String, dynamic>> _upcomingMatches = [];
  final List<Map<String, dynamic>> _favorites = [];

  bool _loadingPast = false;
  bool _loadingLive = false;
  bool _loadingUpcoming = false;

  DateTime _pastDate = DateTime.now().subtract(const Duration(days: 1));
  DateTime _upcomingDate = DateTime.now().add(const Duration(days: 1));

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  bool _searchActive = false;


  String _matchId(Map<String, dynamic> event) {
    final id = event['id']?.toString() ?? "";
    if (id.isNotEmpty) return id;
    return "${FootballService.getTeamName(event['homeTeam'])}|${FootballService.getTeamName(event['awayTeam'])}|${FootballService.getMatchTime(event)}";
  }

  bool _isFavorite(Map<String, dynamic> event) =>
      _favorites.any((f) => _matchId(f) == _matchId(event));

  void _toggleFavorite(Map<String, dynamic> event) {
    setState(() {
      if (_isFavorite(event)) {
        _favorites.removeWhere((f) => _matchId(f) == _matchId(event));
      } else {
        _favorites.add(Map<String, dynamic>.from(event));
      }
    });
  }


  List<Map<String, dynamic>> _filterMatches(List<Map<String, dynamic>> matches) {
    if (_searchQuery.isEmpty) return matches;
    final q = _searchQuery.toLowerCase();
    return matches.where((e) {
      final home = FootballService.getTeamName(e['homeTeam']).toLowerCase();
      final away = FootballService.getTeamName(e['awayTeam']).toLowerCase();
      final tournament = FootballService.getTournamentName(e).toLowerCase();
      return home.contains(q) || away.contains(q) || tournament.contains(q);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this, initialIndex: 2);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) return;
      if (_tabController.index == 2) _loadLive();
    });
    _loadLive();
    _loadPast();
    _loadUpcoming();
    _liveTimer = Timer.periodic(const Duration(seconds: 60), (_) {
      if (_tabController.index == 2) _loadLive();
    });
  }

  @override
  void dispose() {
    _liveTimer?.cancel();
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime dt) =>
      "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}";

  String _displayDate(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final diff = DateTime(dt.year, dt.month, dt.day).difference(today).inDays;

    if (diff == -1) return "Вчера";
    if (diff == 0) return "Сегодня";
    if (diff == 1) return "Завтра";

    const months = ["","янв","фев","мар","апр","май","июн","июл","авг","сен","окт","ноя","дек"];

    return "${dt.day} ${months[dt.month]} ${dt.year}";
  }

  Future<void> _loadPast() async {
    setState(() => _loadingPast = true);
    final res = await FootballService.getMatchesByDate(_formatDate(_pastDate));
    final events = List<Map<String, dynamic>>.from(res["events"] ?? []);
    final finished = events.where((e) => FootballService.isFinished(e)).toList();
    setState(() {
      _loadingPast = false;
      _pastMatches = finished.isNotEmpty ? finished : events;
    });
  }

  Future<void> _loadLive() async {
    setState(() => _loadingLive = true);
    final res = await FootballService.getLiveMatches();
    final events = List<Map<String, dynamic>>.from(res["events"] ?? []);
    setState(() {
      _loadingLive = false;
      _liveMatches = events;
    });
  }

  Future<void> _loadUpcoming() async {
    setState(() => _loadingUpcoming = true);
    final res = await FootballService.getMatchesByDate(_formatDate(_upcomingDate));
    final events = List<Map<String, dynamic>>.from(res["events"] ?? []);
    final upcoming = events.where((e) => FootballService.isNotStarted(e)).toList();
    setState(() {
      _loadingUpcoming = false;
      _upcomingMatches = upcoming.isNotEmpty ? upcoming : events;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 48, 48, 48),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 27, 33, 72),
        foregroundColor: Colors.white,

        title: _searchActive
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                cursorColor: Colors.white,
                decoration: InputDecoration(
                  hintText: "Команда или турнир...",
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                  border: InputBorder.none,
                ),
                onChanged: (v) => setState(() => _searchQuery = v.trim()),
              )

            : const Row(children: [

                Text("⚽", style: TextStyle(fontSize: 25)),

                SizedBox(width: 8),

                Text("Футбол.Live", style: TextStyle(fontWeight: FontWeight.bold)),

              ]),

        actions: [
          if (_searchActive)

            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => setState(() {
                _searchActive = false;
                _searchQuery = "";
                _searchController.clear();
              }),
            )

          else
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () => setState(() => _searchActive = true),
            ),
        ],

        bottom: _searchActive
            ? null
            : TabBar(
                controller: _tabController,
                indicatorColor: const Color.fromARGB(255, 255, 4, 4),
                labelColor: Colors.white,
                unselectedLabelColor: const Color.fromARGB(153, 255, 255, 255),
                tabs: [

                  Tab(
                    text: "Избранное",
                    icon: Stack(
                      clipBehavior: Clip.none,
                      children: [

                        const Icon(Icons.star, size: 20, color: Colors.amber),

                        if (_favorites.isNotEmpty)

                          Positioned(
                            top: -4, right: -8,
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: const BoxDecoration(
                                  color: Colors.red, shape: BoxShape.circle),
                              
                              child: Text("${_favorites.length}",

                                  style: const TextStyle(
                                      fontSize: 8,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ),

                      ],
                    ),
                  ),

                  const Tab(text: "Прошедшие", icon: Icon(Icons.history, size: 18)),
                  const Tab(text: "Live", icon: Icon(Icons.circle, size: 14, color: Colors.redAccent)),
                  const Tab(text: "Предстоящие", icon: Icon(Icons.schedule, size: 18)),
                ],
              ),
      ),

      body: _searchActive
          ? _buildSearchResults()
          : TabBarView(
              controller: _tabController,
              children: [
                _buildFavoritesTab(),
                _buildPastTab(),
                _buildLiveTab(),
                _buildUpcomingTab(),
              ],
            ),
            
    );
  }

  Widget _buildSearchResults() {
    if (_searchQuery.isEmpty) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [

          Icon(Icons.search, size: 72, color: Colors.grey.shade600),

          const SizedBox(height: 16),

          Text("Введите название команды или турнира",
              style: TextStyle(color: Colors.grey.shade400, fontSize: 15),
              textAlign: TextAlign.center),

        ]),
      );
    }

    final filtered = _filterMatches([..._liveMatches, ..._pastMatches, ..._upcomingMatches]);
    if (filtered.isEmpty) {

      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [

          Icon(Icons.sports_soccer, size: 72, color: Colors.grey.shade600),

          const SizedBox(height: 16),

          Text("Ничего не найдено по «$_searchQuery»",
              style: TextStyle(color: Colors.grey.shade400, fontSize: 15),
              textAlign: TextAlign.center),

        ]),
      );
    }
    return Column(children: [

      Container(
        width: double.infinity,
        color: const Color.fromARGB(255, 35, 35, 35),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),

        child: Text("Найдено: ${filtered.length} матчей",
            style: const TextStyle(color: Colors.white70, fontSize: 13)),

      ),

      Expanded(
        child: ListView.builder(
          padding: const EdgeInsets.only(bottom: 20),
          itemCount: filtered.length,
          itemBuilder: (_, i) {
            final event = filtered[i];
            final type = FootballService.isLive(event)
                ? MatchType.live
                : FootballService.isFinished(event)
                    ? MatchType.past
                    : MatchType.upcoming;

            return MatchCard(
              event: event,
              type: type,
              isFavorite: _isFavorite(event),
              onToggleFavorite: () => _toggleFavorite(event),
            );

          },
        ),
      ),

    ]);
  }

  Widget _buildFavoritesTab() {
    return Column(children: [
      Container(
        width: double.infinity,
        color: const Color(0xFFF57F17),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(children: [

          const Icon(Icons.star, color: Colors.white, size: 18),

          const SizedBox(width: 8),

          Expanded(
            child: Text(
              _favorites.isEmpty ? "Избранные матчи" : "Избранные матчи (${_favorites.length})",
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),

          if (_favorites.isNotEmpty)

            TextButton(
              onPressed: () => setState(() => _favorites.clear()),
              child: const Text("Очистить",
                  style: TextStyle(color: Colors.white70, fontSize: 12)),
            ),

        ]),
      ),

      Expanded(
        child: _favorites.isEmpty
            ? Center(
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [

                  Icon(Icons.star_border, size: 72, color: Colors.grey.shade600),

                  const SizedBox(height: 16),

                  Text("Нет избранных матчей",
                      style: TextStyle(color: Colors.grey.shade400, fontSize: 16)),

                  const SizedBox(height: 8),

                  Text("Нажмите ★ на любом матче\nчтобы добавить",
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                      textAlign: TextAlign.center),

                ]),
              )

            : ListView.builder(

                padding: const EdgeInsets.only(bottom: 20),

                itemCount: _favorites.length,
                itemBuilder: (_, i) {
                  final event = _favorites[i];
                  final type = FootballService.isLive(event)
                      ? MatchType.live
                      : FootballService.isFinished(event)
                          ? MatchType.past
                          : MatchType.upcoming;

                  return MatchCard(
                    event: event,
                    type: type,
                    isFavorite: true,
                    onToggleFavorite: () => _toggleFavorite(event),
                  );

                },
              ),

      ),
    ]);
  }

  Widget _buildPastTab() {
    return Column(children: [

      DateSelector(
        label: _displayDate(_pastDate),
        color: const Color(0xFF37474F),
        onPrev: () {
          setState(() => _pastDate = _pastDate.subtract(const Duration(days: 1)));
          _loadPast();
        },
        onNext: () {
          if (_pastDate.isBefore(DateTime.now().add(const Duration(days: 1)))) {
            setState(() => _pastDate = _pastDate.add(const Duration(days: 1)));
            _loadPast();
          }
        },
      ),

      Expanded(
        child: _loadingPast
            ? const Center(child: CircularProgressIndicator())
            : _pastMatches.isEmpty
                ? _emptyState(Icons.history, "Нет матчей за эту дату")
                : MatchList(
                    matches: _pastMatches,
                    type: MatchType.past,
                    isFavorite: _isFavorite,
                    onToggleFavorite: _toggleFavorite,
                  ),
      ),

    ]);
  }

  Widget _buildLiveTab() {
    return Column(children: [

      Container(
        color: const Color(0xFFB71C1C),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(children: [

          const Icon(Icons.circle, color: Colors.white, size: 10),

          const SizedBox(width: 8),

          const Expanded(
            child: Text("Матчи в прямом эфире",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),

          if (_loadingLive)

            const SizedBox(width: 18, height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))

          else
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white, size: 20),
              onPressed: _loadLive,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),

        ]),
      ),

      Expanded(
        child: _loadingLive
            ? const Center(child: CircularProgressIndicator(color: Colors.red))
            : _liveMatches.isEmpty
                ? _emptyState(Icons.sports_soccer, "Нет матчей в эфире",
                    subtitle: "Попробуйте обновить позже")
                : MatchList(
                    matches: _liveMatches,
                    type: MatchType.live,
                    isFavorite: _isFavorite,
                    onToggleFavorite: _toggleFavorite,
                  ),
      ),

    ]);
  }

  Widget _buildUpcomingTab() {
    return Column(children: [
      DateSelector(
        label: _displayDate(_upcomingDate),
        color: const Color(0xFF1565C0),
        
        onPrev: () {
          final today = DateTime.now();
          final prev = _upcomingDate.subtract(const Duration(days: 1));
          if (!prev.isBefore(DateTime(today.year, today.month, today.day))) {
            setState(() => _upcomingDate = prev);
            _loadUpcoming();
          }
        },
        
        onNext: () {
          setState(() => _upcomingDate = _upcomingDate.add(const Duration(days: 1)));
          _loadUpcoming();
        },
      ),

      Expanded(
        child: _loadingUpcoming
            ? const Center(child: CircularProgressIndicator())
            : _upcomingMatches.isEmpty
                ? _emptyState(Icons.schedule, "Нет предстоящих матчей")
                : MatchList(
                    matches: _upcomingMatches,
                    type: MatchType.upcoming,
                    isFavorite: _isFavorite,
                    onToggleFavorite: _toggleFavorite,
                  ),
      ),

    ]);
  }

  Widget _emptyState(IconData icon, String msg, {String? subtitle}) {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [

        Icon(icon, size: 72, color: Colors.grey.shade300),

        const SizedBox(height: 16),

        Text(msg,
            style: TextStyle(
                color: Colors.grey.shade600, fontSize: 16, fontWeight: FontWeight.w500)),

        if (subtitle != null) ...[

          const SizedBox(height: 6),

          Text(subtitle, style: TextStyle(color: Colors.grey.shade400, fontSize: 13)),

        ],
        
      ]),
    );
  }
}