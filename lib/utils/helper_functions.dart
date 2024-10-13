
import 'package:flutter/material.dart';

class HelperFunctions {

  // Declare a Map to store note names and their respective colors
  static const Map<String, Color> noteColorMap = {
    'C': Colors.red,
    'D': Colors.orange,
    'E': Colors.amber,
    'F': Colors.green,
    'G': Colors.teal,
    'A': Colors.blue,
    'B': Colors.purple,
    'C5': Colors.pink,
  };

  // Path to the directory containing sound assets
  static const String assetPath = 'assets/sounds';

  /// Returns a list of asset paths for a given list of notes.
  static List<String> getNoteAssets(List<String> notes) {
    return notes.map(getAssetPathForNote).toList();
  }

  /// Retrieves the asset path for a specific note.
  /// Defaults to C4 if the note is unrecognized.
  static String getAssetPathForNote(String note) {
    switch (note) {
      case 'C':
        return '$assetPath/C4.wav'; // Lower C (C4)
      case 'D':
        return '$assetPath/D.wav';
      case 'E':
        return '$assetPath/E.wav';
      case 'F':
        return '$assetPath/F.wav';
      case 'G':
        return '$assetPath/G.wav';
      case 'A':
        return '$assetPath/A.wav';
      case 'B':
        return '$assetPath/B.wav';
      case 'C5':
        return '$assetPath/C5.wav'; // Higher C (C5)
      default:
        return '$assetPath/C4.wav'; // Default to C4 if unrecognized
    }
  }

  /// Returns a width multiplier based on the note for visual key representation.
  /// Defaults to 1.0 for unrecognized notes.
  static double getWidthMultiplierForKey(String note) {
    switch (note) {
      case 'C':
        return 1.0;
      case 'D':
        return 0.9;
      case 'E':
        return 0.8;
      case 'F':
        return 0.7;
      case 'G':
        return 0.6;
      case 'A':
        return 0.5;
      case 'B':
        return 0.4;
      case 'C5':
        return 0.3;
      default:
        return 1.0;
    }
  }
}


/*
class HelperFunctions {
  // Get note assets based on notes list
  static List<String> getNoteAssets(List<String> notes) {
    return notes.map((note) => getAssetPathForNote(note)).toList();
  }

  // Get the asset path for a specific note
  static String getAssetPathForNote(String note) {
    switch (note) {
      case 'C':
        return '$assetPath/C4.wav'; // Lower C (C4)
      case 'D':
        return '$assetPath/D.wav';
      case 'E':
        return '$assetPath/E.wav';
      case 'F':
        return '$assetPath/F.wav';
      case 'G':
        return '$assetPath/G.wav';
      case 'A':
        return '$assetPath/A.wav';
      case 'B':
        return '$assetPath/B.wav';
      case 'C5':
        return '$assetPath/C5.wav'; // Higher C (C5)
      default:
        return '$assetPath/C4.wav'; // Default asset path if note is unrecognized
    }
  }

  // Get width multiplier for visual representation of keys
  static double getWidthMultiplierForKey(String note) {
    switch (note) {
      case 'C':
        return 1.0;
      case 'D':
        return 0.9;
      case 'E':
        return 0.8;
      case 'F':
        return 0.7;
      case 'G':
        return 0.6;
      case 'A':
        return 0.5;
      case 'B':
        return 0.4;
      case 'C5':
        return 0.3;
      default:
        return 1.0; // Default full width for unrecognized note
    }
  }

  // Static path for the sound directory
  static String assetPath = 'assets/sounds';
}
*/
