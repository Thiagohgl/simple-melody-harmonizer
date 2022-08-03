library progressions_database;

import 'musical_classes.dart';

Note STANDARD_TONIC = Note.fromString("C");
List<Progression> progressionsDatabase = [
  Progression.fromRomanIntervals(['ii', 'V', 'I'], 'ii-V-I',
      ['emotive', 'slow', 'sad', 'melancolic'], STANDARD_TONIC),
  Progression.fromRomanIntervals(['vi', 'ii', 'V', 'I'], 'vi-ii-V-I',
      ['emotive', 'slow', 'sad', 'melancolic'], STANDARD_TONIC),
  Progression.fromRomanIntervals(['I', 'V', 'vi', 'IV'], 'I-V-vi-IV',
      ['happy', 'uplifting', 'pop', 'funny'], STANDARD_TONIC),
  Progression.fromRomanIntervals(['I', 'IV', 'V', 'IV'], 'I-IV-V-IV',
      ['happy', 'dance', 'pop', 'simple'], STANDARD_TONIC),
  Progression.fromRomanIntervals(['I', 'I', 'IV', 'V'], 'I-I-IV-V',
      ['happy', 'direct', 'pop', 'simple'], STANDARD_TONIC),
  Progression.fromRomanIntervals(['vi', 'IV', 'I', 'V'], 'vi-IV-I-V',
      ['heroic', 'hopefull', 'happy'], STANDARD_TONIC),
  Progression.fromRomanIntervals(['vi', 'I', 'V', 'IV'], 'vi-I-V-IV',
      ['sad', 'hopefull', 'emotive', 'desperation'], STANDARD_TONIC),
  Progression.fromRomanIntervals(['I', 'vi', 'IV', 'V'], 'I-vi-IV-V',
      ['50s', 'dance', 'doo-wop'], STANDARD_TONIC),
  Progression.fromRomanIntervals(['I', 'vi', 'ii', 'V'], 'I-vi-ii-V',
      ['50s', 'dance', 'doo-wop', 'minor'], STANDARD_TONIC),
  Progression.fromRomanIntervals(['I', 'V+', 'IV', 'V'], 'I-V+-IV-V',
      ['parallel minor', 'epic', 'heroic', 'dissonance'], STANDARD_TONIC),
  Progression.fromRomanIntervals(
      ['I', 'V', 'V+', 'IV'],
      'I-V-V+-IV',
      [
        'parallel minor',
        'epic',
        'surprising',
        'dissonance',
        'suspend 4+ at V+'
      ],
      STANDARD_TONIC),
  Progression.fromRomanIntervals(['ii', 'V', 'iii', 'IV'], 'ii-V-iii-IV',
      ['sad', 'emotional', 'melancolic'], STANDARD_TONIC),
  Progression.fromRomanIntervals(['IV', 'ii', 'iii', 'vi'], 'IV-ii-iii-vi',
      ['sad', 'hopeful', 'rock'], STANDARD_TONIC),
  Progression.fromRomanIntervals(['vi', 'V', 'IV', 'III'], 'vi-V-IV-III',
      ['adalusian', 'flamenco', 'dancing', 'exotic'], STANDARD_TONIC),
  Progression.fromRomanIntervals(['ii', 'VI+', 'I'], 'ii-VI+-I',
      ['backdoor', 'happy', 'dance'], STANDARD_TONIC),
  Progression.fromRomanIntervals(['I', 'V', 'VI+', 'IV'], 'I-V-VI+-IV',
      ['chromatic descending', 'climax', 'tension,happy'], STANDARD_TONIC),
  Progression.fromRomanIntervals(['I', 'IV', 'ii', 'V'], 'I-IV-ii-V',
      ['bridge', 'jazz', 'Montgomery', 'moving feeling'], STANDARD_TONIC),
  Progression.fromRomanIntervals(
      ['I', 'V', 'vi', 'iii', 'IV', 'I', 'IV', 'V'],
      'I-V-vi-iii-IV-I-IV-V',
      ['romanesca', 'canon', 'happy', 'classic'],
      STANDARD_TONIC),
  Progression.fromRomanIntervals(['I', 'II+', 'V'], 'I-II+-V',
      ['Chromatic mediant', 'happy', 'resolution'], STANDARD_TONIC),
  Progression.fromRomanIntervals(['i', 'VI+', 'iv', 'V'], 'i-VI+-IV-V',
      ['Chromatic mediant', ' sad', 'mystic'], STANDARD_TONIC),
  Progression.fromRomanIntervals(['IV', 'I', 'V', 'ii'], 'IV-I-V-ii',
      ['minor', 'fight', 'break'], STANDARD_TONIC),
  Progression.fromRomanIntervals(['IV', 'V', 'iii', 'vi'], 'IV-V-iii-vi',
      ['Happy', 'Dance', 'Pop'], STANDARD_TONIC)
];

const int NUMBER_OF_STANDARD_PROGRESSIONS = 22;//progressionsDatabase.length;
