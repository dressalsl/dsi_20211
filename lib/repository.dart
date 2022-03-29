import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';

class ParPalavra {
  String first, second;
  ParPalavra(this.first, this.second);
}

class ParPalavraRepository {}

ParPalavraRepository rep = ParPalavraRepository();

List createTwentyWords() {
  var result = [];
  for (var i = 0; i < 20; i++) {
    WordPair wp = WordPair.random();
    ParPalavra p = ParPalavra(wp.first, wp.second);
    result.add(p);
  }
  return result;
}
