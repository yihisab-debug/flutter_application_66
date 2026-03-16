import 'package:flutter/material.dart';

class TeamAvatar extends StatelessWidget {
  final String name;
  final String? logoUrl;
  final double size;

  const TeamAvatar({
    super.key,
    required this.name,
    this.logoUrl,
    this.size = 28,
  });

  @override
  Widget build(BuildContext context) {
    if (logoUrl != null && logoUrl!.isNotEmpty) {
      return SizedBox(
        width: size,
        height: size,

        child: ClipRRect(
          borderRadius: BorderRadius.circular(size / 2),

          child: Image.network(
            logoUrl!,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _fallback(),
          ),
          
        ),
      );
    }
    return _fallback();
  }

  Widget _fallback() {
    final initials = _getInitials(name);
    final color = _colorFromName(name);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        shape: BoxShape.circle,
        border: Border.all(color: color.withOpacity(0.5), width: 1),
      ),

      child: Center(

        child: Text(
          initials,
          style: TextStyle(
            color: color,
            fontSize: size * 0.35,
            fontWeight: FontWeight.w800,
          ),
        ),
        
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }

  Color _colorFromName(String name) {
    final colors = [
      const Color(0xFF00C853),
      const Color(0xFF2979FF),
      const Color(0xFFFF6D00),
      const Color(0xFFAA00FF),
      const Color(0xFF00BCD4),
      const Color(0xFFFF1744),
      const Color(0xFFFFD600),
      const Color(0xFF00E5FF),
    ];
    final index = name.codeUnits.fold(0, (a, b) => a + b) % colors.length;
    return colors[index];
  }
}