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

  bool get isLive =>
      status.toLowerCase().contains('live') ||
      status.toLowerCase().contains('1h') ||
      status.toLowerCase().contains('2h') ||
      status.toLowerCase().contains('ht') ||
      status == 'inprogress' ||
      status == 'in_progress';

  bool get isFinished =>
      status.toLowerCase().contains('fin') ||
      status.toLowerCase().contains('ended') ||
      status.toLowerCase() == 'ft' ||
      status.toLowerCase() == 'aet' ||
      status.toLowerCase() == 'pen';

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
    final homeTeam = json['HomeTeam'] ?? json['home_team'] ?? json['home'] ?? {};
    final awayTeam = json['AwayTeam'] ?? json['away_team'] ?? json['away'] ?? {};
    final score = json['Score'] ?? json['score'] ?? {};
    final league = json['League'] ?? json['league'] ?? json['tournament'] ?? {};

    String homeTeamName = '';
    String awayTeamName = '';
    String? homeTeamLogo;
    String? awayTeamLogo;
    String leagueName = '';
    String? leagueLogo;
    String? homeScore;
    String? awayScore;

    if (homeTeam is Map) {
      homeTeamName = homeTeam['name'] ?? homeTeam['Name'] ?? homeTeam['longName'] ?? '';
      homeTeamLogo = homeTeam['logo'] ?? homeTeam['Logo'] ?? homeTeam['image'];
    } else if (homeTeam is String) {
      homeTeamName = homeTeam;
    }

    if (awayTeam is Map) {
      awayTeamName = awayTeam['name'] ?? awayTeam['Name'] ?? awayTeam['longName'] ?? '';
      awayTeamLogo = awayTeam['logo'] ?? awayTeam['Logo'] ?? awayTeam['image'];
    } else if (awayTeam is String) {
      awayTeamName = awayTeam;
    }

    if (league is Map) {
      leagueName = league['name'] ?? league['Name'] ?? league['longName'] ?? '';
      leagueLogo = league['logo'] ?? league['Logo'];
    } else if (league is String) {
      leagueName = league;
    }

    if (score is Map) {
      homeScore = score['home']?.toString() ??
          score['Home']?.toString() ??
          score['homeScore']?.toString();
      awayScore = score['away']?.toString() ??
          score['Away']?.toString() ??
          score['awayScore']?.toString();
    }

    // Direct score fields
    homeScore ??= json['homeScore']?.toString() ?? json['HomeScore']?.toString();
    awayScore ??= json['awayScore']?.toString() ?? json['AwayScore']?.toString();

    // Fallback for team names
    if (homeTeamName.isEmpty) {
      homeTeamName = json['homeTeamName']?.toString() ?? json['HomeTeamName']?.toString() ?? 'Home Team';
    }
    if (awayTeamName.isEmpty) {
      awayTeamName = json['awayTeamName']?.toString() ?? json['AwayTeamName']?.toString() ?? 'Away Team';
    }
    if (leagueName.isEmpty) {
      leagueName = json['leagueName']?.toString() ?? json['LeagueName']?.toString() ?? sport;
    }

    final status = json['status'] ?? json['Status'] ?? json['matchStatus'] ?? 'scheduled';
    final minute = json['minute']?.toString() ?? json['Minute']?.toString() ?? json['matchMinute']?.toString();
    final startTime = json['startTime'] ?? json['StartTime'] ?? json['matchTime'] ?? json['date'];

    return Match(
      id: json['id']?.toString() ?? json['Id']?.toString() ?? json['matchId']?.toString() ?? Random().nextInt(999999).toString(),
      homeTeam: homeTeamName,
      awayTeam: awayTeamName,
      homeTeamLogo: homeTeamLogo,
      awayTeamLogo: awayTeamLogo,
      homeScore: homeScore,
      awayScore: awayScore,
      status: status.toString(),
      minute: minute,
      league: leagueName,
      leagueLogo: leagueLogo,
      leagueCountry: json['country']?.toString() ?? json['Country']?.toString(),
      startTime: startTime?.toString(),
      sport: sport,
    );
  }
}
