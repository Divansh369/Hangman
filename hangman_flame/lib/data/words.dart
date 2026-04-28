import 'dart:math';

/// Theme-based structure: complete ALL subcategories to finish a challenge
/// Each subcategory has 2-4 words with interconnected hints like a crossword

final Map<String, Map<String, List<String>>> themes = {
  'Literary Shadows': {
    'Gothic Protagonists': ['heathcliff', 'dorian', 'jekyll', 'frankenstein'],
    'Forbidden Knowledge': ['necronomicon', 'prometheus', 'pandora', 'faust'],
    'Twisted Morality': ['macbeth', 'raskolnikov', 'kurtz', 'iago'],
  },
  'Quantum Paradoxes': {
    'Physics Pioneers': ['heisenberg', 'schrodinger', 'dirac', 'planck'],
    'Theoretical Concepts': ['entanglement', 'superposition', 'uncertainty', 'wavefunction'],
    'Particle Realms': ['electron', 'neutrino', 'photon', 'muon'],
  },
  'Architectural Legacy': {
    'Structural Marvels': ['aqueduct', 'cantilever', 'geodesic', 'buttress'],
    'Historic Monuments': ['colosseum', 'parthenon', 'machu', 'angkor'],
    'Modern Masterpieces': ['guggenheim', 'fallingwater', 'sagrada', 'burjkhalifa'],
  },
  'Cryptic Cipher': {
    'Ancient Scripts': ['hieroglyph', 'cuneiform', 'rune', 'aramaic'],
    'Code Breaking': ['enigma', 'caesar', 'substitution', 'vigenere'],
    'Secret Meanings': ['steganography', 'cryptogram', 'cipher', 'decryption'],
  },
  'Existential Inquiry': {
    'Philosophical Riddles': ['absurdism', 'nihilism', 'stoicism', 'epicureanism'],
    'Mind Wanderers': ['kierkegaard', 'sartre', 'camus', 'wittgenstein'],
    'Ontological Questions': ['being', 'essence', 'phenomenology', 'metaphysics'],
  },
  'Celestial Navigation': {
    'Deep Space Objects': ['quasar', 'pulsar', 'nebula', 'blackhole'],
    'Cosmic Events': ['supernova', 'eclipse', 'conjunction', 'aurora'],
    'Orbital Mechanics': ['apogee', 'perigee', 'retrograde', 'parallax'],
  },
  'Synthetic Biology': {
    'Molecular Processes': ['mitosis', 'meiosis', 'photosynthesis', 'fermentation'],
    'Genetic Elements': ['chromosome', 'allele', 'codon', 'telomere'],
    'Cellular Structures': ['ribosome', 'mitochondria', 'lysosome', 'golgi'],
  },
  'Musical Complexity': {
    'Harmonic Structures': ['fugue', 'sonata', 'cantata', 'toccata'],
    'Compositional Geniuses': ['bach', 'mozart', 'beethoven', 'shostakovich'],
    'Experimental Sounds': ['dissonance', 'atonal', 'polyrhythm', 'microtonal'],
  },
  'Archaeological Enigma': {
    'Lost Civilizations': ['babylon', 'persepolis', 'pompeii', 'timbuktu'],
    'Artifact Mysteries': ['rosettastone', 'antikythera', 'nazca', 'stonehenge'],
    'Excavation Sites': ['troy', 'ur', 'carthage', 'petra'],
  },
  'Dimensional Abstractions': {
    'Mathematical Spaces': ['hyperbolic', 'euclidean', 'riemannian', 'minkowski'],
    'Higher Concepts': ['fractal', 'manifold', 'torus', 'mobius'],
    'Paradoxical Geometry': ['klein', 'tesseract', 'calabi', 'holonomy'],
  },
  'Ocean Wonders': {
    'Sea Creatures': ['dolphin', 'starfish', 'octopus', 'seahorse'],
    'Marine Habitats': ['coral', 'kelp', 'trench', 'reef'],
    'Ocean Phenomena': ['tide', 'current', 'wave', 'undertow'],
  },
  'Desert Mysteries': {
    'Desert Animals': ['camel', 'scorpion', 'meerkat', 'jackal'],
    'Desert Features': ['dune', 'oasis', 'mirage', 'wadi'],
    'Desert Survival': ['cactus', 'sandstorm', 'drought', 'nomad'],
  },
  'Mountain Peaks': {
    'Famous Mountains': ['everest', 'kilimanjaro', 'denali', 'fuji'],
    'Mountain Features': ['glacier', 'summit', 'ridge', 'gorge'],
    'Mountain Life': ['avalanche', 'altitude', 'ascent', 'piedmont'],
  },
  'Tropical Paradise': {
    'Tropical Fruits': ['mango', 'pineapple', 'coconut', 'papaya'],
    'Tropical Trees': ['palm', 'bamboo', 'teak', 'mahogany'],
    'Tropical Weather': ['monsoon', 'humidity', 'rainforest', 'typhoon'],
  },
  'Night Sky Magic': {
    'Constellations': ['orion', 'ursa', 'perseus', 'draco'],
    'Celestial Events': ['meteor', 'comet', 'eclipse', 'solstice'],
    'Night Observers': ['astronomer', 'telescope', 'observatory', 'planet'],
  },
};

