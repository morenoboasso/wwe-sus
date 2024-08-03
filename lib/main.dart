import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get_storage/get_storage.dart';
import 'package:vibration/vibration.dart';
import 'package:wwe_bets/routes.dart';
import 'package:wwe_bets/services/db_service.dart';
import 'package:wwe_bets/style/color_style.dart';
import 'package:wwe_bets/style/text_style.dart';
import 'package:wwe_bets/widgets/login/login_input.dart';
import 'firebase_options.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await GetStorage.init(); // Inizializza GetStorage


    runApp(const MyApp(initialRoute: AppRoutes.mainScreen));
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({required this.initialRoute, super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'CodeBets',
      initialRoute: initialRoute,
      getPages: AppRoutes.routes,
    );
  }
}

//login
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get isLandscape =>
      MediaQuery.of(context).orientation == Orientation.landscape;

  @override
  Widget build(BuildContext context) {
    String userName = '';
    DbService dbService = DbService();

    return Scaffold(
      body: isLandscape
          ? SingleChildScrollView(
        child: _buildContent(userName, dbService),
      )
          : _buildContent(userName, dbService),
    );
  }

  Widget _buildContent(String userName, DbService dbService) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/bg.png"),
              fit: BoxFit.cover,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _animation.value,
                      child: RotationTransition(
                        turns: _animation,
                        child: Column(
                          children: [
                            Image.asset(
                              "assets/logo.png",
                              width: isLandscape
                                  ? MediaQuery.of(context).size.width * 0.4
                                  : MediaQuery.of(context).size.width * 0.6,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20,),
                Text("Login", style: TextStyleBets.titleBlue,
                ),
                const SizedBox(height: 40,),
                SizedBox(
                  height: 60,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: LoginTextField(
                            onChanged: (value) {
                              userName = value.trim();
                            },
                          ),
                        ),
                        const SizedBox(width: 5),
                        ElevatedButton(
                          onPressed: () async {
                            if (userName.isNotEmpty) {
                              userName = userName[0].toUpperCase() +
                                  userName.substring(1);
                            }
                            bool nameExists = await dbService
                                .checkUserNameExists(userName);
                            if (nameExists) {
                              Get.offNamed(AppRoutes.mainScreen);
                              GetStorage().write('userName', userName);
                              FocusScope.of(context).unfocus();
                            } else {
                              Vibration.vibrate(
                                  duration: 200, amplitude: 128);
                              Get.snackbar(
                                'Accesso Fallito',
                                'Sei così stupido che non sai il tuo nome?',
                                icon: const Icon(
                                  Icons.error_sharp,
                                  color: Colors.white,
                                ),
                                backgroundColor: Colors.red,
                                colorText: Colors.white,
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            shape: const CircleBorder(),
                            backgroundColor: ColorsBets.blueHD,
                            padding: const EdgeInsets.all(10),
                          ),
                          child: const Icon(
                            Icons.arrow_forward,
                            size: 30,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40,),
              ],
            ),
          ),
        ),
        const Positioned(
          left: 0, right: 0, bottom: 10,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                "Questo gioco crea dipendenza, pertanto è vietato ai minori di 18.",
                style: TextStyle(
                  color: Colors.black45,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ],
    );
  }
}