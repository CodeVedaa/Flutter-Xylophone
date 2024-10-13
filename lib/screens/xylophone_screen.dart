import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:xylophone/screens/song_library.dart';
import 'package:xylophone/utils/helper_functions.dart';

class XylophoneScreen extends StatefulWidget {
  const XylophoneScreen({super.key});

  @override
  State<XylophoneScreen> createState() => _XylophoneScreenState();
}

class _XylophoneScreenState extends State<XylophoneScreen> {
  late AudioPlayer _player;
  String? _playingNote;

  int _currentNoteIndex = 0;
  List<String> _currentSongNotes = [];
  String? _selectedSong;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer(); // 1. Initialize the AudioPlayer
  }

  @override
  void dispose() {
    _player.dispose(); // 2. Set the Asset file Path  to play
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double totalWidth = MediaQuery.of(context).size.width;
    double baseWidth = totalWidth - 40;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFD5B07C),
        title: const Text("Xylophone"),
      ),
      backgroundColor: const Color(0xFFD5B07C),
      drawer: _selectedSong == null ? buildDrawer(context) : null,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              // Display currently playing notes at the top
              _displayCurrentlyPlayingNotes(),

              const SizedBox(height: 8),

              // Build the xylophone keys with decreasing width

              // Loop through the Map entries to dynamically create the keys
              Column(
                children: HelperFunctions.noteColorMap.entries.map((entry) {
                  return _buildKey(
                    label: entry.key,
                    // The note label (C, D, E, etc.)
                    assetPath: HelperFunctions.getAssetPathForNote(entry.key),
                    // Function to get the asset path
                    width: baseWidth *
                        HelperFunctions.getWidthMultiplierForKey(entry.key),
                    // Adjust width for each note
                    color: entry.value, // The color from the map
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKey(
      {required String label,
      required String assetPath,
      required double width,
      required Color color}) {
    bool isHighlighted =
        _playingNote == label; // Check if the note is currently playing
    return InkWell(
      splashColor: Colors.white.withOpacity(0.3),
      highlightColor: Colors.white.withOpacity(0.1),
      onTap: _selectedSong == null // Disable tapping when a song is playing
          ? () {
              _playSound(assetPath, label, color);
            }
          : null,
      child: Container(
        height: 50,
        width: width,
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: isHighlighted ? color.withOpacity(0.5) : color,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.black, width: 2),
        ),
        child: Center(
            child: Text(
          label,
          style: TextStyle(
              color: isHighlighted ? Colors.red : Colors.white,
              // Change color based on playing state
              fontSize: 18,
              fontWeight: FontWeight.bold),
        )),
      ),
    );
  }

  Drawer buildDrawer(BuildContext context) {
    return Drawer(
      //selectedSong == null ? null :
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Color(0xFFD5B07C),
            ),
            child: Text(
              'Select a Song',
              style: TextStyle(fontSize: 24, color: Colors.white),
            ),
          ),
          ...SongLibrary.songs.keys.map((songName) {
            return ListTile(
              title: Text(songName),
              onTap: () {
                _playSong(songName);
                Navigator.pop(context);
              },
            );
          }),
        ],
      ),
    );
  }

  Future<void> _playSound(String assetPath, String label, Color color) async {
    try {
      await _player.stop(); //Stop before playing new Note
      if (!mounted) return;
      setState(() {
        _playingNote = label; // Set the currently playing note
      });

      await _player.setAsset(assetPath); // 2. Set the Asset file Path  to play
      _player.play(); // 3. Play the Audio

      // Scroll to the current note index
      _scrollToCurrentNote();

      await Future.delayed(const Duration(milliseconds: 500));

      setState(() {
        _playingNote = null; // Reset playing note after delay
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to play sound: $e")),
      );
    }
  }

  // Function to scroll to the current playing note to keep it centered.
  void _scrollToCurrentNote() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Check if the ScrollController has attached to a ScrollView
      if (_scrollController.hasClients) {
        final scrollPosition = _currentNoteIndex * 20.0 - (MediaQuery.of(context).size.width / 2); // Adjust scroll to center the currently playing note
        _scrollController.animateTo(
          scrollPosition.clamp(0.0, _scrollController.position.maxScrollExtent),
          duration: const Duration(milliseconds: 300), //  Smooth scroll duration
          curve: Curves.easeInOut,
        );
      }
    });
  }

  // Function to play a song by iterating through each note in the sequence.
  void _playSong(String songName) async {
    List<String> assetsList = [];
    setState(() {
      _selectedSong = songName; // Update the currently selected song.
      _currentSongNotes = SongLibrary.songs[songName]!.split(' '); // Split the notes into a list.
      assetsList = HelperFunctions.getNoteAssets(_currentSongNotes); // Convert note names to asset paths.
    });

    // Loop through each note and play it one by one.
    for (int i = 0; i < assetsList.length; i++) {
      String currentNote = _currentSongNotes[i]; // Get the current note.
      Color currentColor = HelperFunctions.noteColorMap[currentNote] ?? Colors.grey; // Get the color for the note.

      setState(() {
        _currentNoteIndex = i; // Update the index to highlight the current note.
      });

      // Play the note and wait for it to finish before proceeding.
      await _playSound(assetsList[i], _currentSongNotes[i], currentColor);
      await Future.delayed(const Duration(milliseconds: 300)); // Pause between notes for smoother playback.
    }

    // Reset the song state after playing.
    setState(() {
      _selectedSong = null;
      _playingNote = null;
    });

    // Show a message when the song finishes playing.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Song finished!")),
    );
  }

  // Widget to display the notes of the currently selected song, highlighting the playing note.
  Widget _displayCurrentlyPlayingNotes() {
    if (_selectedSong != null && _currentSongNotes.isNotEmpty) {
      return SingleChildScrollView(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _currentSongNotes.asMap().entries.map((entry) {
            int index = entry.key; // Note's position in the sequence.
            String note = entry.value; // Note value (e.g., C, D).

            return _currentNoteIndex == index
                ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                  color: HelperFunctions.noteColorMap[note],
                  shape: BoxShape.circle), // Highlight the current note.
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Text(
                  note,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            )
                : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                note,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _currentNoteIndex == index
                      ? Colors.teal
                      : Colors.black,
                ),
              ),
            );
          }).toList(),
        ),
      );
    } else {
      return const SizedBox(); // Return empty if no song is selected.
    }
  }
}
