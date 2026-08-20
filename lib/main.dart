import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme/ember_theme.dart';
import 'features/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait orientation for mobile arcade gameplay
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0C1024),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const EmberboundApp());
}

class EmberboundApp extends StatelessWidget {
  const EmberboundApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EMBERBOUND',
      debugShowCheckedModeBanner: false,
      theme: EmberTheme.theme,
      home: const HomeScreen(),
    );
  }
}
