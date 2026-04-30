import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../config/app_colors.dart';
import '../config/app_constants.dart';
import 'academic_resources_screen.dart';
import 'notice_board_screen.dart';
import 'library_screen.dart';
import 'transport_screen.dart';
import 'cafeteria_screen.dart';
import 'cgpa_calculator_screen.dart';
import 'progress_tracker_screen.dart';
import 'query_board_screen.dart';
import 'student_dashboard.dart';

class TeacherDashboard extends StatelessWidget {
  const TeacherDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return const StudentDashboard(); // Same as student but with upload access
  }
}