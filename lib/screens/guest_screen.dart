import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/app_colors.dart';
import '../config/app_constants.dart';
import 'notice_board_screen.dart';
import 'library_screen.dart';
import 'transport_screen.dart';
import 'cafeteria_screen.dart';
import 'login_screen.dart';

class GuestScreen extends StatelessWidget {
  const GuestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
            gradient: LinearGradient(
                colors: [Color(0xFFF5F6FA), Colors.white],
                begin: Alignment.topCenter)),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(children: [
              const SizedBox(height: 20),
              Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 15)
                      ]),
                  child:
                      const Icon(Icons.school, size: 50, color: Colors.white)),
              const SizedBox(height: 16),
              Text(AppConstants.appName,
                  style: GoogleFonts.poppins(
                      fontSize: 26, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('Guest Mode - Limited Access',
                  style: GoogleFonts.poppins(
                      fontSize: 14, color: AppColors.textSecondary)),
              const SizedBox(height: 20),
              Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12)),
                  child: Row(children: [
                    const Icon(Icons.info_outline, color: AppColors.warning),
                    const SizedBox(width: 10),
                    Expanded(
                        child: Text(
                            'You can view public info & order food. Login for full access.',
                            style: GoogleFonts.poppins(
                                fontSize: 12, color: AppColors.textPrimary)))
                  ])),
              const SizedBox(height: 24),
              GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  children: [
                    _card(
                        Icons.campaign,
                        'Public Notices',
                        AppColors.warning,
                        () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const NoticeBoardScreen()))),
                    _card(
                        Icons.local_library,
                        'Library Info',
                        AppColors.success,
                        () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const LibraryScreen()))),
                    _card(
                        Icons.directions_bus,
                        'Bus Schedule',
                        AppColors.info,
                        () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const TransportScreen()))),
                    _card(
                        Icons.restaurant,
                        'Cafeteria Menu',
                        AppColors.error,
                        () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const CafeteriaScreen()))),
                  ]),
              const SizedBox(height: 24),
              SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                      onPressed: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const LoginScreen())),
                      icon: const Icon(Icons.login),
                      label: Text('Login for Full Access',
                          style: GoogleFonts.poppins(
                              fontSize: 15, fontWeight: FontWeight.w600)))),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _card(IconData icon, String title, Color color, VoidCallback onTap) {
    return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Container(
                padding: const EdgeInsets.all(16),
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(16)),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, size: 36, color: color),
                      const SizedBox(height: 10),
                      Text(title,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                              fontSize: 13, fontWeight: FontWeight.w600))
                    ]))));
  }
}
