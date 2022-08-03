import 'package:flutter/material.dart';
import 'package:melody_harmonizer/melody_saved_db_obj.dart';
import 'audio_player.dart';
import 'musical_classes.dart';

class SavedMelodyList extends StatefulWidget {
  late SavedMelodies _savedMelodies;

  SavedMelodyList(this._savedMelodies);

  @override
  _SavedMelodyList createState() => _SavedMelodyList(_savedMelodies);
}

class _SavedMelodyList extends State<SavedMelodyList> {
  late SavedMelodies _savedMelodies;
  String searchTags = '';
  final searchParameterControler = TextEditingController();
  _SavedMelodyList(this._savedMelodies);
  MidiPlayer midi = MidiPlayer();
  int standardBPM = 140;

  int currentPlayerSection = 0;

  @override
  Widget build(BuildContext context) {
    final tiles = _savedMelodies
        .getHarmonizations()
        .map((fullHarmonization currentHarmonization) {
      if (searchTags != '') {
        String harmonizationName = currentHarmonization.getName();
        if (!harmonizationName.contains(searchTags)) return SizedBox.shrink();
      }

      return Center(
        child: Container(
          padding: EdgeInsets.all(0),
          decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(50),
              boxShadow: [BoxShadow(blurRadius: 5, spreadRadius: 2)],
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  Colors.white,
                  Color(0xffCFD8DD),
                ],
              )),
          child: Card(
            color: Color.fromRGBO(0, 0, 0, 0.0),
            shadowColor: Color.fromRGBO(0, 0, 0, 0.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                    leading: Icon(Icons.music_note),
                    title: Text(currentHarmonization.getName()),
                    subtitle: Column(children: [
                      Text(' Roman: ' +
                          currentHarmonization
                              .getProgression()
                              .getRomanIntervalsAsString()),
                      Text(' Chords: ' +
                          currentHarmonization
                              .getProgression()
                              .getProgressionAsString(currentHarmonization
                                  .getMaximumHarmonyLength())),
                      Text('Melody: ' +
                          currentHarmonization.getMelodyNotesAsString()),
                    ])),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    TextButton(
                      child: Text(
                        'Hear Harmony with melody',
                        style: TextStyle(color: Color(0xff467387)),
                      ),
                      onPressed: () {
                        currentPlayerSection = (currentPlayerSection + 1) % 2;
                        midi.setCurrentPlayerSection(currentPlayerSection);
                        midi.setBPM(standardBPM);
                        midi.playMelodyWithProgression(
                            currentHarmonization.getMelody(),
                            currentHarmonization.getProgression(),
                            currentPlayerSection);
                      },
                    ),
                    SizedBox(width: 8),
                    TextButton(
                      child: Text(
                        'Delete melody',
                        style: TextStyle(color: Color(0xff8E74D4)),
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text("Delete melody"),
                              content: Text(
                                  "Are you sure you want to delete this melody?"),
                              actions: <Widget>[
                                TextButton(
                                  child: Text("Yes"),
                                  onPressed: () {
                                    _savedMelodies
                                        .removeHarmonizationFromDatabase(
                                            currentHarmonization);
                                    Navigator.of(context).pop();
                                    setState(() {});
                                  },
                                ),
                                TextButton(
                                  child: Text("No"),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                    SizedBox(width: 8),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    });

    final divided = tiles.isNotEmpty
        ? ListTile.divideTiles(context: context, tiles: tiles).toList()
        : <Widget>[];

    return Column(children: [
      Container(
          margin: EdgeInsets.all(5.0),
          child: TextField(
            obscureText: false,
            decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enter tag',
                labelStyle: TextStyle(color: Colors.white)),
            style: TextStyle(color: Colors.white),
            controller: searchParameterControler,
            onChanged: (String value) => setState(() => {searchTags = value}),
          )),
      Expanded(child: ListView(children: divided))
    ]);
  }
}
