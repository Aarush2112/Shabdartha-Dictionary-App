import '../models/word_model.dart';

/// Curated Lexicon for Garuda Lexicon.
/// Contains verified etymologies, academic Indian language connections,
/// and literary insights.
final List<WordEntry> curatedWordEntries = [
  // --- INDIAN LOANWORDS (Direct Borrowings) ---
  const WordEntry(
    word: 'juggernaut',
    phonetic: '/ˈdʒʌɡ.ə.nɔːt/',
    meanings: [
      WordMeaning(
        partOfSpeech: 'noun',
        definitions: [
          DefinitionItem(
            definition:
                'A huge, powerful, and overwhelming force or institution that crushes anything in its path.',
            example:
                'The industrial juggernaut revolutionized the valley over the span of two decades.',
            synonyms: ['steamroller', 'behemoth', 'colossus', 'powerhouse'],
            antonyms: ['featherweight', 'weakling'],
          ),
        ],
      ),
    ],
    origin:
        'Late 17th century: directly borrowed from the title of the deity Jagannath in Puri, Odisha.',
    etymology:
        'Anglicized from Odia/Sanskrit "Jagannātha" (जगन्नाथ: sovereign of the cosmos). Early European travelers were awestruck by the massive chariot procession during the annual Ratha Yatra in Puri, leading to the figurative English usage denoting an unstoppable force.',
    indianConnections: [
      IndianLanguageConnection(
        language: 'Sanskrit / Odia',
        nativeScript: 'जगन्नाथ',
        transliteration: 'jagannātha',
        meaning: 'Lord of the Universe (jagat = world/universe + nātha = protector/master).',
        relationType: IndianRelationType.loanword,
        academicNote:
            'A historic 17th-century loanword. The massive 45-foot chariots of Puri Temple inspired English writers to coin the term metaphorically for an overwhelming momentum.',
        isVerified: true,
      ),
    ],
    editorialInsight:
        'A striking example of how a sacred festival in coastal Odisha entered global rhetoric as an archetype of sheer, irresistible motion.',
    isCurated: true,
  ),

  const WordEntry(
    word: 'avatar',
    phonetic: '/ˈæv.ə.tɑːr/',
    meanings: [
      WordMeaning(
        partOfSpeech: 'noun',
        definitions: [
          DefinitionItem(
            definition:
                'An embodiment or incarnation of a concept, philosophy, or deity; in digital contexts, an iconic representation of an internet user.',
            example:
                'In modern computing, every user navigates virtual worlds through an interactive avatar.',
            synonyms: ['incarnation', 'manifestation', 'embodiment', 'archetype'],
            antonyms: ['abstraction', 'disembodiment'],
          ),
        ],
      ),
    ],
    origin: 'Late 18th century: via Sanskrit avatāra.',
    etymology:
        'Derived from the Sanskrit prefix "ava-" (down, away) and the root "tṛ" (to cross over, pass). Literally denotes a deliberate descent from a spiritual or higher realm into mundane earthly existence.',
    indianConnections: [
      IndianLanguageConnection(
        language: 'Sanskrit',
        nativeScript: 'अवतार',
        transliteration: 'avatāra',
        meaning: 'Descent; the crossing down of divine consciousness into temporal form.',
        relationType: IndianRelationType.loanword,
        academicNote:
            'Traditionally refers to the ten primary descents (Daśāvatāra) of Vishnu. Modern computer science borrowed the term in the 1980s (popularized by Chip Morningstar in Habitat and Neal Stephenson in Snow Crash) to signify a person\'s digital manifestation.',
        isVerified: true,
      ),
    ],
    editorialInsight:
        'From Vedic cosmology to cyberspace: "Avatar" is among the most successful trans-cultural semantic migrations in the history of language.',
    isCurated: true,
  ),

  const WordEntry(
    word: 'guru',
    phonetic: '/ˈɡʊr.uː/',
    meanings: [
      WordMeaning(
        partOfSpeech: 'noun',
        definitions: [
          DefinitionItem(
            definition:
                'An influential teacher, trusted mentor, or recognized master of a discipline.',
            example:
                'She sought the counsel of a veteran design guru before launching her architectural studio.',
            synonyms: ['mentor', 'master', 'guide', 'preceptor', 'sage'],
            antonyms: ['novice', 'disciple', 'pupil', 'amateur'],
          ),
        ],
      ),
    ],
    origin: 'From Sanskrit "guru", literally meaning weighty, grave, or venerable.',
    etymology:
        'Cognate with Latin "gravis" (heavy, weighty) and Greek "barus". A guru is one who possesses spiritual and intellectual "weight", capable of dispelling darkness ("gu" = obscurity, "ru" = remover).',
    indianConnections: [
      IndianLanguageConnection(
        language: 'Sanskrit',
        nativeScript: 'गुरु',
        transliteration: 'guru',
        meaning: 'Heavy, venerable; an enlightened guide who dispels ignorance.',
        relationType: IndianRelationType.loanword,
        academicNote:
            'Both a direct loanword and an ancient PIE cognate to Latin "gravis" (grave, heavy). In Indic tradition, the guru-śiṣya paramparā represents the unbroken lineage of pedagogical transmission.',
        isVerified: true,
      ),
    ],
    editorialInsight:
        'While modern corporate lexicon has secularized "guru" to signify an expert, its classical resonance remains rooted in reverence, wisdom, and moral gravity.',
    isCurated: true,
  ),

  const WordEntry(
    word: 'bungalow',
    phonetic: '/ˈbʌŋ.ɡə.loʊ/',
    meanings: [
      WordMeaning(
        partOfSpeech: 'noun',
        definitions: [
          DefinitionItem(
            definition:
                'A low-built house, typically with a single story or an upper story set in a sloping roof, often surrounded by wide verandas.',
            example:
                'They retired to a quiet, shaded bungalow nestled on the slopes of the Nilgiri hills.',
            synonyms: ['cottage', 'lodge', 'cabin', 'villa'],
          ),
        ],
      ),
    ],
    origin: 'Late 17th century: from Hindi baṅglā.',
    etymology:
        'From Hindi "baṅglā" meaning "belonging to Bengal". The architectural form originated as the traditional low-thatched, airy cottage typical of the rural Bengal delta, adapted with wide verandas for hot tropical climates.',
    indianConnections: [
      IndianLanguageConnection(
        language: 'Hindi / Bengali',
        nativeScript: 'बंगला / বাংলা',
        transliteration: 'baṅglā',
        meaning: 'Of or belonging to Bengal; a cottage in the Bengali style.',
        relationType: IndianRelationType.loanword,
        academicNote:
            'Adopted into global English during British maritime trade in eastern India and subsequently evolved into an international architectural genre from California to Queensland.',
        isVerified: true,
      ),
    ],
    editorialInsight:
        'A quintessential indigenous architectural concept that circumnavigated the globe to become an emblem of domestic leisure worldwide.',
    isCurated: true,
  ),

  const WordEntry(
    word: 'jungle',
    phonetic: '/ˈdʒʌŋ.ɡəl/',
    meanings: [
      WordMeaning(
        partOfSpeech: 'noun',
        definitions: [
          DefinitionItem(
            definition:
                'An area of land overgrown with dense forest, tangled vegetation, and rich biodiversity; metaphorically, an unruly or fiercely competitive environment.',
            example:
                'Deep within the forest canopy, the sounds of the living jungle echoed at twilight.',
            synonyms: ['rainforest', 'wilderness', 'tangle', 'undergrowth'],
            antonyms: ['clearing', 'desert', 'tundra'],
          ),
        ],
      ),
    ],
    origin: 'Late 18th century: via Hindi jaṅgal from Sanskrit jaṅgala.',
    etymology:
        'Fascinatingly, the ancient Sanskrit "jaṅgala" originally referred to arid, wasteland, or dry scrub terrain. Through medieval vernacular Hindi usage, it shifted to denote uncultivated, wild, overgrown bushland and dense woodland.',
    indianConnections: [
      IndianLanguageConnection(
        language: 'Sanskrit / Hindi',
        nativeScript: 'जङ्गल / जंगल',
        transliteration: 'jaṅgala / jaṅgal',
        meaning: 'Wild land; arid waste (Sanskrit) -> uncultivated forest (Hindi).',
        relationType: IndianRelationType.loanword,
        academicNote:
            'A classic case of semantic inversion: in Vedic texts jaṅgala meant dry open land, whereas in modern global English it signifies lush, dense, damp tropical rain forest.',
        isVerified: true,
      ),
    ],
    editorialInsight:
        'Few words illustrate semantic evolution more dramatically than "jungle" — travelling from dry Vedic plains to lush tropical canopies.',
    isCurated: true,
  ),

  const WordEntry(
    word: 'bandana',
    phonetic: '/bænˈdæn.ə/',
    meanings: [
      WordMeaning(
        partOfSpeech: 'noun',
        definitions: [
          DefinitionItem(
            definition:
                'A large triangular or square piece of printed cloth, typically brightly colored and tied around the head or neck.',
            example: 'He wore a rust-colored bandana to keep the desert dust at bay.',
            synonyms: ['kerchief', 'scarf', 'headband', 'bandeau'],
          ),
        ],
      ),
    ],
    origin: 'Mid-18th century: via Portuguese from Hindi bāndhnā "to tie".',
    etymology:
        'Originates from the Hindi verb "bāndhnā" (बाँधना), referring to the ancient tie-dye technique of Rajasthan and Gujarat known as Bandhani. Adopted into maritime global trade as colorful spotted neckerchiefs.',
    indianConnections: [
      IndianLanguageConnection(
        language: 'Hindi / Gujarati',
        nativeScript: 'बाँधना / બંધણી',
        transliteration: 'bāndhnā / bāndhaṇī',
        meaning: 'To tie, bind; the traditional resist tie-dye textile process.',
        relationType: IndianRelationType.loanword,
        academicNote:
            'Direct loanword from the Indian textile trade. Bandhani fabrics date back to the Indus Valley Civilization and Ajanta wall murals.',
        isVerified: true,
      ),
    ],
    editorialInsight:
        'A global fashion staple born from the ancient tie-dye vats of western India.',
    isCurated: true,
  ),

  const WordEntry(
    word: 'cheetah',
    phonetic: '/ˈtʃiː.tə/',
    meanings: [
      WordMeaning(
        partOfSpeech: 'noun',
        definitions: [
          DefinitionItem(
            definition:
                'A large, slender feline of Africa and formerly India, noted as the fastest terrestrial mammal.',
            example: 'The cheetah sprinted across the savanna with breathtaking velocity.',
            synonyms: ['hunting leopard'],
          ),
        ],
      ),
    ],
    origin: 'Late 18th century: from Hindi cītā, from Sanskrit citraka "spotted one".',
    etymology:
        'Derived from the Sanskrit "citra" (चित्र: variegated, spotted, manifold) + suffix "-ka". In ancient India, cheetahs were tamed by royal houses for coursing antelope.',
    indianConnections: [
      IndianLanguageConnection(
        language: 'Sanskrit / Hindi',
        nativeScript: 'चित्रक / चीता',
        transliteration: 'citraka / cītā',
        meaning: 'The spotted or variegated one.',
        relationType: IndianRelationType.loanword,
        academicNote:
            'Direct loanword through Hindi. Mentions of hunting cheetahs appear in classical Sanskrit poetics and medieval Mughal chronicles.',
        isVerified: true,
      ),
    ],
    editorialInsight:
        'From Sanskrit poetics of color and pattern ("citra") to the fastest creature on earth.',
    isCurated: true,
  ),

  const WordEntry(
    word: 'dental',
    phonetic: '/ˈdɛn.təl/',
    meanings: [
      WordMeaning(
        partOfSpeech: 'adjective',
        definitions: [
          DefinitionItem(
            definition:
                'Relating to the teeth or dentistry; in phonetics, a consonant articulated with the tongue against the upper teeth.',
            example: 'Sanskrit and Italian preserve crisp dental consonants.',
            synonyms: ['odontic'],
          ),
        ],
      ),
    ],
    origin: 'Late 16th century: from Medieval Latin dentalis, from dens ("tooth").',
    etymology:
        'Inherited from Proto-Indo-European *h₁dónts (tooth). Directly shares prehistoric ancestor with Sanskrit "danta" (दन्त), Greek "odont-", and Germanic "tooth".',
    indianConnections: [
      IndianLanguageConnection(
        language: 'Sanskrit',
        nativeScript: 'दन्त',
        transliteration: 'danta',
        meaning: 'Tooth; also refers to the dental varga (ta, tha, da, dha, na) in Sanskrit phonology.',
        relationType: IndianRelationType.cognate,
        academicNote:
            'A pristine PIE cognate (*h₁dónts). English "tooth" and Latin "dens/dental" share common genetic ancestry with Sanskrit "danta".',
        isVerified: true,
      ),
    ],
    editorialInsight:
        'A profound phonetic cognate uniting anatomical terms across Indo-European languages.',
    isCurated: true,
  ),

  // --- PROTO-INDO-EUROPEAN (PIE) COGNATES ---
  const WordEntry(
    word: 'brother',
    phonetic: '/ˈbrʌð.ər/',
    meanings: [
      WordMeaning(
        partOfSpeech: 'noun',
        definitions: [
          DefinitionItem(
            definition:
                'A male person in relation to other offspring of the same parents; a comrade or fellow member bound by shared purpose or blood.',
            example:
                'The two comrades worked together as brothers in their pursuit of scientific discovery.',
            synonyms: ['sibling', 'kinsman', 'compatriot', 'comrade'],
          ),
        ],
      ),
    ],
    origin: 'Old English brōthor, from Proto-Germanic *brōþēr.',
    etymology:
        'Inherited from Proto-Indo-European *bʰréh₂tēr. Demonstrates the sound correspondences of Grimm\'s Law, directly sharing a prehistoric parentage with Sanskrit bhrātṛ, Greek phrātēr, and Latin frater.',
    indianConnections: [
      IndianLanguageConnection(
        language: 'Sanskrit',
        nativeScript: 'भ्रातृ',
        transliteration: 'bhrātṛ',
        meaning: 'Brother; an intimate male kin or fraternal ally.',
        relationType: IndianRelationType.cognate,
        academicNote:
            'NOT a borrowing. English "brother" and Sanskrit "bhrātṛ" are genetic cousins descended independently from the Proto-Indo-European root *bʰréh₂tēr over 5,000 years.',
        isVerified: true,
      ),
    ],
    editorialInsight:
        'A living testament to the shared linguistic heritage uniting Indo-European languages across millennia and continents.',
    isCurated: true,
  ),

  const WordEntry(
    word: 'mother',
    phonetic: '/ˈmʌð.ər/',
    meanings: [
      WordMeaning(
        partOfSpeech: 'noun',
        definitions: [
          DefinitionItem(
            definition:
                'A female parent; an originating source, wellspring, or nurturing protector.',
            example:
                'The earth was revered by ancient poets as the gentle mother of all living things.',
            synonyms: ['maternal parent', 'progenitor', 'creator', 'source'],
          ),
        ],
      ),
    ],
    origin: 'Old English mōdor, from Proto-Germanic *mōdēr.',
    etymology:
        'Descended from Proto-Indo-European *méh₂tēr. Preserved with near-universal phonetic clarity across the entire Indo-European family, including Sanskrit mātṛ, Greek mētēr, Latin mater, and Old Irish máthair.',
    indianConnections: [
      IndianLanguageConnection(
        language: 'Sanskrit',
        nativeScript: 'मातृ',
        transliteration: 'mātṛ',
        meaning: 'Mother; the fundamental nurturing and life-giving principle.',
        relationType: IndianRelationType.cognate,
        academicNote:
            'A pristine PIE cognate (*méh₂tēr). Notice the phonetic fidelity between Sanskrit "mātṛ", Hindi "mātā", and English "mother".',
        isVerified: true,
      ),
    ],
    editorialInsight:
        'One of humanity\'s most ancient surviving vocal patterns, spoken almost identically across ancient Punjab, classical Athens, and modern London.',
    isCurated: true,
  ),

  const WordEntry(
    word: 'name',
    phonetic: '/neɪm/',
    meanings: [
      WordMeaning(
        partOfSpeech: 'noun',
        definitions: [
          DefinitionItem(
            definition:
                'A word or set of words by which a person, animal, place, or thing is known, addressed, or classified; a reputation or renown.',
            example:
                'He earned a distinguished name throughout the academy for his meticulous translations.',
            synonyms: ['title', 'appellation', 'designation', 'sobriquet', 'repute'],
          ),
        ],
      ),
    ],
    origin: 'Old English nama, from Proto-Germanic *namô.',
    etymology:
        'Rooted in Proto-Indo-European *h₁nómn̥. This ancient root evolved into Sanskrit "nāma", Latin "nomen", Greek "onoma", and Old Church Slavonic "imę".',
    indianConnections: [
      IndianLanguageConnection(
        language: 'Sanskrit / Hindi',
        nativeScript: 'नाम',
        transliteration: 'nāma / nām',
        meaning: 'Name, designation, essence, personal distinction.',
        relationType: IndianRelationType.cognate,
        academicNote:
            'Genuine PIE cognate (*h₁nómn̥). In Sanskrit poetics, "nāma-rūpa" represents the dual manifestation of name and form through which the phenomenal universe is perceived.',
        isVerified: true,
      ),
    ],
    editorialInsight:
        'Both ancient rishis and early Germanic bards uttered almost the exact same syllable to signify identity.',
    isCurated: true,
  ),

  // --- LITERARY & POETIC VOCABULARY ---
  const WordEntry(
    word: 'petrichor',
    phonetic: '/ˈpɛt.rɪ.kɔːr/',
    meanings: [
      WordMeaning(
        partOfSpeech: 'noun',
        definitions: [
          DefinitionItem(
            definition:
                'A pleasant, distinctive earthy smell that frequently accompanies the first rain after a long period of warm, dry weather.',
            example:
                'As the first monsoon drops struck the parched red clay, the courtyard filled with intoxicating petrichor.',
            synonyms: ['earth-fragrance', 'rain-scent'],
          ),
        ],
      ),
    ],
    origin:
        'Coined in 1964 by Australian researchers Isabel Joy Bear and Richard G. Thomas in the journal Nature.',
    etymology:
        'Formed from Greek "petra" (stone or rock) + "īchōr" (the ethereal fluid that flows in the veins of the gods in Greek mythology).',
    indianConnections: [
      IndianLanguageConnection(
        language: 'Hindi / Sanskrit parallel',
        nativeScript: 'सौंधी खुशबू / सौगन्ध्य',
        transliteration: 'saundhī khushbū / saugandhya',
        meaning: 'The gentle, fragrant aroma of parched earth kissed by the initial shower.',
        relationType: IndianRelationType.conceptualParallel,
        academicNote:
            'In Kannauj, Uttar Pradesh, traditional attar artisans have distilled this exact fragrance into pottery-infused perfume known as "Mitti Attar" for centuries before the word petrichor was coined.',
        isVerified: true,
      ),
    ],
    editorialInsight:
        'While the scientific term is modern Greek in origin, the sensory experience has been celebrated in Indian monsoon literature and Kannauj perfumery for centuries.',
    isCurated: true,
  ),

  const WordEntry(
    word: 'serendipity',
    phonetic: '/ˌsɛr.ənˈdɪp.ɪ.ti/',
    meanings: [
      WordMeaning(
        partOfSpeech: 'noun',
        definitions: [
          DefinitionItem(
            definition:
                'The occurrence and development of events by chance in a happy, fortunate, or beneficent way.',
            example:
                'Finding that rare handwritten Sanskrit manuscript in an obscure bookstall was pure serendipity.',
            synonyms: ['providence', 'fluke', 'good fortune', 'windfall', 'auspiciousness'],
            antonyms: ['misfortune', 'adversity', 'misadventure'],
          ),
        ],
      ),
    ],
    origin: 'Coined in 1754 by the English author Horace Walpole.',
    etymology:
        'Walpole coined the term after reading the Persian fairy tale "The Three Princes of Serendip", whose heroes were "always making discoveries, by accidents and sagacity, of things they were not in quest of". "Serendip" was the Arabic/Persian name for Sri Lanka, itself adapted from Sanskrit "Simhaladvipa" (lion island).',
    indianConnections: [
      IndianLanguageConnection(
        language: 'Sanskrit / Pali origin of place-name',
        nativeScript: 'सिंहलद्वीप',
        transliteration: 'siṃhaladvīpa',
        meaning: 'Island of the Lions (origin of Old Persian Sarandīb -> Serendip).',
        relationType: IndianRelationType.loanword,
        academicNote:
            'A fascinating geographic toponym: Sanskrit "Siṃhaladvīpa" passed through Arabic trade sailors as "Sarandīb", which Horace Walpole turned into English "serendipity".',
        isVerified: true,
      ),
    ],
    editorialInsight:
        'A reminder that chance favors the prepared, observant mind — wrapped in the maritime geography of ancient Indian Ocean voyagers.',
    isCurated: true,
  ),

  const WordEntry(
    word: 'ineffable',
    phonetic: '/ɪnˈɛf.ə.bəl/',
    meanings: [
      WordMeaning(
        partOfSpeech: 'adjective',
        definitions: [
          DefinitionItem(
            definition:
                'Too great, sacred, or intense to be adequately expressed or described in words; inexpressible.',
            example:
                'Gazing into the Himalayan starlight, she felt an ineffable serenity settle over her spirit.',
            synonyms: ['indescribable', 'unutterable', 'transcendent', 'unspoken', 'numinous'],
            antonyms: ['expressible', 'definable', 'articulable'],
          ),
        ],
      ),
    ],
    origin: 'Late Middle English: from Latin ineffabilis (in- "not" + effabilis "speakable").',
    etymology:
        'From Latin "in-" (negative prefix) + "effari" (to speak out, utter, from ex- + fari to speak). Relates to concepts that transcend verbal categorization.',
    indianConnections: [
      IndianLanguageConnection(
        language: 'Sanskrit conceptual parallel',
        nativeScript: 'अनिर्वचनीय',
        transliteration: 'anirvacanīya',
        meaning: 'Beyond articulation; that which cannot be predicated through language alone.',
        relationType: IndianRelationType.conceptualParallel,
        academicNote:
            'In Advaita Vedānta epistemology, "anirvacanīya" denotes reality that transcends empirical verbal categories — precisely the philosophical counterpart to English "ineffable".',
        isVerified: true,
      ),
    ],
    editorialInsight:
        'When speech exhausts its instruments, language invents words like "ineffable" to acknowledge its own noble limitations.',
    isCurated: true,
  ),

  const WordEntry(
    word: 'melancholy',
    phonetic: '/ˈmɛl.ənˌkɒl.i/',
    meanings: [
      WordMeaning(
        partOfSpeech: 'noun',
        definitions: [
          DefinitionItem(
            definition:
                'A tender, reflective feeling of pensive sadness, typically with no obvious or immediate cause.',
            example:
                'An exquisite melancholy runs through the verses of John Keats and Mir Taqi Mir.',
            synonyms: ['pensiveness', 'wistfulness', 'sorrow', 'despondency', 'gloom'],
            antonyms: ['jubilance', 'euphoria', 'cheer'],
          ),
        ],
      ),
      WordMeaning(
        partOfSpeech: 'adjective',
        definitions: [
          DefinitionItem(
            definition: 'Having a feeling of melancholy; sad and pensive.',
            example: 'The cello produced a deeply melancholy refrain.',
          ),
        ],
      ),
    ],
    origin: 'From Greek melankholia, from melas ("black") + khole ("bile").',
    etymology:
        'Stemming from the ancient humorism theory of medicine, where black bile was believed to induce contemplative sadness. Unlike clinical depression, literary melancholy often carries an aesthetic sweetness.',
    indianConnections: [
      IndianLanguageConnection(
        language: 'Sanskrit aesthetic parallel',
        nativeScript: 'करुण रस',
        transliteration: 'karuṇa rasa',
        meaning: 'The aesthetic mood of pathos, grief, and poignant tenderness.',
        relationType: IndianRelationType.conceptualParallel,
        academicNote:
            'In Bharata Muni\'s Nāṭyaśāstra, Karuṇa Rasa captures the profound emotional catharsis of poetic sorrow, mirroring the literary appreciation of melancholy in romantic poetry.',
        isVerified: true,
      ),
    ],
    editorialInsight:
        'Distinguished from mere sadness: melancholy is reflective and tender, often serving as the quiet forge of poetry and deep introspection.',
    isCurated: true,
  ),

  const WordEntry(
    word: 'solitude',
    phonetic: '/ˈsɒl.ɪ.tjuːd/',
    meanings: [
      WordMeaning(
        partOfSpeech: 'noun',
        definitions: [
          DefinitionItem(
            definition:
                'The state or situation of being alone, especially when viewed as pleasant, contemplative, and restorative.',
            example:
                'In the quiet solitude of his study, the author found the clarity required to finish his opus.',
            synonyms: ['seclusion', 'retirement', 'peace', 'tranquility', 'aloneness'],
            antonyms: ['loneliness', 'companionability', 'crowd'],
          ),
        ],
      ),
    ],
    origin: 'Middle English: via Old French from Latin solitudo, from solus "alone".',
    etymology:
        'From Latin "solus" (lone, sole). As May Sarton famously wrote: "Loneliness is the poverty of self; solitude is the richness of self."',
    indianConnections: [
      IndianLanguageConnection(
        language: 'Sanskrit conceptual parallel',
        nativeScript: 'एकान्त',
        transliteration: 'ekānta',
        meaning: 'A solitary place; quiet seclusion devoted to inner contemplation.',
        relationType: IndianRelationType.conceptualParallel,
        academicNote:
            'Sanskrit "ekāntatā" (एकान्तता) denotes fruitful, sacred seclusion that nurtures dhyāna (meditation), distinguishing inward peacefulness from painful loneliness.',
        isVerified: true,
      ),
    ],
    editorialInsight:
        'A crucial distinction: loneliness is longing for others; solitude is being companion enough for oneself.',
    isCurated: true,
  ),

  const WordEntry(
    word: 'equanimity',
    phonetic: '/ˌɛk.wəˈnɪm.ɪ.ti/',
    meanings: [
      WordMeaning(
        partOfSpeech: 'noun',
        definitions: [
          DefinitionItem(
            definition:
                'Mental calmness, composure, and evenness of temper, especially in difficult, demanding, or stressful situations.',
            example:
                'He accepted both public praise and fierce criticism with identical equanimity.',
            synonyms: ['composure', 'imperturbability', 'serenity', 'poise', 'equilibrium'],
            antonyms: ['anxiety', 'agitation', 'hysteria', 'discomposure'],
          ),
        ],
      ),
    ],
    origin: 'Early 17th century: from Latin aequanimitas, from aequus ("equal") + animus ("mind").',
    etymology:
        'From Latin "aequus" (level, even, balanced) + "animus" (spirit, mind). Literally: possessing an even, unshakable spirit.',
    indianConnections: [
      IndianLanguageConnection(
        language: 'Sanskrit philosophical equivalent',
        nativeScript: 'समत्वम्',
        transliteration: 'samatvam',
        meaning: 'Equanimity; unwavering balance in joy and sorrow, gain and loss.',
        relationType: IndianRelationType.conceptualParallel,
        academicNote:
            'Bhagavad Gita 2.48 establishes: "samatvaṁ yoga ucyate" (Equanimity of mind is called Yoga). A profound conceptual bridge to Western stoic ataraxia and equanimity.',
        isVerified: true,
      ),
    ],
    editorialInsight:
        'Not indifference or apathy, but the masterly capacity to remain centered amidst the storm.',
    isCurated: true,
  ),

  const WordEntry(
    word: 'eloquence',
    phonetic: '/ˈɛl.ə.kwəns/',
    meanings: [
      WordMeaning(
        partOfSpeech: 'noun',
        definitions: [
          DefinitionItem(
            definition:
                'Fluent, graceful, or persuasive speaking or writing; the art of expressing thought with clarity and moving force.',
            example:
                'The statesman spoke with an eloquence that stirred the conscience of the assembly.',
            synonyms: ['oratory', 'fluency', 'articulacy', 'expressiveness', 'persuasiveness'],
            antonyms: ['inarticulacy', 'haltingness', 'stammering'],
          ),
        ],
      ),
    ],
    origin: 'Middle English: via Old French from Latin eloquentia, from eloqui "speak out".',
    etymology:
        'From Latin "e-" (out) + "loqui" (to speak). Relates directly to speech that flows outwards with luminous transparency.',
    indianConnections: [
      IndianLanguageConnection(
        language: 'Sanskrit conceptual equivalent',
        nativeScript: 'वाग्मिता',
        transliteration: 'vāgmitā',
        meaning: 'Excellence in speech; the divine grace of articulate, persuasive voice.',
        relationType: IndianRelationType.conceptualParallel,
        academicNote:
            'Derived from the root "vāc" (speech/voice, cognate with Latin "vox"). In classical Indian rhetoric, vāgmitā requires both moral truth (satya) and agreeable beauty (priya).',
        isVerified: true,
      ),
    ],
    editorialInsight:
        'True eloquence is not ornamentation; it is the courage to speak with utter lucidity.',
    isCurated: true,
  ),
];

/// Helper to find a curated word case-insensitively
WordEntry? findCuratedWord(String query) {
  final clean = query.trim().toLowerCase();
  for (final entry in curatedWordEntries) {
    if (entry.word.toLowerCase() == clean) {
      return entry;
    }
  }
  return null;
}

/// Helper to get suggestions from curated list
List<WordEntry> searchCuratedWords(String query) {
  if (query.trim().isEmpty) return [];
  final clean = query.trim().toLowerCase();
  return curatedWordEntries.where((e) {
    return e.word.toLowerCase().startsWith(clean) || e.word.toLowerCase().contains(clean);
  }).toList();
}
