import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/constants/supabase_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme/app_theme.dart';
import 'theme/theme_provider.dart';
import 'screens/landing_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/main_layout.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseConstants.supabaseUrl,
    anonKey: SupabaseConstants.supabaseAnonKey,
  );

  final prefs = await SharedPreferences.getInstance();
  final onboardingComplete = prefs.getBool('onboarding_complete') ?? false;

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: VzhaApp(showOnboarding: !onboardingComplete),
    ),
  );
}

class VzhaApp extends StatefulWidget {
  final bool showOnboarding;
  const VzhaApp({super.key, required this.showOnboarding});

  @override
  State<VzhaApp> createState() => _VzhaAppState();
}

class _VzhaAppState extends State<VzhaApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _setupAuthListener();
  }

  void _setupAuthListener() {
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      if (event == AuthChangeEvent.signedIn) {
        _navigatorKey.currentState?.pushNamedAndRemoveUntil('/dashboard', (route) => false);
      } else if (event == AuthChangeEvent.signedOut) {
        _navigatorKey.currentState?.pushNamedAndRemoveUntil('/login', (route) => false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: 'VZHA',
      theme: AppTheme.getTheme(
        primaryColor: themeProvider.primaryColor,
        fontFamily: themeProvider.fontFamily,
        isDarkMode: themeProvider.isDarkMode,
        fontColor: themeProvider.fontColor,
      ),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(themeProvider.fontSizeScale),
          ),
          child: child!,
        );
      },
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (context) => widget.showOnboarding ? const OnboardingScreen() : const LandingScreen(),
        '/splash': (context) => const SplashScreen(),
        '/dashboard': (context) => const MainLayout(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
      },
      initialRoute: '/splash',
    );
  }
}
