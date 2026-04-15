import 'package:flutter_test/flutter_test.dart';
import 'package:hangman_flame/game/difficulty_level.dart';

void main() {
  group('DifficultyLevel Tests', () {
    test('Easy difficulty has correct values', () {
      expect(DifficultyLevel.easy.maxWrongGuesses, equals(8));
      expect(DifficultyLevel.easy.scoreMultiplier, equals(1.0));
      expect(DifficultyLevel.easy.displayName, equals('Easy'));
    });

    test('Medium difficulty has correct values', () {
      expect(DifficultyLevel.medium.maxWrongGuesses, equals(6));
      expect(DifficultyLevel.medium.scoreMultiplier, equals(1.5));
      expect(DifficultyLevel.medium.displayName, equals('Medium'));
    });

    test('Hard difficulty has correct values', () {
      expect(DifficultyLevel.hard.maxWrongGuesses, equals(4));
      expect(DifficultyLevel.hard.scoreMultiplier, equals(2.0));
      expect(DifficultyLevel.hard.displayName, equals('Hard'));
    });

    group('Star calculation', () {
      test('Returns 0 stars if score is below minimum', () {
        expect(DifficultyLevel.easy.calculateStars(10, 20), equals(0));
        expect(DifficultyLevel.medium.calculateStars(15, 20), equals(0));
        expect(DifficultyLevel.hard.calculateStars(5, 20), equals(0));
      });

      test('Returns 1 star if score meets minimum but below minimum+5', () {
        expect(DifficultyLevel.easy.calculateStars(20, 20), equals(1));
        expect(DifficultyLevel.medium.calculateStars(20, 20), equals(1));
        expect(DifficultyLevel.hard.calculateStars(20, 20), equals(1));

        expect(DifficultyLevel.easy.calculateStars(24, 20), equals(1));
      });

      test('Returns 2 stars if score between minimum+5 and minimum+10', () {
        expect(DifficultyLevel.easy.calculateStars(25, 20), equals(2));
        expect(DifficultyLevel.medium.calculateStars(25, 20), equals(2));
        expect(DifficultyLevel.hard.calculateStars(25, 20), equals(2));

        expect(DifficultyLevel.easy.calculateStars(29, 20), equals(2));
      });

      test('Returns 3 stars if score is minimum+10 or more', () {
        expect(DifficultyLevel.easy.calculateStars(30, 20), equals(3));
        expect(DifficultyLevel.medium.calculateStars(30, 20), equals(3));
        expect(DifficultyLevel.hard.calculateStars(30, 20), equals(3));

        expect(DifficultyLevel.easy.calculateStars(50, 20), equals(3));
      });
    });

    test('All difficulty levels are valid enums', () {
      expect(DifficultyLevel.values.length, equals(3));
      expect(
        DifficultyLevel.values,
        containsAll([
          DifficultyLevel.easy,
          DifficultyLevel.medium,
          DifficultyLevel.hard,
        ]),
      );
    });
  });
}
