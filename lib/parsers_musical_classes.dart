import 'package:sqflite/sqflite.dart';

import 'musical_classes.dart';

abstract class Parser {
  objectToDatabaseRepresentation(var object);
  databaseToObject(var object);
}

abstract class DatabaseTransfer {
  Future<List> getAllData();
  void addEntry(Map<String, String> entry);
  void removeEntry(Map<String, String> entry);
  void addDatabase(var database);
}

class SqlLiteDatabase extends DatabaseTransfer {
  late Database database;
  String sqlTable = 'progressions';

  @override
  void addDatabase(var _database) {
    database = _database as Database;
  }

  @override
  Future<List> getAllData() async {
    final List<Map<String, dynamic>> databaseQueries =
        await database.query(sqlTable);
    return databaseQueries;
  }

  @override
  void addEntry(Map<String, String> entry) {
    database.insert(
      sqlTable,
      entry,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  void removeEntry(Map<String, String> entry) {
    database.delete(
      sqlTable,
      where: 'name = ?',
      whereArgs: [entry['name']],
    );
  }
}

class SqlHarmonizationsDatabase extends SqlLiteDatabase {
  late Database database;
  String sqlTable = 'harmonizations';
}

class SqlProgressionsDatabase extends SqlLiteDatabase {
  late Database database;
  String sqlTable = 'progressions';
}

class FullHarmonizationParser extends Parser {
  @override
  databaseToObject(var representation) {
    List melody = representation['melody']!
        .split('-')
        .map((e) => Note.fromString(e))
        .toList(); //
    List<String> romanIntervals =
        representation['romanProgression']!.split(',');

    Note tonic = Note.fromString(representation['progressionTonic']);
    Progression progression = Progression.fromRomanIntervals(romanIntervals,
        representation['name']!, representation['tags']!.split(','), tonic);

    fullHarmonization harmonization = fullHarmonization(
        representation['name']!, melody.cast<Note>(), progression);
    return harmonization;
  }

  @override
  Map<String, String> objectToDatabaseRepresentation(var harmonization) {
    harmonization = harmonization as fullHarmonization;

    String name = harmonization.name;
    String romanProgression =
        harmonization.getProgression().getRomanIntervalsAsString();
    String melody = harmonization.getMelodyNotesAsString();
    String progressionTonic = harmonization.getTonicAsString();

    Map<String, String> representation = {
      'name': name,
      'romanProgression': romanProgression,
      'melody': melody,
      'progressionTonic': progressionTonic,
      'tags': harmonization.getProgression().getTags()
    };
    return representation;
  }
}

class ProgressionParser extends Parser {
  @override
  databaseToObject(var representation) {
    //representation = representation as Map<String,String>;
    List<String> romanIntervals =
        representation['romanProgression']!.split(',');

    Note tonic = Note.fromString("C");
    if (representation.containsKey('progressionTonic')) {
      tonic = Note.fromString(representation['progressionTonic']);
    }

    Progression progression = Progression.fromRomanIntervals(romanIntervals,
        representation['name']!, representation['tags']!.split(','), tonic);

    return progression;
  }

  @override
  Map<String, String> objectToDatabaseRepresentation(var progression) {
    progression = progression as Progression;

    String name = progression.getProgressionName();
    String romanProgression = progression.getRomanIntervalsAsString();
    String Tags = progression.getTags();
    String progressionTonic = progression.getTonic().getNoteString();

    Map<String, String> representation = {
      'name': name,
      'romanProgression': romanProgression,
      'tags': Tags,
      'progressionTonic': progressionTonic
    };
    return representation;
  }
}
