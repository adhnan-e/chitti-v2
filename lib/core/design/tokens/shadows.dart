import 'package:flutter/material.dart';

/// Shadow tokens for consistent elevation
abstract class AppShadows {
  // No shadow
  static const List<BoxShadow> none = [];

  // Subtle shadow (cards at rest)
  static const List<BoxShadow> sm = [
    BoxShadow(
      color: Color(0x1A000000),
      offset: Offset(0, 1),
      blurRadius: 2,
      spreadRadius: 0,
    ),
  ];

  // Default shadow (interactive cards)
  static const List<BoxShadow> md = [
    BoxShadow(
      color: Color(0x1A000000),
      offset: Offset(0, 2),
      blurRadius: 8,
      spreadRadius: 0,
    ),
  ];

  // Elevated shadow (floating elements)
  static const List<BoxShadow> lg = [
    BoxShadow(
      color: Color(0x26000000),
      offset: Offset(0, 4),
      blurRadius: 16,
      spreadRadius: 0,
    ),
  ];

  // High elevation shadow (modals, dropdowns)
  static const List<BoxShadow> xl = [
    BoxShadow(
      color: Color(0x33000000),
      offset: Offset(0, 8),
      blurRadius: 32,
      spreadRadius: 0,
    ),
  ];

  // Primary color glow (for primary buttons on hover)
  static List<BoxShadow> primaryGlow = [
    BoxShadow(
      color: const Color(0xFF13EC5B).withOpacity(0.3),
      offset: const Offset(0, 4),
      blurRadius: 16,
      spreadRadius: 0,
    ),
  ];

  // Error glow (for error states)
  static List<BoxShadow> errorGlow = [
    BoxShadow(
      color: const Color(0xFFF85149).withOpacity(0.3),
      offset: const Offset(0, 4),
      blurRadius: 16,
      spreadRadius: 0,
    ),
  ];
}
