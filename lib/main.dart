import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';

final suggestions = <WordPair>[];
final biggerFont = const TextStyle(fontSize: 18);
final saved = <WordPair>[];
final formKey = GlobalKey<FormState>();
bool isGrid = false;
bool isAddWord = false;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Startup Name Generator',
        theme: ThemeData(
          primarySwatch: Colors.pink,
        ),
        //home: RandomWords(),
        initialRoute: '/',
        routes: {
          '/': (context) => RandomWords(),
          '/edit': (context) => EditScreen()
        },
        debugShowCheckedModeBanner: false);
  }
}

class RandomWords extends StatefulWidget {
  const RandomWords({Key? key}) : super(key: key);

  @override
  _RandomWordsState createState() => _RandomWordsState();
}

class _RandomWordsState extends State<RandomWords> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Startup Name Generator'),
        actions: [
          IconButton(icon: Icon(Icons.star), onPressed: _pushSaved),
          IconButton(
              onPressed: () => setState(() {
                    if (isGrid) {
                      isGrid = false;
                    } else {
                      isGrid = true;
                    }
                  }),
              icon: Icon(Icons.change_circle_outlined)),
          IconButton(
              icon: Icon(Icons.add_circle_outline_rounded),
              onPressed: () => setState(() {
                    if (isAddWord) {
                      isAddWord = false;
                    } else {
                      isAddWord = true;
                    }
                  }))
        ],
      ),
      body: _buildSuggestions(),
    );
  }

  Widget _buildSuggestions() {
    switch (isGrid) {
      case false:
        return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemBuilder: (BuildContext _context, int i) {
              if (i.isOdd) {
                return Divider();
              }
              final int index = i ~/ 2;
              if (index >= suggestions.length) {
                suggestions.addAll(generateWordPairs().take(10));
              }
              return _buildRow(suggestions[index], index, context);
            });
      case true:
        return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.5,
            ),
            itemBuilder: (BuildContext _context, int i) {
              final int index = i;
              if (index >= suggestions.length) {
                suggestions.addAll(generateWordPairs().take(10));
              }
              return _buildRow(suggestions[index], index, context);
            });
    }
    return Text('');
  }

  Widget _buildRow(WordPair name, int index, BuildContext context) {
    final strName = name.toString();
    final alreadySaved = saved.contains(name);
    return Dismissible(
        direction: DismissDirection.endToStart,
        key: Key(strName),
        child: ListTile(
          title: Text(
            name.asPascalCase,
            style: biggerFont,
          ),
          trailing: IconButton(
            icon: Icon(alreadySaved ? Icons.favorite : Icons.favorite_border),
            color: alreadySaved ? Colors.pink : null,
            onPressed: () {
              setState(() {
                if (alreadySaved) {
                  saved.remove(name);
                } else {
                  saved.add(name);
                }
              });
            },
          ),
          onTap: () {
            //_editRow(name, index, context)
            Navigator.pushNamed(context, '/edit',
                arguments: {'name': name, 'index': index});
            ;
          },
        ),
        background: Container(
            color: Colors.red,
            child: Align(
                alignment: AlignmentDirectional.centerEnd,
                child: Icon(Icons.delete_forever))),
        onDismissed: (direction) {
          setState(() {
            suggestions.remove(name);
            if (alreadySaved) {
              saved.remove(name);
            }
          });
        });
  }

  void _pushSaved() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          final tiles = saved.map(
            (name) {
              return ListTile(
                title: Text(
                  name.asPascalCase,
                  style: biggerFont,
                ),
              );
            },
          );
          final divided = ListTile.divideTiles(
            context: context,
            tiles: tiles,
          ).toList();

          return Scaffold(
            appBar: AppBar(
              title: Text('Saved Suggestions'),
            ),
            body: ListView(children: divided),
          );
        }, // ...to here.
      ),
    );
  }
}

class EditScreen extends StatefulWidget {
  // const _EditScreen({ Key? key }) : super(key: key);

  @override
  EditScreenState createState() => EditScreenState();
}

class EditScreenState extends State<EditScreen> {
  String first = '';
  String second = '';
  final formKey = GlobalKey<FormState>();
  Widget build(BuildContext context) {
    Map arguments = ModalRoute.of(context)!.settings.arguments as Map;
    var name = arguments['name'];
    var index = arguments['index'];
    first = name.first;
    second = name.second;
    return Scaffold(
        appBar: AppBar(title: const Text('Edit')),
        body: Wrap(
          children: <Widget>[
            Form(
                key: formKey,
                child: Column(children: [
                  TextFormField(
                      validator: (value) {
                        return value!.isEmpty ? 'Can not be null' : null;
                      },
                      autofocus: true,
                      initialValue: first,
                      keyboardType: TextInputType.text,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                      ),
                      decoration: InputDecoration(
                        labelText: 'First Name',
                        contentPadding: const EdgeInsets.only(
                            left: 15, top: 15, right: 15, bottom: 15),
                      ),
                      onChanged: (value) => first = value.toString()),
                  TextFormField(
                      validator: (value) {
                        return value!.isEmpty ? 'Can not be null' : null;
                      },
                      autofocus: true,
                      initialValue: second,
                      keyboardType: TextInputType.text,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Second Name',
                        contentPadding: const EdgeInsets.only(
                            left: 15, top: 15, right: 15, bottom: 15),
                      ),
                      onChanged: (value) => second = value.toString())
                ])),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => _saveEdit(context, first, second, index, name),
                child: Text('Save'),
                style: TextButton.styleFrom(
                  primary: Colors.pink,
                  padding: EdgeInsets.all(4),
                  side: BorderSide(
                    color: Colors.pink,
                  ),
                  backgroundColor: Colors.pink.shade100,
                  minimumSize: Size(200, 50),
                ),
              ),
            )
          ],
        ));
  }

  void _saveEdit(BuildContext context, first, second, index, name) {
    if (!formKey.currentState!.validate()) return;
    formKey.currentState!.save();
    setState(() {
      final newName = WordPair(first, second);
      final oldName = name;
      suggestions[index] = newName;

      if (saved.contains(oldName)) {
        saved.remove(oldName);
        saved.add(newName);
      }
    });
    Navigator.pop(context);
  }
}
