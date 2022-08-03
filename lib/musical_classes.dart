library musical_classes;

import 'progressions_database.dart';
import 'dart:math';

final int numberOfNotes = 7;
final int numberOfVariations = 3;
final int numberOfUniqueNotes = 12;
List<String> allNoteStrings = ["C", "D", "E", "F", "G", "A", "B"];
List<String> noteVariationIdentifiers = ["b", "", "#"];
List<int> allAbsoluteNoteIdx = [0, 2, 4, 5, 7, 9, 11];
List<int> allAbsoluteVariationIdx = [-1, 0, 1];
var intervalMap = {
  '2': 2,
  'm': 3,
  '3': 4,
  '4': 5,
  '#4': 6,
  '5': 7,
  '#5': 8,
  '6': 9,
  '7': 10,
  'maj7': 12,
  'b9': 1,
  '9': 2,
  '11': 5,
  '13': 9
};
var noteMap = {
  '0': "C",
  '1': "C#",
  '2': "D",
  '3': "D#",
  '4': "E",
  '5': "F",
  '6': "F#",
  '7': "G",
  '8': "G#",
  '9': "A",
  '10': "A#",
  '11': "B"
};
var romanIntervalMap = {
  'I': 0,
  'I+': 1,
  'II': 2,
  'II+': 3,
  'III': 4,
  'IV': 5,
  'IV+': 6,
  'V': 7,
  'V+': 8,
  'VI': 9,
  'VI+': 10,
  'VII': 11,
  'i': 0,
  'i+': 1,
  'ii': 2,
  'ii+': 3,
  'iii': 4,
  'iv': 5,
  'iv+': 6,
  'v': 7,
  'v+': 8,
  'vi': 9,
  'vi+': 10,
  'vii': 11
};

var chordToInverval = {
  'C': 'I',
  'C#': 'I+',
  'D': 'II',
  'D#': 'II+',
  'E': 'III',
  'F': 'IV',
  'F#': 'IV+',
  'G': 'V',
  'G#': 'V+',
  'A': 'VI',
  'A#': 'VI+',
  'B': 'VII',
  'c': 'i',
  'c#': 'i+',
  'd': 'ii',
  'd#': 'ii+',
  'e': 'iii',
  'f': 'iv',
  'f#': 'iv+',
  'g': 'v',
  'g#': 'v+',
  'a': 'vi',
  'a#': 'vi+',
  'b': 'vii',
};

Map<int, String> intervalToRomanMap = {};

int wrapperAbsoluteNoteValue(int noteAbsoluteIdx) {
  return noteAbsoluteIdx % numberOfUniqueNotes;
}

class Note {
  late int _noteStringIdx;
  late int _noteIdentifierIdx;
  late int _octave = 3;

  Note(int noteStringIdx, int noteIdentifierIdx, {int octave = 3}) {
    _noteStringIdx = noteStringIdx;
    _noteIdentifierIdx = noteIdentifierIdx;
    _octave = octave;
  }

  Note.fromString(String noteString, {int octave = 3}) {
    convertStringToNoteIndices(noteString);
    _octave = octave;
  }

  void convertStringToNoteIndices(String noteString) {
    _noteStringIdx = allNoteStrings.indexOf(noteString[0]);
    if (noteString.length == 2)
      _noteIdentifierIdx = noteVariationIdentifiers.indexOf(noteString[1]);
    else
      _noteIdentifierIdx = 1;
  }

  int getNoteAbsoluteIdx() {
    return wrapperAbsoluteNoteValue((allAbsoluteNoteIdx[_noteStringIdx] +
        allAbsoluteVariationIdx[_noteIdentifierIdx]));
  }

  int getMidiInteger() {
    return numberOfUniqueNotes * _octave +
        wrapperAbsoluteNoteValue((allAbsoluteNoteIdx[_noteStringIdx] +
            allAbsoluteVariationIdx[_noteIdentifierIdx]));
  }

  void tranposeInSemitones(int semitones) {
    int newAbsoluteIdx =
        wrapperAbsoluteNoteValue(getNoteAbsoluteIdx() + semitones);
    String newNoteString = noteMap[newAbsoluteIdx.toString()]!;
    convertStringToNoteIndices(newNoteString);
  }

