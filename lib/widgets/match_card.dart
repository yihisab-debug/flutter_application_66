import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/match.dart';
import '../providers/favorites_provider.dart';
import 'team_avatar.dart';

class MatchCard extends StatelessWidget {
  final Match match;

  const MatchCard({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    return Consumer<FavoritesProvider>(
      builder: (context, fav, _) {
        final isFav = fav.isFavorite(match.id);
        return GestureDetector(
          onTap: () => _showMatchDetails(context),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF131929),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: match.isLive
                    ? const Color(0xFF00C853).withOpacity(0.3)
                    : Colors.white.withOpacity(0.05),
                width: 1,
              ),
            ),

            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [

                  _StatusColumn(match: match),

                  const SizedBox(width: 12),

                  Expanded(child: _TeamsColumn(match: match)),

                  const SizedBox(width: 8),

                  _FavoriteButton(
                    isFavorite: isFav,
                    onTap: () => fav.toggleFavorite(match),
                  ),

                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showMatchDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF131929),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _MatchDetailSheet(match: match),
    );
  }
}

class _StatusColumn extends StatelessWidget {
  final Match match;

  const _StatusColumn({required this.match});

  @override
  Widget build(BuildContext context) {
    if (match.isLive) {
      return SizedBox(
        width: 52,
        child: Column(
          children: [

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF00C853),
                borderRadius: BorderRadius.circular(4),
              ),

              child: const Text(
                'LIVE',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
            ),

            if (match.minute != null) ...[

              const SizedBox(height: 3),

              Text(
                match.minute!,
                style: const TextStyle(
                  color: Color(0xFF00C853),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),

            ],
          ],
        ),
      );
    }

    if (match.isFinished) {
      return SizedBox(
        width: 52,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(4),
          ),
          
          child: Text(
            match.status.toUpperCase(),
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return SizedBox(
      width: 52,
      child: Text(
        _formatTime(match.startTime),
        style: const TextStyle(
          color: Colors.white60,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  String _formatTime(String? iso) {
    if (iso == null) return '--:--';
    try {
      final dt = DateTime.parse(iso).toLocal();
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return iso.length > 5 ? iso.substring(0, 5) : iso;
    }
  }
}

class _TeamsColumn extends StatelessWidget {
  final Match match;

  const _TeamsColumn({required this.match});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        _TeamRow(
          name: match.homeTeam,
          logoUrl: match.homeTeamLogo,
          score: match.homeScore,
          isWinner: _isHomeWinner(),
        ),

        const SizedBox(height: 8),

        _TeamRow(
          name: match.awayTeam,
          logoUrl: match.awayTeamLogo,
          score: match.awayScore,
          isWinner: _isAwayWinner(),
        ),

      ],
    );
  }

  bool _isHomeWinner() {
    if (!match.isFinished) return false;
    final h = int.tryParse(match.homeScore?.split('-').first ?? '');
    final a = int.tryParse(match.awayScore?.split('-').first ?? '');
    if (h == null || a == null) return false;
    return h > a;
  }

  bool _isAwayWinner() {
    if (!match.isFinished) return false;
    final h = int.tryParse(match.homeScore?.split('-').first ?? '');
    final a = int.tryParse(match.awayScore?.split('-').first ?? '');
    if (h == null || a == null) return false;
    return a > h;
  }
}

class _TeamRow extends StatelessWidget {
  final String name;
  final String? logoUrl;
  final String? score;
  final bool isWinner;

  const _TeamRow({
    required this.name,
    this.logoUrl,
    this.score,
    this.isWinner = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [

        TeamAvatar(name: name, logoUrl: logoUrl, size: 22),

        const SizedBox(width: 8),

        Expanded(
          child: Text(
            name,
            style: TextStyle(
              color: isWinner ? Colors.white : Colors.white70,
              fontSize: 13,
              fontWeight: isWinner ? FontWeight.w700 : FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),

        if (score != null) ...[
          const SizedBox(width: 8),

          Text(
            score!,
            style: TextStyle(
              color: isWinner ? Colors.white : Colors.white60,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),

        ],
      ],
    );
  }
}

class _FavoriteButton extends StatelessWidget {
  final bool isFavorite;
  final VoidCallback onTap;

  const _FavoriteButton({required this.isFavorite, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedSwitcher(

        duration: const Duration(milliseconds: 200),

        child: Icon(
          isFavorite ? Icons.star : Icons.star_border,
          key: ValueKey(isFavorite),
          color: isFavorite ? const Color(0xFFFFD700) : Colors.white30,
          size: 20,
        ),

      ),
    );
  }
}

class _MatchDetailSheet extends StatelessWidget {
  final Match match;

  const _MatchDetailSheet({required this.match});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          const SizedBox(height: 20),

          Text(
            match.league,
            style: const TextStyle(
              color: Color(0xFF00C853),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),

          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _DetailTeam(name: match.homeTeam, logoUrl: match.homeTeamLogo),
              Column(
                children: [

                  if (match.homeScore != null && match.awayScore != null)

                    Text(
                      '${match.homeScore} - ${match.awayScore}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                      ),
                    )

                  else
                    const Text(
                      'vs',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 24,
                        fontWeight: FontWeight.w300,
                      ),
                    ),

                  const SizedBox(height: 6),

                  _StatusBadge(match: match),

                ],
              ),
              _DetailTeam(name: match.awayTeam, logoUrl: match.awayTeamLogo),
            ],
          ),

          const SizedBox(height: 24),

          Consumer<FavoritesProvider>(
            builder: (context, fav, _) {
              final isFav = fav.isFavorite(match.id);
              return OutlinedButton.icon(

                onPressed: () => fav.toggleFavorite(match),

                icon: Icon(
                  isFav ? Icons.star : Icons.star_border,
                  color: isFav ? const Color(0xFFFFD700) : Colors.white60,
                ),

                label: Text(
                  isFav ? 'Remove from Favorites' : 'Add to Favorites',
                  style: TextStyle(
                    color: isFav ? const Color(0xFFFFD700) : Colors.white60,
                  ),
                ),

                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: isFav
                        ? const Color(0xFFFFD700).withOpacity(0.4)
                        : Colors.white24,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
              
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _DetailTeam extends StatelessWidget {
  final String name;
  final String? logoUrl;

  const _DetailTeam({required this.name, this.logoUrl});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        TeamAvatar(name: name, logoUrl: logoUrl, size: 44),

        const SizedBox(height: 8),

        SizedBox(
          width: 90,
          child: Text(
            name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),

      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final Match match;

  const _StatusBadge({required this.match});

  @override
  Widget build(BuildContext context) {
    if (match.isLive) {

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFF00C853),
          borderRadius: BorderRadius.circular(20),
        ),

        child: Text(
          match.minute != null ? 'LIVE ${match.minute}' : 'LIVE',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 10,
            fontWeight: FontWeight.w900,
          ),
        ),
        
      );
    }
    return Text(
      match.status.toUpperCase(),
      style: const TextStyle(color: Colors.white54, fontSize: 11),
    );
  }
}
