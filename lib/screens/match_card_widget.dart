import 'package:flutter/material.dart';
import '../services/football_service.dart';
import 'match_type.dart';

class MatchCard extends StatelessWidget {
  final Map<String, dynamic> event;
  final MatchType type;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;

  const MatchCard({
    super.key,
    required this.event,
    required this.type,
    required this.isFavorite,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final home = FootballService.getTeamName(event['homeTeam']);
    final away = FootballService.getTeamName(event['awayTeam']);
    final score = FootballService.formatScore(event);
    final time = FootballService.getMatchTime(event);
    final statusDesc = FootballService.getStatusDescription(event);

    final Color textColor = isFavorite ? Colors.black87 : Colors.white;
    final Color bgColor = isFavorite ? Colors.amber.shade50 : Colors.transparent;

    return Container(

      decoration: BoxDecoration(
        color: bgColor,
        border: Border(bottom: BorderSide(color: Colors.grey.shade800)),
      ),

      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [

          SizedBox(width: 64, child: _StatusBadge(type: type, time: time, desc: statusDesc)),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                _TeamRow(name: home, color: const Color(0xFF1B5E20), textColor: textColor),

                const SizedBox(height: 6),

                _TeamRow(name: away, color: const Color(0xFF1565C0), textColor: textColor),

              ],
            ),
          ),

          const SizedBox(width: 6),

          if (type != MatchType.upcoming)

            Container(
              width: 56,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              decoration: BoxDecoration(
                color: type == MatchType.live
                    ? const Color(0xFFFFEBEE)
                    : Colors.grey.shade100,

                borderRadius: BorderRadius.circular(8),

                border: Border.all(
                  color: type == MatchType.live
                      ? Colors.red.shade200
                      : Colors.grey.shade300,
                ),
              ),

              child: Text(
                score,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: type == MatchType.live
                      ? Colors.red.shade700
                      : Colors.black87,
                ),
              ),
            ),

          const SizedBox(width: 4),

          GestureDetector(
            onTap: onToggleFavorite,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(6),

              decoration: BoxDecoration(
                color: isFavorite ? Colors.amber.shade200 : Colors.transparent,
                shape: BoxShape.circle,
              ),

              child: Icon(
                isFavorite ? Icons.star : Icons.star_border,
                color: isFavorite ? Colors.amber.shade700 : Colors.grey.shade400,
                size: 22,
              ),

            ),
          ),

        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final MatchType type;
  final String time;
  final String desc;

  const _StatusBadge({required this.type, required this.time, required this.desc});

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case MatchType.live:
        return Column(mainAxisSize: MainAxisSize.min, children: [

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
                color: Colors.red, borderRadius: BorderRadius.circular(4)),
            
            child: const Text("LIVE",
                style: TextStyle(
                    color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),      
          ),

          if (desc.isNotEmpty) ...[

            const SizedBox(height: 3),

            Text(desc,
                style: const TextStyle(fontSize: 10, color: Colors.red),
                textAlign: TextAlign.center),
          ],
        ]);

      case MatchType.past:
        return Column(mainAxisSize: MainAxisSize.min, children: [

          Text(time,
              style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey.shade400),
              textAlign: TextAlign.center),

          const SizedBox(height: 2),

          Text("Завершён",
              style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
              textAlign: TextAlign.center),
        ]);

      case MatchType.upcoming:

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          decoration: BoxDecoration(
            color:const Color.fromARGB(255, 27, 33, 72),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.blue.shade700),
          ),

          child: Text(
            time.isNotEmpty ? time : "—",
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
          ),

        );
    }
  }
}

class _TeamRow extends StatelessWidget {
  final String name;
  final Color color;
  final Color textColor;

  const _TeamRow({
    required this.name,
    required this.color,
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Row(children: [

      Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        alignment: Alignment.center,
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : "?",
          style: const TextStyle(
              color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
        ),
      ),

      const SizedBox(width: 8),

      Expanded(
        child: Text(
          name,
          style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: textColor),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      
    ]);
  }
}