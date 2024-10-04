import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get_storage/get_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wwe_bets/routes/routes.dart';
import 'package:wwe_bets/services/db_service.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await GetStorage.init();

  // Richiesta del permesso di inviare notifiche
  await Permission.notification.request();

  await NotificationService().init();

  final box = GetStorage();
  final userName = box.read('userName');

  runApp(MyApp(initialRoute: userName != null ? AppRoutes.mainScreen : AppRoutes.login));
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
