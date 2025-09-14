import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'main.dart'; // To access the 'supabase' client

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _usernameController = TextEditingController();
  final _gameIdController = TextEditingController();
  String _userEmail = 'Loading...';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      final userId = supabase.auth.currentUser!.id;
      final data = await supabase
          .from('users')
          .select('username, game_id')
          .eq('id', userId)
          .single();

      if (mounted) {
        _usernameController.text = data['username'] ?? '';
        _gameIdController.text = data['game_id'] ?? '';
        _userEmail = supabase.auth.currentUser!.email!;
      }
    } catch (e) {
      _showErrorSnackBar('Could not load profile.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _updateProfile() async {
    setState(() => _isLoading = true);
    try {
      final userId = supabase.auth.currentUser!.id;
      final username = _usernameController.text.trim();
      final gameId = _gameIdController.text.trim();

      await supabase.from('users').update({
        'username': username,
        'game_id': gameId,
      }).eq('id', userId);
      
      _showSuccessSnackBar('Profile updated successfully!');

    } catch (e) {
      _showErrorSnackBar('Could not update profile.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

   void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _gameIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20.0),
              children: [
                Center(
                  child: Text(
                    'My Profile',
                    style: GoogleFonts.orbitron(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 30),

                // Email field (non-editable)
                Text('Email Address', style: TextStyle(color: Colors.grey[400])),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[850],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(_userEmail, style: const TextStyle(fontSize: 16)),
                ),
                const SizedBox(height: 20),

                // Username field
                Text('Username', style: TextStyle(color: Colors.grey[400])),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    hintText: 'Enter your public username',
                    filled: true,
                    fillColor: Color(0xFF2a2a2a)
                  ),
                ),
                const SizedBox(height: 20),

                // Game ID field
                Text('In-Game ID (BGMI/FreeFire Name)', style: TextStyle(color: Colors.grey[400])),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _gameIdController,
                   decoration: const InputDecoration(
                    hintText: 'Enter your game ID',
                    filled: true,
                    fillColor: Color(0xFF2a2a2a)
                  ),
                ),
                const SizedBox(height: 40),

                // Update button
                ElevatedButton(
                  onPressed: _updateProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurpleAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: const Text('UPDATE PROFILE'),
                ),
              ],
            ),
    );
  }
}
