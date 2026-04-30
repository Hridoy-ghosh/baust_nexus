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

class StudentDashboard extends StatelessWidget {
  const StudentDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthService>().currentUser;
    final now = DateTime.now();
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final roleLabel = user?.role == 'admin' ? 'Admin' : user?.role == 'teacher' ? 'Teacher' : 'Student';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: Text('BAUST Nexus', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No new notifications'), backgroundColor: AppColors.info),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthService>().signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          
            // ============ HELLO CARD ============
    Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF667eea), Color(0xFF764ba2)], begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: const Color(0xFF667eea).withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5))],
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text('Hello,', style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70)),
    const SizedBox(height: 2),
    Text(
      user?.name ?? 'User',  // Full Name দেখাবে
      style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
    ),
    const SizedBox(height: 8),
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(12)),
      child: Text(
        '${user?.role?.toUpperCase() ?? 'STUDENT'} • ${user?.department ?? 'N/A'}',  // Role + Dept
        style: GoogleFonts.poppins(fontSize: 11, color: Colors.white),
      ),
    ),
    const SizedBox(height: 12),
    Row(children: [
      Text('${days[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}, ${now.year}', style: GoogleFonts.poppins(fontSize: 13, color: Colors.white70)),
      const Spacer(),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.timer, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Text('No Upcoming Exam', style: GoogleFonts.poppins(fontSize: 11, color: Colors.white)),
        ]),
      ),
    ]),
  ]),
),
          
          // ============ ACADEMIC SERVICES ============
          Text(
            '📚 Academic Services',
            style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 14),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.1,
            children: [
              _serviceCard(
                '📝',
                'Academic\nResources',
                'Notes, Slides, Books & More',
                AppColors.cse,
                () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AcademicResourcesScreen())),
              ),
              _serviceCard(
                '📢',
                'Notice\nBoard',
                'Updates, Events & Announcements',
                AppColors.warning,
                () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NoticeBoardScreen())),
              ),
              _serviceCard(
                '📖',
                'Library',
                'Books, E-Books & Borrow',
                AppColors.success,
                () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LibraryScreen())),
              ),
              _serviceCard(
                '🚌',
                'Transport',
                'Bus Schedule & Routes',
                AppColors.info,
                () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TransportScreen())),
              ),
              _serviceCard(
                '🍽️',
                'Cafeteria',
                'Miritika Menu & Orders',
                AppColors.error,
                () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CafeteriaScreen())),
              ),
              _serviceCard(
                '💬',
                'Query Board',
                'Ask Questions & Get Help',
                AppColors.ict,
                () => Navigator.push(context, MaterialPageRoute(builder: (_) => const QueryBoardScreen())),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // ============ ACADEMIC TOOLS ============
          Text(
            '🧮 Academic Tools',
            style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 14),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.1,
            children: [
              _serviceCard(
                '🧮',
                'CGPA\nCalculator',
                'Calculate Your Grades',
                const Color(0xFF4A148C),
                () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CGPACalculatorScreen())),
              ),
              _serviceCard(
                '📊',
                'Progress\nTracker',
                'Track Academic Progress',
                const Color(0xFF37474F),
                () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProgressTrackerScreen())),
              ),
              _serviceCard(
                '📅',
                'Academic\nCalendar 2026',
                'Schedule & Holidays',
                AppColors.primary,
                () => _showCalendar(context),
              ),
              _serviceCard(
                '👔',
                'Dress Code',
                'BAUST Guidelines',
                AppColors.info,
                () => _showDressCode(context),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // ============ QUICK LINKS ============
          Text(
            '🔗 Quick Links',
            style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 12),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 3,
            child: Column(children: [
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.map, color: AppColors.success, size: 22),
                ),
                title: Text(
                  'Campus Map',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                subtitle: Text(
                  'Find buildings & facilities',
                  style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey),
                ),
                trailing: const Icon(Icons.chevron_right, size: 20),
                onTap: () => _showMap(context),
              ),
            ]),
          ),
          
          const SizedBox(height: 20),
        ]),
      ),
    );
  }

  // ============ SERVICE CARD WIDGET ============
  Widget _serviceCard(String emoji, String title, String subtitle, Color color, VoidCallback onTap) {
    return Card(
      elevation: 3,
      shadowColor: color.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              colors: [Colors.white, color.withOpacity(0.03)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(emoji, style: const TextStyle(fontSize: 24)),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary, height: 1.3),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey),
            ),
          ]),
        ),
      ),
    );
  }

  // ============ SHOW CALENDAR ============
  void _showCalendar(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              // Calendar Header
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  height: 160,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(colors: [Color(0xFF1A237E), Color(0xFF3949AB)]),
                  ),
                  child: Center(
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      const Icon(Icons.calendar_month, size: 50, color: Colors.white),
                      const SizedBox(height: 10),
                      Text(
                        'BAUST Academic Calendar 2026',
                        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      Text(
                        'Saidpur Cantonment, Nilphamari',
                        style: GoogleFonts.poppins(fontSize: 10, color: Colors.white70),
                      ),
                    ]),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Semester Schedule
              _calSection('📅 Semester Schedule', [
                'Summer Semester: January - May 2026',
                'Summer Mid-term Exam: March 2026',
                'Summer Final Exam: May 2026',
                'Winter Semester: July - November 2026',
                'Winter Mid-term Exam: September 2026',
                'Winter Final Exam: November 2026',
              ]),
              const SizedBox(height: 10),
              
              // Holidays
              _calSection('🎉 Government Holidays 2026', [
                '04 February - Sab-E-Barat',
                '21 February - International Mother Language Day',
                '17 March - Bangabandhu Sheikh Mujibur Rahman Birthday',
                '26 March - Independence & National Day',
                '14 April - Bengali New Year (Pahela Baishakh)',
                '01 May - May Day',
                '16 December - Victory Day',
                '25 December - Christmas Day',
              ]),
              const SizedBox(height: 10),
              
              // Admission
              _calSection('📋 Admission 2026', [
                'Summer Admission: Last Date 27/11/2025 | Test: 30/11/2025',
                'Winter Admission: Last Date 11/06/2026 | Test: 14/06/2026',
              ]),
              const SizedBox(height: 16),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Close', style: GoogleFonts.poppins()),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _calSection(String title, List<String> items) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 6),
        ...items.map((i) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(children: [
            const Icon(Icons.circle, size: 5, color: AppColors.primary),
            const SizedBox(width: 8),
            Expanded(child: Text(i, style: GoogleFonts.poppins(fontSize: 12))),
          ]),
        )),
      ]),
    );
  }

  // ============ SHOW DRESS CODE ============
  void _showDressCode(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(children: [
          const Icon(Icons.checkroom, color: AppColors.primary),
          const SizedBox(width: 8),
          Text('BAUST Dress Code', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        ]),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            _dressItem('👨‍🎓 Male Student - Summer', AppConstants.dressCode['male_summer']!),
            const SizedBox(height: 12),
            _dressItem('👨‍🎓 Male Student - Winter', AppConstants.dressCode['male_winter']!),
            const SizedBox(height: 12),
            _dressItem('👩‍🎓 Female Student - Summer', AppConstants.dressCode['female_summer']!),
            const SizedBox(height: 12),
            _dressItem('👩‍🎓 Female Student - Winter', AppConstants.dressCode['female_winter']!),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(children: [
                const Icon(Icons.info, color: AppColors.warning, size: 16),
                const SizedBox(width: 6),
                Expanded(child: Text('ID card must be worn at all times', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.warning))),
              ]),
            ),
          ]),
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close', style: GoogleFonts.poppins()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dressItem(String title, String desc) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 13)),
    const SizedBox(height: 4),
    Text(desc, style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary)),
  ]);

  // ============ SHOW CAMPUS MAP ============
  void _showMap(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(children: [
          const Icon(Icons.map, color: AppColors.success),
          const SizedBox(width: 8),
          Text('BAUST Campus Map', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        ]),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          _mapItem('🏛️', 'Academic Building', 'Main Campus - All Departments'),
          const Divider(),
          _mapItem('📚', 'Central Library', 'Administration Building, Ground Floor'),
          const Divider(),
          _mapItem('🍽️', 'Miritika Cafeteria', 'Student Center, Ground Floor'),
          const Divider(),
          _mapItem('🚌', 'Bus Stand', 'Main Gate Area'),
          const Divider(),
          _mapItem('🕌', 'Mosque', 'Near Academic Building'),
          const Divider(),
          _mapItem('🏥', 'Medical Center', 'Ground Floor, Admin Building'),
          const Divider(),
          _mapItem('🏢', 'Administration Building', 'Main Entrance'),
        ]),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close', style: GoogleFonts.poppins()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _mapItem(String icon, String name, String location) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(children: [
      Text(icon, style: const TextStyle(fontSize: 28)),
      const SizedBox(width: 12),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 2),
          Text(location, style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey)),
        ]),
      ),
    ]),
  );
}