  String getNoteString() {
    return allNoteStrings[_noteStringIdx] +
        noteVariationIdentifiers[_noteIdentifierIdx];
  }

  Note getEnharmonic() {
    switch (_noteIdentifierIdx) {
      case 0: // bemol to sus
        int newNoteStringIdx = (_noteStringIdx - 1) % numberOfNotes;
        int newNoteVariationIdentifierIdx = 2;
        return Note.fromString(allNoteStrings[newNoteStringIdx] +
            noteVariationIdentifiers[newNoteVariationIdentifierIdx]);

      case 1: // No change if no bemol/sus
        return Note.fromString(getNoteString());

      case 2: // sus to bemol
        int newNoteStringIdx = (_noteStringIdx + 1) % numberOfNotes;
        int newNoteVariationIdentifierIdx = 0;
        return Note.fromString(allNoteStrings[newNoteStringIdx] +
            noteVariationIdentifiers[newNoteVariationIdentifierIdx]);
    }

    return Note.fromString(getNoteString());
  }

  Note getInterval(String interval) {
    int newNoteAbsoluteIdx =
        wrapperAbsoluteNoteValue(intervalMap[interval]! + getNoteAbsoluteIdx());

    return Note.fromString(noteMap[newNoteAbsoluteIdx.toString()]!);
  }

  Note getIntervalFromSeminotes(int semitones) {
    int newNoteAbsoluteIdx =
        wrapperAbsoluteNoteValue(semitones + getNoteAbsoluteIdx());

    return Note.fromString(noteMap[newNoteAbsoluteIdx.toString()]!);
  }

  int getAbsoluteIntervalFromNote(Note newNote) {
    return wrapperAbsoluteNoteValue(
        newNote.getNoteAbsoluteIdx() - getNoteAbsoluteIdx());
  }
}
////////////////////////////////////////// CHORD ////////////////////////////

class Chord {
  List<Note> _chordNotes = [];
  List<String> _intervals = [];
  Note _tonic = Note.fromString("C");
  bool _isMinor = false;
  bool _isMajor = false;
  bool _isSuspended = false;
  bool _isMajor7 = false;
  bool _isMinor7 = false;
  bool _isFlat5 = false;
  bool _isDiminished = false;
  String _chordName = "";

  Chord(Note tonic, List<String> intervals) {
    _tonic = tonic;
    _chordNotes.add(_tonic);
    _intervals = intervals;
    getChordNotesFromIntervals();
    updateChordIdentifiers();
    _chordName = getChordName();
  }

  Chord.minorChord(Note tonic) {
    _tonic = tonic;
    _chordNotes.add(_tonic);
    _intervals = ['m', '5'];
    getChordNotesFromIntervals();
    updateChordIdentifiers();
    _chordName = getChordName();
  }

  Chord.majorChord(Note tonic) {
    _tonic = tonic;
    _chordNotes.add(_tonic);
    _intervals = ['3', '5'];
    getChordNotesFromIntervals();
    updateChordIdentifiers();
    _chordName = getChordName();
  }
  void updateChordIdentifiers() {
    for (int idxNote = 1; idxNote < _chordNotes.length; idxNote++) {
      int absoluteInterval =
          _tonic.getAbsoluteIntervalFromNote(_chordNotes[idxNote]);
      if (absoluteInterval == intervalMap['m'])
        _isMinor = true;
      else if (absoluteInterval == intervalMap['3'])
        _isMajor = true;
      else if (absoluteInterval == intervalMap['4'])
        _isSuspended = true;
      else if (absoluteInterval == intervalMap['maj7'])
        _isMajor7 = true;
      else if (absoluteInterval == intervalMap['7'])
        _isMinor7 = true;
      else if (absoluteInterval == intervalMap['#4']) _isFlat5 = true;
    }

    _isDiminished = _isMinor && _isFlat5;
  }

