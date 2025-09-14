import 'package:flutter/material.dart';
import 'main.dart'; // To access the 'supabase' client
import 'login_page.dart'; // To navigate back to login page on logout

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = supabase.auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await supabase.auth.signOut();
              if (context.mounted) {
                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginPage()));
              }
            },
          )
        ],
      ),
      body: Center(
        child: Text('Welcome, ${user?.email ?? 'Player'}!'),
      ),
    );
  }
}
