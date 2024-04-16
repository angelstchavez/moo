import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:moo/features/app/splash_screen/splash_screen.dart';
import 'package:moo/features/user_auth/presentation/pages/home_page.dart';
import 'package:moo/features/user_auth/presentation/pages/login_page.dart';
import 'package:moo/features/user_auth/presentation/pages/sign_up_page.dart';
import 'package:moo/features/user_auth/presentation/widgets/navigation_bar.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: const FirebaseOptions(
      apiKey: "AIzaSyBOkRQvsxoUvvG_k-3kxY8p55fjwegINTM",
      appId: "1:173997870344:web:fda390459bc809ff7530bd",
      messagingSenderId: "173997870344",
      projectId: "moo-app-6485e",
    ));
  }
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Moo',
      routes: {
        '/': (context) => const SplashScreen(
              child: LoginPage(),
            ),
        '/login': (context) => const LoginPage(),
        '/signUp': (context) => const SignUpPage(),
        '/home': (context) => const NavBar(),
      },
    );
  }
}
