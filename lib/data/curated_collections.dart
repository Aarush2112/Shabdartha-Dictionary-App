import 'package:flutter/material.dart';
import '../models/collection_model.dart';

final List<WordCollection> curatedCollections = [
  const WordCollection(
    id: 'indian_origin',
    title: 'Words of Indian Origin',
    subtitle: 'From Sanskrit and Hindi to global English',
    description:
        'Explore words that traversed maritime routes, colonial trade, and philosophical transmissions to become permanent pillars of global English.',
    icon: Icons.temple_hindu_outlined,
    tag: 'Etymology',
    wordList: [
      'juggernaut',
      'avatar',
      'guru',
      'bungalow',
      'jungle',
      'bandana',
      'cheetah',
      'loot',
      'cot',
      'dinghy',
    ],
  ),
  const WordCollection(
    id: 'pie_cognates',
    title: 'Ancient Kinship (PIE Cognates)',
    subtitle: 'Shared prehistoric roots between Sanskrit and English',
    description:
        'These words were not borrowed. Over 5,000 years ago, ancestral speakers uttered shared Proto-Indo-European roots that blossomed into Sanskrit on the Indus and English on the Thames.',
    icon: Icons.account_tree_outlined,
    tag: 'Linguistics',
    wordList: [
      'brother',
      'mother',
      'name',
      'dental',
      'two',
      'mental',
    ],
  ),
  const WordCollection(
    id: 'emotions',
    title: 'Complex & Subtle Emotions',
    subtitle: 'Feelings that demand precise language',
    description:
        'Nuanced terms that capture delicate emotional landscapes where ordinary vocabulary falls short.',
    icon: Icons.favorite_border_rounded,
    tag: 'Emotions',
    wordList: [
      'melancholy',
      'solitude',
      'petrichor',
      'serendipity',
      'ineffable',
      'equanimity',
    ],
  ),
  const WordCollection(
    id: 'writing_precision',
    title: 'Words for Writing & Rhetoric',
    subtitle: 'Elevate your essays, stories, and discourse',
    description:
        'Architectural words chosen for their musicality, precision, and persuasive resonance in prose.',
    icon: Icons.menu_book_outlined,
    tag: 'Writing',
    wordList: [
      'eloquence',
      'equanimity',
      'ineffable',
      'serendipity',
      'lucid',
      'cogent',
    ],
  ),
  const WordCollection(
    id: 'commonly_confused',
    title: 'Commonly Confused Words',
    subtitle: 'Master delicate semantic distinctions',
    description:
        'Words frequently conflated in modern usage, clarified with precision.',
    icon: Icons.compare_arrows_rounded,
    tag: 'Distinctions',
    wordList: [
      'melancholy',
      'solitude',
      'avatar',
      'juggernaut',
      'guru',
      'bungalow',
    ],
  ),
];
