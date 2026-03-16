import 'dart:math';

class Match {
  final String id;
  final String homeTeam;
  final String awayTeam;
  final String? homeTeamLogo;
  final String? awayTeamLogo;
  final String? homeScore;
  final String? awayScore;
  final String status;
  final String? minute;
  final String league;
  final String? leagueLogo;
  final String? leagueCountry;
  final String? startTime;
  final String sport;

  Match({
    required this.id,
    required this.homeTeam,
    required this.awayTeam,
    this.homeTeamLogo,
    this.awayTeamLogo,
    this.homeScore,
    this.awayScore,
    required this.status,
    this.minute,
    required this.league,
    this.leagueLogo,
    this.leagueCountry,
    this.startTime,
    this.sport = 'football',
  });

  bool get isLive {
    final s = status.toLowerCase();
    return s == 'inprogress' ||
        s == 'in_progress' ||
        s == 'live' ||
        s == '1st' ||
        s == '2nd' ||
        s == 'ht' ||
        s == 'ot' ||
        s == 'overtime' ||
        s.contains('inprogress') ||
        s.contains('live') ||
        s.contains('1h') ||
        s.contains('2h') ||
        s.contains('halftime');
  }

  bool get isFinished {
    final s = status.toLowerCase();
    return s == 'finished' ||
        s == 'ended' ||
        s == 'complete' ||
        s == 'ft' ||
        s == 'aet' ||
        s == 'pen' ||
        s == 'fin' ||
        s.contains('finish') ||
        s.contains('ended');
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'homeTeam': homeTeam,
        'awayTeam': awayTeam,
        'homeTeamLogo': homeTeamLogo,
        'awayTeamLogo': awayTeamLogo,
        'homeScore': homeScore,
        'awayScore': awayScore,
        'status': status,
        'minute': minute,
        'league': league,
        'leagueLogo': leagueLogo,
        'leagueCountry': leagueCountry,
        'startTime': startTime,
        'sport': sport,
      };

  factory Match.fromJson(Map<String, dynamic> json) => Match(
        id: json['id'] ?? '',
        homeTeam: json['homeTeam'] ?? '',
        awayTeam: json['awayTeam'] ?? '',
        homeTeamLogo: json['homeTeamLogo'],
        awayTeamLogo: json['awayTeamLogo'],
        homeScore: json['homeScore'],
        awayScore: json['awayScore'],
        status: json['status'] ?? '',
        minute: json['minute'],
        league: json['league'] ?? '',
        leagueLogo: json['leagueLogo'],
        leagueCountry: json['leagueCountry'],
        startTime: json['startTime'],
        sport: json['sport'] ?? 'football',
      );

