import 'package:flutter/material.dart';

class SportTabBar extends StatelessWidget {
  final TabController tabController;
  final List<({String label, IconData icon})> sports;

  const SportTabBar({
    super.key,
    required this.tabController,
    required this.sports,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      height: 44,
      child: TabBar(
        controller: tabController,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        indicator: BoxDecoration(
          color: const Color(0xFF00C853),
          borderRadius: BorderRadius.circular(22),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.black,
        unselectedLabelColor: Colors.white60,
        labelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        padding: EdgeInsets.zero,
        tabs: sports
            .map(
              (s) => Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(s.icon, size: 15),
                    const SizedBox(width: 5),
                    Text(s.label),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
