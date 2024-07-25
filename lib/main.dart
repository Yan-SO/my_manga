import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_mangas/src/ui/screens/home_page.dart';
import 'package:my_mangas/src/ui/theme/colors_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      title: 'My Mangas',
      theme: ThemeData(
        colorScheme: MyColorsTheme.myColors(),
        useMaterial3: true,
      ),
      home: SafeArea(child: HomePage()),
    );
  }
}
