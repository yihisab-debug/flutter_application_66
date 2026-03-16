import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/match.dart';

class SportsApiService {
  static const String _baseUrl = 'https://sportapi7.p.rapidapi.com';
  static const String _apiKey = '641463bd55mshdc081dd89ead397p159456jsn3abbef24543a';
  static const String _apiHost = 'sportapi7.p.rapidapi.com';

  static Map<String, String> get _headers => {
        'X-RapidAPI-Key': _apiKey,
        'X-RapidAPI-Host': _apiHost,
        'Content-Type': 'application/json',
      };

  static String _todayDate() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  static Future<List<Match>> getFootballMatches() async {
    return _fetchMatches('football', 'football');
  }

  static Future<List<Match>> getBasketballMatches() async {
    return _fetchMatches('basketball', 'basketball');
  }

  static Future<List<Match>> getTennisMatches() async {
    return _fetchMatches('tennis', 'tennis');
  }

  static Future<List<Match>> getHockeyMatches() async {
    return _fetchMatches('ice-hockey', 'hockey');
  }

  static Future<List<Match>> _fetchMatches(
      String apiSport, String appSport) async {
    try {
      final date = _todayDate();
      final url = Uri.parse(
          '$_baseUrl/api/v1/sport/$apiSport/scheduled-events/$date');

      final response = await http
          .get(url, headers: _headers)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        List<dynamic> events = [];
        if (data is Map) {
          events = data['events'] ?? data['data'] ?? data['results'] ?? [];
        } else if (data is List) {
          events = data;
        }

        if (events.isEmpty) {
          return _getMockData(appSport);
        }

        final parsed = _parseMatches(events, appSport);
        return parsed.isEmpty ? _getMockData(appSport) : parsed;
      } else if (response.statusCode == 429) {

        return _getMockData(appSport);
      } else {
        return _getMockData(appSport);
      }
    } catch (e) {
      print('[$appSport] API error: $e');
      return _getMockData(appSport);
    }
  }

  static List<Match> _parseMatches(List events, String sport) {
    final result = <Match>[];
    for (final e in events) {
      try {
        if (e is Map<String, dynamic>) {
          result.add(Match.fromApiJson(e, sport));
        }
      } catch (err) {

      }
    }
    return result;
  }

  static List<Match> _getMockData(String sport) {
    switch (sport) {
      case 'football':
        return _getMockFootballMatches();
      case 'basketball':
        return _getMockBasketballMatches();
      case 'tennis':
        return _getMockTennisMatches();
      case 'hockey':
        return _getMockHockeyMatches();
      default:
        return [];
    }
  }

  static List<Match> _getMockFootballMatches() {
    final now = DateTime.now();
    return [

      Match(
        id: 'f1',
        homeTeam: 'Manchester City',
        awayTeam: 'Arsenal',
        homeScore: '2',
        awayScore: '1',
        status: 'inprogress',
        minute: "67'",
        league: 'Premier League',
        leagueCountry: 'England',
        startTime: now.subtract(const Duration(minutes: 67)).toIso8601String(),
        sport: 'football',
      ),

      Match(
        id: 'f2',
        homeTeam: 'Real Madrid',
        awayTeam: 'Barcelona',
        homeScore: '1',
        awayScore: '1',
        status: 'ht',
        minute: 'HT',
        league: 'La Liga',
        leagueCountry: 'Spain',
        startTime: now.subtract(const Duration(minutes: 45)).toIso8601String(),
        sport: 'football',
      ),

      Match(
        id: 'f3',
        homeTeam: 'PSG',
        awayTeam: 'Marseille',
        homeScore: '3',
        awayScore: '0',
        status: 'finished',
        league: 'Ligue 1',
        leagueCountry: 'France',
        startTime: now.subtract(const Duration(hours: 2)).toIso8601String(),
        sport: 'football',
      ),

      Match(
        id: 'f4',
        homeTeam: 'Bayern Munich',
        awayTeam: 'Borussia Dortmund',
        status: 'scheduled',
        league: 'Bundesliga',
        leagueCountry: 'Germany',
        startTime: now.add(const Duration(hours: 3)).toIso8601String(),
        sport: 'football',
      ),

      Match(
        id: 'f5',
        homeTeam: 'Juventus',
        awayTeam: 'Inter Milan',
        status: 'scheduled',
        league: 'Serie A',
        leagueCountry: 'Italy',
        startTime: now.add(const Duration(hours: 5)).toIso8601String(),
        sport: 'football',
      ),

      Match(
        id: 'f6',
        homeTeam: 'Chelsea',
        awayTeam: 'Liverpool',
        homeScore: '0',
        awayScore: '2',
        status: 'finished',
        league: 'Premier League',
        leagueCountry: 'England',
        startTime: now.subtract(const Duration(hours: 4)).toIso8601String(),
        sport: 'football',
      ),

      Match(
        id: 'f7',
        homeTeam: 'Atletico Madrid',
        awayTeam: 'Sevilla',
        homeScore: '1',
        awayScore: '0',
        status: 'inprogress',
        minute: "34'",
        league: 'La Liga',
        leagueCountry: 'Spain',
        startTime: now.subtract(const Duration(minutes: 34)).toIso8601String(),
        sport: 'football',
      ),

      Match(
        id: 'f8',
        homeTeam: 'AC Milan',
        awayTeam: 'Napoli',
        homeScore: '2',
        awayScore: '2',
        status: 'inprogress',
        minute: "78'",
        league: 'Serie A',
        leagueCountry: 'Italy',
        startTime: now.subtract(const Duration(minutes: 78)).toIso8601String(),
        sport: 'football',
      ),

    ];
  }

  static List<Match> _getMockBasketballMatches() {
    final now = DateTime.now();
    return [

      Match(
        id: 'b1',
        homeTeam: 'LA Lakers',
        awayTeam: 'Boston Celtics',
        homeScore: '98',
        awayScore: '105',
        status: 'inprogress',
        minute: 'Q3 8:42',
        league: 'NBA',
        leagueCountry: 'USA',
        startTime: now.subtract(const Duration(minutes: 65)).toIso8601String(),
        sport: 'basketball',
      ),

      Match(
        id: 'b2',
        homeTeam: 'Golden State Warriors',
        awayTeam: 'Chicago Bulls',
        homeScore: '120',
        awayScore: '110',
        status: 'finished',
        league: 'NBA',
        leagueCountry: 'USA',
        startTime: now.subtract(const Duration(hours: 3)).toIso8601String(),
        sport: 'basketball',
      ),

      Match(
        id: 'b3',
        homeTeam: 'Miami Heat',
        awayTeam: 'Philadelphia 76ers',
        status: 'scheduled',
        league: 'NBA',
        leagueCountry: 'USA',
        startTime: now.add(const Duration(hours: 4)).toIso8601String(),
        sport: 'basketball',
      ),

      Match(
        id: 'b4',
        homeTeam: 'Real Madrid',
        awayTeam: 'FC Barcelona',
        homeScore: '78',
        awayScore: '82',
        status: 'inprogress',
        minute: 'Q4 2:15',
        league: 'ACB Liga',
        leagueCountry: 'Spain',
        startTime: now.subtract(const Duration(minutes: 90)).toIso8601String(),
        sport: 'basketball',
      ),

      Match(
        id: 'b5',
        homeTeam: 'Denver Nuggets',
        awayTeam: 'Phoenix Suns',
        homeScore: '88',
        awayScore: '91',
        status: 'finished',
        league: 'NBA',
        leagueCountry: 'USA',
        startTime: now.subtract(const Duration(hours: 5)).toIso8601String(),
        sport: 'basketball',
      ),

    ];
  }

  static List<Match> _getMockTennisMatches() {
    final now = DateTime.now();
    return [

      Match(
        id: 't1',
        homeTeam: 'Carlos Alcaraz',
        awayTeam: 'Jannik Sinner',
        homeScore: '6-4, 3',
        awayScore: '4, 5',
        status: 'inprogress',
        minute: 'Set 2',
        league: 'ATP Masters 1000',
        leagueCountry: 'International',
        startTime: now.subtract(const Duration(hours: 1)).toIso8601String(),
        sport: 'tennis',
      ),

      Match(
        id: 't2',
        homeTeam: 'Aryna Sabalenka',
        awayTeam: 'Iga Swiatek',
        homeScore: '6-7, 6-4, 6',
        awayScore: '7, 3, 4',
        status: 'inprogress',
        minute: 'Set 3',
        league: 'WTA 1000',
        leagueCountry: 'International',
        startTime: now.subtract(const Duration(hours: 2)).toIso8601String(),
        sport: 'tennis',
      ),

      Match(
        id: 't3',
        homeTeam: 'Novak Djokovic',
        awayTeam: 'Daniil Medvedev',
        homeScore: '7-6, 6-3',
        awayScore: '5, 2',
        status: 'finished',
        league: 'ATP 500',
        leagueCountry: 'International',
        startTime: now.subtract(const Duration(hours: 4)).toIso8601String(),
        sport: 'tennis',
      ),

      Match(
        id: 't4',
        homeTeam: 'Rafael Nadal',
        awayTeam: 'Alexander Zverev',
        status: 'scheduled',
        league: 'ATP Masters 1000',
        leagueCountry: 'International',
        startTime: now.add(const Duration(hours: 2)).toIso8601String(),
        sport: 'tennis',
      ),

    ];
  }

  static List<Match> _getMockHockeyMatches() {
    final now = DateTime.now();
    return [

      Match(
        id: 'h1',
        homeTeam: 'Toronto Maple Leafs',
        awayTeam: 'Montreal Canadiens',
        homeScore: '3',
        awayScore: '2',
        status: 'inprogress',
        minute: 'P2 12:33',
        league: 'NHL',
        leagueCountry: 'Canada/USA',
        startTime: now.subtract(const Duration(minutes: 55)).toIso8601String(),
        sport: 'hockey',
      ),

      Match(
        id: 'h2',
        homeTeam: 'Boston Bruins',
        awayTeam: 'NY Rangers',
        homeScore: '4',
        awayScore: '1',
        status: 'finished',
        league: 'NHL',
        leagueCountry: 'USA',
        startTime: now.subtract(const Duration(hours: 3)).toIso8601String(),
        sport: 'hockey',
      ),

      Match(
        id: 'h3',
        homeTeam: 'Tampa Bay Lightning',
        awayTeam: 'Florida Panthers',
        status: 'scheduled',
        league: 'NHL',
        leagueCountry: 'USA',
        startTime: now.add(const Duration(hours: 2)).toIso8601String(),
        sport: 'hockey',
      ),

      Match(
        id: 'h4',
        homeTeam: 'Colorado Avalanche',
        awayTeam: 'Vegas Golden Knights',
        homeScore: '2',
        awayScore: '3',
        status: 'inprogress',
        minute: 'P3 5:10',
        league: 'NHL',
        leagueCountry: 'USA',
        startTime: now.subtract(const Duration(minutes: 100)).toIso8601String(),
        sport: 'hockey',
      ),
      
    ];
  }
}