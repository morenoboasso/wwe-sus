import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get_storage/get_storage.dart';
import 'package:wwe_bets/routes/routes.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';
import 'services/firebase/firebase_auth_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    // Ignore missing .env in builds where secrets are injected differently.
  }
  debugPrint(
    '[ENV] loaded=${dotenv.isInitialized} '
    'gemini=${dotenv.env['GEMINI_API_KEY']?.isNotEmpty == true} '
    'aiUser=${dotenv.env['AI_USER_ID']?.isNotEmpty == true}',
  );

  // Initialize Firebase safely (avoid duplicate-app on hot restart)
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } else {
      Firebase.app();
    }
  } on FirebaseException catch (e) {
    if (e.code == 'duplicate-app') {
      Firebase.app();
    } else {
      rethrow;
    }
  }

  final authService = FirebaseAuthService();
  await authService.ensureSignedIn();
  await GetStorage.init();

  final player = AudioPlayer();
  await player.setAudioContext(
    AudioContext(
      android: const AudioContextAndroid(
        audioFocus: AndroidAudioFocus.none,
        usageType: AndroidUsageType.media,
        contentType: AndroidContentType.music,
      ),
      iOS: AudioContextIOS(
        category: AVAudioSessionCategory.playback,
        options: const {AVAudioSessionOptions.mixWithOthers},
      ),
    ),
  );
  await player.setVolume(0.35);
  await player.play(AssetSource('sound.mp3'));

  final box = GetStorage();
  final userName = box.read('userName');

  runApp(ProviderScope(child: MyApp(initialRoute: userName != null ? AppRoutes.mainScreen : AppRoutes.login)));
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({required this.initialRoute, super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'WWE PPV',
      initialRoute: initialRoute,
      getPages: AppRoutes.routes,
    );
  }
}
