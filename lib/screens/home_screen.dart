import 'package:flutter/material.dart';
import 'matches_tab.dart';
import 'favorites_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static const List<({String label, IconData icon})> _tabs = [
    (label: 'Scores', icon: Icons.sports_soccer),
    (label: 'Favorites', icon: Icons.star),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),

      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          MatchesTab(),
          FavoritesScreen(),
        ],
      ),

      bottomNavigationBar: Container(

        decoration: BoxDecoration(
          color: const Color(0xFF0D1220),
          border: Border(
            top: BorderSide(color: Colors.white.withOpacity(0.08), width: 1),
          ),
        ),

        child: SafeArea(
          child: SizedBox(
            height: 64,

            child: Row(
              children: List.generate(_tabs.length, (i) {
                final tab = _tabs[i];
                final selected = _selectedIndex == i;

                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedIndex = i),
                    behavior: HitTestBehavior.opaque,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [

                        Icon(
                          tab.icon,
                          color: selected
                              ? const Color(0xFF00C853)
                              : Colors.white38,
                          size: 24,
                        ),

                        const SizedBox(height: 4),

                        Text(
                          tab.label,
                          style: TextStyle(
                            color: selected
                                ? const Color(0xFF00C853)
                                : Colors.white38,
                            fontSize: 11,
                            fontWeight: selected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                        
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}