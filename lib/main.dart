import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/theme/game_theme.dart';
import 'state/player_profile_state.dart';
import 'state/hero_state.dart';
import 'state/inventory_state.dart';
import 'state/talent_state.dart';
import 'screens/home_screen.dart';

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
      systemNavigationBarColor: Color(0xFF131127),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const CupHeroesApp());
}

class CupHeroesApp extends StatelessWidget {
  const CupHeroesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PlayerProfileState()),
        ChangeNotifierProvider(create: (_) => HeroState()),
        ChangeNotifierProvider(create: (_) => InventoryState()),
        ChangeNotifierProvider(create: (_) => TalentState()),
      ],
      child: MaterialApp(
        title: 'Cup Heroes',
        debugShowCheckedModeBanner: false,
        theme: GameTheme.theme,
        home: const HomeScreen(),
      ),
    );
  }
}
