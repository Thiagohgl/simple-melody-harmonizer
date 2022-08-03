import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:melody_harmonizer/harmony_saved_db_obj.dart';
import 'package:provider/provider.dart';
import 'musical_classes.dart';
import 'piano.dart';

class HarmonyInput extends StatefulWidget {
  @override
  _HarmonyInput createState() => _HarmonyInput();
}

enum ChordTypes { maj, min }

class _HarmonyInput extends State<HarmonyInput> {
  final harmonyEntryController = TextEditingController();
  final tagsEntryController = TextEditingController();

  List<String> fixedChords = [];
  double chordNoteRadius = 0.0;

  Color colorFix = Color(0xff7CA1AD);
  Color colorNew = Colors.white;
  Color colorLast = Color(0xffCFD8DD);

  List<bool> chordIsMinor = [];
  bool currentChordIsMinor = false;
  @override
  Widget build(BuildContext context) {
    double heightScreen = MediaQuery.of(context).size.height;

    chordNoteRadius = heightScreen * 0.09;

    String lastPlayerNote =
        Provider.of<PianoModel>(context, listen: true).getLastPlayedNote();

    final fixedNoteWidgets = fixedChords.map((chordString) {
      return ChordInCircle(chordString, chordNoteRadius, colorFix);
    });

    final chordsWidgets = fixedNoteWidgets.isNotEmpty
        ? ListTile.divideTiles(context: context, tiles: fixedNoteWidgets)
            .toList()
        : <Widget>[];

    if (currentChordIsMinor) {
      lastPlayerNote = lastPlayerNote.toLowerCase();
    }
    chordsWidgets.add(ChordInCircle(lastPlayerNote, chordNoteRadius, colorNew));

    return Scaffold(
        appBar: AppBar(
          title: Text('Add new progression'),
          backgroundColor: Color(0xff467387),
        ),
        body: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                Color(0xff3b3b3E),
                Color(0xff214657),
              ],
            )),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                  child: Piano(
                    Provider.of<PianoModel>(context, listen: false),
                  ),
                  height: heightScreen * 0.25,
                  decoration: new BoxDecoration(
                      boxShadow: [BoxShadow(blurRadius: 2, spreadRadius: 2)]),
                ),
                Expanded(
                    child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Minor Chord?",
                        style: TextStyle(fontSize: 20, color: Colors.white70)),
                    CupertinoSwitch(
                      activeColor: Color(0xffCFD8DD),
                      value: currentChordIsMinor,
                      onChanged: (bool value) {
                        setState(() {
                          currentChordIsMinor = value;
                        });
                      },
                    )
                  ],
                )),
                Expanded(
                    child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          border: Border.all(width: 2.0, color: Colors.black),
                          gradient: LinearGradient(
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                            colors: [
                              Color(0xff214657),
                              Color(0xffCFD8DD),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                                spreadRadius: 5,
                                blurRadius: 7,
                                color: Colors.black,
                                offset: Offset(0, 7))
                          ],
                        ),
                        child: ListView(
                          children: chordsWidgets,
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.all(8),
                        ))),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.all(Radius.circular(50)),
                          ),
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50)),
                                primary: colorFix,
                                shadowColor: Colors.black,
                              ),
                              onPressed: () {
                                setState(() {
                                  if (fixedChords.isNotEmpty) {
                                    fixedChords.removeLast();
                                  }
                                });
                              },
                              child: Text(
                                'Remove Last',
                              ))),
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50)),
                            primary: Color(0xff8E74D4),
                          ),
                          onPressed: () {
                            setState(() {
                              if (currentChordIsMinor)
                                fixedChords.add(lastPlayerNote.toLowerCase());
                              else
                                fixedChords.add(lastPlayerNote);
                            });
                          },
                          child: Text('Fix Note'))
                    ],
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  'Tags',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                  textAlign: TextAlign.left,
                ),
                SizedBox(
                  height: 20,
                ),
                TextField(
                  obscureText: false,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'happy,adventurous,grandious',
                    labelStyle: TextStyle(color: Colors.white24),
                  ),
                  controller: tagsEntryController,
                ),
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.all(Radius.circular(50)),
                    boxShadow: [
                      BoxShadow(
                          spreadRadius: 4,
                          blurRadius: 4,
                          offset: Offset(0, 15),
                          color: Color(0xff3B3B3E))
                    ],
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50)),
                      primary: fixedChords.isNotEmpty
                          ? Color(0xff8E74D4)
                          : Color.fromRGBO(0, 0, 0, 0),
                    ),
                    onPressed: () {
                      saveProgression();
                    },
                    child: const Text(
                      'Save Progression',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
              ],
            )));
  }

  void saveProgression() {
    var progressionRomanRepresentation = notesToRomanSequence(fixedChords);
    var progressionName = progressionRomanRepresentation.join('-');
    var progressionTags = tagsEntryController.text.split(',');

    var tonic = Note.fromString("C");
    Progression progression = Progression.fromRomanIntervals(
        progressionRomanRepresentation,
        progressionName,
        progressionTags,
        tonic);

    Provider.of<SavedHarmonies>(context, listen: false)
        .addProgression(progression);
    Provider.of<SavedHarmonies>(context, listen: false)
        .addProgressionToDatabase(progression);

    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Progression saved!"),
            actions: <Widget>[
              MaterialButton(
                  child: Text('Done'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  }),
            ],
          );
        });
  }

  List<String> notesToRomanSequence(List<String> noteStrings) {
    List<String> romanSequence = [];
    for (String note in noteStrings) {
      String validNote = note.substring(0, note.length - 1);
      String correspondingChord = chordToInverval[validNote] as String;
      romanSequence.add(correspondingChord);
    }
    return romanSequence;
  }
}

class ChordInCircle extends StatelessWidget {
  final String noteString;
  final double radius;
  final Color color;

  ChordInCircle(this.noteString, this.radius, this.color);

  @override
  Widget build(BuildContext context) {
    String validNote = noteString.substring(0, noteString.length - 1);
    String correspondingChord = chordToInverval[validNote] as String;

    return Container(
      width: radius,
      height: radius,
      decoration: new BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(blurRadius: 2, spreadRadius: 2)]),
      child: Center(child: Text(correspondingChord)),
    );
  }
}
