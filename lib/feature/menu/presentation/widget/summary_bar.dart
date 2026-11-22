import 'package:flutter/material.dart';

/// One-line bold summary with a deepOrange icon, used at the top of menu tabs.
class SummaryBar extends StatelessWidget {
  final IconData icon;
  final String text;
  final Widget? trailing;

  const SummaryBar({super.key, required this.icon, required this.text, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.deepOrange),
          const SizedBox(width: 6),
          Expanded(
            child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
