import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/user_provider.dart';
import 'providers/course_group_provider.dart';
import 'providers/batch_provider.dart';
import 'providers/stats_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/teacher/teacher_dashboard.dart';
import 'screens/student/student_dashboard.dart';
import 'constants/app_constants.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const GauravanaiApp());
}

class GauravanaiApp extends StatelessWidget {
  const GauravanaiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => UserProvider()),
          ChangeNotifierProvider(create: (_) => CourseGroupProvider()),
          ChangeNotifierProvider(create: (_) => BatchProvider()),
          ChangeNotifierProvider(create: (_) => StatsProvider()),
        ],
      child: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          return MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(AppColors.primaryColorValue),
                brightness: Brightness.light,
              ),
              textTheme: GoogleFonts.notoSansTextTheme(), // Supports Devanagari
              appBarTheme: const AppBarTheme(
                centerTitle: true,
                elevation: 0,
              ),
              cardTheme: CardThemeData(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                ),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.largePadding,
                    vertical: AppConstants.defaultPadding,
                  ),
                ),
              ),
              inputDecorationTheme: InputDecorationTheme(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                ),
                contentPadding: const EdgeInsets.all(AppConstants.defaultPadding),
              ),
            ),
            home: _AppInitializer(userProvider: userProvider),
          );
        },
      ),
    );
  }

  Widget _getHomeScreen(UserProvider userProvider) {
    if (userProvider.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (userProvider.isLoggedIn) {
      if (userProvider.isTeacher) {
        return const TeacherDashboard();
      } else if (userProvider.isStudent) {
        return const StudentDashboard();
      }
    }

    return const LoginScreen();
  }
}

class _AppInitializer extends StatefulWidget {
  final UserProvider userProvider;

  const _AppInitializer({required this.userProvider});

  @override
  State<_AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<_AppInitializer> {
  @override
  void initState() {
    super.initState();
    // Initialize user authentication state after the build phase
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.userProvider.initializeUser();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        return _getHomeScreen(userProvider);
      },
    );
  }

  Widget _getHomeScreen(UserProvider userProvider) {
    if (userProvider.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (userProvider.isLoggedIn) {
      if (userProvider.isTeacher) {
        return const TeacherDashboard();
      } else if (userProvider.isStudent) {
        return const StudentDashboard();
      }
    }

    return const LoginScreen();
  }
}