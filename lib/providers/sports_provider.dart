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
      List<Match> matches;
      switch (sport) {
        case 'football':
          matches = await SportsApiService.getFootballMatches();
          break;
        case 'basketball':
          matches = await SportsApiService.getBasketballMatches();
          break;
        case 'tennis':
          matches = await SportsApiService.getTennisMatches();
          break;
        case 'hockey':
          matches = await SportsApiService.getHockeyMatches();
          break;
        default:
          matches = [];
      }
      _matchesBySport[sport] = matches;
    } catch (e) {
      _errors[sport] = e.toString();
    }

    _loading[sport] = false;
    notifyListeners();
  }

  Future<void> refreshMatches(String sport) async {
    _matchesBySport.remove(sport);
    await loadMatches(sport);
  }
}
