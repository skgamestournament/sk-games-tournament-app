import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'main.dart'; // To access the 'supabase' client

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Map<String, dynamic>>?> _tournamentsFuture;
  bool _isJoining = false;

  @override
  void initState() {
    super.initState();
    _tournamentsFuture = _fetchTournaments();
  }
  
  Future<List<Map<String, dynamic>>?> _fetchTournaments() async {
    try {
      final data = await supabase
          .from('tournaments')
          .select()
          .eq('status', 'upcoming')
          .order('match_time', ascending: true);
      return data;
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Error fetching tournaments: ${e.toString()}');
      }
      return null;
    }
  }

  Future<void> _joinTournament(int tournamentId, int entryFee) async {
    // Show confirmation dialog
    final wantsToJoin = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Join'),
          content: Text('Are you sure you want to join this tournament for ₹$entryFee?'),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
            TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Join')),
          ],
        );
      },
    );

    if (wantsToJoin != true) return; // User cancelled

    setState(() => _isJoining = true);

    try {
      final result = await supabase.rpc('join_tournament', params: {
        'tournament_id_to_join': tournamentId,
      });

      if (mounted) {
        if (result == 'SUCCESS') {
          _showSuccessSnackBar('Successfully joined the tournament!');
          // Refresh the list to reflect any changes
          setState(() {
            _tournamentsFuture = _fetchTournaments();
          });
        } else if (result == 'INSUFFICIENT_BALANCE') {
          _showErrorSnackBar('Insufficient balance in your wallet.');
        } else if (result == 'ALREADY_JOINED') {
          _showErrorSnackBar('You have already joined this tournament.');
        } else {
          _showErrorSnackBar('An unknown error occurred.');
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Error: ${e.toString()}');
      }
    }

    setState(() => _isJoining = false);
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isJoining 
        ? const Center(child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
        : FutureBuilder<List<Map<String, dynamic>>?>(
        future: _tournamentsFuture,
        builder: (context, snapshot) {
          // ... (rest of the builder logic remains the same)
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || snapshot.data == null) {
            return const Center(child: Text('Error loading tournaments or no data.'));
          }
          if (snapshot.data!.isEmpty) {
            return const Center(child: Text('No upcoming tournaments right now.'));
          }

          final tournaments = snapshot.data!;

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _tournamentsFuture = _fetchTournaments();
              });
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(12.0),
              itemCount: tournaments.length,
              itemBuilder: (context, index) {
                final tournament = tournaments[index];
                return _buildTournamentCard(tournament);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildTournamentCard(Map<String, dynamic> tournament) {
    final matchTime = DateTime.parse(tournament['match_time']);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      color: Colors.grey[850],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tournament['title'],
              style: GoogleFonts.orbitron(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Game: ${tournament['game_name']}',
              style: const TextStyle(fontSize: 16, color: Colors.white70),
            ),
            const SizedBox(height: 8),
            Text(
              'Time: ${matchTime.day}/${matchTime.month} - ${matchTime.hour}:${matchTime.minute.toString().padLeft(2, '0')}',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const Divider(height: 24, color: Colors.grey),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('PRIZE POOL', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    Text(
                      '₹${tournament['prize_pool']}',
                      style: const TextStyle(fontSize: 18, color: Colors.greenAccent, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('ENTRY FEE', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    Text(
                      '₹${tournament['entry_fee']}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                )
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _joinTournament(tournament['id'], tournament['entry_fee']),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurpleAccent),
                child: const Text('Join Now', style: TextStyle(color: Colors.white)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
