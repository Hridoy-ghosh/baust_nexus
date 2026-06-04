import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../config/app_constants.dart';
import '../services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeIn),
    );
    _scaleAnim = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.elasticOut),
    );
    _animController.forward();

    Timer(const Duration(seconds: 4), () {
      if (!mounted) return;
      final auth = context.read<AuthService>();
      if (auth.isLoggedIn) {
        if (auth.isAdmin) {
          Navigator.pushReplacementNamed(context, '/admin_dashboard');
        } else if (auth.isTeacher) {
          Navigator.pushReplacementNamed(context, '/teacher_dashboard');
        } else {
          Navigator.pushReplacementNamed(context, '/student_dashboard');
        }
      } else {
        Navigator.pushReplacementNamed(context, '/login');
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1A237E), Color(0xFF3949AB)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Spacer(flex: 2),
          AnimatedBuilder(
            animation: _scaleAnim,
            builder: (context, child) => Transform.scale(
              scale: _scaleAnim.value,
              child: Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(35),
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 20)],
                ),
                child: const Icon(Icons.school, size: 70, color: Color(0xFF1A237E)),
              ),
            ),
          ),
          const SizedBox(height: 40),
          AnimatedBuilder(
            animation: _fadeAnim,
            builder: (context, child) => Opacity(
              opacity: _fadeAnim.value,
              child: Column(children: [
                Text(
                  AppConstants.appName,
                  style: GoogleFonts.poppins(fontSize: 34, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  AppConstants.appTagline,
                  style: GoogleFonts.poppins(fontSize: 16, color: Colors.white70),
                ),
                const SizedBox(height: 16),
                Text(
                  AppConstants.universityName,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.white54),
                ),
              ]),
            ),
          ),
          const Spacer(flex: 2),
          const SizedBox(
            width: 30,
            height: 30,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 16),
          Text('Loading...', style: GoogleFonts.poppins(fontSize: 14, color: Colors.white54)),
          const SizedBox(height: 50),
        ]),
      ),
    );
  }
}