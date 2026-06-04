import 'dart:io';
import 'package:path_provider/path_provider.dart';
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
import 'campus_map_screen.dart';
import 'todo_list_screen.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  Future<File?> _getLocalProfilePicture(String userId) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/profile_$userId.png');
    if (await file.exists()) {
      return file;
    }
    return null;
  }

  Widget _buildProfilePicture(String? userId, String userName) {
    if (userId == null) return const SizedBox();
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        FutureBuilder<File?>(
          future: _getLocalProfilePicture(userId),
          builder: (context, snapshot) {
            final file = snapshot.data;
            if (file != null) {
              return CircleAvatar(
                radius: 28,
                backgroundImage: FileImage(file),
              );
            }
            return CircleAvatar(
              radius: 28,
              backgroundColor: Colors.white.withOpacity(0.2),
              child: Text(
                userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                style: GoogleFonts.poppins(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
              ),
            );
          },
        ),
        Container(
          padding: const EdgeInsets.all(3),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.camera_alt, size: 10, color: Color(0xFF764ba2)),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthService>().currentUser;
    final now = DateTime.now();
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final roleLabel = user?.role == 'admin' ? 'ADMIN' : user?.role == 'teacher' ? 'TEACHER' : 'STUDENT';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: Text('BAUST Nexus', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 18)),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, size: 22),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No new notifications'), backgroundColor: AppColors.info, duration: Duration(seconds: 1)),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, size: 22),
            onPressed: () {
              context.read<AuthService>().signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          
          // ============ HELLO CARD ============
          InkWell(
            onTap: () async {
              await Navigator.pushNamed(context, '/profile');
              if (mounted) setState(() {});
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF667eea).withValues(alpha: 0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Hello,', style: GoogleFonts.poppins(fontSize: 13, color: Colors.white70, fontWeight: FontWeight.w400)),
                          const SizedBox(height: 2),
                          Text(user?.name ?? 'User', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10)),
                            child: Text('$roleLabel • ${user?.department ?? 'N/A'}', style: GoogleFonts.poppins(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w500)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildProfilePicture(user?.id, user?.name ?? 'User'),
                  ],
                ),
                const SizedBox(height: 10),
                Row(children: [
                  Text('${days[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}, ${now.year}', style: GoogleFonts.poppins(fontSize: 11, color: Colors.white70)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(14)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.timer, color: Colors.white, size: 14),
                      const SizedBox(width: 4),
                      Text('No Upcoming Exam', style: GoogleFonts.poppins(fontSize: 10, color: Colors.white)),
                    ]),
                  ),
                ]),
              ]),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // ============ ACADEMIC SERVICES SECTION ============
          Row(children: [
            const Icon(Icons.school, size: 20, color: AppColors.primary),
            const SizedBox(width: 6),
            Text('Academic Services', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          ]),
          const SizedBox(height: 12),
          
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 0.88,
            children: [
              _buildServiceCard(
                emoji: '📝',
                title: 'Academic\nResources',
                subtitle: 'Notes, Slides & Books',
                color: AppColors.cse,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AcademicResourcesScreen())),
              ),
              _buildServiceCard(
                emoji: '📢',
                title: 'Notice\nBoard',
                subtitle: 'Events & Updates',
                color: AppColors.warning,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NoticeBoardScreen())),
              ),
              _buildServiceCard(
                emoji: '📖',
                title: 'Library',
                subtitle: 'Books & E-Books',
                color: AppColors.success,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LibraryScreen())),
              ),
              _buildServiceCard(
                emoji: '🚌',
                title: 'Transport',
                subtitle: 'Bus Schedule',
                color: AppColors.info,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TransportScreen())),
              ),
              _buildServiceCard(
                emoji: '🍽️',
                title: 'Cafeteria',
                subtitle: 'Miritika Menu',
                color: AppColors.error,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CafeteriaScreen())),
              ),
              _buildServiceCard(
                emoji: '💬',
                title: 'Query\nBoard',
                subtitle: 'Ask & Answer',
                color: AppColors.ict,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const QueryBoardScreen())),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // ============ ACADEMIC TOOLS SECTION ============
          Row(children: [
            const Icon(Icons.calculate, size: 20, color: AppColors.primary),
            const SizedBox(width: 6),
            Text('Academic Tools', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          ]),
          const SizedBox(height: 12),
          
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 0.88,
            children: [
              _buildServiceCard(
                emoji: '🧮',
                title: 'CGPA\nCalculator',
                subtitle: 'Calculate Grades',
                color: const Color(0xFF4A148C),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CGPACalculatorScreen())),
              ),
              _buildServiceCard(
                emoji: '📊',
                title: 'Progress\nTracker',
                subtitle: 'Track Progress',
                color: const Color(0xFF37474F),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProgressTrackerScreen())),
              ),
              _buildServiceCard(
                emoji: '👔',
                title: 'Dress\nCode',
                subtitle: 'Guidelines',
                color: AppColors.info,
                onTap: () => _showDressCodeDialog(context),
              ),
              _buildServiceCard(
                emoji: '✅',
                title: 'To Do\nList',
                subtitle: 'Manage Tasks',
                color: const Color(0xFF7B1FA2),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TodoListScreen())),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // ============ QUICK LINKS ============
          Row(children: [
            const Icon(Icons.link, size: 20, color: AppColors.primary),
            const SizedBox(width: 6),
            Text('Quick Links', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          ]),
          const SizedBox(height: 10),
          
          // Academic Calendar Card with Picture
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => _showCalendarDialog(context),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(14), topRight: Radius.circular(14)),
                    child: Image.asset(
                      'assets/images/academic_calendar.png',
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 120,
                          width: double.infinity,
                          color: AppColors.primary,
                          child: const Center(
                            child: Icon(Icons.calendar_month, size: 50, color: Colors.white),
                          ),
                        );
                      },
                    ),
                  ),
                  ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.calendar_today, color: AppColors.warning, size: 22),
                    ),
                    title: Text('Academic Calendar 2026', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: Text('View full schedule', style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey)),
                    trailing: const Icon(Icons.chevron_right, size: 20, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Campus Map Card with Picture
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CampusMapScreen())),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(14), topRight: Radius.circular(14)),
                    child: Image.asset(
                      'assets/images/campus_map.png',
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 120,
                          width: double.infinity,
                          color: AppColors.success,
                          child: const Center(
                            child: Icon(Icons.map, size: 50, color: Colors.white),
                          ),
                        );
                      },
                    ),
                  ),
                  ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.map, color: AppColors.success, size: 22),
                    ),
                    title: Text('Campus Map', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: Text('Find buildings & facilities', style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey)),
                    trailing: const Icon(Icons.chevron_right, size: 20, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 20),
        ]),
      ),
    );
  }

  // ============ SERVICE CARD BUILDER ============
  Widget _buildServiceCard({
    required String emoji,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shadowColor: color.withValues(alpha: 0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [Colors.white, color.withValues(alpha: 0.04)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(emoji, style: const TextStyle(fontSize: 22)),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: Colors.grey,
                  fontWeight: FontWeight.w400,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============ ACADEMIC CALENDAR DIALOG WITH PICTURE ============
  void _showCalendarDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(20),
          constraints: const BoxConstraints(maxHeight: 550),
          child: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              // Calendar Image Banner (Clickable to zoom)
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const FullScreenImagePage(
                        imagePath: 'assets/images/academic_calendar.png',
                      ),
                    ),
                  );
                },
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.asset(
                        'assets/images/academic_calendar.png',
                        height: 160,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 140,
                            width: double.infinity,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(colors: [Color(0xFF1A237E), Color(0xFF3949AB)]),
                            ),
                            child: const Center(
                              child: Icon(Icons.calendar_month, size: 60, color: Colors.white),
                            ),
                          );
                        },
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.all(8),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.zoom_in, color: Colors.white, size: 14),
                          SizedBox(width: 4),
                          Text(
                            'Tap to Zoom',
                            style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Semester Schedule
              _buildCalendarSection(
                title: '📅 Semester Schedule',
                items: [
                  'Summer Semester: January - May 2026',
                  'Summer Mid-term Exam: March 2026',
                  'Summer Final Exam: May 2026',
                  'Winter Semester: July - November 2026',
                  'Winter Mid-term Exam: September 2026',
                  'Winter Final Exam: November 2026',
                ],
              ),
              const SizedBox(height: 10),
              
              // Holidays
              _buildCalendarSection(
                title: '🎉 Government Holidays 2026',
                items: [
                  '04 February - Sab-E-Barat',
                  '21 February - International Mother Language Day',
                  '17 March - Bangabandhu Birthday',
                  '26 March - Independence & National Day',
                  '14 April - Bengali New Year',
                  '01 May - May Day',
                  '16 December - Victory Day',
                  '25 December - Christmas Day',
                ],
              ),
              const SizedBox(height: 10),
              
              // Admission
              _buildCalendarSection(
                title: '📋 Admission 2026',
                items: [
                  'Summer: Last 27/11/2025 | Test: 30/11/2025',
                  'Winter: Last 11/06/2026 | Test: 14/06/2026',
                ],
              ),
              const SizedBox(height: 16),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text('Close', style: GoogleFonts.poppins()),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarSection({required String title, required List<String> items}) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(height: 6),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Icon(Icons.circle, size: 4, color: AppColors.primary),
            const SizedBox(width: 6),
            Expanded(child: Text(item, style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary))),
          ]),
        )),
      ]),
    );
  }

  // ============ DRESS CODE DIALOG ============
  void _showDressCodeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(children: [
          const Icon(Icons.checkroom, color: AppColors.primary, size: 22),
          const SizedBox(width: 8),
          Text('BAUST Dress Code', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
        ]),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            _buildDressSection('👨‍🎓 Male Student - Summer', AppConstants.dressCode['male_summer']!),
            const SizedBox(height: 12),
            _buildDressSection('👨‍🎓 Male Student - Winter', AppConstants.dressCode['male_winter']!),
            const SizedBox(height: 12),
            _buildDressSection('👩‍🎓 Female Student - Summer', AppConstants.dressCode['female_summer']!),
            const SizedBox(height: 12),
            _buildDressSection('👩‍🎓 Female Student - Winter', AppConstants.dressCode['female_winter']!),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(children: [
                const Icon(Icons.info, color: AppColors.warning, size: 16),
                const SizedBox(width: 6),
                Expanded(child: Text('ID card must be worn at all times', style: GoogleFonts.poppins(fontSize: 11, color: AppColors.warning))),
              ]),
            ),
          ]),
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              child: Text('Close', style: GoogleFonts.poppins()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDressSection(String title, String desc) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 13)),
      const SizedBox(height: 3),
      Text(desc, style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary)),
    ]);
  }
}

class FullScreenImagePage extends StatelessWidget {
  final String imagePath;
  const FullScreenImagePage({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: InteractiveViewer(
              panEnabled: true,
              boundaryMargin: const EdgeInsets.all(20),
              minScale: 1.0,
              maxScale: 5.0,
              child: Image.asset(
                imagePath,
                fit: BoxFit.contain,
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            child: CircleAvatar(
              backgroundColor: Colors.black.withOpacity(0.5),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}