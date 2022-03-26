import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'package:flutter/rendering.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Startup Name Generator',
        theme: ThemeData(
          primarySwatch: Colors.pink,
        ),
        home: RandomWords(),
        debugShowCheckedModeBanner: false);
  }
}

class RandomWords extends StatefulWidget {
  const RandomWords({Key? key}) : super(key: key);

  @override
  _RandomWordsState createState() => _RandomWordsState();
}

class _RandomWordsState extends State<RandomWords> {
  final _suggestions = <String>[];
  final _saved = <String>{};
  final _biggerFont = const TextStyle(fontSize: 18);
  final _formKey = GlobalKey<FormState>();
  bool isGrid = false;

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
              icon: Icon(Icons.change_circle_outlined))
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
              if (index >= _suggestions.length) {
                _suggestions.add(WordPair.random().asPascalCase);
              }
              return _buildRow(_suggestions[index], index);
            });
      case true:
        return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.5,
            ),
            itemBuilder: (BuildContext _context, int i) {
              final int index = i;
              if (index >= _suggestions.length) {
                _suggestions.add(WordPair.random().asPascalCase);
              }
              return _buildRow(_suggestions[index], index);
            });
    }
    return Text('');
  }

  Widget _buildRow(String name, int index) {
    final alreadySaved = _saved.contains(name);
    return Dismissible(
        direction: DismissDirection.endToStart,
        key: Key(name),
        child: ListTile(
          title: Text(
            name,
            style: _biggerFont,
          ),
          trailing: IconButton(
            icon: Icon(alreadySaved ? Icons.favorite : Icons.favorite_border),
            color: alreadySaved ? Colors.pink : null,
            onPressed: () {
              setState(() {
                if (alreadySaved) {
                  _saved.remove(name);
                } else {
                  _saved.add(name);
                }
              });
            },
          ),
          onTap: () {
            _editRow(name, index);
          },
        ),
        background: Container(
            color: Colors.red,
            child: Align(
                alignment: AlignmentDirectional.centerEnd,
                child: Icon(Icons.delete_forever))),
        onDismissed: (direction) {
          setState(() {
            _suggestions.remove(name);
            if (alreadySaved) {
              _saved.remove(name);
            }
          });
        });
  }

  void _pushSaved() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          final tiles = _saved.map(
            (name) {
              return ListTile(
                title: Text(
                  name,
                  style: _biggerFont,
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

  void _saveEdit(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _formKey.currentState!.save();
    });
    Navigator.pop(context);
  }

  void _editRow(String name, int index) {
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (BuildContext context) {
      return Scaffold(
          appBar: AppBar(title: const Text('Edit')),
          body: Wrap(
            children: <Widget>[
              Form(
                  key: _formKey,
                  child: TextFormField(
                    validator: (value) {
                      return value!.isEmpty ? 'Can not be null' : null;
                    },
                    autofocus: true,
                    initialValue: name,
                    keyboardType: TextInputType.text,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Name',
                      contentPadding: const EdgeInsets.only(
                          left: 15, top: 15, right: 15, bottom: 15),
                    ),
                    onSaved: (value) {
                      _suggestions[index] = value.toString();
                      if (_saved.contains(name)) {
                        _saved.remove(name);
                        _saved.add(value.toString());
                      }
                    },
                  )),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => _saveEdit(context),
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
    }));
  }
}