/// Sophisticated interconnected hints system (crossword-like relationships)
final Map<String, Map<String, String>> hintsByTheme = {
  'Literary Shadows': {
    'heathcliff': 'Orphan on Yorkshire moors; name foreshadows violent nature (Brontë)',
    'dorian': 'His portrait ages while he stays young; vanity\'s price (Wilde)',
    'jekyll': 'Chemical experiment creates monstrous alter-ego; duality personified',
    'frankenstein': 'Scientist who loved ambition more than ethics; monster\'s creator',
    'necronomicon': 'Cthulhu\'s grimoire; forbidden text in Lovecraft\'s cosmic horror',
    'prometheus': 'Stole fire from gods; eternal punishment for mankind\'s benefit',
    'pandora': 'Box released all evils; hope trapped inside was cruel mercy',
    'faust': 'Sold soul to Mephistopheles; knowledge hunger leads to damnation',
    'macbeth': 'Thane corrupted by prophecy; witches\' visions destroy his kingdom',
    'raskolnikov': 'Murderer justified by philosophy; conscience eats him from inside',
    'kurtz': 'Ivory trader in Congo; colonialism\'s hollow godhood (Heart of Darkness)',
    'iago': 'Most honest villain; manipulates through reputation\'s illusion',
  },
  'Quantum Paradoxes': {
    'heisenberg': 'Cannot measure both position and momentum; uncertainty principle bearer',
    'schrodinger': 'Cat both alive and dead until observed; superposition\'s infamous thought experiment',
    'dirac': 'Predicted antimatter; mathematical elegance revealed universe\'s hidden symmetry',
    'planck': 'Quanta\'s discoverer; Planck constant links energy and frequency',
    'entanglement': 'Two particles share state instantaneously; Einstein called it spooky action',
    'superposition': 'Quantum state exists in all possibilities simultaneously before collapse',
    'uncertainty': 'Fundamental limit; knowing speed means losing position information',
    'wavefunction': 'Schrödinger\'s mathematical description; probability wave that collapses',
    'electron': 'Negative charge; behaves as both particle and wave',
    'neutrino': 'Ghost particle barely interacts; billions pass through you each second',
    'photon': 'Light quantum; massless but carries momentum and energy',
    'muon': 'Heavy electron\'s cousin; exists only microseconds before decay',
  },
  'Architectural Legacy': {
    'aqueduct': 'Roman engineering marvel; gravity-fed water across vast distances',
    'cantilever': 'Beam fixed at one end; projecting structure defies apparent support',
    'geodesic': 'Buckminster Fuller\'s dome; triangular network maximizes strength-to-weight',
    'buttress': 'Medieval support structure; distributes outward thrust of high walls',
    'colosseum': 'Roman amphitheater for gladiators; sand absorbed blood and carnage',
    'parthenon': 'Doric temple to Athena; optical illusions prevent visual distortion',
    'machu': 'Inca citadel in Peru\'s clouds; built without mortar yet endures',
    'angkor': 'Khmer temple complex; divine cosmology mapped in stone and reflection',
    'guggenheim': 'Spiraling museum designed by Wright; form challenges function',
    'fallingwater': 'Cantilevered house over waterfall; nature and architecture merge',
    'sagrada': 'Gaudí\'s unfinished basilica; organic forms mimicking living structure',
    'burjkhalifa': 'World\'s tallest building; spiral geometry inspired by spiral minaret',
  },
  'Cryptic Cipher': {
    'hieroglyph': 'Egyptian script blending sound and meaning; Rosetta Stone\'s key',
    'cuneiform': 'Wedge-shaped marks on clay; Mesopotamia\'s earliest written language',
    'rune': 'Ancient Germanic alphabet; angular design suited carving on stone',
    'aramaic': 'Semitic language Jesus spoke; still used in Amidah prayer',
    'enigma': 'Nazi encryption machine; cracked at Bletchley Park; won wars',
    'caesar': 'Shift cipher; each letter rotated by fixed number (ancient and weak)',
    'substitution': 'Replace each letter with another; frequency analysis breaks it',
    'vigenere': 'Polyalphabetic cipher; key repeats creating multiple substitutions',
    'steganography': 'Hiding messages within benign text; security through obscurity',
    'cryptogram': 'Encrypted message needing key; puzzle hiding intelligence',
    'cipher': 'Algorithm transforming plain into secret; mathematics meets espionage',
    'decryption': 'Process of reversing encryption; breaking code without key needs genius',
  },
  'Existential Inquiry': {
    'absurdism': 'Life\'s meaninglessness is primary fact; fight anyway (Camus)',
    'nihilism': 'No objective truth, meaning, or morality; only perspective remains',
    'stoicism': 'Virtue is only good; control only what you can control',
    'epicureanism': 'Pleasure is highest good; moderation prevents suffering (misunderstood)',
    'kierkegaard': 'Danish existentialist; anguish precedes free choice and authenticity',
    'sartre': 'Existence precedes essence; radical freedom creates anguish',
    'camus': 'Absurdist philosopher; embrace meaninglessness with passionate rebellion',
    'wittgenstein': 'Logical positivist; language\'s limits define thought\'s boundaries',
    'being': 'Ontological foundation; Heidegger\'s central metaphysical concern',
    'essence': 'Fixed nature predefined; opposed by existentialist freedom doctrine',
    'phenomenology': 'Study of consciousness and experience; appearance is what matters',
    'metaphysics': 'Beyond physical; explores reality\'s ultimate nature and structure',
  },
  'Celestial Navigation': {
    'quasar': 'Quasi-stellar object; distant active galactic nuclei blazing energy',
    'pulsar': 'Rotating neutron star; lighthouse pulses at precise intervals',
    'nebula': 'Interstellar cloud; nursery where stars ignite from gas and dust',
    'blackhole': 'Spacetime singularity; escape velocity exceeds light\'s speed infinitely',
    'supernova': 'Stellar explosion; neutron star formation ends giant\'s life violently',
    'eclipse': 'Shadow\'s dance; one celestial body blocks another from view',
    'conjunction': 'Planets align in same direction; close approach in sky',
    'aurora': 'Polar lights from solar wind; magnetic field\'s visible interaction',
    'apogee': 'Highest orbital point; farthest from central body at peak',
    'perigee': 'Lowest orbital point; closest approach maximizes gravitational effect',
    'retrograde': 'Apparent backward motion; perspective makes planets seem reversed',
    'parallax': 'Position shift from observer movement; measuring distance to stars',
  },
  'Synthetic Biology': {
    'mitosis': 'Cell division preserving chromosome number; produces identical daughters',
    'meiosis': 'Reduction division halving chromosomes; creates gametes for reproduction',
    'photosynthesis': 'Light to chemical energy; plants convert sunlight to glucose bonds',
    'fermentation': 'Anaerobic metabolism; yeast makes alcohol without oxygen\'s presence',
    'chromosome': 'DNA package; contains genes arranged on condensed protein scaffolds',
    'allele': 'Gene variant at same locus; different versions create traits',
    'codon': 'Three-base sequence; specifies which amino acid protein should incorporate',
    'telomere': 'DNA sequence protecting chromosome end; shortens with each division',
    'ribosome': 'Protein synthesis factory; reads mRNA creating amino acid chains',
    'mitochondria': 'Cellular power plant; ATP production fuels all biological work',
    'lysosome': 'Digestive compartment; enzymes break down waste and dead material',
    'golgi': 'Trafficking hub; packages proteins into vesicles for secretion export',
  },
  'Musical Complexity': {
    'fugue': 'Counterpoint technique; multiple voices chase same theme through variations',
    'sonata': 'Multi-movement structure; exposition, development, recapitulation form',
    'cantata': 'Vocal piece with accompaniment; narrative through musical storytelling',
    'toccata': 'Keyboard virtuosity showcase; technical display of rapid figuration',
    'bach': 'Polymath of counterpoint; mathematical precision in musical architecture',
    'mozart': 'Child prodigy; effortless melodies hide structural complexity underneath',
    'beethoven': 'Bridge to Romantic era; deafness didn\'t silence his inner voice',
    'shostakovich': 'Soviet survivor; music encoded political protest and personal anguish',
    'dissonance': 'Clashing tones; tension demanding resolution into consonance\'s stability',
    'atonal': 'Twelve-tone system rejects hierarchy; equal chromatic pitch weighting',
    'polyrhythm': 'Multiple concurrent rhythms; different meters overlapping simultaneously',
    'microtonal': 'Pitches beyond Western scale; quarter-tones expand harmonic possibilities',
  },
  'Archaeological Enigma': {
    'babylon': 'Hanging gardens myth; Nebuchadnezzar\'s Mesopotamian power center lost',
    'persepolis': 'Persian ceremonial capital; Alexander burned it ending Achaemenid empire',
    'pompeii': 'Vesuvius froze moments; ash preserved vice and virtue together',
    'timbuktu': 'Mali\'s golden city; Islamic manuscripts hidden for centuries then found',
    'rosettastone': 'Rosetta unlocked hieroglyphs; Egyptian-Greek bilingual mystery decoder',
    'antikythera': 'Ancient computer; clockwork from shipwreck preceded mechanical calendars',
    'nazca': 'Geoglyphs visible only from sky; purpose remains beautifully mysterious',
    'stonehenge': 'Megaliths aligned astronomically; Neolithic engineering\'s enduring puzzle',
    'troy': 'Schliemann\'s excavation; legendary city vindicated by archaeology\'s spade',
    'ur': 'Sumerian birthplace; ziggurat towers above Mesopotamian origin story',
    'carthage': 'Rome\'s rival civilization; destroyed then buried beneath history',
    'petra': 'Rose-red city carved into sandstone cliffs; Nabataean marvel hidden remotely',
  },
  'Dimensional Abstractions': {
    'hyperbolic': 'Negative curvature space; parallel postulate fails creating more parallels',
    'euclidean': 'Flat geometry; triangles sum 180 degrees establishing parallel uniqueness',
    'riemannian': 'Positive curvature surface; triangles sum exceeding 180 on spheres',
    'minkowski': 'Spacetime geometry; Einstein\'s mathematical stage for relativity theater',
    'fractal': 'Self-similar pattern; Mandelbrot set reveals infinite complexity\'s beauty',
    'manifold': 'Higher-dimensional surface; locally flat yet globally curved stranger',
    'torus': 'Donut surface; topologically distinct though embedded in 3D space',
    'mobius': 'Single-sided surface; strip twisted creates impossible topology\'s paradox',
    'klein': 'Non-orientable surface; bottle without inside or outside boundary division',
    'tesseract': 'Four-dimensional hypercube; perspective projection baffles 3D observers',
    'calabi': 'Complex geometry manifold; string theory\'s hidden dimension refuge',
    'holonomy': 'Parallel transport around loop; curvature revealed through path dependence',
  },
  'Ocean Wonders': {
    'dolphin': 'Intelligent marine mammal known for playfulness and echolocation abilities',
    'starfish': 'Five-armed sea creature that can regenerate lost limbs over time',
    'octopus': 'Eight-armed mollusk master of camouflage and intelligence',
    'seahorse': 'Tiny horse-like fish where males carry eggs in special pouch',
    'coral': 'Living organism that builds colorful underwater reefs with symbiotic algae',
    'kelp': 'Giant seaweed forming underwater forests off rocky coasts',
    'trench': 'Deepest ocean ravines where crushing pressure defines extreme biology',
    'reef': 'Biodiverse underwater ecosystem built by coral and teeming with life',
    'tide': 'Moon\'s gravitational pull causes predictable daily water rise and fall',
    'current': 'Moving ocean river flowing beneath surface with tremendous force',
    'wave': 'Energy traveling across surface; can cross entire ocean undiminished',
    'undertow': 'Dangerous backward surface current pulling swimmers away from shore',
  },
  'Desert Mysteries': {
    'camel': 'Ship of the desert; stores water and fat for long treks',
    'scorpion': 'Venomous arachnid that glows under ultraviolet light',
    'meerkat': 'Small African mammal standing upright to watch for predators',
    'jackal': 'Wild dog-like predator thriving in harsh desert environment',
    'dune': 'Shifting sand mountain shaped by wind\'s relentless force',
    'oasis': 'Life-giving water source surrounded by vast barren wasteland',
    'mirage': 'Optical illusion caused by heat distorting light waves',
    'wadge': 'Dry riverbed that floods during rare desert rainstorms',
    'cactus': 'Plant storing water in fleshy tissues for survival',
    'sandstorm': 'Violent wind carrying walls of sand across the desert',
    'drought': 'Extended period of no rainfall causing water scarcity',
    'nomad': 'Desert dweller constantly moving seeking water and resources',
  },
  'Mountain Peaks': {
    'everest': 'Tallest mountain on Earth; climbers face thin air near summit',
    'kilimanjaro': 'Highest peak in Africa with snow at equatorial latitude',
    'denali': 'Alaska\'s tallest peak previously named McKinley',
    'fuji': 'Japan\'s iconic volcanic mountain sacred in culture',
    'glacier': 'Ancient flowing ice river slowly carving valleys',
    'summit': 'Mountain\'s highest point where climbers plant flags',
    'ridge': 'Narrow mountain crest separating valleys on either side',
    'gorge': 'Deep narrow valley with steep rocky walls',
    'avalanche': 'Massive dangerous snow and rock slides down mountains',
    'altitude': 'Height above sea level affecting oxygen availability',
    'ascent': 'Climb upward toward mountain peak with increasing difficulty',
    'piedmont': 'Hilly region at mountain base transitioning to plains',
  },
  'Tropical Paradise': {
    'mango': 'Sweet tropical fruit called the king of fruits',
    'pineapple': 'Spiky tropical fruit with golden sweet flesh inside',
    'coconut': 'Versatile tropical fruit providing water juice and meat',
    'papaya': 'Orange tropical fruit with black seeds and digestive enzymes',
    'palm': 'Tropical tree with fronds providing shade and coconuts',
    'bamboo': 'Fast-growing plant stronger than steel yet flexible',
    'teak': 'Valuable hardwood from Southeast Asian tropical forests',
    'mahogany': 'Beautiful reddish-brown wood prized for fine furniture',
    'monsoon': 'Seasonal wind bringing heavy rains to tropical regions',
    'humidity': 'High moisture in tropical air making it feel thick',
    'rainforest': 'Dense tropical forest receiving heavy daily rainfall',
    'jungle': 'Thick impenetrable tropical vegetation filled with wildlife',
  },
  'Night Sky Magic': {
    'orion': 'Hunter constellation visible in winter night sky',
    'ursa': 'Bear constellation containing the famous Big Dipper',
    'perseus': 'Hero constellation with variable star Algol blinking',
    'draco': 'Dragon constellation winding through northern sky',
    'meteor': 'Space rock burning bright during atmospheric entry',
    'comet': 'Icy wanderer with spectacular tail when near sun',
    'eclipse': 'Moon blocking sun creating eerie daytime darkness',
    'solstice': 'Day with longest or shortest daylight of the year',
    'astronomer': 'Scientist studying celestial objects and phenomena',
    'telescope': 'Instrument magnifying distant stars and galaxies',
    'observatory': 'Facility equipped with telescopes for sky study',
    'planet': 'Celestial body orbiting star like Earth orbiting sun',
  },
};

