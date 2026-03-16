import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/favorites_provider.dart';
import '../widgets/match_card.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [

          _buildHeader(),

          Expanded(
            child: Consumer<FavoritesProvider>(
              builder: (context, provider, _) {
                final favorites = provider.favorites;

                if (favorites.isEmpty) {
                  return _buildEmpty();
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: favorites.length,
                  itemBuilder: (_, i) => MatchCard(match: favorites[i]),
                );

              },
            ),
          ),

        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Row(
        children: [

          Container(
            padding: const EdgeInsets.all(8),

            decoration: BoxDecoration(
              color: const Color(0xFFFFD700).withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),

            child: const Icon(
              Icons.star,
              color: Color(0xFFFFD700),
              size: 20,
            ),
            
          ),

          const SizedBox(width: 12),

          const Text(
            'Favorites',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),

        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              shape: BoxShape.circle,
            ),

            child: const Icon(
              Icons.star_border,
              color: Colors.white30,
              size: 52,
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            'No favorites yet',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Tap the star icon on any match\nto add it to favorites',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white38, fontSize: 13, height: 1.5),
          ),
          
        ],
      ),
    );
  }
}