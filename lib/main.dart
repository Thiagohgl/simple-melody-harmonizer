import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:melody_harmonizer/harmony_saved_db_obj.dart';
import 'package:path/path.dart';
import 'harmony_input_view.dart';
import 'progressions_list_view.dart';
import 'melody_saved_view.dart';
import 'melody_input_view.dart';
import 'melody_saved_db_obj.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'parsers_musical_classes.dart';
import 'piano.dart';

void main() async {
  // Avoid errors caused by flutter upgrade.
// Importing 'package:flutter/widgets.dart' is required.
  WidgetsFlutterBinding.ensureInitialized();

  final sqliteDB = await openDatabase(
    join(await getDatabasesPath(), 'smartHarmonyDB.db'),
    onCreate: (db, version) {
      db.execute(
          'CREATE TABLE harmonizations(id INTEGER PRIMARY KEY, name TEXT, romanProgression TEXT, melody TEXT, progressionTonic TEXT, tags TEXT)');
      return db.execute(
        'CREATE TABLE progressions(id INTEGER PRIMARY KEY, name TEXT, romanProgression TEXT, tags TEXT)',
      );
    },
    version: 1,
  );

  DatabaseTransfer database = SqlHarmonizationsDatabase();
  database.addDatabase(sqliteDB);

  DatabaseTransfer databaseProgression = SqlProgressionsDatabase();
  databaseProgression.addDatabase(sqliteDB);

  var melodiesDatabase = SavedMelodies(database);
  var harmoniesDatabase = SavedHarmonies(databaseProgression);

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => melodiesDatabase),
      ChangeNotifierProvider(create: (context) => harmoniesDatabase)
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  static const String _title = 'Melody Harmonizer';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      home: Scaffold(
        body: HomePage(),
      ),
      routes: <String, WidgetBuilder>{
        '/foundProgressions': (BuildContext context) => Scaffold(
            appBar: AppBar(
              title: Text('Found valid progressions'),
              backgroundColor: Colors.blueGrey,
            ),
            body: Text('')),
        '/melodySelection': (BuildContext context) => Scaffold(
                body: ChangeNotifierProvider(
              create: (context) => PianoModel(),
              child: MelodyInput(),
            )),
        '/harmonySelection': (BuildContext context) => Scaffold(
                body: ChangeNotifierProvider(
              create: (context) => PianoModel(),
              child: HarmonyInput(),
            ))
      },
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();
  final double bottomBarRadius = 0;

  // Controllers
  final melodyEntryController = TextEditingController();
  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    melodyEntryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff7CA1AD),
      bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(bottomBarRadius),
                topLeft: Radius.circular(bottomBarRadius)),
            boxShadow: [
              BoxShadow(color: Colors.black38, spreadRadius: 0, blurRadius: 3),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(bottomBarRadius),
              topRight: Radius.circular(bottomBarRadius),
            ),
            child: BottomNavigationBar(
              items: [
                BottomNavigationBarItem(
                    icon: Icon(Icons.music_note), label: ''),
                BottomNavigationBarItem(icon: Icon(Icons.book), label: '')
              ],
              onTap: _onTappedBar,
              selectedItemColor: Colors.blueGrey,
              currentIndex: _selectedIndex,
            ),
          )),
      body: PageView(
          controller: _pageController,
          children: <Widget>[
            Consumer<SavedMelodies>(
              builder: (context, savedMelodies, child) {
                if (savedMelodies.isEmpty())
                  return ChangeNotifierProvider(
                    create: (context) => PianoModel(),
                    child: Container(
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
                        child: MelodyInput()),
                  );
                else
                  return Scaffold(
                      appBar: AppBar(
                        title: Text('Saved Melodies'),
                        backgroundColor: Color(0xff467387),
                        actions: <Widget>[
                          IconButton(
                            icon: Icon(
                              Icons.info_outline,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text('Info'),
                                      content: Text(
                                          'Software by Thiago Lobato. Check the GitHub repository for license information and code: https://github.com/Thiagohgl/simple-melody-harmonizer.'),
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
                              Color(0xff7CA1AD),
                              Color(0xff214657),
                              Color(0xff3B3B3E),
                            ],
                          )),
                          child: SavedMelodyList(savedMelodies)),
                      floatingActionButton: FloatingActionButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/melodySelection',
                              arguments: {});
                        },
                        child: const Icon(Icons.add),
                        backgroundColor: Color(0xffF7A814),
                      ));
              },
            ),
            Scaffold(
                appBar: AppBar(
                  title: Text('Progressions Database'),
                  backgroundColor: Color(0xff467387),
                ),
                body: Container(
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
                    child: Consumer<SavedHarmonies>(
                      builder: (context, savedHarmonies, child) {
                        return ProgressionsLists(savedHarmonies);
                      },
                    )), // ProgressionsTab
                floatingActionButton: FloatingActionButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/harmonySelection',
                        arguments: {});
                  },
                  child: const Icon(Icons.add),
                  backgroundColor: Color(0xff8E74D4),
                )),
          ],
          onPageChanged: (page) {
            setState(() {
              _selectedIndex = page;
            });
          }),
    );
  }

  void _onTappedBar(int value) {
    setState(() {
      _selectedIndex = value;
    });
    _pageController.jumpToPage(value);
  }
}
