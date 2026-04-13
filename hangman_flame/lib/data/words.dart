import 'dart:math';

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
    'mercury', 'venus', 'earth', 'mars', 'jupiter', 'saturn', 'uranus', 'neptune', 'pluto',
    'kepler', 'proxima', 'sirius', 'betelgeuse', 'altair', 'vega', 'deneb', 'arcturus', 'polaris', 'rigel'
  ],
  'Sports': [
    'football', 'basketball', 'cricket', 'tennis', 'baseball', 'hockey', 'volleyball', 'rugby', 'boxing', 'golf',
    'swimming', 'skiing', 'skating', 'badminton', 'table tennis', 'archery', 'gymnastics', 'wrestling', 'sumo', 'curling'
  ],
  'Colors': [
    'red', 'blue', 'green', 'yellow', 'orange', 'purple', 'pink', 'brown', 'black', 'white',
    'gray', 'silver', 'gold', 'peach', 'olive', 'navy', 'turquoise', 'khaki', 'indigo', 'violet'
  ],
  'Movies': [
    'inception', 'gladiator', 'titanic', 'avatar', 'matrix', 'jaws', 'psycho', 'vertigo', 'casablanca', 'frozen',
    'forrestgump', 'theriddler', 'interstellar', 'dune', 'oppenheimer', 'thedarkknight', 'pulpfiction', 'sevensofar', 'goodfellas', 'godfather'
  ],
  'Scientists': [
    'einstein', 'newton', 'darwin', 'curie', 'galileo', 'hawking', 'tesla', 'edison', 'pasteur', 'lovelace',
    'bohr', 'mendel', 'feynman', 'schrodinger', 'planck', 'heisenberg', 'dirac', 'born', 'boltzmann', 'rumford'
  ],
  'Months': [
    'january', 'february', 'march', 'april', 'may', 'june',
    'july', 'august', 'september', 'october', 'november', 'december'
  ],
  'Weekdays': [
    'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'
  ],
  'Zodiac Signs': [
    'aries', 'taurus', 'gemini', 'cancer', 'leo', 'virgo',
    'libra', 'scorpio', 'sagittarius', 'capricorn', 'aquarius', 'pisces'
  ],
  'Cities': [
    'london', 'paris', 'tokyo', 'newyork', 'berlin', 'sydney', 'mumbai', 'dubai', 'cairo', 'moscow', 'beijing', 'rome',
    'bangkok', 'barcelona', 'amsterdam', 'istanbul', 'lasvegas', 'toronoto', 'singapore', 'hongkong'
  ],
  'Instruments': [
    'guitar', 'piano', 'violin', 'drums', 'trumpet', 'flute', 'saxophone', 'cello', 'harp', 'trombone',
    'clarinet', 'oboe', 'banjo', 'harmonica', 'organ', 'mandolin', 'tambourine', 'xylophone', 'marimba', 'accordion'
  ],
  'Tech Brands': [
    'google', 'apple', 'microsoft', 'amazon', 'tesla', 'samsung', 'nvidia', 'intel', 'meta', 'netflix',
    'adobe', 'ibm', 'oracle', 'cisco', 'qualcomm', 'amd', 'mozilla', 'slack', 'spotify', 'uber'
  ],
  'Vegetables': [
    'carrot', 'potato', 'tomato', 'broccoli', 'spinach', 'cucumber', 'pepper', 'onion', 'garlic', 'cabbage',
    'lettuce', 'celery', 'beets', 'radish', 'squash', 'zucchini', 'leek', 'asparagus', 'peas', 'artichoke'
  ],
  'Space': [
    'galaxy', 'nebula', 'asteroid', 'comet', 'supernova', 'blackhole', 'meteor', 'telescope', 'astronaut', 'orbit',
    'satellite', 'cosmos', 'universe', 'infinity', 'eclipse', 'aurora', 'lunar', 'solar', 'gravity', 'wormhole'
  ],
  'Mythology': [
    'dragon', 'phoenix', 'unicorn', 'griffin', 'mermaid', 'centaur', 'minotaur', 'pegasus', 'hydra', 'kraken',
    'sphinx', 'basilisk', 'harpy', 'ghoul', 'demon', 'fairy', 'elf', 'troll', 'vampire', 'werewolf'
  ],
  'Geography': [
    'mountain', 'ocean', 'desert', 'forest', 'river', 'island', 'glacier', 'volcano', 'canyon', 'valley',
    'plateau', 'reef', 'delta', 'lagoon', 'fjord', 'prairie', 'tundra', 'swamp', 'cavern', 'waterfall'
  ],
  'History': [
    'medieval', 'renaissance', 'revolution', 'empire', 'dynasty', 'crusade', 'renaissance', 'armada', 'conquest', 'monarchy',
    'republic', 'independence', 'abolition', 'civilization', 'settlement', 'colonization', 'migration', 'ancient', 'warfare', 'treaty'
  ],
  'Famous People': [
    'napoleon', 'cleopatra', 'shakespeare', 'michelangelo', 'leonardo', 'mozart', 'beethoven', 'churchill', 'gandhi', 'mandela',
    'lincoln', 'washington', 'jefferson', 'queen elizabeth', 'julius caesar', 'napoleon', 'lincoln', 'kennedy', 'edison', 'wright brothers'
  ],
  'Food & Drinks': [
    'pizza', 'burger', 'sushi', 'pasta', 'steak', 'chicken', 'salad', 'soup', 'bread', 'cheese',
    'chocolate', 'coffee', 'tea', 'juice', 'wine', 'beer', 'cocktail', 'smoothie', 'sandwich', 'taco'
  ],
  'Vehicles': [
    'car', 'truck', 'bicycle', 'motorcycle', 'airplane', 'helicopter', 'boat', 'ship', 'train', 'bus',
    'taxi', 'ambulance', 'police car', 'fire truck', 'bulldozer', 'crane', 'rocket', 'submarine', 'yacht', 'scooter'
  ],
  'Nature': [
    'tree', 'flower', 'grass', 'moss', 'fern', 'cactus', 'rose', 'sunflower', 'daisy', 'tulip',
    'butterfly', 'bee', 'ladybug', 'ant', 'worm', 'snail', 'spider', 'beetle', 'moth', 'cricket'
  ]
};

String getRandomWord(String category) {
  final words = categories[category];
  if (words == null || words.isEmpty) return 'flutter';
  return words[Random().nextInt(words.length)].toLowerCase();
}
