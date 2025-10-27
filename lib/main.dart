import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get/get.dart';
import 'authentication.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://xxgmyjumrvyaffrdbegg.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inh4Z215anVtcnZ5YWZmcmRiZWdnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQxMDUyOTksImV4cCI6MjA2OTY4MTI5OX0.RtBhqxuroi-Lwrhf4sbVlgp-Dr2dg6I2NI3iRwBHHVc',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Third Eye',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        fontFamily: 'Rubik',
      ),
      home: const AuthWrapper(), // Start with authentication check
      debugShowCheckedModeBanner: false,
    );
  }
}
