import 'package:flutter/material.dart';

class WordCollection {
  final String id;
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final List<String> wordList;
  final String tag;

  const WordCollection({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.wordList,
    required this.tag,
  });
}
