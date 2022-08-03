import 'package:flutter/material.dart';
import 'package:tonic/tonic.dart';
import 'audio_player.dart';
import 'dart:math';
import 'musical_classes.dart';

class PianoModel extends ChangeNotifier {
  int _lastPlayedNote = 30;

  void setLastPlayedNote(int lastPlayedNote) {
    _lastPlayedNote = lastPlayedNote;
    notifyListeners();
  }

  String getLastPlayedNote() {
    int octaveCalibration = -2;
    int octave = (_lastPlayedNote / 12).round() + octaveCalibration;
    String noteString = noteMap[(_lastPlayedNote % 12).toString()].toString();
    return noteString + octave.toString();
  }
}

class Piano extends StatefulWidget {
  PianoModel model;

  Piano(this.model);

  @override
  _Piano createState() => _Piano(model);
}

class _Piano extends State<Piano> {
  MidiPlayer midiObj = MidiPlayer();

  double get keyWidth => 60 + (60 * _widthRatio);
  double _widthRatio = 0.0;
  bool _showLabels = true;
  int lastPlayedNote = 24;
  int velocity = 127;
  Random random = new Random();
  PianoModel model;

  _Piano(this.model);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 7,
      controller: ScrollController(initialScrollOffset: 1270.0),
      scrollDirection: Axis.horizontal,
      itemBuilder: (BuildContext context, int index) {
        final int i = index * 12;
        return SafeArea(
          child: Stack(children: <Widget>[
            Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
              _buildKey(24 + i, false),
              _buildKey(26 + i, false),
              _buildKey(28 + i, false),
              _buildKey(29 + i, false),
              _buildKey(31 + i, false),
              _buildKey(33 + i, false),
              _buildKey(35 + i, false),
            ]),
            Positioned(
                left: 0.0,
                right: 0.0,
                bottom: 75,
                top: 0.0,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(width: keyWidth * .5),
                      _buildKey(25 + i, true),
                      _buildKey(27 + i, true),
                      Container(width: keyWidth),
                      _buildKey(30 + i, true),
                      _buildKey(32 + i, true),
                      _buildKey(34 + i, true),
                      Container(width: keyWidth * .5),
                    ])),
          ]),
        );
      },
    );
  }

  Widget _buildKey(int midi, bool accidental) {
    final pitchName = Pitch.fromMidiNumber(midi).toString();
    final pianoKey = Stack(
      children: <Widget>[
        Semantics(
            button: true,
            hint: pitchName,
            child: Material(
                borderRadius: borderRadius,
                color: accidental ? Colors.black : Colors.white,
                child: InkWell(
                  //borderRadius: borderRadius,
                  highlightColor: Colors.grey,
                  onTap: () {},
                  onTapDown: (_) {
                    lastPlayedNote = midi;
                    midiObj.play(midi, velocity: velocity);
                    model.setLastPlayedNote(lastPlayedNote);
                  },
                ))),
        Positioned(
            left: 0.0,
            right: 0.0,
            bottom: 20.0,
            child: _showLabels
                ? Text(pitchName,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: !accidental ? Colors.black : Colors.white))
                : Container()),
      ],
    );
    if (accidental) {
      return Container(
          width: keyWidth,
          margin: EdgeInsets.symmetric(horizontal: 0.0),
          padding: EdgeInsets.symmetric(horizontal: keyWidth * .1),
          child: Material(
              elevation: 2.0,
              borderRadius: borderRadius,
              shadowColor: Color(0x802196F3),
              child: pianoKey));
    }
    return Container(
        width: keyWidth,
        child: pianoKey,
        margin: EdgeInsets.symmetric(horizontal: 0.0));
  }
}

const BorderRadiusGeometry borderRadius = BorderRadius.only(
    bottomLeft: Radius.circular(2.0), bottomRight: Radius.circular(2.0));
