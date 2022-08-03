import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'musical_classes.dart';
import 'piano.dart';
import 'progressions_found_view.dart';

class MelodyInput extends StatefulWidget {
  @override
  _MelodyInput createState() => _MelodyInput();
}

class _MelodyInput extends State<MelodyInput> {
  bool useNoteAs7 = true;
  bool useNoteAs9 = true;
  bool useNoteAs4 = false;
  bool useNoteAs6 = false;
  List<String> fixedNotes = [];
  double melodyNoteRadius = 30;

  Color colorFix = Color(0xff7CA1AD);
  Color colorNew = Colors.white;
  Color colorLast = Color(0xffCFD8DD);

  TextStyle styleOfText = TextStyle(fontSize: 18, color: Color(0xffCFD8DD));

  TextStyle styleOfFixNode = TextStyle(fontSize: 18, color: Colors.white);
  TextStyle styleOfRemoveNode = TextStyle(fontSize: 18, color: Colors.white);

  @override
  Widget build(BuildContext context) {
    double heightScreen = MediaQuery.of(context).size.height;

    melodyNoteRadius = heightScreen * 0.09;

    String lastPlayerNote =
        Provider.of<PianoModel>(context, listen: true).getLastPlayedNote();

    final fixedNoteWidgets = fixedNotes.map((melodyString) {
      return CircleNoteInCircle(melodyString, melodyNoteRadius, colorFix);
    });

    final melodyWidgets = fixedNoteWidgets.isNotEmpty
        ? ListTile.divideTiles(context: context, tiles: fixedNoteWidgets)
            .toList()
        : <Widget>[];

    melodyWidgets
        .add(CircleNoteInCircle(lastPlayerNote, melodyNoteRadius, colorNew));

    return Scaffold(
        appBar: AppBar(
          title: Text('Create new melody'),
          backgroundColor: Color(0xff467387),
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.help_outline,
                color: Colors.white,
              ),
              onPressed: () {
                // do something
                // Add a mensage box with a BSD license
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Tutorial'),
                        content: Text(
                            '1: Play the keyboard to select a note. \n2: Click on "Fix note" to define a chord transition note. \n3: Click on "Find harmonies" to get valid harmonies. '),
                        actions: <Widget>[
                          ElevatedButton(
                            child: Text('Close'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          )
                        ],
                      );
                    });
              },
            )
          ],
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
                SizedBox(height: 20),
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
                          children: melodyWidgets,
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
                                  if (fixedNotes.isNotEmpty) {
                                    fixedNotes.removeLast();
                                  }
                                });
                              },
                              child: Text(
                                'Remove Last',
                                style: styleOfRemoveNode,
                              ))),
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50)),
                            primary: Color(0xffF7A814),
                          ),
                          onPressed: () {
                            setState(() {
                              fixedNotes.add(lastPlayerNote);
                            });
                          },
                          child: Text('Fix Note', style: styleOfFixNode))
                    ],
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                SizedBox(
                  width: 1,
                  height: 20,
                ),
                Text(
                  "Notes in Chord as:",
                  style: TextStyle(color: Color(0xffCFD8DD), fontSize: 20),
                  textAlign: TextAlign.left,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Row(children: [
                            Text('7th ', style: styleOfText),
                            CupertinoSwitch(
                              activeColor: Color(0xffCFD8DD),
                              value: useNoteAs7,
                              onChanged: (bool value) {
                                setState(() {
                                  useNoteAs7 = value;
                                });
                              },
                            )
                          ]),
                          Row(children: [
                            Text(
                              ' 9th ',
                              style: styleOfText,
                            ),
                            CupertinoSwitch(
                              activeColor: Color(0xffCFD8DD),
                              value: useNoteAs9,
                              onChanged: (bool value) {
                                setState(() {
                                  useNoteAs9 = value;
                                });
                              },
                            )
                          ])
                        ]),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Row(children: [
                            Text('11th', style: styleOfText),
                            CupertinoSwitch(
                              activeColor: Color(0xffCFD8DD),
                              value: useNoteAs4,
                              onChanged: (bool value) {
                                setState(() {
                                  useNoteAs4 = value;
                                });
                              },
                            )
                          ]),
                          Row(children: [
                            Text('13th', style: styleOfText),
                            CupertinoSwitch(
                              activeColor: Color(0xffCFD8DD),
                              value: useNoteAs6,
                              onChanged: (bool value) {
                                setState(() {
                                  useNoteAs6 = value;
                                });
                              },
                            )
                          ])
                        ])
                  ],
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
                      primary: fixedNotes.isNotEmpty
                          ? Color(0xffF7A814)
                          : Color.fromRGBO(0, 0, 0, 0),
                    ),
                    onPressed: () {
                      getNewMelodies();
                    },
                    child: const Text(
                      'Find Harmonies',
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

  void getNewMelodies() {
    var melodyNoteStrings = fixedNotes.map((noteString) {
      return noteString.substring(0, noteString.length - 1);
    }).toList();
    List<Note> melodyNotes = [];
    for (int noteStringIdx = 0;
        noteStringIdx < melodyNoteStrings.length;
        noteStringIdx++) {
      melodyNotes.add(Note.fromString(melodyNoteStrings[noteStringIdx]));
    }

    ChordRestrictions restrictions =
        ChordRestrictions(useNoteAs7, useNoteAs9, useNoteAs4, useNoteAs6);

    if (melodyNotes.length == 0) return;

    var searchResult = findValidProgressionForMelody(melodyNotes, restrictions);
    List<Progression> allFoundProgressions = searchResult[0];

    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => Scaffold(
            appBar: AppBar(
              title: Text('Harmonies Found'),
              backgroundColor: Color(0xff467387),
            ),
            body: (FoundProgressionsLists(allFoundProgressions.toSet().toList(),
                melodyNotes.length, melodyNotes)))));
  }
}

class CircleNoteInCircle extends StatelessWidget {
  final String noteString;
  final double radius;
  final Color color;

  CircleNoteInCircle(this.noteString, this.radius, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: radius,
      height: radius,
      decoration: new BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(blurRadius: 2, spreadRadius: 2)]),
      child: Center(child: Text(noteString)),
    );
  }
}
