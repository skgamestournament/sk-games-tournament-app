import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'main.dart'; // To access the 'supabase' client

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // A future to hold the tournament data
  late final Future<List<Map<String, dynamic>>?> _tournamentsFuture;

  @override
  void initState() {
    super.initState();
    // Fetch tournaments when the page loads
    _tournamentsFuture = _fetchTournaments();
  }
  
  // Function to fetch data from Supabase
  Future<List<Map<String, dynamic>>?> _fetchTournaments() async {
    try {
      final data = await supabase
          .from('tournaments')
          .select()
          .eq('status', 'upcoming') // Fetch only upcoming tournaments
          .order('match_time', ascending: true);
      return data;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching tournaments: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Map<String, dynamic>>?>(
        future: _tournamentsFuture,
        builder: (context, snapshot) {
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
                onPressed: () {
                  // TODO: Implement join logic
                   ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Join functionality will be added soon!')),
                  );
                },
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
