import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'config/app_theme.dart';
import 'config/app_colors.dart';
import 'config/app_constants.dart';
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
import 'screens/cgpa_calculator_screen.dart';
import 'screens/progress_tracker_screen.dart';
import 'screens/query_board_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
          '/cgpa_calculator': (context) => const CGPACalculatorScreen(),
          '/progress_tracker': (context) => const ProgressTrackerScreen(),
          '/query_board': (context) => const QueryBoardScreen(),
        },
      ),
    );
  }
}