import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:tiddart/firebase_options.dart';
import 'bindings/app_binding.dart';
import 'routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔥 Initialiser Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const TiddartApp());
}

class TiddartApp extends StatelessWidget {
  const TiddartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tiddart',
      initialBinding: AppBinding(),
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFFCEEDB),
        primarySwatch: Colors.brown,
        textTheme: GoogleFonts.alkalamiTextTheme(
          Theme.of(context).textTheme,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFCEEDB),
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.brown),
          titleTextStyle: TextStyle(
            color: Colors.brown,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      initialRoute: AppRoutes.welcome,
      getPages: AppPages.routes,
    );
  }
}
