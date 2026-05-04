import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/constants/supabase_constants.dart';
import 'theme/app_theme.dart';
import 'theme/theme_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/main_layout.dart';
import 'screens/landing_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseConstants.supabaseUrl,
    anonKey: SupabaseConstants.supabaseAnonKey,
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const VzhaApp(),
    ),
  );
}

class VzhaApp extends StatelessWidget {
  const VzhaApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return MaterialApp(
      title: 'VZHA',
      theme: AppTheme.getTheme(themeProvider.primaryColor, themeProvider.fontFamily),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(themeProvider.fontSizeScale),
          ),
          child: child!,
        );
      },
      debugShowCheckedModeBanner: false,
      home: const LandingScreen(),
    );
  }
}
