import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_midi/flutter_midi.dart';
import 'musical_classes.dart';

class MidiPlayer {
  final _flutterMidi = FlutterMidi();
  int timeInMSToStopNote = 800;
  int bpm = 120;
  double oneOver60 = 1.0 / 60;
  double signatureNote = 4;
  int durationBetweenChordsInMs = 500;
  int durationBetweenChordAndMelodyInMs = 500;
  int currentPlayerSection = 0;

  String _value = 'assets/Kawai Grand Piano.sf2';

  MidiPlayer() {
    if (!kIsWeb) {
      load(_value);
    } else {
      _flutterMidi.prepare(sf2: null);
    }

    this.setBPM(bpm);
  }

  void load(String asset) async {
    print('Loading File...');
    _flutterMidi.unmute();
    ByteData _byte = await rootBundle.load(asset);
    _flutterMidi.prepare(sf2: _byte, name: _value.replaceAll('assets/', ''));
  }

  void setCurrentPlayerSection(int section) {
    currentPlayerSection = section;
  }

  void play(int midi, {int velocity = 127}) {
    if (kIsWeb) {
      // WebMidi.play(midi);
    } else {
      _flutterMidi.playMidiNote(midi: midi, velocity: velocity); //,
      Future.delayed(Duration(milliseconds: timeInMSToStopNote),
          () => _flutterMidi.stopMidiNote(midi: midi));
    }
  }

  void stopAllNotes() {
    int totalNumberOfMidNotes = 256;
    for (int note = 0; note < totalNumberOfMidNotes; note++)
      _flutterMidi.stopMidiNote(midi: note);
  }

  void setBPM(int bpm) {
    double oneOver60 = 1.0 / 60;
    double signatureNote = 4;
    durationBetweenChordsInMs =
        (signatureNote / (bpm * oneOver60) * 1000).toInt();
    durationBetweenChordAndMelodyInMs =
        (durationBetweenChordsInMs * 0.01).toInt();
    this.timeInMSToStopNote = (durationBetweenChordsInMs * 0.8).toInt();
  }

  void playMelodyWithProgression(List<Note> melody,
      Progression currentProgression, int localPlayerSection) async {
    int octaveChange = 12;
    int mideMidleC = 60 - 12;

    int numberOfChords = currentProgression.numberOfChords();
    int melodyNoteIdx = 0;
    int melodyLength = melody.length;
    int chordLength = currentProgression.numberOfChords();

    // Different volumes so it is more enjoyable to hear
    int velocityMelody = 127;
    int velocityBass = 50;
    int velocityHarmony = 100;

    int maximumLength = max(melodyLength, numberOfChords);
    for (int idxChord = 0; idxChord < maximumLength; idxChord++) {
      final chord =
          currentProgression.getProgressionChords()[idxChord % chordLength];
      List<Note> notes = chord.getChordNotes();

      for (final note in notes)
        await Future.delayed(
            Duration(milliseconds: 0),
            () => this.play(mideMidleC + note.getNoteAbsoluteIdx(),
                velocity: velocityHarmony));

      if (currentPlayerSection != localPlayerSection) return;

      await Future.delayed(
          Duration(milliseconds: durationBetweenChordsInMs * 0),
          () => this.play(
              mideMidleC +
                  chord.getTonic().getNoteAbsoluteIdx() -
                  2 * octaveChange,
              velocity: velocityBass));

      if (melodyLength != 0) {
        int wrapAroundMelodyIdx = (melodyNoteIdx % melody.length).toInt();
        if (idxChord < melodyLength) {
          await Future.delayed(
              Duration(milliseconds: durationBetweenChordAndMelodyInMs),
              () => this.play(
                  mideMidleC +
                      melody[wrapAroundMelodyIdx].getNoteAbsoluteIdx() +
                      octaveChange,
                  velocity: velocityMelody));
        }
      }
      if (currentPlayerSection != localPlayerSection) return;

      await new Future.delayed(
          Duration(milliseconds: durationBetweenChordsInMs));

      if (currentPlayerSection != localPlayerSection) return;

      melodyNoteIdx += 1;
    }
  }
}