  Map<String, bool> getChordIdentifiers() {
    return {
      'isMinor': _isMinor,
      'isMajor': _isMajor,
      'isSuspended': _isSuspended,
      'isMajor7': _isMajor7,
      'isMinor7': _isMinor7,
      'isDiminished': _isDiminished
    };
  }

  bool isChordOfTheSameType(Chord chordToCompare) {
    Map<String, bool> newChordIdentifiers =
        chordToCompare.getChordIdentifiers();
    var chordIdentifiers = getChordIdentifiers();

    bool chordsAreOfTheSameType = true;

    for (final key in newChordIdentifiers.keys)
      chordsAreOfTheSameType = chordsAreOfTheSameType &&
          (newChordIdentifiers[key] == chordIdentifiers[key]);
    return chordsAreOfTheSameType;
  }

  Note getTonic() {
    return _tonic;
  }

  void getChordNotesFromIntervals() {
    for (int noteIdx = 0; noteIdx < _intervals.length; noteIdx++) {
      _chordNotes.add(_tonic.getInterval(_intervals[noteIdx]));
    }
  }

  List<Note> getChordNotes() {
    return _chordNotes;
  }

  String getChordName() {
    String chordName = _chordNotes[0].getNoteString();
    for (int intervalIdx = 0;
        intervalIdx < _chordNotes.length - 1;
        intervalIdx++) {
      if (_intervals[intervalIdx].length > 1 ||
          _intervals[intervalIdx][0] == 'm')
        chordName += _intervals[intervalIdx];
    }

    return chordName;
  }

  bool noteInChord(Note note) {
    bool noteInChord = false;
    int noteAbsoluteIdx = note.getNoteAbsoluteIdx();
    for (int noteIdx = 0; noteIdx < _chordNotes.length; noteIdx++) {
      noteInChord =
          noteAbsoluteIdx == _chordNotes[noteIdx].getNoteAbsoluteIdx();
      if (noteInChord) break;
    }
    return noteInChord;
  }

  void transposeInSemitones(int semitones) {
    for (int noteIdx = 0; noteIdx < _chordNotes.length; noteIdx++)
      _chordNotes[noteIdx].tranposeInSemitones(semitones);
  }
}

class ChordRestrictions {
  bool useNoteAs7 = true;
  bool useNoteAs9 = true;
  bool useNoteAs4 = true;
  bool useSixth = true;
  ChordRestrictions(
      this.useNoteAs7, this.useNoteAs9, this.useNoteAs4, this.useSixth);
}

List<Chord> generatePossibleChordsForNote(
    Note note, ChordRestrictions chordRestrictions) {
  List<Chord> possibleChords = [];
  // note as fundamental
  Chord major = Chord(note, ['3', '5']);
  Chord minor = Chord(note, ['m', '5']);
  possibleChords.add(major);
  possibleChords.add(minor);

  // note as third
  Chord majorThird = Chord(note.getIntervalFromSeminotes(8), ['3', '5']);
  Chord minorThird = Chord(note.getIntervalFromSeminotes(9), ['m', '5']);
  possibleChords.add(majorThird);
  possibleChords.add(minorThird);

  // Note as suspension
  Chord fourthSuspension =
      Chord(note.getIntervalFromSeminotes(7), ['3', '4', '5']);
  Chord secondSuspension =
      Chord(note.getIntervalFromSeminotes(10), ['2', '3', '5']);
  if (chordRestrictions.useNoteAs4) possibleChords.add(fourthSuspension);

  if (chordRestrictions.useNoteAs9) possibleChords.add(secondSuspension);

  // note as fifth
  Chord perfectFifthMajor = Chord(note.getIntervalFromSeminotes(5), ['3', '5']);
  Chord perfectFifthMinor = Chord(note.getIntervalFromSeminotes(5), ['m', '5']);
  Chord diminuteFifth = Chord(note.getIntervalFromSeminotes(6), ['m', '#4']);
  possibleChords.add(perfectFifthMajor);
  possibleChords.add(perfectFifthMinor);

  possibleChords.add(diminuteFifth);

  // Note as a sixth
  Chord sixthMajor = Chord(note.getIntervalFromSeminotes(5), ['3', '6']);
  Chord sixthMinor = Chord(note.getIntervalFromSeminotes(5), ['m', '6']);
  if (chordRestrictions.useSixth) {
    possibleChords.add(sixthMajor);
    possibleChords.add(sixthMinor);
  }

  // note as seven
  if (chordRestrictions.useNoteAs7) {
    Chord majorSeven =
        Chord(note.getIntervalFromSeminotes(1), ['3', '5', 'maj7']);
    Chord minorSeven = Chord(note.getIntervalFromSeminotes(2), ['3', '5', '7']);
    possibleChords.add(majorSeven);
    possibleChords.add(minorSeven);
  }

  return possibleChords;
}