/// Legacy simple categories for backward compatibility (fallback for 2-Player/Multiplayer)
final Map<String, List<String>> categories = {
  'Animals': [
    'lion', 'tiger', 'elephant', 'giraffe', 'zebra', 'kangaroo', 'penguin', 'dolphin', 'shark', 'octopus',
    'bear', 'cheetah', 'wolf', 'deer', 'eagle', 'owl', 'rabbit', 'squirrel', 'fox', 'whale'
  ],
  'Fruits': [
    'apple', 'banana', 'orange', 'strawberry', 'pineapple', 'watermelon', 'mango', 'cherry', 'grape', 'kiwi',
    'peach', 'pear', 'blueberry', 'coconut', 'papaya', 'lemon', 'lime', 'raspberry', 'apricot', 'blackberry'
  ],
  'Countries': [
    'france', 'germany', 'brazil', 'canada', 'australia', 'japan', 'india', 'egypt', 'mexico', 'italy',
    'spain', 'thailand', 'norway', 'argentina', 'greece', 'portugal', 'turkey', 'sweden', 'netherlands', 'switzerland'
  ],
  'Programming': [
    'flutter', 'dart', 'python', 'javascript', 'rust', 'kotlin', 'swift', 'java', 'ruby', 'golang',
    'cplusplus', 'csharp', 'php', 'typescript', 'scala', 'perl', 'haskell', 'clojure', 'groovy', 'solidity'
  ],
  'Planets': [
    'mercury', 'venus', 'earth', 'mars', 'jupiter', 'saturn', 'uranus', 'neptune', 'pluto', 'kepler',
    'proxima', 'sirius', 'betelgeuse', 'altair', 'vega', 'deneb', 'arcturus', 'polaris', 'rigel'
  ],
  'Sports': [
    'football', 'basketball', 'cricket', 'tennis', 'baseball', 'hockey', 'volleyball', 'rugby', 'boxing', 'golf',
    'swimming', 'skiing', 'skating', 'badminton', 'archery', 'gymnastics', 'wrestling', 'sumo', 'curling'
  ],
  'Colors': [
    'red', 'blue', 'green', 'yellow', 'brown', 'purple', 'pink', 'black', 'white', 'gray',
    'silver', 'gold', 'olive', 'navy', 'turquoise', 'khaki', 'indigo', 'violet', 'maroon', 'crimson'
  ],
  'Movies': [
    'inception', 'gladiator', 'titanic', 'avatar', 'matrix', 'jaws', 'psycho', 'vertigo', 'casablanca', 'frozen',
    'interstellar', 'dune', 'oppenheimer', 'goodfellas', 'godfather'
  ],
  'Scientists': [
    'einstein', 'newton', 'darwin', 'curie', 'galileo', 'hawking', 'tesla', 'edison', 'pasteur', 'lovelace',
    'bohr', 'mendel', 'feynman', 'planck', 'heisenberg', 'dirac', 'born', 'boltzmann', 'rumford'
  ],
  'Months': [
    'january', 'february', 'march', 'april', 'may', 'june',
    'july', 'august', 'september', 'october', 'november', 'december'
  ],
  'Weekdays': [
    'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'
  ],
  'Cities': [
    'london', 'paris', 'tokyo', 'newyork', 'berlin', 'sydney', 'mumbai', 'dubai', 'cairo', 'moscow',
    'beijing', 'rome', 'bangkok', 'barcelona', 'amsterdam', 'istanbul', 'lasvegas', 'toronto', 'singapore', 'hongkong'
  ],
};

/// Helper to get a random theme
String getRandomTheme({Random? random}) {
  random ??= Random();
  final themeList = themes.keys.toList();
  return themeList[random.nextInt(themeList.length)];
}

/// Helper to get all words in a theme
List<String> getAllWordsInTheme(String themeName) {
  final subcategories = themes[themeName];
  if (subcategories == null) return [];
  
  List<String> allWords = [];
  subcategories.forEach((_, words) {
    allWords.addAll(words);
  });
  return allWords;
}

/// Helper to get hint for a specific word
String? getHintForWord(String themeName, String word) {
  return hintsByTheme[themeName]?[word];
}

/// Helper to get all subcategories in a theme
List<String> getSubcategoriesInTheme(String themeName) {
  return themes[themeName]?.keys.toList() ?? [];
}

/// Helper to get words in a subcategory
List<String> getWordsInSubcategory(String themeName, String subcategoryName) {
  return themes[themeName]?[subcategoryName] ?? [];
}

String getRandomWord(String category) {
  final words = categories[category];
  if (words == null || words.isEmpty) return 'flutter';
  return words[Random().nextInt(words.length)].toLowerCase();
}
