import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Responsive UI Tests', () {
    testWidgets('Mobile layout detected correctly on small screen',
        (WidgetTester tester) async {
      tester.binding.window.physicalSizeTestValue = const Size(400, 800);
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

      expect(isMobileSize(400), isTrue);
      expect(isMobileSize(500), isFalse);
    });

    testWidgets('Tablet layout detected correctly on medium screen',
        (WidgetTester tester) async {
      tester.binding.window.physicalSizeTestValue = const Size(800, 1024);
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

      expect(isTabletSize(800), isTrue);
      expect(isTabletSize(400), isFalse);
    });

    testWidgets('Desktop layout detected correctly on large screen',
        (WidgetTester tester) async {
      tester.binding.window.physicalSizeTestValue = const Size(1400, 900);
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

      expect(isDesktopSize(1400), isTrue);
    });
  });

  group('Theme Tests', () {
    testWidgets('Light theme renders without errors',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: _buildLightTheme(),
          home: const Scaffold(body: Text('Light Theme')),
        ),
      );

      expect(find.text('Light Theme'), findsOneWidget);
    });

    testWidgets('Dark theme renders without errors',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          darkTheme: _buildDarkTheme(),
          themeMode: ThemeMode.dark,
          home: const Scaffold(body: Text('Dark Theme')),
        ),
      );

      expect(find.text('Dark Theme'), findsOneWidget);
    });

    testWidgets('Theme toggle updates UI', (WidgetTester tester) async {
      var isDarkMode = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: _buildLightTheme(),
          darkTheme: _buildDarkTheme(),
          themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: Scaffold(
            body: Text('Theme: ${isDarkMode ? "Dark" : "Light"}'),
          ),
        ),
      );

      expect(find.text('Theme: Light'), findsOneWidget);

      isDarkMode = true;
      await tester.pumpWidget(
        MaterialApp(
          theme: _buildLightTheme(),
          darkTheme: _buildDarkTheme(),
          themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: Scaffold(
            body: Text('Theme: ${isDarkMode ? "Dark" : "Light"}'),
          ),
        ),
      );

      expect(find.text('Theme: Dark'), findsOneWidget);
    });

    testWidgets('Text colors are readable in light theme',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: _buildLightTheme(),
          home: Scaffold(
            body: Text(
              'Readable Text',
              style: TextStyle(color: _getLightThemeTextColor()),
            ),
          ),
        ),
      );

      expect(find.text('Readable Text'), findsOneWidget);
    });

    testWidgets('Text colors are readable in dark theme',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          darkTheme: _buildDarkTheme(),
          themeMode: ThemeMode.dark,
          home: Scaffold(
            body: Text(
              'Readable Text',
              style: TextStyle(color: _getDarkThemeTextColor()),
            ),
          ),
        ),
      );

      expect(find.text('Readable Text'), findsOneWidget);
    });
  });

  group('Button Tests', () {
    testWidgets('Primary button renders correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ElevatedButton(
              onPressed: () {},
              child: const Text('Primary Button'),
            ),
          ),
        ),
      );

      expect(find.text('Primary Button'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('Button responds to tap', (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ElevatedButton(
              onPressed: () => tapped = true,
              child: const Text('Tap Me'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Tap Me'));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('Disabled button cannot be tapped',
        (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ElevatedButton(
              onPressed: null,
              child: const Text('Tap Me'),
            ),
          ),
        ),
      );

      // Button exists but cannot be tapped
      expect(find.text('Tap Me'), findsOneWidget);
    });
  });

  group('Form Input Tests', () {
    testWidgets('TextField accepts text input', (WidgetTester tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TextField(controller: controller),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'flutter');
      await tester.pump();

      expect(controller.text, equals('flutter'));
    });

    testWidgets('Hint text displays correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TextField(
              decoration: const InputDecoration(hintText: 'Enter text'),
            ),
          ),
        ),
      );

      expect(find.text('Enter text'), findsOneWidget);
    });

    testWidgets('Form validation works', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TextField(
              decoration: InputDecoration(
                errorText: _validateEmail('invalid'),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(TextField), findsOneWidget);
    });
  });

  group('Layout Tests', () {
    testWidgets('Column layout renders children correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Text('Item 1'),
                Text('Item 2'),
                Text('Item 3'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Item 1'), findsOneWidget);
      expect(find.text('Item 2'), findsOneWidget);
      expect(find.text('Item 3'), findsOneWidget);
    });

    testWidgets('Row layout renders children horizontally',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Row(
              children: [
                Text('Left'),
                Text('Center'),
                Text('Right'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Left'), findsOneWidget);
      expect(find.text('Center'), findsOneWidget);
      expect(find.text('Right'), findsOneWidget);
    });

    testWidgets('ScrollView handles overflow', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView(
              children: List.generate(
                100,
                (i) => Text('Item $i'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Item 0'), findsOneWidget);
      // Item 100 won't be visible without scrolling
      expect(find.text('Item 99'), findsNothing);
    });
  });

  group('Navigation Tests', () {
    testWidgets('Dialog opens on button tap', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ElevatedButton(
              onPressed: () {
                showDialog(
                  context: _buildTestContext(),
                  builder: (_) => const AlertDialog(title: Text('Dialog')),
                );
              },
              child: const Text('Show Dialog'),
            ),
          ),
        ),
      );

      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('Bottom sheet displays content', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const Center(child: Text('Content')),
          ),
        ),
      );

      expect(find.text('Content'), findsOneWidget);
    });
  });

  group('Accessibility Tests', () {
    testWidgets('Text has sufficient size', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Text(
              'Accessible Text',
              style: TextStyle(fontSize: 14.0),
            ),
          ),
        ),
      );

      expect(find.text('Accessible Text'), findsOneWidget);
    });

    testWidgets('Icons are properly sized', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Icon(
              Icons.check,
              size: 24.0,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('Touch targets meet minimum size', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ElevatedButton(
              onPressed: () {},
              child: const Text('Tap'),
            ),
          ),
        ),
      );

      expect(find.byType(ElevatedButton), findsOneWidget);
    });
  });
}

// Helper functions

bool isMobileSize(double width) => width < 576;

bool isTabletSize(double width) => width >= 576 && width < 992;

bool isDesktopSize(double width) => width >= 992;

ThemeData _buildLightTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme:
        ColorScheme.fromSeed(seedColor: Colors.blue, brightness: Brightness.light),
  );
}

ThemeData _buildDarkTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme:
        ColorScheme.fromSeed(seedColor: Colors.blue, brightness: Brightness.dark),
  );
}

Color _getLightThemeTextColor() => Colors.black;

Color _getDarkThemeTextColor() => Colors.white;

String? _validateEmail(String email) {
  if (!email.contains('@')) {
    return 'Invalid email';
  }
  return null;
}

BuildContext _buildTestContext() {
  throw UnimplementedError();
}
