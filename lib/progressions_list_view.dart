library lists_widgets;

import 'package:flutter/material.dart';
import 'harmony_saved_db_obj.dart';
import 'musical_classes.dart';
import 'progressions_database.dart';
import 'audio_player.dart';

class ProgressionsLists extends StatefulWidget {
  SavedHarmonies harmonies;

  ProgressionsLists(this.harmonies);

  @override
  _ProgressionsLists createState() => _ProgressionsLists(harmonies);
}

class _ProgressionsLists extends State<ProgressionsLists> {
  List<Progression> _saved = progressionsDatabase;
  SavedHarmonies harmonies;
  String searchTags = '';
  final searchParameterControler = TextEditingController();
  MidiPlayer midi = MidiPlayer();
  int standardBPM = 140;

  int currentPlayerSection = 0;

  _ProgressionsLists(this.harmonies);

  @override
  Widget build(BuildContext context) {
    List<Progression> savedPlusDatabase = _saved;

    var progressionsFromDatabase = harmonies.getProgressions();
    for (final progression in progressionsFromDatabase) {
      if (!savedPlusDatabase.contains(progression))
        savedPlusDatabase.add(progression);
    }

    final tiles = savedPlusDatabase.map((Progression currentProgression) {
      if (searchTags != '') {
        String progressionTags = currentProgression.getTags();
        if (!progressionTags.contains(searchTags)) return SizedBox.shrink();
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
                    Colors.white, //0xff3b3b3E 545357
                    Color(0xffCFD8DD), //7CA1AD
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
                    title: Text(currentProgression.getProgressionName()),
                    subtitle: Text(currentProgression.getTags()),
                  ),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        TextButton(
                          child: Text(
                            'Hear Progression',
                            style: TextStyle(color: Color(0xff467387)),
                          ),
                          onPressed: () {
                            currentPlayerSection =
                                (currentPlayerSection + 1) % 2;
                            midi.setCurrentPlayerSection(currentPlayerSection);
                            midi.setBPM(standardBPM);
                            midi.playMelodyWithProgression(
                                [], currentProgression, currentPlayerSection);
                          },
                        ),
                        TextButton(
                          child: Text(
                            'Delete Progression',
                            style: TextStyle(color: Color(0xff8E74D4)),
                          ),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                int idx = savedPlusDatabase
                                    .indexOf(currentProgression);

                                if (idx < NUMBER_OF_STANDARD_PROGRESSIONS) {
                                  return AlertDialog(
                                      title: Text("Warning"),
                                      content: Text(
                                          "Can't delete standard progression"));
                                }
                                return AlertDialog(
                                  title: Text("Delete progression"),
                                  content: Text(
                                      "Are you sure you want to delete this progression?"),
                                  actions: <Widget>[
                                    TextButton(
                                      child: Text("Yes"),
                                      onPressed: () {
                                        harmonies.removeProgressionFromDatabase(
                                            currentProgression);
                                        Navigator.of(context).pop();
                                        setState(() {
                                          _saved.remove(currentProgression);
                                        });
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
                        )
                      ]),
                ],
              ),
            )),
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
              border: OutlineInputBorder(borderSide: BorderSide(width: 3)),
              labelText: 'Enter tag',
              labelStyle: TextStyle(color: Colors.white),
            ),
            style: TextStyle(color: Colors.white),
            controller: searchParameterControler,
            onChanged: (String value) => setState(() => {searchTags = value}),
          )),
      Expanded(child: ListView(children: divided))
    ]);
  }
}
