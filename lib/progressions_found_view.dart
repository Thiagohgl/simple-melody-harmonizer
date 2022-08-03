import 'dart:async';
import 'dart:math';
// ignore: import_of_legacy_library_into_null_safe
import 'package:provider/provider.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import 'package:flutter/material.dart';
import 'melody_saved_db_obj.dart';
import 'musical_classes.dart';
import 'progressions_database.dart';
import 'audio_player.dart';

class FoundProgressionsLists extends StatefulWidget {
  late List<Progression> _foundProgressions;
  late int _numberOfMelodyNotes;
  late List<Note> _melody;

  FoundProgressionsLists(
      this._foundProgressions, this._numberOfMelodyNotes, this._melody);

  @override
  _FoundProgressionsLists createState() => _FoundProgressionsLists(
      _foundProgressions, _numberOfMelodyNotes, _melody);
}

class _FoundProgressionsLists extends State<FoundProgressionsLists> {
  List<Progression> _saved = progressionsDatabase;
  List<Note> _melody;
  final searchParameterControler = TextEditingController();
  String searchTags = '';
  int musicBPM = 120;
  int currentPlayerSection = 0;
  MidiPlayer midi = MidiPlayer();
  TextStyle textButtonStyle = TextStyle(
      color: Color(0xff8E74D4), fontSize: 14, fontStyle: FontStyle.italic);
  TextStyle textButtonHearHarmonyStyle = TextStyle(
      color: Color(0xff467387), fontSize: 14, fontStyle: FontStyle.italic);

  late List<Progression> foundProgressions;
  late int numberOfMelodyNotes;
  _FoundProgressionsLists(
      this.foundProgressions, this.numberOfMelodyNotes, this._melody);

  Future<dynamic> showDialogToGetHarmonizationName(
      BuildContext context) //Future<String>
  {
    TextEditingController harmonizationNameController = TextEditingController();

    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Enter harmonization name"),
            content: TextField(
              controller: harmonizationNameController,
            ),
            actions: <Widget>[
              MaterialButton(
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop("HARMONIZATION_CANCELED");
                  }),
              MaterialButton(
                child: Text('Save harmonization'),
                onPressed: () {
                  Navigator.of(context)
                      .pop(harmonizationNameController.text.toString());
                },
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    final tiles = foundProgressions.map((Progression currentProgression) {
      if (searchTags != '') {
        String currentProgressionTags = currentProgression.getTags();
        if (!currentProgressionTags.contains(searchTags))
          return SizedBox.shrink();
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
                  title: Text(currentProgression.getProgressionAsString(max(
                      numberOfMelodyNotes,
                      currentProgression.numberOfChords()))),
                  subtitle: Text(currentProgression.getTags()),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    TextButton(
                      child: Text('Hear Harmony with melody',
                          style: textButtonHearHarmonyStyle),
                      onPressed: () {
                        currentPlayerSection = (currentPlayerSection + 1) % 2;
                        midi.setCurrentPlayerSection(currentPlayerSection);
                        midi.playMelodyWithProgression(
                            _melody, currentProgression, currentPlayerSection);
                      },
                    ),
                    SizedBox(width: 8),
                    TextButton(
                      child: Text(
                        'Save melody',
                        style: textButtonStyle,
                      ),
                      onPressed: () {
                        showDialogToGetHarmonizationName(context)
                            .then((harmonizationName) {
                          harmonizationName = harmonizationName as String;

                          if (harmonizationName == "HARMONIZATION_CANCELED")
                            return;

                          fullHarmonization harmonization = fullHarmonization(
                              harmonizationName, _melody, currentProgression);
                          Provider.of<SavedMelodies>(context, listen: false)
                              .addHarmonization(harmonization);
                          Provider.of<SavedMelodies>(context, listen: false)
                              .addHarmonizationToDatabase(harmonization);

                          showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text("Harmonization saved!"),
                                  actions: <Widget>[
                                    MaterialButton(
                                        child: Text('Done'),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        }),
                                  ],
                                );
                              });
                        });
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

    return Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color(0xff7CA1AD),
            Color(0xff214657),
            Color(0xff3B3B3E),
          ],
        )),
        child: Column(children: [
          Container(
              margin: EdgeInsets.all(1.0),
              child: TextField(
                obscureText: false,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderSide: BorderSide(width: 20)),
                  labelText: 'Enter tag',
                  labelStyle: TextStyle(color: Colors.white),
                  fillColor: Colors.white,
                ),
                style: TextStyle(color: Colors.white),
                controller: searchParameterControler,
                onChanged: (String value) =>
                    setState(() => {searchTags = value}),
              )),
          Expanded(child: ListView(children: divided)),
          bpmSelector()
        ]));
  }

  Widget bpmSelector() {
    return SleekCircularSlider(
      min: 80,
      max: 220,
      initialValue: 120,
      appearance: CircularSliderAppearance(
          customColors: CustomSliderColors(
              trackColor: Color(0xffCFD8DD),
              progressBarColors: [Color(0xff8E74D4), Colors.white])),
      onChange: (double value) {
        // callback providing a value while its being changed (with a pan gesture)
        musicBPM = value.toInt();
        midi.setBPM(musicBPM);
      },
      onChangeStart: (double startValue) {
        // callback providing a starting value (when a pan gesture starts)
      },
      onChangeEnd: (double endValue) {
        // ucallback providing an ending value (when a pan gesture ends)
      },
      innerWidget: (double value) {
        return Center(
            child: Text(
          value.toInt().toString() + ' BPM',
          style: TextStyle(fontSize: 16, color: Colors.white),
        ));
      },
    );
  }
}
