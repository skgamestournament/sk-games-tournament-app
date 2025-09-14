import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// IMPORTANT: We will create this login_page.dart file in the next step.
// For now, this line will show an error, but that's okay.
// import 'login_page.dart'; 

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  // =================================================================
  // == IMPORTANT: Replace with YOUR Supabase URL and Anon Key ==
  // =================================================================
  await Supabase.initialize(
    url: 'https://efzutfrykarzqbfurkhw.supabase.co', // Paste your Project URL here
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVmenV0ZnJ5a2FyenFiZnVya2h3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc4Mzg2ODMsImV4cCI6MjA3MzQxNDY4M30.MERlzLikedbA8OzMalSTbtepW0VsErjDQY3EzQLuyQ0', // Paste your anon public key here
  );

  runApp(const MyApp());
}

// Helper variable to access the Supabase client easily
final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SK Games Tournament',
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.deepPurple,
        scaffoldBackgroundColor: const Color(0xFF121212),
        // You can add more theme customizations here
      ),
      // We will set the home page to LoginPage in the next step.
      // For now, we are just setting up the connection.
      home: const Scaffold(
        body: Center(
          child: Text('App Initialized!'),
        ),
      ),
    );
  }
}
