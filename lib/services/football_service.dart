import 'dart:convert';
import 'package:http/http.dart' as http;

class FootballService {
  static const _apiKey = "4bab0e5e3amsh05c8cae404ab8edp11cedcjsn1228d31d701e";
  static const _host = "sportapi7.p.rapidapi.com";

  static Map<String, String> get _headers => {
        "x-rapidapi-key": _apiKey,
        "x-rapidapi-host": _host,
        "Content-Type": "application/json",
      };

  static Future<Map<String, dynamic>> getMatchesByDate(String date) async {
    try {
      final url = Uri.parse(
          "https://$_host/api/v1/sport/football/scheduled-events/$date/inverse");
      final response = await http.get(url, headers: _headers);
      return _parse(response);
    } catch (e) {
      return {"events": [], "rawBody": "", "statusCode": 0, "error": e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getLiveMatches() async {
    try {
      final url = Uri.parse(
          "https://$_host/api/v1/sport/football/events/live");
      final response = await http.get(url, headers: _headers);
      return _parse(response);
    } catch (e) {
      return {"events": [], "rawBody": "", "statusCode": 0, "error": e.toString()};
    }
  }

  static Map<String, dynamic> _parse(http.Response response) {
    final rawBody = response.body;
    final statusCode = response.statusCode;

    if (statusCode != 200) {
      return {
        "events": [],
        "rawBody": rawBody,
        "statusCode": statusCode,
        "error": "HTTP $statusCode"
      };
    }

    try {
      final data = jsonDecode(rawBody);
      final events = _extractEvents(data);
      return {"events": events, "rawBody": rawBody, "statusCode": statusCode};
    } catch (e) {
      return {
        "events": [],
        "rawBody": rawBody,
        "statusCode": statusCode,
        "error": "JSON parse error: $e"
      };
    }
  }

  static List<Map<String, dynamic>> _extractEvents(dynamic data) {
    if (data is Map) {
      for (final key in ["events", "results", "data", "items", "matches"]) {
        if (data.containsKey(key) && data[key] is List) {
          return (data[key] as List)
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList();
        }
      }
      for (final val in data.values) {
        if (val is List && val.isNotEmpty && val.first is Map) {
          return val
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList();
        }
      }
    }
    if (data is List) {
      return data
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    return [];
  }

  static String formatScore(Map<String, dynamic> event) {
    final home = event['homeScore'];
    final away = event['awayScore'];
    if (home == null || away == null) return "- : -";
    final hc = _scoreVal(home);
    final ac = _scoreVal(away);
    return "$hc : $ac";
  }

  static dynamic _scoreVal(dynamic score) {
    if (score is Map) {
      return score['current'] ?? score['display'] ?? score['normaltime'] ?? "-";
    }
    return "-";
  }

  static String getStatusType(Map<String, dynamic> event) {
    final status = event['status'];
    if (status == null) return "notstarted";
    return (status['type'] as String? ?? "notstarted").toLowerCase();
  }

  static String getStatusDescription(Map<String, dynamic> event) {
    final status = event['status'];
    if (status == null) return "";
    return status['description'] as String? ?? "";
  }

  static bool isLive(Map<String, dynamic> event) => getStatusType(event) == "inprogress";
  static bool isFinished(Map<String, dynamic> event) => getStatusType(event) == "finished";
  static bool isNotStarted(Map<String, dynamic> event) => getStatusType(event) == "notstarted";

  static String getHomeName(Map<String, dynamic> event) =>
      getTeamName(event['homeTeam']);

  static String getAwayName(Map<String, dynamic> event) =>
      getTeamName(event['awayTeam']);

  static String getTeamName(dynamic team) {
    if (team == null) return "—";
    return (team['name'] ?? team['shortName'] ?? "—").toString();
  }

  static String getTournamentName(Map<String, dynamic> event) {
    final t = event['tournament'];
    if (t == null) return "Другие матчи";
    final category = t['category'];
    final name = t['name']?.toString() ?? "";
    if (category != null && category is Map) {
      final catName = category['name']?.toString() ?? "";
      return catName.isNotEmpty ? "$catName — $name" : name;
    }
    return name.isNotEmpty ? name : "Другие матчи";
  }

  static String getMatchTime(Map<String, dynamic> event) {
    final ts = event['startTimestamp'];
    if (ts == null) return "";
    final dt = DateTime.fromMillisecondsSinceEpoch((ts as int) * 1000).toLocal();
    return "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
  }
}