////////////////////////////////////////// PROGRESSION ////////////////////////////
class Progression {
  List<Chord> _progressionChords = [];
  List<int> _intervals = [];
  List<int> _deltaIntervals = [];
  List<String> _progressionTags = [];
  List<String> _romanIntervals = [];
  String _progressionName = '';
  Note _tonic = Note.fromString("C");
  int numberOfChords() => _progressionChords.length;

  Progression(List<Chord> chords, String progressionName, List<String> tags,
      Note tonic) {
    _progressionChords = chords;
    _progressionName = progressionName;
    _progressionTags = tags;
    _tonic = tonic;

    for (int idxChord = 0; idxChord < chords.length - 1; idxChord++) {
      _deltaIntervals.add(chords[idxChord]
          .getTonic()
          .getAbsoluteIntervalFromNote(chords[idxChord + 1].getTonic()));
      _intervals.add(chords[0]
          .getTonic()
          .getAbsoluteIntervalFromNote(chords[idxChord + 1].getTonic()));
    }
  }

  Progression.fromAbsoluteIntervals(List<int> intervals, String progressionName,
      List<String> tags, Note tonic) {
    _intervals = intervals;
    _progressionName = progressionName;
    _progressionTags = tags;
    _tonic = tonic;
    calculateDeltaIntervals();
  }

  Progression.fromRomanIntervals(List<String> intervals, String progressionName,
      List<String> tags, Note tonic) {
    _romanIntervals = intervals;
    _tonic = tonic;

    for (int interval = 0; interval < intervals.length; interval++) {
      _intervals.add(romanIntervalMap[intervals[interval]]!);

      bool isChordMajor =
          intervals[interval][0].toUpperCase() == intervals[interval][0];

      if (isChordMajor)
        _progressionChords.add(Chord.majorChord(
            _tonic.getIntervalFromSeminotes(_intervals[interval])));
      else
        _progressionChords.add(Chord.minorChord(
            _tonic.getIntervalFromSeminotes(_intervals[interval])));
    }
    _progressionName = progressionName;
    _progressionTags = tags;
    calculateDeltaIntervals();
  }

  void updateChords() {
    for (int interval = 0; interval < _romanIntervals.length; interval++) {
      bool isChordMajor = _romanIntervals[interval][0].toUpperCase() ==
          _romanIntervals[interval][0];

      if (isChordMajor)
        _progressionChords[interval] = Chord.majorChord(
            _tonic.getIntervalFromSeminotes(_intervals[interval]));
      else
        _progressionChords[interval] = Chord.minorChord(
            _tonic.getIntervalFromSeminotes(_intervals[interval]));
    }
  }

  void calculateDeltaIntervals() {
    _deltaIntervals.clear();
    _deltaIntervals.add(0);
    for (int intervalIdx = 1; intervalIdx < _intervals.length; intervalIdx++) {
      _deltaIntervals.add(wrapperAbsoluteNoteValue(
          _intervals[intervalIdx] - _intervals[intervalIdx - 1]));
    }
  }

  void setProgressionTonic(Note tonic) {
    int semitonesBetweenNodes =
        tonic.getNoteAbsoluteIdx() - _tonic.getNoteAbsoluteIdx();

    transposeInSemitones(semitonesBetweenNodes);
    _tonic = tonic;
  }

  void transposeInSemitones(int semitones) {
    for (int chordIdx = 0; chordIdx < _progressionChords.length; chordIdx++)
      _progressionChords[chordIdx].transposeInSemitones(semitones);
  }

