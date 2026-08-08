import 'package:flutter/material.dart';

// Single source of truth for the SmartQ brand green, used both directly (auth screens, cards
// that need the exact brand color regardless of theme) and to seed the app's actual ThemeData
// (theme_provider.dart) so Theme.of(context).colorScheme.* resolves to on-brand colors too,
// instead of Flutter's black/white Material defaults.
const Color kSmartQGreen = Color(0xFF1B7A3D);
const Color kSmartQGreenLight = Color(0xFFEAF6EE);
