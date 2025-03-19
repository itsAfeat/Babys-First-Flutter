import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MainAppState(),
      child: MaterialApp(
        title: 'Word Maker',
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.light,
          colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepOrange, brightness: Brightness.light),
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepPurple, brightness: Brightness.dark),
        ),
        themeMode: ThemeMode.system,
        home: MainAppPage(),
      ),
    );
  }
}

class MainAppState extends ChangeNotifier {
  var current = WordPair.random();
  var favs = <WordPair>[];

  // Get the next random wordpair
  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  // Add/remove wordpairs from ones favourites
  void toggleFavs() {
    if (favs.contains(current)) {
      favs.remove(current);
    } else {
      favs.add(current);
    }
    notifyListeners();
  }

  void removeFav(WordPair pair) {
    favs.remove(pair);
    notifyListeners();
  }

  void clearFavs() {
    favs.clear();
    notifyListeners();
  }
}

class MainAppPage extends StatefulWidget {
  @override
  State<MainAppPage> createState() => _MainAppPageState();
}

class _MainAppPageState extends State<MainAppPage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
      case 1:
        page = FavouritesPage();
      default:
        throw UnimplementedError('No widget for $selectedIndex');
    }

    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        body: Row(
          children: [
            SafeArea(
              child: NavigationRail(
                extended: constraints.maxWidth >= 600,
                destinations: [
                  NavigationRailDestination(
                    icon: Icon(Icons.home),
                    label: Text('Home'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.favorite),
                    label: Text('Favourties'),
                  ),
                ],
                selectedIndex: selectedIndex,
                onDestinationSelected: (value) {
                  setState(() {
                    selectedIndex = value;
                  });
                },
              ),
            ),
            Expanded(
              child: Container(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: page,
              ),
            )
          ],
        ),
      );
    });
  }
}

class FavouritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MainAppState>();

    return Scaffold(
      body: Center(
        child: ListView(
          children: appState.favs
              .map((f) => Card(
                    child: ListTile(
                      title: Text(f.asUpperCase),
                      trailing: Icon(Icons.delete),
                      onTap: () {
                        appState.removeFav(f);
                      },
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MainAppState>();
    var pair = appState.current;
    final scheme = Theme.of(context).colorScheme;

    IconData favIcon =
        (appState.favs.contains(pair) ? Icons.favorite_border : Icons.favorite);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // const Text('Noget tilfældig tekst: '),
            BigCard(pair: pair),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton.icon(
                    icon: Icon(favIcon),
                    style: ButtonStyle(
                      backgroundColor:
                          WidgetStatePropertyAll(scheme.inversePrimary),
                      foregroundColor:
                          WidgetStatePropertyAll(scheme.onSecondaryContainer),
                    ),
                    onPressed: () {
                      appState.toggleFavs();
                    },
                    onLongPress: () {
                      appState.clearFavs();
                    },
                    label: Text('Like')),
                SizedBox(
                  width: 20,
                ),
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor:
                        WidgetStatePropertyAll(scheme.secondaryContainer),
                    foregroundColor:
                        WidgetStatePropertyAll(scheme.onSecondaryContainer),
                  ),
                  onPressed: () {
                    appState.getNext();
                  },
                  child: Text('Næste ord'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displaySmall!.copyWith(
        color: theme.colorScheme.onPrimary, fontWeight: FontWeight.bold);

    return Card(
      color: theme.colorScheme.primary,
      elevation: 7.5,
      margin: EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text(
          pair.asUpperCase,
          style: style,
          semanticsLabel: "${pair.first} ${pair.second}",
        ),
      ),
    );
  }
}
