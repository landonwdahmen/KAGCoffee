import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/material.dart';
import 'screens/login.dart';
import 'screens/register.dart';
import 'screens/home.dart';
import 'screens/account.dart';
import 'screens/order.dart';
import 'screens/search.dart';
import 'screens/contact.dart';
import 'screens/editAccount.dart';
import 'screens/checkout.dart';
import 'screens/orderPlaced.dart';
import 'screens/coffeeDisc.dart';
import 'screens/bagelDisc.dart';
import 'screens/genDisc.dart';
import 'screens/createPost.dart';
import 'screens/indivPost.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Activate App Check with the Play Integrity provider.
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
  );

  // Optional: Print the token to verify if needed.
  var tokenResult = await FirebaseAppCheck.instance.getToken();
  // ignore: avoid_print
  print("App Check token: $tokenResult");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KagCoffee',
      initialRoute: '/',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF5F5DC), // Light beige background
        primaryColor: const Color(0xFF800000), // Maroon primary color
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
          ),
        ),
      ),
      routes: {
        '/': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/home': (context) => const HomePage(),
        '/account': (context) => const AccountPage(),
        '/order': (context) => const OrderPage(),
        '/search': (context) => const SearchPage(),
        '/contact': (context) => const ContactPage(),
        '/editAccount': (context) => const EditAccountPage(),
        '/checkout': (context) => const CheckoutPage(),
        '/orderPlaced': (context) => const OrderPlacedPage(),
        '/coffeeDisc': (context) => const CoffeeDiscPage(),
        '/bagelDisc': (context) => const BagelDiscPage(),
        '/genDisc': (context) => const GenDiscPage(),
        '/createPost': (context) => const CreatePostPage(),
      },
      // Use onGenerateRoute for routes that require parameters.
      onGenerateRoute: (settings) {
        if (settings.name == '/indivPost') {
          final args = settings.arguments;
          if (args is Map<String, dynamic> && args['postId'] is String) {
            return MaterialPageRoute(
              builder: (context) => IndivPostPage(postId: args['postId']),
            );
          } else {
            // If no valid postId is provided, show an error page.
            return MaterialPageRoute(
              builder: (context) => Scaffold(
                appBar: AppBar(title: const Text("Error")),
                body: const Center(child: Text("No valid post ID provided.")),
              ),
            );
          }
        }
        // Fallback route.
        return MaterialPageRoute(builder: (context) => const LoginPage());
      },
    );
  }
}