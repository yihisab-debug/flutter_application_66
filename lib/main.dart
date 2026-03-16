import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/favorites_provider.dart';
import 'providers/sports_provider.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      
      providers: [
        ChangeNotifierProvider(create: (_) => FavoritesProvider()..init()),
        ChangeNotifierProvider(create: (_) => SportsProvider()),
      ],

      child: MaterialApp(
        title: 'LiveScore',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF00C853),
            brightness: Brightness.dark,
          ),

          scaffoldBackgroundColor: const Color(0xFF0A0E1A),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF0D1220),
            foregroundColor: Colors.white,
            elevation: 0,
          ),
        ),
        
        home: const HomeScreen(),
      ),

    );
  }
}