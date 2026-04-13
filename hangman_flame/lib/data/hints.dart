import 'dart:math';

final Map<String, List<String>> wordHints = {
  // Animals (20 words)
  'lion': [
    'Large social cat where males have a noticeable mane.',
    'Often depicted as a symbol of strength and royalty.',
  ],
  'tiger': [
    'A solitary big cat with distinctive striped fur.',
    'Powerful predator that stalks prey in forests.',
  ],
  'elephant': [
    'Large land mammal with a flexible trunk and big ears.',
    'Known for strong family bonds and long memory.',
  ],
  'giraffe': [
    'Very tall mammal with a notably long neck.',
    'Has a patterned coat of irregular patches.',
  ],
  'zebra': [
    'Equine animal marked by bold black and white striping.',
    'Often seen grazing on African grasslands in herds.',
  ],
  'kangaroo': [
    'Hops on powerful hind legs and carries young in a pouch.',
    'A well known Australian marsupial.',
  ],
  'penguin': [
    'A flightless bird adapted to cold and excellent swimmer.',
    'Waddles on land and is black and white.',
  ],
  'dolphin': [
    'Social marine mammal known for intelligence and playfulness.',
    'Uses echolocation to navigate the ocean.',
  ],
  'shark': [
    'A predatory fish with streamlined body.',
    'Many species are apex predators of the ocean.',
  ],
  'octopus': [
    'Eight-armed mollusk famous for camouflage.',
    'Can squeeze through very small spaces.',
  ],
  'bear': [
    'Large carnivorous mammal that stands on hind legs.',
    'Known for strength and hibernation in winter.',
  ],
  'cheetah': [
    'Fastest land animal with slender build.',
    'Has distinctive black tear marks on face.',
  ],
  'wolf': [
    'Pack animal similar to domestic dog.',
    'Communicates with howling and howls.',
  ],
  'deer': [
    'Herbivore with antlers, hunted historically.',
    'Known for grace and speed.',
  ],
  'eagle': [
    'Large bird of prey known for strength and vision.',
    'Symbol of freedom and power.',
  ],
  'owl': [
    'Nocturnal bird of prey that hunts at night.',
    'Known for large forward-facing eyes.',
  ],
  'rabbit': [
    'Small hopping mammal with long ears.',
    'Known for reproducing rapidly.',
  ],
  'squirrel': [
    'Small furry rodent that jumps between trees.',
    'Collects and stores acorns for winter.',
  ],
  'fox': [
    'Cunning canine predator with bushy tail.',
    'Often depicted in folklore as clever.',
  ],
  'whale': [
    'Largest animal ever to exist on Earth.',
    'Marine mammal that breaches the water.',
  ],

  // Fruits (20 words)
  'apple': [
    'Crunchy fruit that can be red, green, or yellow.',
    'Commonly eaten raw or used in pies.',
  ],
  'banana': [
    'Long curved fruit with soft interior.',
    'Popular quick snack high in potassium.',
  ],
  'orange': [
    'Citrus fruit with bright rind.',
    'Often associated with vitamin C.',
  ],
  'strawberry': [
    'Small red fruit with seeds on surface.',
    'Often used in desserts and jams.',
  ],
  'pineapple': [
    'Tropical fruit with tough spiky exterior.',
    'Common in tropical dishes and drinks.',
  ],
  'watermelon': [
    'Large fruit with green rind and red flesh.',
    'Popular in summer and at picnics.',
  ],
  'mango': [
    'Sweet tropical stone fruit.',
    'Used in desserts and smoothies.',
  ],
  'cherry': [
    'Small round red fruit.',
    'May have a hard pit inside.',
  ],
  'grape': [
    'Small fruit that grows in clusters.',
    'Used to make wine and raisins.',
  ],
  'kiwi': [
    'Small brown fuzzy fruit with green flesh.',
    'Has sweet-tart flavor.',
  ],
  'peach': [
    'Fuzzy stone fruit with orange flesh.',
    'Sweetest when ripe in summer.',
  ],
  'pear': [
    'Fruit shaped like a teardrop.',
    'Sweet and juicy when ripe.',
  ],
  'blueberry': [
    'Small round blue berry.',
    'Rich in antioxidants.',
  ],
  'coconut': [
    'Tropical fruit with hard shell.',
    'Contains white flesh and liquid.',
  ],
  'papaya': [
    'Tropical fruit with orange flesh.',
    'Contains black seeds.',
  ],
  'lemon': [
    'Sour yellow citrus fruit.',
    'Used for juice and flavor.',
  ],
  'lime': [
    'Small green citrus fruit.',
    'Very sour and acidic.',
  ],
  'raspberry': [
    'Small red berry.',
    'Delicate and used in desserts.',
  ],
  'apricot': [
    'Orange stone fruit.',
    'Smaller than peach.',
  ],
  'blackberry': [
    'Small dark purple berry.',
    'Grows on thorny bushes.',
  ],

  // Countries (20 words)
  'france': [
    'European country famed for cuisine and wine.',
    'Known for the Eiffel Tower.',
  ],
  'germany': [
    'Central European country known for engineering.',
    'Famous for beer festivals.',
  ],
  'brazil': [
    'Largest country in South America.',
    'Known for carnival and Amazon rainforest.',
  ],
  'canada': [
    'Vast North American country with forests.',
    'Known for maple syrup.',
  ],
  'australia': [
    'Island continent with kangaroos.',
    'Known for the Outback.',
  ],
  'japan': [
    'Island nation in East Asia.',
    'Known for technology and sushi.',
  ],
  'india': [
    'South Asian country with diverse cultures.',
    'Home to the Taj Mahal.',
  ],
  'egypt': [
    'North African country famous for pyramids.',
    'Has the Nile River.',
  ],
  'mexico': [
    'North American country with vibrant culture.',
    'Known for its food and beaches.',
  ],
  'italy': [
    'European country with art and architecture.',
    'Home to Rome and Venice.',
  ],
  'spain': [
    'Country in southwestern Europe.',
    'Known for flamenco and beaches.',
  ],
  'thailand': [
    'Southeast Asian country.',
    'Known as Land of Smiles.',
  ],
  'norway': [
    'Scandinavian country with fjords.',
    'Known for Northern Lights.',
  ],
  'argentina': [
    'South American country known for tango.',
    'Famous for beef and wine.',
  ],
  'greece': [
    'European country with ancient ruins.',
    'Known for mythology and islands.',
  ],
  'portugal': [
    'Westernmost country in Europe.',
    'Known for Port wine.',
  ],
  'turkey': [
    'Transcontinental country spanning Europe and Asia.',
    'Known for Istanbul.',
  ],
  'sweden': [
    'Scandinavian country.',
    'Known for furniture and design.',
  ],
  'netherlands': [
    'Northern European country.',
    'Famous for windmills and tulips.',
  ],
  'switzerland': [
    'Landlocked Alpine country.',
    'Known for chocolate and watches.',
  ],

  // Programming (20 words)
  'flutter': [
    'UI toolkit for building cross-platform apps.',
    'Often paired with a language for mobile development.',
  ],
  'dart': [
    'Programming language for client development.',
    'Commonly used with Flutter.',
  ],
  'python': [
    'High-level language prized for readability.',
    'Widely used in data science.',
  ],
  'javascript': [
    'Language that runs in web browsers.',
    'Central to web development.',
  ],
  'rust': [
    'Systems language focusing on safety.',
    'Popular for low-level tasks.',
  ],
  'kotlin': [
    'Modern language used for Android apps.',
    'Interoperable with Java.',
  ],
  'swift': [
    'Language for Apple platforms.',
    'Used for iOS and macOS apps.',
  ],
  'java': [
    'Long-established language for enterprise systems.',
    'Runs on a virtual machine.',
  ],
  'ruby': [
    'Dynamic language known for elegant syntax.',
    'Associated with Rails web framework.',
  ],
  'golang': [
    'Statically typed language created for simplicity.',
    'Used for network services.',
  ],
  'cplusplus': [
    'Powerful language for system programming.',
    'Known for performance.',
  ],
  'csharp': [
    'Language developed by Microsoft.',
    'Runs on the .NET framework.',
  ],
  'php': [
    'Server-side scripting language.',
    'Used for web development.',
  ],
  'typescript': [
    'Builds on JavaScript with type safety.',
    'Compiles to JavaScript.',
  ],
  'scala': [
    'Language that runs on Java Virtual Machine.',
    'Combines functional and object-oriented features.',
  ],
  'perl': [
    'Dynamic language known for text processing.',
    'Used for system administration.',
  ],
  'haskell': [
    'Functional programming language.',
    'Known for purity and elegance.',
  ],
  'clojure': [
    'Functional language on the Java platform.',
    'Emphasizes immutability.',
  ],
  'groovy': [
    'Dynamic language for the Java platform.',
    'Can be used as a scripting language.',
  ],
  'solidity': [
    'Language for writing smart contracts.',
    'Used on Ethereum blockchain.',
  ],

  // Planets (19 words)
  'mercury': [
    'Rocky planet closest to the Sun.',
    'Has extreme temperature swings.',
  ],
  'venus': [
    'Second planet with thick atmosphere.',
    'Has reflective clouds.',
  ],
  'earth': [
    'Our home planet.',
    'Rich in water and life.',
  ],
  'mars': [
    'The red planet.',
    'Iron-rich soil.',
  ],
  'jupiter': [
    'Giant gas planet.',
    'Has a famous swirling storm.',
  ],
  'saturn': [
    'Gas giant noted for ring system.',
    'Beautiful rings from ice and rock.',
  ],
  'uranus': [
    'Ice giant with blue-green color.',
    'Has a tilted rotation.',
  ],
  'neptune': [
    'Distant ice giant with deep blue hue.',
    'Known for strong winds.',
  ],
  'pluto': [
    'Dwarf world reclassified from planet.',
    'Small icy body in outer solar system.',
  ],
  'kepler': [
    'Space telescope for finding exoplanets.',
    'Named after a famous astronomer.',
  ],
  'proxima': [
    'Closest star to our Sun.',
    'Part of Alpha Centauri system.',
  ],
  'sirius': [
    'Brightest star in the night sky.',
    'Located in Canis Major constellation.',
  ],
  'betelgeuse': [
    'Red supergiant star.',
    'One of the largest known stars.',
  ],
  'altair': [
    'Bright star in Aquila constellation.',
    'Fifth brightest star visible.',
  ],
  'vega': [
    'Bright star in Lyra constellation.',
    'Part of Summer Triangle.',
  ],
  'deneb': [
    'Bright star in Cygnus constellation.',
    'Third brightest in Summer Triangle.',
  ],
  'arcturus': [
    'Bright star in Bootes constellation.',
    'One of brightest stars visible.',
  ],
  'polaris': [
    'North Star used for navigation.',
    'Marks true north.',
  ],
  'rigel': [
    'Blue supergiant star in Orion.',
    'Second brightest in Orion constellation.',
  ],

  // Sports (20 words)
  'football': [
    'Team sport with goals.',
    'Played on a large field.',
  ],
  'basketball': [
    'Teams score by shooting through hoops.',
    'Played on an indoor court.',
  ],
  'cricket': [
    'Bat-and-ball sport with innings.',
    'Popular in many countries.',
  ],
  'tennis': [
    'Racquet sport across a net.',
    'Played one-on-one or in pairs.',
  ],
  'baseball': [
    'Bat-and-ball game with bases.',
    'Has innings structure.',
  ],
  'hockey': [
    'Fast team sport on ice or turf.',
    'Uses sticks and pucks or balls.',
  ],
  'volleyball': [
    'Players volley ball over net.',
    'Try to ground it on opponent side.',
  ],
  'rugby': [
    'Contact sport with oval ball.',
    'Originates from England.',
  ],
  'boxing': [
    'Combat sport with rounds.',
    'Fighters wear gloves.',
  ],
  'golf': [
    'Players hit balls into holes.',
    'Uses clubs on a course.',
  ],
  'swimming': [
    'Racquet sport across a net.',
    'Competitive racing in water.',
  ],
  'skiing': [
    'Winter sport down snowy slopes.',
    'Uses skis and poles.',
  ],
  'skating': [
    'Moving across ice on skates.',
    'Can be figure or speed skating.',
  ],
  'badminton': [
    'Racquet sport with shuttlecock.',
    'Similar to tennis but faster.',
  ],
  'table tennis': [
    'Ping pong game on a table.',
    'Uses small paddles and ball.',
  ],
  'archery': [
    'Sport of shooting arrows at targets.',
    'Requires accuracy and strength.',
  ],
  'gymnastics': [
    'Sport with acrobatic movements.',
    'Performed with grace and flexibility.',
  ],
  'wrestling': [
    'Combat sport involving grappling.',
    'Athletes try to pin opponent.',
  ],
  'sumo': [
    'Traditional Japanese wrestling.',
    'Large wrestlers in ring.',
  ],
  'curling': [
    'Winter sport on ice.',
    'Slide stones toward target.',
  ],

  // Colors (20 words)
  'red': ['Primary color associated with warmth.'],
  'blue': ['Primary color linked to sky and sea.'],
  'green': ['Color associated with plants and nature.'],
  'yellow': ['Bright color linked to sunlight.'],
  'brown': ['Earthy color found in wood.'],
  'purple': ['Rich color associated with royalty.'],
  'pink': ['Pale red often associated with softness.'],
  'black': ['Darkest shade.'],
  'white': ['Light color associated with purity.'],
  'gray': ['Neutral color between black and white.'],
  'silver': ['Metallic gray color.'],
  'gold': ['Warm metallic yellow color.'],
  'olive': ['Dark yellowish-green color.'],
  'navy': ['Dark shade of blue.'],
  'turquoise': ['Blue-green color.'],
  'khaki': ['Dull yellowish-brown color.'],
  'indigo': ['Deep blue-purple color.'],
  'violet': ['Purple color from rainbow.'],
  'maroon': ['Dark brownish-red color.'],
  'crimson': ['Deep red color.'],

  // Movies (20 words)
  'inception': ['Mind-bending sci-fi about layered dreams.'],
  'gladiator': ['Historical epic about arena and hero.'],
  'titanic': ['Romantic drama on ocean liner.'],
  'avatar': ['Sci-fi set on alien world.'],
  'matrix': ['Cyberpunk about simulated reality.'],
  'jaws': ['Thriller about dangerous shark.'],
  'psycho': ['Psychological thriller at motel.'],
  'vertigo': ['Thriller dealing with obsession.'],
  'casablanca': ['Wartime romance in Morocco.'],
  'frozen': ['Animated musical about ice powers.'],
  'forrestgump': ['Drama following mans life journey.'],
  'theriddler': ['Crime thriller about serial killer.'],
  'interstellar': ['Sci-fi about space exploration.'],
  'dune': ['Epic sci-fi set on desert planet.'],
  'oppenheimer': ['Historical drama about scientist.'],
  'thedarkknight': ['Batman superhero film.'],
  'pulpfiction': ['Non-linear crime drama.'],
  'sevensofar': ['Dark thriller about detective.'],
  'goodfellas': ['Crime film about mafia.'],
  'godfather': ['Epic crime saga.'],

  // Scientists (20 words)
  'einstein': ['Physicist famous for theory of relativity.'],
  'newton': ['Formulated laws of motion and gravity.'],
  'darwin': ['Known for theory of evolution.'],
  'curie': ['Pioneering researcher in radioactivity.'],
  'galileo': ['Astronomer who supported heliocentrism.'],
  'hawking': ['Theoretical physicist studying black holes.'],
  'tesla': ['Inventor associated with alternating current.'],
  'edison': ['Inventor known for electrical inventions.'],
  'pasteur': ['Microbiologist who developed pasteurization.'],
  'lovelace': ['Computing pioneer and mathematician.'],
  'bohr': ['Physicist who studied atomic structure.'],
  'mendel': ['Founder of genetics.'],
  'feynman': ['Influential theoretical physicist.'],
  'schrodinger': ['Quantum physicist known for thought experiment.'],
  'planck': ['Originated quantum theory.'],
  'heisenberg': ['Developed uncertainty principle.'],
  'dirac': ['Predicted the positron.'],
  'born': ['Quantum mechanics pioneer.'],
  'boltzmann': ['Statistical mechanics founder.'],
  'rumford': ['Physicist studying heat.'],

  // Months (12 words)
  'january': ['First month of year.'],
  'february': ['Short month with leap year adjustments.'],
  'march': ['Start of spring in northern hemisphere.'],
  'april': ['Month of showers and growth.'],
  'may': ['Spring month with flowers.'],
  'june': ['Start of summer.'],
  'july': ['Midsummer month.'],
  'august': ['Late summer month.'],
  'september': ['Transition from summer to autumn.'],
  'october': ['Autumn month with colorful leaves.'],
  'november': ['Late autumn month.'],
  'december': ['Holiday month at year end.'],

  // Weekdays (7 words)
  'monday': ['Start of work week.'],
  'tuesday': ['Second work day.'],
  'wednesday': ['Midweek day or hump day.'],
  'thursday': ['Day before weekend.'],
  'friday': ['Last weekday.'],
  'saturday': ['Weekend day.'],
  'sunday': ['Weekend day for rest.'],

  // Zodiac Signs (12 words)
  'aries': ['First zodiac sign.'],
  'taurus': ['Sign of steadiness.'],
  'gemini': ['Sign of duality.'],
  'cancer': ['Sign of home and family.'],
  'leo': ['Sign of confidence.'],
  'virgo': ['Sign of detail.'],
  'libra': ['Sign of balance.'],
  'scorpio': ['Sign of intensity.'],
  'sagittarius': ['Sign of exploration.'],
  'capricorn': ['Sign of discipline.'],
  'aquarius': ['Sign of innovation.'],
  'pisces': ['Sign of imagination.'],

  // Cities (20 words)
  'london': ['Historic capital of UK.'],
  'paris': ['Romantic city with Eiffel Tower.'],
  'tokyo': ['Vibrant Asian metropolis.'],
  'newyork': ['Large US city with skyscrapers.'],
  'berlin': ['European city with history.'],
  'sydney': ['Australian city with opera house.'],
  'mumbai': ['Indian metropolis.'],
  'dubai': ['City known for luxury.'],
  'cairo': ['Egyptian city on the Nile.'],
  'moscow': ['Russian capital.'],
  'beijing': ['Chinese capital.'],
  'rome': ['Ancient city with ruins.'],
  'bangkok': ['Thai capital.'],
  'barcelona': ['Spanish city with architecture.'],
  'amsterdam': ['Dutch city with canals.'],
  'istanbul': ['Turkish metropolis.'],
  'lasvegas': ['US city known for casinos.'],
  'toronto': ['Canadian city.'],
  'singapore': ['City-state in Southeast Asia.'],
  'hongkong': ['Asian financial hub.'],

  // Instruments (20 words)
  'guitar': ['Stringed instrument.'],
  'piano': ['Keyboard instrument.'],
  'violin': ['String instrument with bow.'],
  'drums': ['Percussion rhythm instrument.'],
  'trumpet': ['Brass instrument.'],
  'flute': ['Woodwind instrument.'],
  'saxophone': ['Jazz instrument.'],
  'cello': ['Large string instrument.'],
  'harp': ['Plucked string instrument.'],
  'trombone': ['Brass instrument with slide.'],
  'clarinet': ['Woodwind instrument.'],
  'oboe': ['Reedy woodwind.'],
  'banjo': ['Stringed percussion instrument.'],
  'harmonica': ['Small wind instrument.'],
  'organ': ['Large keyboard instrument.'],
  'mandolin': ['Small string instrument.'],
  'tambourine': ['Percussion with jingles.'],
  'xylophone': ['Percussion with wooden bars.'],
  'marimba': ['Large xylophone.'],
  'accordion': ['Keyboard with bellows.'],

  // Tech Brands (20 words)
  'google': ['Search and tech company.'],
  'microsoft': ['Software company.'],
  'amazon': ['Online shopping giant.'],
  'samsung': ['Consumer electronics company.'],
  'nvidia': ['GPU manufacturer.'],
  'intel': ['CPU manufacturer.'],
  'meta': ['Social media company.'],
  'netflix': ['Streaming service.'],
  'adobe': ['Software for design.'],
  'ibm': ['Computer company.'],
  'oracle': ['Database company.'],
  'cisco': ['Networking company.'],
  'qualcomm': ['Mobile chip company.'],
  'amd': ['Processor manufacturer.'],
  'mozilla': ['Firefox browser.'],
  'slack': ['Communication platform.'],
  'spotify': ['Music streaming service.'],
  'uber': ['Ride sharing service.'],
  'linkin path': ['Professional networking site.'],
  'dropbox': ['Cloud storage service.'],

  // Vegetables (20 words)
  'carrot': ['Orange root vegetable.'],
  'potato': ['Starchy tuber.'],
  'tomato': ['Red vegetable.'],
  'broccoli': ['Green cruciferous vegetable.'],
  'spinach': ['Leafy green.'],
  'cucumber': ['Crisp watery vegetable.'],
  'pepper': ['Vegetable with seeds.'],
  'onion': ['Pungent bulb.'],
  'garlic': ['Aromatic bulb.'],
  'cabbage': ['Leafy round vegetable.'],
  'lettuce': ['Leafy salad vegetable.'],
  'celery': ['Stalk vegetable.'],
  'beets': ['Purple root vegetable.'],
  'radish': ['Crunchy root vegetable.'],
  'squash': ['Summer or winter vegetable.'],
  'zucchini': ['Green summer squash.'],
  'leek': ['Vegetable similar to onion.'],
  'asparagus': ['Spring vegetable with stalks.'],
  'peas': ['Small green legumes.'],
  'artichoke': ['Thistle-like vegetable.'],

  // Space (20 words)
  'galaxy': ['Vast system of stars.'],
  'nebula': ['Cloud of gas in space.'],
  'asteroid': ['Small rocky body.'],
  'comet': ['Icy body with tail.'],
  'supernova': ['Explosive star death.'],
  'blackhole': ['Region with extreme gravity.'],
  'meteor': ['Burning space rock.'],
  'telescope': ['Observation instrument.'],
  'astronaut': ['Space traveler.'],
  'orbit': ['Path around celestial body.'],
  'satellite': ['Object orbiting planet.'],
  'cosmos': ['The universe.'],
  'universe': ['All of existence.'],
  'infinity': ['Without end.'],
  'eclipse': ['Shadow of one body on another.'],
  'aurora': ['Northern lights.'],
  'lunar': ['Relating to moon.'],
  'solar': ['Relating to sun.'],
  'gravity': ['Force of attraction.'],
  'wormhole': ['Theoretical tunnel through space.'],

  // Mythology (20 words)
  'dragon': ['Legendary reptilian creature.'],
  'phoenix': ['Bird reborn from ashes.'],
  'unicorn': ['Horse with single horn.'],
  'griffin': ['Lion-eagle hybrid.'],
  'mermaid': ['Half woman, half fish.'],
  'centaur': ['Half human, half horse.'],
  'minotaur': ['Man with bull head.'],
  'pegasus': ['Winged horse.'],
  'hydra': ['Multi-headed serpent.'],
  'kraken': ['Sea monster.'],
  'sphinx': ['Creature with human head.'],
  'basilisk': ['Legendary serpent.'],
  'harpy': ['Bird-woman creature.'],
  'ghoul': ['Undead creature.'],
  'demon': ['Evil spirit.'],
  'fairy': ['Magical tiny being.'],
  'elf': ['Magical humanoid.'],
  'troll': ['Large ugly creature.'],
  'vampire': ['Undead blood drinker.'],
  'werewolf': ['Human wolf hybrid.'],

  // Geography (20 words)
  'mountain': ['High landform.'],
  'ocean': ['Large body of water.'],
  'desert': ['Arid land.'],
  'forest': ['Dense trees.'],
  'river': ['Flowing water body.'],
  'island': ['Land surrounded by water.'],
  'glacier': ['Frozen ice mass.'],
  'volcano': ['Mountain that erupts.'],
  'canyon': ['Deep valley.'],
  'valley': ['Low land between mountains.'],
  'plateau': ['Flat elevated land.'],
  'reef': ['Underwater rock formation.'],
  'delta': ['Triangular river mouth.'],
  'lagoon': ['Shallow body of water.'],
  'fjord': ['Narrow sea inlet.'],
  'prairie': ['Flat grassland.'],
  'tundra': ['Arctic treeless land.'],
  'swamp': ['Wet marshy area.'],
  'cavern': ['Large underground cave.'],
  'waterfall': ['Cascading water.'],

  // History (20 words)
  'medieval': ['Period of Middle Ages.'],
  'renaissance': ['Period of rebirth.'],
  'revolution': ['Dramatic change.'],
  'empire': ['Large territory ruled.'],
  'dynasty': ['Series of rulers.'],
  'crusade': ['Religious military campaign.'],
  'armada': ['Fleet of ships.'],
  'conquest': ['Military takeover.'],
  'monarchy': ['Rule by king.'],
  'republic': ['Rule by representatives.'],
  'independence': ['Freedom from rule.'],
  'abolition': ['Ending of slavery.'],
  'civilization': ['Advanced society.'],
  'settlement': ['New community.'],
  'colonization': ['Establishing colonies.'],
  'migration': ['Mass movement.'],
  'ancient': ['Very old period.'],
  'warfare': ['Armed conflict.'],
  'treaty': ['Peace agreement.'],
  'baroque': ['Ornate artistic period.'],

  // Famous People (20 words)
  'napoleon': ['French military leader.'],
  'cleopatra': ['Egyptian queen.'],
  'shakespeare': ['English playwright.'],
  'michelangelo': ['Renaissance artist.'],
  'leonardo': ['Renaissance polymath.'],
  'mozart': ['Classical composer.'],
  'beethoven': ['German composer.'],
  'churchill': ['British wartime leader.'],
  'gandhi': ['Indian independence leader.'],
  'mandela': ['South African president.'],
  'lincoln': ['US president.'],
  'washington': ['First US president.'],
  'jefferson': ['US founding father.'],
  'queen elizabeth': ['British monarch.'],
  'julius caesar': ['Roman leader.'],
  'kennedy': ['US president.'],
  'aristotle': ['Ancient Greek philosopher and scientist.'],
  'wright brothers': ['Aviation pioneers.'],
  'hannibal': ['Carthaginian military commander.'],
  'confucius': ['Chinese philosopher.'],

  // Food & Drinks (20 words)
  'pizza': ['Cheese and tomato dish.'],
  'burger': ['Bread with patty.'],
  'sushi': ['Japanese rice dish.'],
  'pasta': ['Italian noodles.'],
  'steak': ['Grilled beef.'],
  'chicken': ['Poultry meat.'],
  'salad': ['Mixed greens.'],
  'soup': ['Hot liquid dish.'],
  'bread': ['Baked grain product.'],
  'cheese': ['Dairy product.'],
  'chocolate': ['Sweet cocoa product.'],
  'coffee': ['Caffeinated beverage.'],
  'tea': ['Hot leaf beverage.'],
  'juice': ['Liquid from fruit.'],
  'wine': ['Fermented grapes.'],
  'beer': ['Fermented grain drink.'],
  'cocktail': ['Mixed alcoholic drink.'],
  'smoothie': ['Blended fruit drink.'],
  'sandwich': ['Bread with filling.'],
  'taco': ['Mexican food.'],

  // Vehicles (20 words)
  'car': ['Personal automobile.'],
  'truck': ['Heavy cargo vehicle.'],
  'bicycle': ['Two wheeled transport.'],
  'motorcycle': ['Motorized bike.'],
  'airplane': ['Flying aircraft.'],
  'helicopter': ['Flying with rotors.'],
  'boat': ['Water transport.'],
  'ship': ['Large vessel.'],
  'train': ['Rail transport.'],
  'bus': ['Public transport.'],
  'taxi': ['Cab service.'],
  'ambulance': ['Emergency vehicle.'],
  'police': ['Law enforcement.'],
  'fire truck': ['Emergency fire vehicle.'],
  'bulldozer': ['Construction vehicle.'],
  'crane': ['Lifting construction.'],
  'rocket': ['Space vehicle.'],
  'submarine': ['Underwater vessel.'],
  'yacht': ['Luxury boat.'],
  'scooter': ['Small vehicle.'],

  // Nature (20 words)
  'tree': ['Large woody plant.'],
  'flower': ['Colorful bloom.'],
  'grass': ['Green ground cover.'],
  'moss': ['Small green plant.'],
  'fern': ['Feathery plant.'],
  'cactus': ['Desert plant.'],
  'rose': ['Fragrant flower.'],
  'sunflower': ['Large yellow flower.'],
  'daisy': ['White flower.'],
  'tulip': ['Spring flower.'],
  'butterfly': ['Winged insect.'],
  'bee': ['Pollinating insect.'],
  'ladybug': ['Spotted beetle.'],
  'ant': ['Colony insect.'],
  'worm': ['Soil creature.'],
  'snail': ['Shell carrying mollusk.'],
  'spider': ['Eight legged arachnid.'],
  'beetle': ['Hard winged insect.'],
  'moth': ['Nocturnal insect.'],
  'grasshopper': ['Jumping insect.'],
};

String? getHintForWord(String word) {
  final key = word.toLowerCase();
  final list = wordHints[key];
  if (list == null || list.isEmpty) return null;
  return list[Random().nextInt(list.length)];
}
