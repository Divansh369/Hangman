// Difficulty levels with associated max wrong guesses
enum DifficultyLevel {
  easy(maxWrongGuesses: 8, scoreMultiplier: 1.0),
  medium(maxWrongGuesses: 6, scoreMultiplier: 1.5),
  hard(maxWrongGuesses: 4, scoreMultiplier: 2.0);

  final int maxWrongGuesses;
  final double scoreMultiplier;

  const DifficultyLevel({required this.maxWrongGuesses, required this.scoreMultiplier});

  String get displayName {
    switch (this) {
      case DifficultyLevel.easy:
        return 'Easy';
      case DifficultyLevel.medium:
        return 'Medium';
      case DifficultyLevel.hard:
        return 'Hard';
    }
  }

  int calculateStars(int score, int minScore) {
    if (score < minScore) return 0;
    if (score < minScore + 5) return 1;
    if (score < minScore + 10) return 2;
    return 3;
  }
}