  factory Match.fromApiJson(Map<String, dynamic> json, String sport) {

    final homeTeamRaw =
        json['homeTeam'] ?? json['HomeTeam'] ?? json['home_team'] ?? json['home'] ?? {};
    final awayTeamRaw =
        json['awayTeam'] ?? json['AwayTeam'] ?? json['away_team'] ?? json['away'] ?? {};

    String homeTeamName =
        _extractName(homeTeamRaw) ?? json['homeTeamName']?.toString() ?? 'Home Team';
    String awayTeamName =
        _extractName(awayTeamRaw) ?? json['awayTeamName']?.toString() ?? 'Away Team';
    String? homeTeamLogo = _extractLogo(homeTeamRaw);
    String? awayTeamLogo = _extractLogo(awayTeamRaw);

    final tournamentRaw =
        json['tournament'] ?? json['league'] ?? json['League'] ?? {};
    String leagueName = '';
    String? leagueLogo;
    String? leagueCountry;

    if (tournamentRaw is Map) {
      leagueName = tournamentRaw['name']?.toString() ??
          tournamentRaw['uniqueName']?.toString() ??
          '';
      leagueLogo = tournamentRaw['logo']?.toString();
      final category = tournamentRaw['category'];
      if (category is Map) {
        leagueCountry = category['name']?.toString();
      }

      final unique = tournamentRaw['uniqueTournament'];
      if (leagueName.isEmpty && unique is Map) {
        leagueName = unique['name']?.toString() ?? '';
      }
    } else if (tournamentRaw is String) {
      leagueName = tournamentRaw;
    }

    if (leagueName.isEmpty) leagueName = sport;

    String? homeScore;
    String? awayScore;

    final homeScoreRaw = json['homeScore'];
    final awayScoreRaw = json['awayScore'];

    if (homeScoreRaw is Map) {
      homeScore = homeScoreRaw['current']?.toString() ??
          homeScoreRaw['normaltime']?.toString() ??
          homeScoreRaw['display']?.toString();
    } else if (homeScoreRaw is int || homeScoreRaw is double) {
      homeScore = homeScoreRaw.toString();
    } else if (homeScoreRaw is String) {
      homeScore = homeScoreRaw;
    }

    if (awayScoreRaw is Map) {
      awayScore = awayScoreRaw['current']?.toString() ??
          awayScoreRaw['normaltime']?.toString() ??
          awayScoreRaw['display']?.toString();
    } else if (awayScoreRaw is int || awayScoreRaw is double) {
      awayScore = awayScoreRaw.toString();
    } else if (awayScoreRaw is String) {
      awayScore = awayScoreRaw;
    }

    if (homeScore == null && awayScore == null) {
      final scoreRaw = json['score'] ?? json['Score'];
      if (scoreRaw is Map) {
        homeScore = scoreRaw['home']?.toString() ??
            (scoreRaw['homeScore'] is Map
                ? scoreRaw['homeScore']['current']?.toString()
                : scoreRaw['homeScore']?.toString());
        awayScore = scoreRaw['away']?.toString() ??
            (scoreRaw['awayScore'] is Map
                ? scoreRaw['awayScore']['current']?.toString()
                : scoreRaw['awayScore']?.toString());
      }
    }

    String statusStr = 'scheduled';
    final statusRaw = json['status'] ?? json['Status'];
    if (statusRaw is Map) {
      statusStr = statusRaw['type']?.toString() ??
          statusRaw['description']?.toString() ??
          'scheduled';
    } else if (statusRaw is String) {
      statusStr = statusRaw;
    } else if (statusRaw is int) {
      statusStr = _numericStatusToString(statusRaw);
    }

    String? minute;
    final timeRaw = json['time'] ?? json['Time'];
    if (timeRaw is Map) {
      final played = timeRaw['played'];
      final injuryTime = timeRaw['injurytime'];
      final current = timeRaw['current'];
      if (played != null) {
        minute = (injuryTime != null && injuryTime > 0)
            ? "${played}+${injuryTime}'"
            : "${played}'";
      } else if (current != null) {
        minute = "${current}'";
      }
    }

    if (statusRaw is Map) {
      final desc = statusRaw['description']?.toString().toLowerCase() ?? '';
      if (desc.contains('halftime') || desc.contains('half time') || desc == 'ht') {
        minute = 'HT';
      }
    }
    minute ??= json['minute']?.toString();

    String? startTime;
    final startTimeRaw =
        json['startTimestamp'] ?? json['startTime'] ?? json['StartTime'] ?? json['date'];
    if (startTimeRaw is int) {
      startTime =
          DateTime.fromMillisecondsSinceEpoch(startTimeRaw * 1000).toIso8601String();
    } else if (startTimeRaw is String) {
      startTime = startTimeRaw;
    }

    final id = json['id']?.toString() ??
        json['Id']?.toString() ??
        json['matchId']?.toString() ??
        Random().nextInt(999999).toString();

    return Match(
      id: id,
      homeTeam: homeTeamName,
      awayTeam: awayTeamName,
      homeTeamLogo: homeTeamLogo,
      awayTeamLogo: awayTeamLogo,
      homeScore: homeScore,
      awayScore: awayScore,
      status: statusStr,
      minute: minute,
      league: leagueName,
      leagueLogo: leagueLogo,
      leagueCountry: leagueCountry,
      startTime: startTime,
      sport: sport,
    );
  }

  static String? _extractName(dynamic raw) {
    if (raw is Map) {
      return raw['name']?.toString() ??
          raw['Name']?.toString() ??
          raw['shortName']?.toString() ??
          raw['longName']?.toString();
    } else if (raw is String && raw.isNotEmpty) {
      return raw;
    }
    return null;
  }

  static String? _extractLogo(dynamic raw) {
    if (raw is Map) {
      final logo = raw['logo']?.toString() ??
          raw['Logo']?.toString() ??
          raw['image']?.toString();
      return (logo != null && logo.isNotEmpty) ? logo : null;
    }
    return null;
  }

  static String _numericStatusToString(int code) {

    switch (code) {
      case 0:
        return 'scheduled';
      case 6:
      case 7:
        return 'inprogress';
      case 31:
        return 'ht';
      case 100:
        return 'finished';
      default:
        return 'scheduled';
    }
  }
}