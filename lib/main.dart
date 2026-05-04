import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/constants/supabase_constants.dart';
import 'theme/app_theme.dart';
import 'screens/auth/login_screen.dart';
import 'screens/main_layout.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseConstants.supabaseUrl,
    anonKey: SupabaseConstants.supabaseAnonKey,
  );

  runApp(const VzhaApp());
}

class VzhaApp extends StatelessWidget {
  const VzhaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VZHA',
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      home: Supabase.instance.client.auth.currentSession == null
          ? const LoginScreen()
          : const MainLayout(),
    );
  }
}
