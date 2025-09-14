import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'main.dart'; // To access the 'supabase' client

class MyTournamentsPage extends StatefulWidget {
  const MyTournamentsPage({super.key});

  @override
  State<MyTournamentsPage> createState() => _MyTournamentsPageState();
}

class _MyTournamentsPageState extends State<MyTournamentsPage> {
  late Future<List<Map<String, dynamic>>> _joinedTournamentsFuture;

  @override
  void initState() {
    super.initState();
    _joinedTournamentsFuture = _fetchJoinedTournaments();
  }

  Future<List<Map<String, dynamic>>> _fetchJoinedTournaments() async {
    final userId = supabase.auth.currentUser!.id;
    try {
      // Fetch participants data and the related tournament details using a join
      final response = await supabase
          .from('participants')
          .select('*, tournaments(*)') // This '*' fetches all columns from participants, and 'tournaments(*)' fetches all related tournament data
          .eq('user_id', userId);
      return response;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching matches: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false, // No back button
          toolbarHeight: 0, // Hide the app bar itself, but keep it for the TabBar
          bottom: const TabBar(
            indicatorColor: Colors.deepPurpleAccent,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: 'UPCOMING / LIVE'),
              Tab(text: 'COMPLETED'),
            ],
          ),
        ),
        body: FutureBuilder<List<Map<String, dynamic>>>(
          future: _joinedTournamentsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return const Center(child: Text('An error occurred.'));
            }
            final allMatches = snapshot.data ?? [];

            final upcomingMatches = allMatches.where((match) => match['tournaments']['status'] != 'completed').toList();
            final completedMatches = allMatches.where((match) => match['tournaments']['status'] == 'completed').toList();

            return TabBarView(
              children: [
                // Upcoming/Live Tab
                _buildMatchList(upcomingMatches, isUpcoming: true),
                // Completed Tab
                _buildMatchList(completedMatches, isUpcoming: false),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildMatchList(List<Map<String, dynamic>> matches, {required bool isUpcoming}) {
    if (matches.isEmpty) {
      return Center(child: Text('No ${isUpcoming ? 'upcoming' : 'completed'} matches.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12.0),
      itemCount: matches.length,
      itemBuilder: (context, index) {
        final match = matches[index];
        final tournament = match['tournaments']; // The tournament data is nested
        return _buildMatchCard(tournament);
      },
    );
  }

  Widget _buildMatchCard(Map<String, dynamic> tournament) {
    final matchTime = DateTime.parse(tournament['match_time']);
    final isLive = tournament['status'] == 'live';

    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      color: isLive ? Colors.purple[900] : Colors.grey[850],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isLive ? const BorderSide(color: Colors.deepPurpleAccent, width: 1.5) : BorderSide.none,
      ),
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
            Text('Game: ${tournament['game_name']}'),
            Text('Time: ${matchTime.day}/${matchTime.month} - ${matchTime.hour}:${matchTime.minute.toString().padLeft(2, '0')}'),
            
            // Show Room ID and Password if the match is live
            if (isLive && tournament['room_id'] != null) ...[
              const Divider(height: 24, color: Colors.grey),
              Text('Room ID:', style: TextStyle(color: Colors.grey[400])),
              SelectableText(
                tournament['room_id'],
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.greenAccent),
              ),
              const SizedBox(height: 8),
              Text('Password:', style: TextStyle(color: Colors.grey[400])),
              SelectableText(
                tournament['room_password'],
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.greenAccent),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
