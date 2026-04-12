import 'dart:math';

final Map<String, List<String>> categories = {
  'Animals': ['lion', 'tiger', 'elephant', 'giraffe', 'zebra', 'kangaroo', 'penguin', 'dolphin', 'shark', 'octopus'],
  'Fruits': ['apple', 'banana', 'orange', 'strawberry', 'pineapple', 'watermelon', 'mango', 'cherry', 'grape', 'kiwi'],
  'Countries': ['france', 'germany', 'brazil', 'canada', 'australia', 'japan', 'india', 'egypt', 'mexico', 'italy'],
  'Programming': ['flutter', 'dart', 'python', 'javascript', 'rust', 'kotlin', 'swift', 'java', 'ruby', 'golang'],
  'Planets': ['mercury', 'venus', 'earth', 'mars', 'jupiter', 'saturn', 'uranus', 'neptune', 'pluto'],
  'Sports': ['football', 'basketball', 'cricket', 'tennis', 'baseball', 'hockey', 'volleyball', 'rugby', 'boxing', 'golf'],
  'Colors': ['red', 'blue', 'green', 'yellow', 'orange', 'purple', 'pink', 'brown', 'black', 'white'],
  'Movies': ['inception', 'gladiator', 'titanic', 'avatar', 'matrix', 'jaws', 'psycho', 'vertigo', 'casablanca', 'frozen'],
  'Scientists': ['einstein', 'newton', 'darwin', 'curie', 'galileo', 'hawking', 'tesla', 'edison', 'pasteur', 'lovelace'],
  'Months': ['january', 'february', 'march', 'april', 'may', 'june', 'july', 'august', 'september', 'october', 'november', 'december'],
  'Weekdays': ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'],
  'Zodiac Signs': ['aries', 'taurus', 'gemini', 'cancer', 'leo', 'virgo', 'libra', 'scorpio', 'sagittarius', 'capricorn', 'aquarius', 'pisces'],
  'Cities': ['london', 'paris', 'tokyo', 'newyork', 'berlin', 'sydney', 'mumbai', 'dubai', 'cairo', 'moscow', 'beijing', 'rome'],
  'Instruments': ['guitar', 'piano', 'violin', 'drums', 'trumpet', 'flute', 'saxophone', 'cello', 'harp', 'trombone'],
  'Tech Brands': ['google', 'apple', 'microsoft', 'amazon', 'tesla', 'samsung', 'nvidia', 'intel', 'meta', 'netflix'],
  'Vegetables': ['carrot', 'potato', 'tomato', 'broccoli', 'spinach', 'cucumber', 'pepper', 'onion', 'garlic', 'cabbage'],
  'Space': ['galaxy', 'nebula', 'asteroid', 'comet', 'supernova', 'blackhole', 'meteor', 'telescope', 'astronaut', 'orbit'],
  'Mythology': ['dragon', 'phoenix', 'unicorn', 'griffin', 'mermaid', 'centaur', 'minotaur', 'pegasus', 'hydra', 'kraken']
};

String getRandomWord(String category) {
  final words = categories[category];
  if (words == null || words.isEmpty) return 'flutter';
  return words[Random().nextInt(words.length)].toLowerCase();
}
