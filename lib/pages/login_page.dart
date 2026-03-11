import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:wwe_bets/routes/routes.dart';
import 'package:wwe_bets/style/color_style.dart';
import 'package:wwe_bets/style/text_style.dart';
import 'package:wwe_bets/widgets/login/login_input.dart';
import 'package:wwe_bets/services/db_service.dart';
import '../repositories/user_repository.dart';
import '../services/firebase/firebase_auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  String? _errorMessage;
  String _userName = '';
  List<String> _cachedUserNames = [];
  bool _hasLoadedNames = false;

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

  bool get isLandscape => MediaQuery.of(context).orientation == Orientation.landscape;

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
              image: AssetImage("assets/bg.jpeg"),
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
                const SizedBox(height: 20),
                 Text("Accedi",style: MemoText.loginText,),
                const SizedBox(height: 40),
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
                              _userName = value.trim();
                            },
                            onSuggestionsRequested: () async {
                              if (!_hasLoadedNames) {
                                _cachedUserNames = await dbService.fetchUserNames();
                                _hasLoadedNames = true;
                              }
                              return _cachedUserNames;
                            },
                          ),
                        ),
                        const SizedBox(width: 5),
                        ElevatedButton(
                          onPressed: () async {
                            await _handleLogin(_userName, dbService);
                          },
                          style: ElevatedButton.styleFrom(
                            shape: const CircleBorder(),
                            backgroundColor: ColorsBets.whiteHD,
                            padding: const EdgeInsets.all(10),
                            side: const BorderSide(color: ColorsBets.blackHD, width: 1),
                          ),
                          child: const Icon(
                            Icons.arrow_forward,
                            size: 35,
                            color: ColorsBets.blackHD,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: _errorMessage == null
                      ? const SizedBox.shrink()
                      : Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30.0),
                          child: Container(
                            key: ValueKey(_errorMessage),
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.22),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.redAccent.withValues(alpha: 0.6), width: 1.2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.redAccent.withValues(alpha: 0.25),
                                  blurRadius: 18,
                                  spreadRadius: 1,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline, color: Colors.white),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style: MemoText.thirdRowMatchInfo.copyWith(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleLogin(String userName, DbService dbService) async {
    userName = userName.trim();
    if (userName.isEmpty) {
      if (!mounted) return;
      setState(() => _errorMessage = 'Inserisci un nome valido.');
      return;
    }
    userName = userName[0].toUpperCase() + userName.substring(1);
    try {
      await FirebaseAuthService().ensureSignedIn();
    } catch (_) {
      if (!mounted) return;
      setState(() => _errorMessage = 'Errore di connessione. Riprova.');
      return;
    }
    final userRepository = UserRepository();
    final nameExists = await dbService.checkUserNameExists(userName);
    if (!mounted) return;
    try {
      setState(() => _errorMessage = null);
      if (nameExists) {
        try {
          await userRepository.migrateUserByNameToCurrent(userName);
        } catch (_) {
          // Ignore migration errors and continue with local profile creation.
        }
      }
      await userRepository.ensureCurrentUserProfile(name: userName);
      Get.offNamed(AppRoutes.mainScreen);
      GetStorage().write('userName', userName);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Errore di connessione. Riprova.';
      });
    }
  }
}
