import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'config/app_theme.dart';
import 'config/app_constants.dart';
import 'config/app_colors.dart';
import 'services/auth_service.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart' as signup;
import 'screens/student_dashboard.dart';
import 'screens/admin_dashboard.dart';
import 'screens/guest_screen.dart';
import 'screens/academic_resources_screen.dart';
import 'screens/notice_board_screen.dart';
import 'screens/library_screen.dart';
import 'screens/transport_screen.dart';
import 'screens/cafeteria_screen.dart';
import 'screens/cafe_admin_panel.dart';
import 'screens/library_admin_panel.dart';
import 'screens/cgpa_calculator_screen.dart';
import 'screens/progress_tracker_screen.dart';
import 'screens/query_board_screen.dart';
import 'screens/profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Supabase.initialize(
      url: 'https://lrdzgwtceivwlmwumurd.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxyZHpnd3RjZWl2d2xtd3VtdXJkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzg0MTU3MDMsImV4cCI6MjA5Mzk5MTcwM30.MVj0YQL7so8B51_wgoSD9P5zk8jCHkd28-7RRtMBY0M',
    );
    print('✅ Supabase connected successfully');
  } catch (e) {
    print('❌ Supabase connection error: $e');
  }
  
  runApp(const BAUSTNexusApp());
}

class BAUSTNexusApp extends StatelessWidget {
  const BAUSTNexusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/login': (context) => const LoginScreen(),
          '/signup': (context) => const signup.SignupScreen(),
          '/student_dashboard': (context) => const StudentDashboard(),
          '/teacher_dashboard': (context) => const StudentDashboard(),
          '/admin_dashboard': (context) => const AdminDashboard(),
          '/guest': (context) => const GuestScreen(),
          '/academic_resources': (context) => const AcademicResourcesScreen(),
          '/notice_board': (context) => const NoticeBoardScreen(),
          '/library': (context) => const LibraryScreen(),
          '/transport': (context) => const TransportScreen(),
          '/cafeteria': (context) => const CafeteriaScreen(),
          '/cafe_admin': (context) => const CafeAdminPanel(),
          '/library_admin': (context) => const LibraryAdminPanel(),
          '/cgpa_calculator': (context) => const CGPACalculatorScreen(),
          '/progress_tracker': (context) => const ProgressTrackerScreen(),
          '/query_board': (context) => const QueryBoardScreen(),
          '/profile': (context) => const ProfileScreen(),
        },
        onGenerateRoute: (settings) {
          return null;
        },
        onUnknownRoute: (settings) {
          return MaterialPageRoute(
            builder: (context) => const Scaffold(
              body: Center(
                child: Text('Page not found'),
              ),
            ),
          );
        },
      ),
    );
  }
}