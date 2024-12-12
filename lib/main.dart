import 'package:final_goodness_ade/screens/splash_screen.dart';
import 'package:final_goodness_ade/utils/app_state.dart';
import 'package:final_goodness_ade/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load();
  runApp(ChangeNotifierProvider(
      create: (context) => AppState(), child: const MainApp()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.theme,
      home: const SplashScreen(),
    );
  }
}
