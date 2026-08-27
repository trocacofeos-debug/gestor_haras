// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class SiteAdminHeader extends StatelessWidget {
  const SiteAdminHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 96,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFF111827), Color(0xFF1E293B)],
        ),
        border: Border(bottom: BorderSide(color: Color(0xFF334155))),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withValues(alpha: .16),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFF818CF8).withValues(alpha: .3),
              ),
            ),
            child: Icon(icon, color: const Color(0xFFA5B4FC), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'CONTEÚDO DO SITE',
                  style: TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFFCBD5E1),
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: .12),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: const Color(0xFF34D399).withValues(alpha: .25),
              ),
            ),
            child: const Row(
              children: [
                Icon(Icons.public_rounded, size: 13, color: Color(0xFF6EE7B7)),
                SizedBox(width: 6),
                Text(
                  'PUBLICADO',
                  style: TextStyle(
                    color: Color(0xFF6EE7B7),
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: .4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
