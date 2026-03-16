import 'package:flutter/material.dart';
import '../models/match.dart';
import '../services/sports_api_service.dart';

class SportsProvider extends ChangeNotifier {
  final Map<String, List<Match>> _matchesBySport = {};
  final Map<String, bool> _loading = {};
  final Map<String, String?> _errors = {};

  List<Match> getMatches(String sport) => _matchesBySport[sport] ?? [];
  bool isLoading(String sport) => _loading[sport] ?? false;
  String? getError(String sport) => _errors[sport];

  Future<void> loadMatches(String sport) async {

    if (_loading[sport] == true) return;

    _loading[sport] = true;
    _errors[sport] = null;
    notifyListeners();

    try {
      final matches = await _fetchForSport(sport);
      _matchesBySport[sport] = matches;
      _errors[sport] = null;
    } catch (e) {
      _errors[sport] = e.toString();

      _matchesBySport.remove(sport);
    } finally {
      _loading[sport] = false;
      notifyListeners();
    }
  }

  Future<void> refreshMatches(String sport) async {
    _matchesBySport.remove(sport);
    _errors[sport] = null;
    await loadMatches(sport);
  }

  Future<List<Match>> _fetchForSport(String sport) {
    switch (sport) {
      case 'football':
        return SportsApiService.getFootballMatches();
      case 'basketball':
        return SportsApiService.getBasketballMatches();
      case 'tennis':
        return SportsApiService.getTennisMatches();
      case 'hockey':
        return SportsApiService.getHockeyMatches();
      default:
        return Future.value([]);
    }
  }
}