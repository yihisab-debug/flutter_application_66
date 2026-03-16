import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/match.dart';

class FavoritesProvider extends ChangeNotifier {
  final List<Match> _favorites = [];
  static const String _key = 'favorites';

  List<Match> get favorites => List.unmodifiable(_favorites);

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_key) ?? [];
    _favorites.clear();
    for (final item in data) {
      try {
        _favorites.add(Match.fromJson(json.decode(item)));
      } catch (_) {}
    }
    notifyListeners();
  }

  bool isFavorite(String matchId) => _favorites.any((m) => m.id == matchId);

  Future<void> toggleFavorite(Match match) async {
    if (isFavorite(match.id)) {
      _favorites.removeWhere((m) => m.id == match.id);
    } else {
      _favorites.add(match);
    }
    await _save();
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _key,
      _favorites.map((m) => json.encode(m.toJson())).toList(),
    );
  }
}