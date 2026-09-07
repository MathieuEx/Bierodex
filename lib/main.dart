import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/supabase_config.dart';
import 'screens/world_globe_screen.dart';
import 'services/beer_collection_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: SupabaseConfig.url,
    publishableKey: SupabaseConfig.anonKey,
  );
  await BeerCollectionService.instance.load();
  runApp(const BierodexApp());
}

SupabaseClient get supabase => Supabase.instance.client;

class BierodexApp extends StatelessWidget {
  const BierodexApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seedColor = Color(0xFFC9752B);
    return MaterialApp(
      title: 'Bierodex',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: seedColor),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const WorldGlobeScreen(),
    );
  }
}
