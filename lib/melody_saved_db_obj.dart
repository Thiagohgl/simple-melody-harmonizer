import 'package:flutter/material.dart';
import 'musical_classes.dart';
import 'parsers_musical_classes.dart';

class SavedMelodies extends ChangeNotifier {
  List<fullHarmonization> _harmonizations = [];
  DatabaseTransfer database;
  Parser parser = FullHarmonizationParser();

  SavedMelodies(this.database) {
    loadDatabase();
  }

  bool isEmpty() {
    return _harmonizations.isEmpty;
  }

  void loadDatabase() async {
    _harmonizations = (await database.getAllData())
        .map((s) => parser.databaseToObject({
              'name': s['name'],
              'romanProgression': s['romanProgression'],
              'melody': s['melody'],
              'progressionTonic': s['progressionTonic'],
              'tags': s['tags']
            }) as fullHarmonization)
        .toList();
  }

  void addHarmonization(fullHarmonization harmonization) {
    _harmonizations.add(harmonization);
    notifyListeners();
  }

  void removeHarmonizationAtIdx(int idx) {
    _harmonizations.removeAt(idx);
    notifyListeners();
  }

  void addHarmonizationToDatabase(fullHarmonization harmonization) {
    database.addEntry(parser.objectToDatabaseRepresentation(harmonization));
  }

  void removeHarmonizationFromDatabase(fullHarmonization harmonization) {
    _harmonizations.remove(harmonization);
    database.removeEntry(parser.objectToDatabaseRepresentation(harmonization));
  }

  List<fullHarmonization> getHarmonizations() => _harmonizations;
}
