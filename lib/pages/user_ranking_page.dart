import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/db_service.dart';
import '../style/text_style.dart';

class RankingPage extends StatefulWidget {
  const RankingPage({super.key});

  @override
  _RankingPageState createState() => _RankingPageState();
}

class _RankingPageState extends State<RankingPage> {
  late Future<List<Map<String, dynamic>>> _rankingFuture;

  @override
  void initState() {
    super.initState();
    _rankingFuture = DbService().getUserRanking();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Classifica', style: MemoText.createMatchCardButton),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'reset') {
                await _resetRanking();
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'reset',
                child: Text('Reset classifica'),
              ),
            ],
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/bg.jpeg',
              fit: BoxFit.cover,
            ),
          ),
          // SafeArea with ranking list
          SafeArea(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _rankingFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No data available'));
                } else {
                  final ranking = snapshot.data!;
                  final totalUsers = ranking.length;

                  // Function to get the emoji based on the position
                  String getPositionEmoji(int index) {
                    if (index == 0) return '🏆'; // First place
                    if (index == 1) return '🥈'; // Second place
                    if (index == 2) return '🥉'; // Third place
                    if (index == totalUsers - 1) return '💩'; // Last place
                    return '• ${index + 1}'; // For other places
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: ranking.length,
                    itemBuilder: (context, index) {
                      final user = ranking[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16.0),
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 6.0,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Position emoji
                            Padding(
                              padding: const EdgeInsets.only(right: 12.0),
                              child: Text(
                                getPositionEmoji(index),
                                style: const TextStyle(
                                  fontSize: 30.0, // Increased size for the position emoji
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            // Profile picture with shadow and border
                            Container(
                              width: 60.0,
                              height: 60.0,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 8.0,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                                border: Border.all(
                                  color: Colors.black, // Border color
                                  width: 2.0, // Border width
                                ),
                              ),
                              child: CircleAvatar(
                                radius: 30.0,
                                backgroundImage: NetworkImage(user['pfp']),
                                backgroundColor: Colors.white,
                                // Add a border to the CircleAvatar
                                foregroundColor: Colors.black,
                              ),
                            ),
                            const SizedBox(width: 12.0),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user['name'],
                                    style: const TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Text(
                                    'Punteggio: ${user['points']}',
                                    style: const TextStyle(
                                      fontSize: 14.0,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
  Future<void> _resetRanking() async {
    try {
      final usersSnapshot = await FirebaseFirestore.instance.collection('users').get();
      for (var doc in usersSnapshot.docs) {
        await doc.reference.update({'points': 0});
      }
      setState(() {
        _rankingFuture = DbService().getUserRanking();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Classifica resettata!')),
      );
    } catch (e) {
      debugPrint('Errore nel reset della classifica: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Errore nel reset della classifica')),
      );
    }
  }
}
