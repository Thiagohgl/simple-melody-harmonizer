import 'package:flutter/material.dart';
import 'musical_classes.dart';
import 'parsers_musical_classes.dart';

class SavedHarmonies extends ChangeNotifier {
  List<Progression> _progressions = [];
  DatabaseTransfer database;
  Parser parser = ProgressionParser();

  SavedHarmonies(this.database) {
    loadDatabase();
  }

  void loadDatabase() async {
    _progressions = (await database.getAllData())
        .map((s) => parser.databaseToObject({
              'name': s['name'],
              'romanProgression': s['romanProgression'],
              'tags': s['tags']
            }) as Progression)
        .toList();
  }

  void addProgression(Progression harmonization) {
    _progressions.add(harmonization);
    notifyListeners();
  }

  void removeProgressionAtIdx(int idx) {
    _progressions.removeAt(idx);
    notifyListeners();
  }

  void addProgressionToDatabase(Progression progression) {
    _progressions.add(progression);
    database.addEntry(parser.objectToDatabaseRepresentation(progression));
  }

  void removeProgressionFromDatabase(Progression progression) {
    _progressions.remove(progression);
    database.removeEntry(parser.objectToDatabaseRepresentation(progression));
  }

  List<Progression> getProgressions() => _progressions;
}
