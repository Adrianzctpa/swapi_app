import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'films.dart';
import 'people.dart';

class PeopleList with ChangeNotifier {
  final fbUrl = dotenv.env['FB_URL'] ?? 'FB_URL is null';
  List<People> _ppl = [];
  Getter _getter = Getter(next: null, previous: null, count: 0, results: []);
  int _id = 0;
  final List<Map<String, Object>> _cachedPeople = [];

  final String _token;
  PeopleList(this._token);

  void setInfo(List<People> people, Getter info, [int? id]) {
    _ppl = people;
    _getter = info;
    id != null ? _id = id : _id = _id;
    notifyListeners();
  }

  bool isCached(People person) {
    final cacheList = [];
    for (var i = 0; i < _cachedPeople.length; i++) {
      final mapPerson = _cachedPeople[i]['person'] as People;
      cacheList.add(mapPerson.name);  
    } 

    return cacheList.contains(person.name);
  }

  void setCachedPeople() { 
    final getFuture = http.get(Uri.parse('$fbUrl/cached.json?auth=$_token'));
      getFuture.then((resp) {
        if (resp.statusCode == 200) {
          if (resp.body == 'null') return;
          final data = Map<String, dynamic>.from(jsonDecode(resp.body));

          data.forEach((key, value) {
            final pers = People.fromJson(value['info']);
            final List films = value['films'].toList();
            final List<Films> filmsList = [];
            for (var i = 0; i < films.length; i++) {
              filmsList.add(Films.fromJson(value['films'][i]));
            }
            _cachedPeople.add({'person': pers, 'films': filmsList});
          });
          notifyListeners();
        }
      }
    );
  }

  List<Map<String,Object>> postAndCache(People person, List<Films> films) {
     if (!isCached(person)) {
      http.post(
        Uri.parse('$fbUrl/cached.json?auth=$_token'),
        body: jsonEncode({
          'name': person.name,
          'films': films,
          'info': person
        })
      );
      
      _cachedPeople.add({'person': person, 'films': films});
      notifyListeners();
    }

    return _cachedPeople;
  }

  List<People> get people => [..._ppl];
  Getter get getter => _getter;
  List<Map<String, Object>> get cachedPeople => [..._cachedPeople];
  int get id => _id;

  // Favorites
  final List<People> _favoritePeople = [];

  void toggleFavorite(People person) {
    if (_favoritePeople.contains(person)) {
      final delFuture = http.get(
        Uri.parse(
          '$fbUrl/favorites.json/?auth=$_token&orderBy="name"&equalTo="${person.name}"'
        )
      );

      delFuture.then((resp) {
        json.decode(resp.body).forEach((key, value) {
          http.delete(
            Uri.parse(
              '$fbUrl/favorites/$key.json?auth=$_token'
            )
          );
          _favoritePeople.remove(person);
          notifyListeners();
        });
      });
    } else {
      http.post(
        Uri.parse('$fbUrl/favorites.json?auth=$_token'),
        body: jsonEncode({
          'name': person.name,
          'info': person
        })
      );
      _favoritePeople.add(person);
      notifyListeners();
    }
  }

  void setFavorites() {
    final getFuture = http.get(Uri.parse('$fbUrl/favorites.json?auth=$_token'));
    getFuture.then((resp) {  
      if (jsonDecode(resp.body) == null) return;  

      final jsonData = Map<String, dynamic>.from(jsonDecode(resp.body));
      jsonData.forEach((key, value) {
        final Map<String, dynamic> info = value['info'];
        final person = People.fromJson(info);

        _favoritePeople.add(person);
      });
      notifyListeners();
    });
  }

  bool isFavorite(People person) {
    for (var i = 0; i < _favoritePeople.length; i++) {
      if (_favoritePeople[i].name == person.name) {
        return true;
      }
    }
    return false;
  }

  List<People> get favPeople => _favoritePeople;
}