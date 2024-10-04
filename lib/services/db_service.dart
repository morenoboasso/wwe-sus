import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);

    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> showNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      channelDescription: 'your_channel_description',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );

    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    await _flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
    );
  }
}

class DbService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GetStorage _storage = GetStorage();
  final NotificationService _notificationService = NotificationService();

  DbService() {
    _notificationService.init(); // Inizializza il servizio di notifiche
  }

  Future<String?> getUserName() async {
    return _storage.read('userName');
  }

  Future<bool> checkUserNameExists(String userName) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('name', isEqualTo: userName)
          .limit(1)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking username: $e');
      return false;
    }
  }

  Future<void> createMatchCard(String payperview, String title, String type, List<String> wrestlers) async {
    try {
      await _firestore.collection('matchCards').add({
        'payperview': payperview,
        'title': title,
        'type': type,
        'wrestlers': wrestlers,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error creating match card: $e');
    }
  }

  Future<void> saveUserSelection(String matchId, String selectedWrestler) async {
    final userName = _storage.read('userName');

    if (userName != null) {
      try {
        await _firestore.collection('userSelections').add({
          'userName': userName,
          'matchId': matchId,
          'selectedWrestler': selectedWrestler,
          'timestamp': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        debugPrint('Error saving user selection: $e');
      }
    } else {
      debugPrint('No user name found in storage.');
    }
  }

  Future<String?> getUserSelection(String matchId) async {
    final userName = _storage.read('userName');

    if (userName != null) {
      try {
        final querySnapshot = await _firestore
            .collection('userSelections')
            .where('userName', isEqualTo: userName)
            .where('matchId', isEqualTo: matchId)
            .limit(1)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          return querySnapshot.docs.first['selectedWrestler'] as String?;
        }
      } catch (e) {
        debugPrint('Error getting user selection: $e');
      }
    }

    return null;
  }

  Future<int> getVoteCount(String matchId) async {
    final querySnapshot = await _firestore
        .collection('userSelections')
        .where('matchId', isEqualTo: matchId)
        .get();

    return querySnapshot.docs.length;
  }

  Future<String?> getMatchWinner(String matchId) async {
    final doc = await _firestore.collection('matchCards').doc(matchId).get();
    return doc.data()?['winner'] as String?;
  }

  Future<void> updateMatchResult(String matchId, String winner) async {
    try {
      await _firestore.collection('matchCards').doc(matchId).update({
        'winner': winner,
        'status': 'completed',
      });
    } catch (e) {
      debugPrint('Error updating match result: $e');
    }
  }

  Future<void> updateUserScore(String matchId, String winner) async {
    final userName = await _storage.read('userName');

    if (userName != null) {
      try {
        final querySnapshot = await _firestore
            .collection('userSelections')
            .where('matchId', isEqualTo: matchId)
            .get();

        // Get users who selected the winner
        final usersWhoWon = querySnapshot.docs
            .where((doc) => doc['selectedWrestler'] == winner)
            .map((doc) => doc['userName'])
            .toSet();

        // Update scores for users who won and notify them
        for (final user in usersWhoWon) {
          await _firestore.collection('users').doc(user).update({
            'points': FieldValue.increment(1),
          });

          // Notify for the victory
          await _notificationService.showNotification(
            'Hai vinto!',
            'Grande, Hai guadagnato un punto!',
          );
        }

        // Notify users who lost
        for (final doc in querySnapshot.docs) {
          final participantUserName = doc['userName'];
          if (!usersWhoWon.contains(participantUserName)) {
            await _notificationService.showNotification(
              'Hai perso!',
              'Mispiace, non hai indovinato!',
            );
          }
        }
      } catch (e) {
        debugPrint('Error updating user score: $e');
      }
    } else {
      debugPrint('No user name found in storage.');
    }
  }
  
  Future<List<Map<String, dynamic>>> getUserRanking() async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .orderBy('points', descending: true)
          .get();

      return querySnapshot.docs.map((doc) => {
        'name': doc['name'],
        'points': doc['points'],
        'pfp': doc['pfp'],
      }).toList();
    } catch (e) {
      debugPrint('Error getting user ranking: $e');
      return [];
    }
  }

  Future<void> deleteMatchCard(String matchId) async {
    final batch = FirebaseFirestore.instance.batch();

    batch.delete(_firestore.collection('matchCards').doc(matchId));

    final userSelectionsSnapshot = await _firestore
        .collection('userSelections')
        .where('matchId', isEqualTo: matchId)
        .get();

    for (var doc in userSelectionsSnapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }
}
