import 'package:flutter/material.dart';
import '../services/football_service.dart';
import 'match_type.dart';
import 'match_card_widget.dart';

class MatchList extends StatelessWidget {
  final List<Map<String, dynamic>> matches;
  final MatchType type;
  final bool Function(Map<String, dynamic>) isFavorite;
  final void Function(Map<String, dynamic>) onToggleFavorite;

  const MatchList({
    super.key,
    required this.matches,
    required this.type,
    required this.isFavorite,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (final m in matches) {
      final key = FootballService.getTournamentName(m);
      grouped.putIfAbsent(key, () => []).add(m);
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 20),
      itemCount: grouped.length,
      itemBuilder: (_, i) {
        final name = grouped.keys.elementAt(i);
        final list = grouped[name]!;
        return _TournamentGroup(
          name: name,
          matches: list,
          type: type,
          isFavorite: isFavorite,
          onToggleFavorite: onToggleFavorite,
        );
      },
    );
  }
}

class _TournamentGroup extends StatelessWidget {
  final String name;
  final List<Map<String, dynamic>> matches;
  final MatchType type;
  final bool Function(Map<String, dynamic>) isFavorite;
  final void Function(Map<String, dynamic>) onToggleFavorite;

  const _TournamentGroup({
    required this.name,
    required this.matches,
    required this.type,
    required this.isFavorite,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Container(
          width: double.infinity,
          color: Colors.grey.shade100,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(children: [

            const Icon(Icons.emoji_events, size: 16, color: Color(0xFF388E3C)),

            const SizedBox(width: 6),

            Expanded(
              child: Text(name,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Color(0xFF1B5E20))),
            ),

            Text("${matches.length}",
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),

          ]),
        ),

        ...matches.map((m) => MatchCard(
              event: m,
              type: type,
              isFavorite: isFavorite(m),
              onToggleFavorite: () => onToggleFavorite(m),
            )),
            
      ],
    );
  }
}