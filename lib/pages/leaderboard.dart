import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import '../services/db_service.dart';
import '../services/leaderboard_filter.dart';
import '../style/color_style.dart';
import '../style/text_style.dart';
import '../widgets/leaderboard/other_user_stats_dialog.dart';
import '../widgets/leaderboard/user_card_leaderboard.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  _LeaderboardPageState createState() => _LeaderboardPageState();
}

enum OrderBy { highestScore, lowestScore, mostCreatedBets, mostWonBets, mostLostBets }

class _LeaderboardPageState extends State<LeaderboardPage> with TickerProviderStateMixin {
  Map<String, dynamic> _usersData = {};
  OrderBy _orderBy = OrderBy.highestScore;
  String _appBarTitle = 'Classifica';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUsersData();
  }

  Future<void> _fetchUsersData() async {
    setState(() {
      _isLoading = true;
    });
    Map<String, dynamic> usersData = await DbService().getUsersData();
    setState(() {
      _usersData = usersData;
      _isLoading = false;
    });
  }

  List<MapEntry<String, int>> _getSortedUsers() {
    List<MapEntry<String, int>> sortedUsers = _usersData.entries
        .where((entry) => entry.key != 'Admin')
        .map((entry) => MapEntry<String, int>(entry.key, _getOrderByValue(entry)))
        .toList();

    sortedUsers.sort((a, b) => _compareValues(a.value, b.value));
    return sortedUsers;
  }

  int _getOrderByValue(MapEntry<String, dynamic> entry) {
    switch (_orderBy) {
      case OrderBy.highestScore:
        return entry.value['score'];
      case OrderBy.lowestScore:
        return entry.value['score'];
      case OrderBy.mostCreatedBets:
        return entry.value['scommesse_create'];
      case OrderBy.mostWonBets:
        return entry.value['scommesse_vinte'];
      case OrderBy.mostLostBets:
        return entry.value['scommesse_perse'];
    }
  }

  int _compareValues(int a, int b) {
    if (_orderBy == OrderBy.lowestScore) {
      return a.compareTo(b);
    }
    return b.compareTo(a);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/bg.jpeg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Column(
            children: [
              AppBar(
                title: AutoSizeText(
                  _appBarTitle,
                  style: TextStyleBets.activeBetTitle,
                  minFontSize: 14,
                  maxLines: 1,
                ),
                centerTitle: true,
                actions: [
                  LeaderboardFilter(
                    orderBy: _orderBy,
                    onSelected: (OrderBy result) {
                      setState(() {
                        _orderBy = result;
                      });
                    },
                    onUpdateTitle: (String newTitle) {
                      setState(() {
                        _appBarTitle = newTitle;
                      });
                    },
                  ),
                ],
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
              Expanded(child: _buildLeaderboard()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboard() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: ColorsBets.blueHD,),
      );
    }
    List<MapEntry<String, int>> sortedUsers = _getSortedUsers();
    return RefreshIndicator(
      color: ColorsBets.yellowHD,
      backgroundColor: ColorsBets.whiteHD,
      onRefresh: _fetchUsersData,
      child: ListView.builder(
        itemCount: sortedUsers.length,
        itemBuilder: (context, index) {
          final userName = sortedUsers[index].key;
          final score = sortedUsers[index].value;
          final userPfp = _usersData[userName]['pfp'];
          final scommesseCreate = _usersData[userName]['scommesse_create'];
          final scommesseVinte = _usersData[userName]['scommesse_vinte'];
          final scommessePerse = _usersData[userName]['scommesse_perse'];

          return UserCard(
            index: index,
            userName: userName,
            score: score,
            userPfp: userPfp,
            totalUsers: sortedUsers.length,
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return UserModal(
                    userPfp: userPfp,
                    userName: userName,
                    score: score,
                    scommesseCreate: scommesseCreate,
                    scommesseVinte: scommesseVinte,
                    scommessePerse: scommessePerse,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}