  Note getTonic() {
    return _tonic;
  }

  String getProgressionName() {
    return _progressionName;
  }

  List<Chord> getProgressionChords() {
    return _progressionChords;
  }

  String getProgressionAsString(int numberOfChordsToGet) {
    String progressionString = _progressionChords[0].getChordName();
    for (int chordIdx = 1; chordIdx < numberOfChordsToGet; chordIdx++)
      progressionString += ' - ' +
          _progressionChords[chordIdx % _progressionChords.length]
              .getChordName();
    return progressionString;
  }

  String getRomanIntervalsAsString() {
    String romanIntervals = '';
    for (int idx = 0; idx < _romanIntervals.length - 1; idx++)
      romanIntervals = romanIntervals + _romanIntervals[idx] + ',';
    romanIntervals =
        romanIntervals + _romanIntervals[_romanIntervals.length - 1];

    return romanIntervals;
  }

  bool chordInProgression(Chord chord, int position) {
    if (position == 0)
      return _progressionChords[position].isChordOfTheSameType(chord);

    bool isChordARepetitionOfTheProgression =
        position >= _progressionChords.length;
    if (isChordARepetitionOfTheProgression) {
      position = position % _progressionChords.length;

      if (position == 0)
        return _progressionChords[0].getTonic().getNoteAbsoluteIdx() ==
                chord.getTonic().getNoteAbsoluteIdx() &&
            _progressionChords[0].isChordOfTheSameType(chord);
    }

    bool chordInProgression = false;
    bool isChordOfTheSameType =
        _progressionChords[position].isChordOfTheSameType(chord);

    bool hasChordTheCorrectInterval = _progressionChords[position - 1]
            .getTonic()
            .getAbsoluteIntervalFromNote(chord.getTonic()) ==
        _deltaIntervals[position];

    chordInProgression = hasChordTheCorrectInterval && isChordOfTheSameType;

    return chordInProgression;
  }

  void addChordToProgression(Chord chord, int position) {
    if (position <
        _progressionChords
            .length) // Only add chord if position below a bar repetition
      _progressionChords[position] = chord;
  }

  String getTags() {
    String tagsString = '';
    for (int tagIdx = 0; tagIdx < _progressionTags.length; tagIdx++)
      tagsString += _progressionTags[tagIdx] + ', ';

    return tagsString;
  }

  void setProgressionTags(List<String> tags) {
    _progressionTags = tags;
  }

  void addProgressionTag(String tag) {
    _progressionTags.add(tag);
  }

  void removeProgressionTag(String tag) {
    _progressionTags.remove(tag);
  }

  void updateTonic() {
    _tonic = Note.fromString(noteMap[wrapperAbsoluteNoteValue(
            _progressionChords[0].getTonic().getNoteAbsoluteIdx() -
                _intervals[0])
        .toString()]!);
  }
}

class fullHarmonization {
  List<Note> melody;
  Progression progression;
  String name;
  fullHarmonization(this.name, this.melody, this.progression);

  fullHarmonization.fromPrimitiveRepresentation(
      this.name, this.melody, this.progression) {}

  String getName() => name;
  List<Note> getMelody() => melody;
  Progression getProgression() => progression;

  String getMelodyNotesAsString() {
    String notesAsString = '';
    for (int idxNote = 0; idxNote < melody.length - 1; idxNote++)
      notesAsString += melody[idxNote].getNoteString() + '-';
    notesAsString += melody[melody.length - 1].getNoteString();
    return notesAsString;
  }

  Map<String, String> getPrimitiveRepresentation() {
    return {'id': ''};
  }

  String getTonicAsString() {
    return progression.getTonic().getNoteString();
  }

  int getMaximumHarmonyLength() {
    return max(progression.getProgressionChords().length, melody.length);
  }
}

