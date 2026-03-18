import 'package:flutter/material.dart';

class DateSelector extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  const DateSelector({
    super.key,
    required this.label,
    required this.color,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      child: Row(children: [

        IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.white),
          onPressed: onPrev,
        ),

        Expanded(
          child: Text(label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        ),

        IconButton(
          icon: const Icon(Icons.chevron_right, color: Colors.white),
          onPressed: onNext,
        ),
        
      ]),
    );
  }
}