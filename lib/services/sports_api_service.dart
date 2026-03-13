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
    try {
      final date = _todayDate();
      final url = Uri.parse('$_baseUrl/api/v1/sport/football/scheduled-events/$date');
      final response = await http.get(url, headers: _headers).timeout(
            const Duration(seconds: 15),
          );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List events = data['events'] ?? data['data'] ?? data ?? [];
        return _parseMatches(events, 'football');
      }
    } catch (e) {
      print('Football API error: $e');
    }
    return _getMockFootballMatches();
  }

  static Future<List<Match>> getBasketballMatches() async {
    try {
      final date = _todayDate();
      final url = Uri.parse('$_baseUrl/api/v1/sport/basketball/scheduled-events/$date');
      final response = await http.get(url, headers: _headers).timeout(
            const Duration(seconds: 15),
          );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List events = data['events'] ?? data['data'] ?? [];
        return _parseMatches(events, 'basketball');
      }
    } catch (e) {
      print('Basketball API error: $e');
    }
    return _getMockBasketballMatches();
  }

  static Future<List<Match>> getTennisMatches() async {
    try {
      final date = _todayDate();
      final url = Uri.parse('$_baseUrl/api/v1/sport/tennis/scheduled-events/$date');
      final response = await http.get(url, headers: _headers).timeout(
            const Duration(seconds: 15),
          );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List events = data['events'] ?? data['data'] ?? [];
        return _parseMatches(events, 'tennis');
      }
    } catch (e) {
      print('Tennis API error: $e');
    }
    return _getMockTennisMatches();
  }

  static Future<List<Match>> getHockeyMatches() async {
    try {
      final date = _todayDate();
      final url = Uri.parse('$_baseUrl/api/v1/sport/ice-hockey/scheduled-events/$date');
      final response = await http.get(url, headers: _headers).timeout(
            const Duration(seconds: 15),
          );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List events = data['events'] ?? data['data'] ?? [];
        return _parseMatches(events, 'hockey');
      }
    } catch (e) {
      print('Hockey API error: $e');
    }
    return _getMockHockeyMatches();
  }

  static List<Match> _parseMatches(List events, String sport) {
    return events
        .map((e) {
          try {
            return Match.fromApiJson(e as Map<String, dynamic>, sport);
          } catch (_) {
            return null;
          }
        })
        .whereType<Match>()
        .toList();
  }

  // ── Mock data fallbacks ──────────────────────────────────────────────────────

  static List<Match> _getMockFootballMatches() {
    final now = DateTime.now();
    return [
      Match(
        id: 'f1', homeTeam: 'Manchester City', awayTeam: 'Arsenal',
        homeScore: '2', awayScore: '1', status: 'live', minute: "67'",
        league: 'Premier League', leagueCountry: 'England',
        startTime: now.subtract(const Duration(minutes: 67)).toIso8601String(),
        sport: 'football',
      ),
      Match(
        id: 'f2', homeTeam: 'Real Madrid', awayTeam: 'Barcelona',
        homeScore: '1', awayScore: '1', status: 'live', minute: "HT",
        league: 'La Liga', leagueCountry: 'Spain',
        startTime: now.subtract(const Duration(minutes: 45)).toIso8601String(),
        sport: 'football',
      ),
      Match(
        id: 'f3', homeTeam: 'PSG', awayTeam: 'Marseille',
        homeScore: '3', awayScore: '0', status: 'FT',
        league: 'Ligue 1', leagueCountry: 'France',
        startTime: now.subtract(const Duration(hours: 2)).toIso8601String(),
        sport: 'football',
      ),
      Match(
        id: 'f4', homeTeam: 'Bayern Munich', awayTeam: 'Borussia Dortmund',
        status: 'scheduled',
        league: 'Bundesliga', leagueCountry: 'Germany',
        startTime: now.add(const Duration(hours: 3)).toIso8601String(),
        sport: 'football',
      ),
      Match(
        id: 'f5', homeTeam: 'Juventus', awayTeam: 'Inter Milan',
        status: 'scheduled',
        league: 'Serie A', leagueCountry: 'Italy',
        startTime: now.add(const Duration(hours: 5)).toIso8601String(),
        sport: 'football',
      ),
      Match(
        id: 'f6', homeTeam: 'Chelsea', awayTeam: 'Liverpool',
        homeScore: '0', awayScore: '2', status: 'FT',
        league: 'Premier League', leagueCountry: 'England',
        startTime: now.subtract(const Duration(hours: 4)).toIso8601String(),
        sport: 'football',
      ),
      Match(
        id: 'f7', homeTeam: 'Atletico Madrid', awayTeam: 'Sevilla',
        homeScore: '1', awayScore: '0', status: 'live', minute: "34'",
        league: 'La Liga', leagueCountry: 'Spain',
        startTime: now.subtract(const Duration(minutes: 34)).toIso8601String(),
        sport: 'football',
      ),
    ];
  }

  static List<Match> _getMockBasketballMatches() {
    final now = DateTime.now();
    return [
      Match(
        id: 'b1', homeTeam: 'LA Lakers', awayTeam: 'Boston Celtics',
        homeScore: '98', awayScore: '105', status: 'live', minute: "Q3 8:42",
        league: 'NBA', leagueCountry: 'USA',
        startTime: now.subtract(const Duration(minutes: 65)).toIso8601String(),
        sport: 'basketball',
      ),
      Match(
        id: 'b2', homeTeam: 'Golden State Warriors', awayTeam: 'Chicago Bulls',
        homeScore: '120', awayScore: '110', status: 'FT',
        league: 'NBA', leagueCountry: 'USA',
        startTime: now.subtract(const Duration(hours: 3)).toIso8601String(),
        sport: 'basketball',
      ),
      Match(
        id: 'b3', homeTeam: 'Miami Heat', awayTeam: 'Philadelphia 76ers',
        status: 'scheduled',
        league: 'NBA', leagueCountry: 'USA',
        startTime: now.add(const Duration(hours: 4)).toIso8601String(),
        sport: 'basketball',
      ),
      Match(
        id: 'b4', homeTeam: 'Real Madrid', awayTeam: 'FC Barcelona',
        homeScore: '78', awayScore: '82', status: 'live', minute: "Q4 2:15",
        league: 'ACB Liga', leagueCountry: 'Spain',
        startTime: now.subtract(const Duration(minutes: 90)).toIso8601String(),
        sport: 'basketball',
      ),
    ];
  }

  static List<Match> _getMockTennisMatches() {
    final now = DateTime.now();
    return [
      Match(
        id: 't1', homeTeam: 'Carlos Alcaraz', awayTeam: 'Jannik Sinner',
        homeScore: '6-4, 3', awayScore: '4, 5', status: 'live', minute: "Set 2",
        league: 'ATP Masters', leagueCountry: 'International',
        startTime: now.subtract(const Duration(hours: 1)).toIso8601String(),
        sport: 'tennis',
      ),
      Match(
        id: 't2', homeTeam: 'Aryna Sabalenka', awayTeam: 'Iga Swiatek',
        homeScore: '6-7, 6-4, 6', awayScore: '7, 3, 4', status: 'live', minute: "Set 3",
        league: 'WTA Tour', leagueCountry: 'International',
        startTime: now.subtract(const Duration(hours: 2)).toIso8601String(),
        sport: 'tennis',
      ),
      Match(
        id: 't3', homeTeam: 'Novak Djokovic', awayTeam: 'Daniil Medvedev',
        homeScore: '7-6, 6-3', awayScore: '5, 2', status: 'FT',
        league: 'ATP 500', leagueCountry: 'International',
        startTime: now.subtract(const Duration(hours: 4)).toIso8601String(),
        sport: 'tennis',
      ),
    ];
  }

  static List<Match> _getMockHockeyMatches() {
    final now = DateTime.now();
    return [
      Match(
        id: 'h1', homeTeam: 'Toronto Maple Leafs', awayTeam: 'Montreal Canadiens',
        homeScore: '3', awayScore: '2', status: 'live', minute: "P2 12:33",
        league: 'NHL', leagueCountry: 'Canada/USA',
        startTime: now.subtract(const Duration(minutes: 55)).toIso8601String(),
        sport: 'hockey',
      ),
      Match(
        id: 'h2', homeTeam: 'Boston Bruins', awayTeam: 'NY Rangers',
        homeScore: '4', awayScore: '1', status: 'FT',
        league: 'NHL', leagueCountry: 'USA',
        startTime: now.subtract(const Duration(hours: 3)).toIso8601String(),
        sport: 'hockey',
      ),
      Match(
        id: 'h3', homeTeam: 'Tampa Bay Lightning', awayTeam: 'Florida Panthers',
        status: 'scheduled',
        league: 'NHL', leagueCountry: 'USA',
        startTime: now.add(const Duration(hours: 2)).toIso8601String(),
        sport: 'hockey',
      ),
    ];
  }
}