/////////////////////////// SEARCH METHODS ////////////////
List findValidProgressionForMelody(
    List<Note> melodyNotes, ChordRestrictions chordRestrictions,
    {onlyEqualLengthProgressions = false}) {
  List<List<Chord>> allChords = [];
  for (int idxNote = 0; idxNote < melodyNotes.length; idxNote++)
    allChords.add(
        generatePossibleChordsForNote(melodyNotes[idxNote], chordRestrictions));

  int numberOfMelodyNotes = melodyNotes.length;
  int chordPosition = 0;
  List<List<int>> validSequencies = [];
  List<String> descriptions = [];
  List<Progression> progressions = [];
  for (var currentProgression in progressionsDatabase) {
    int chordsInCurrentProgression = currentProgression.numberOfChords();
    if (onlyEqualLengthProgressions &&
        numberOfMelodyNotes != chordsInCurrentProgression) continue;

    List<int> sequencies = getValidChordSequenceForProgression(
        currentProgression, allChords, chordPosition, numberOfMelodyNotes);

    if (sequencies.isNotEmpty) {
      validSequencies.add(sequencies);

      descriptions.add(currentProgression.getTags());
      progressions.add(currentProgression);
    }
  }

  var converterdProgressions = convertSequenciesAndChordToProgressions(
      validSequencies, allChords, progressions, numberOfMelodyNotes);
  var allFoundProgressions = converterdProgressions[0];
  var allFoundProgressionsStrings = converterdProgressions[1];

  // Update tonic of all progressions
  for (int idxProgression = 0;
      idxProgression < allFoundProgressions.length;
      idxProgression++) {
    allFoundProgressions[idxProgression].updateTonic();
    allFoundProgressions[idxProgression].updateChords();
  }

  return [allFoundProgressions, descriptions, allFoundProgressionsStrings];
}

List<int> getValidChordSequenceForProgression(Progression progression,
    List<List<Chord>> allChords, int chordPosition, int maximumMelodyLength) {
  List<int> validChordsIdxAtPosition = [];
  List<int> validSequencies = [];

  for (int idxChord = 0;
      idxChord < allChords[chordPosition].length;
      idxChord++) {
    if (progression.chordInProgression(
        allChords[chordPosition][idxChord], chordPosition))
      validChordsIdxAtPosition.add(idxChord);
  }

  if (chordPosition == maximumMelodyLength - 1)
    return validChordsIdxAtPosition;
  else {
    for (int validChordIndex = 0;
        validChordIndex < validChordsIdxAtPosition.length;
        validChordIndex++) {
      progression.addChordToProgression(
          allChords[chordPosition][validChordsIdxAtPosition[validChordIndex]],
          chordPosition);

      List<int> validPositionsForChordAbove =
          getValidChordSequenceForProgression(
              progression, allChords, chordPosition + 1, maximumMelodyLength);

      if (validPositionsForChordAbove.isNotEmpty) {
        validSequencies.add(validChordsIdxAtPosition[validChordIndex]);
        validSequencies.addAll(validPositionsForChordAbove);
      }
    }
  }
  return validSequencies;
}

List convertSequenciesAndChordToProgressions(
    List<List<int>> validSequencies,
    List<List<Chord>> allChords,
    List<Progression> progressions,
    int numberOfMelodyNotes) {
  List<Progression> allFoundProgressions = [];
  List<String> allFoundProgressionsStrings = [];

  for (int foundProgressions = 0;
      foundProgressions < validSequencies.length;
      foundProgressions++) {
    int numberOfTonicsInProgression =
        validSequencies[foundProgressions].length ~/ numberOfMelodyNotes;
    for (int tonic = 0; tonic < numberOfTonicsInProgression; tonic++) {
      Progression progressionTemp = progressions[foundProgressions];
      for (int melodyIdx = 0; melodyIdx < numberOfMelodyNotes; melodyIdx++)
        progressionTemp.addChordToProgression(
            allChords[melodyIdx][validSequencies[foundProgressions]
                [tonic * numberOfMelodyNotes + melodyIdx]],
            melodyIdx);

      allFoundProgressions.add(progressionTemp);
      allFoundProgressionsStrings
          .add(progressionTemp.getProgressionAsString(numberOfMelodyNotes));
    }
  }

  return [allFoundProgressions, allFoundProgressionsStrings];
}
