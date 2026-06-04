import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../config/app_colors.dart';
import '../config/app_constants.dart';
import '../models/user_model.dart';
import 'academic_resources_screen.dart';
import 'cafe_admin_panel.dart';
import 'library_admin_panel.dart';
import 'query_board_screen.dart';
import 'manage_users_screen.dart';
import 'notice_board_screen.dart';
import 'transport_screen.dart';
import 'cgpa_calculator_screen.dart';
import 'progress_tracker_screen.dart';
import 'edit_campus_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});
  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final user = auth.currentUser;
    final role = user?.role ?? '';
    
    // সব Admin-ই access পাবে (Cafe, Library, General সবাই)
    final isAdmin = role == 'admin';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: Text('Admin Dashboard',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              auth.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
        bottom: isAdmin ? TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: Colors.white,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Pending', icon: Icon(Icons.pending, size: 20)),
            Tab(text: 'Edit', icon: Icon(Icons.edit, size: 20)),
            Tab(text: 'Features', icon: Icon(Icons.dashboard, size: 20)),
          ],
        ) : null,
      ),
      body: isAdmin 
        ? TabBarView(
            controller: _tabController,
            children: [
              _buildPendingTab(auth),
              _buildEditTab(context),
              _buildFeaturesTab(context),
            ],
          )
        : _buildFeaturesTab(context),
    );
  }

  // ============ PENDING APPROVALS TAB ============
  Widget _buildPendingTab(AuthService auth) {
    return FutureBuilder<List<UserModel>>(
      future: auth.getPendingUsers(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.error_outline, size: 60, color: AppColors.error),
              const SizedBox(height: 16),
              Text('Error loading data',
                  style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey)),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => setState(() {}),
                child: Text('Retry', style: GoogleFonts.poppins()),
              ),
            ]),
          );
        }

        final pending = snapshot.data ?? [];

        if (pending.isEmpty) {
          return Center(
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.check_circle,
                  size: 80, color: AppColors.success.withValues(alpha: 0.5)),
              const SizedBox(height: 16),
              Text('No pending requests!',
                  style: GoogleFonts.poppins(fontSize: 18, color: Colors.grey)),
              Text('All users have been approved',
                  style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey)),
            ]),
          );
        }

        return RefreshIndicator(
          onRefresh: () async => setState(() {}),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: pending.length,
            itemBuilder: (context, i) {
              final user = pending[i];
              return Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.warning.withValues(alpha: 0.1),
                    child: Text(
                      user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.warning,
                      ),
                    ),
                  ),
                  title: Text(
                    user.name,
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        '${user.role.toUpperCase()} • ${user.department ?? 'N/A'}',
                        style: GoogleFonts.poppins(
                            fontSize: 12, color: AppColors.textSecondary),
                      ),
                      Text(
                        user.email,
                        style: GoogleFonts.poppins(
                            fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                    IconButton(
                      icon: const Icon(Icons.check_circle,
                          color: AppColors.success, size: 30),
                      onPressed: () async {
                        await auth.approveUser(user.id);
                        if (!context.mounted) return;
                        setState(() {});
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('✅ ${user.name} approved!'),
                            backgroundColor: AppColors.success,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      tooltip: 'Approve',
                    ),
                    IconButton(
                      icon: const Icon(Icons.cancel,
                          color: AppColors.error, size: 30),
                      onPressed: () async {
                        await auth.rejectUser(user.id);
                        if (!context.mounted) return;
                        setState(() {});
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('❌ ${user.name} rejected!'),
                            backgroundColor: AppColors.error,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      tooltip: 'Reject',
                    ),
                  ]),
                ),
              );
            },
          ),
        );
      },
    );
  }

  // ============ EDIT TAB ============
  Widget _buildEditTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [Color(0xFFFF6F00), Color(0xFFFF8F00)]),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(children: [
            CircleAvatar(
                radius: 28,
                backgroundColor: Colors.white24,
                child: const Text('✏️', style: TextStyle(fontSize: 22))),
            const SizedBox(width: 12),
            Expanded(
                child: Text('Edit Campus Info',
                    style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white))),
          ]),
        ),
        const SizedBox(height: 20),
        _editCard(
            Icons.local_library,
            'Edit Library Hours',
            'Update opening/closing times',
            AppColors.success,
            () => _editLibraryDialog(context)),
        _editCard(
            Icons.restaurant,
            'Edit Cafeteria Menu',
            'Update daily/weekly menu & prices',
            AppColors.error,
            () => _editCafeteriaDialog(context)),
        _editCard(
            Icons.directions_bus,
            'Edit Bus Schedule',
            'Update routes, timings & fares',
            AppColors.info,
            () => _editTransportDialog(context)),
        _editCard(
            Icons.campaign,
            'Post New Notice',
            'Add academic/exam/event notices',
            AppColors.warning,
            () => _addNoticeDialog(context)),
        _editCard(
            Icons.calendar_today,
            'Update Academic Calendar',
            'Update semester dates & holidays',
            AppColors.primary,
            () => _editCalendarDialog(context)),
        _editCard(
            Icons.checkroom,
            'Update Dress Code',
            'Modify dress code guidelines',
            Colors.purple,
            () => _editDressCodeDialog(context)),
      ]),
    );
  }

  // ============ FEATURES TAB ============
  Widget _buildFeaturesTab(BuildContext context) {
    final auth = context.watch<AuthService>();
    final user = auth.currentUser;
    final role = user?.role ?? '';
    
    // সব Admin-ই সব ফিচার দেখতে পাবে
    final isAdmin = role == 'admin';
    
    // সব ফিচার সবাই দেখতে পারবে (সবাই এ্যাক্সেস পাবে)
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [Color(0xFFC62828), Color(0xFFE53935)]),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(children: [
            CircleAvatar(
                radius: 28,
                backgroundColor: Colors.white24,
                child: const Text('A',
                    style: TextStyle(
                        fontSize: 22,
                        color: Colors.white,
                        fontWeight: FontWeight.bold))),
            const SizedBox(width: 12),
            Text('Admin Controls',
                style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
          ]),
        ),
        const SizedBox(height: 20),
        
        // সব ফিচার একসাথে (Admin ও Common সবাই দেখতে পাবে)
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.1,
          children: [
            // Admin Features
            _featureCard(
                Icons.group,
                'Manage\nUsers',
                AppColors.primary,
                () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ManageUsersScreen()))),
            _featureCard(
                Icons.edit,
                'Edit\nCampus',
                AppColors.warning,
                () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const EditCampusScreen()))),
            _featureCard(
                Icons.restaurant,
                'Cafeteria\nAdmin',
                AppColors.error,
                () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const CafeAdminPanel()))),
            _featureCard(
                Icons.local_library,
                'Library\nAdmin',
                AppColors.success,
                () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const LibraryAdminPanel()))),
            
            // Common Features
            _featureCard(
                Icons.menu_book,
                'Academic\nResources',
                AppColors.cse,
                () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const AcademicResourcesScreen()))),
            _featureCard(
                Icons.campaign,
                'Notice\nBoard',
                AppColors.warning,
                () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const NoticeBoardScreen()))),
            _featureCard(
                Icons.directions_bus,
                'Transport',
                AppColors.info,
                () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const TransportScreen()))),
            _featureCard(
                Icons.calculate,
                'CGPA\nCalculator',
                AppColors.primary,
                () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const CGPACalculatorScreen()))),
            _featureCard(
                Icons.trending_up,
                'Progress\nTracker',
                AppColors.success,
                () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ProgressTrackerScreen()))),
            _featureCard(
                Icons.question_answer,
                'Query\nBoard',
                AppColors.ict,
                () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const QueryBoardScreen()))),
          ],
        ),
      ]),
    );
  }

  // ============ HELPER WIDGETS ============
  Widget _featureCard(
      IconData icon, String title, Color color, VoidCallback onTap) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                  colors: [Colors.white, color.withValues(alpha: 0.05)])),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, size: 28, color: color)),
            const SizedBox(height: 8),
            Text(title,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                    fontSize: 13, fontWeight: FontWeight.w600)),
          ]),
        ),
      ),
    );
  }

  Widget _editCard(IconData icon, String title, String subtitle, Color color,
      VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color)),
        title: Text(title,
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle,
            style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey)),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  // ============ EDIT DIALOGS ============
  void _editLibraryDialog(BuildContext context) {
    final c1 = TextEditingController(text: '8:00 AM - 5:00 PM');
    final c2 =
        TextEditingController(text: 'Administration Building, Ground Floor');
    _showDialog(
        context,
        'Edit Library Info',
        [
          TextField(
              controller: c1,
              decoration: const InputDecoration(
                  labelText: 'Hours', border: OutlineInputBorder())),
          const SizedBox(height: 10),
          TextField(
              controller: c2,
              decoration: const InputDecoration(
                  labelText: 'Location', border: OutlineInputBorder())),
        ],
        () => _showSnackBar(context, '✅ Library info updated!'));
  }

  void _editCafeteriaDialog(BuildContext context) {
    final c = TextEditingController(text: 'Porota, Dal, Egg, Tea - 45 Tk');
    _showDialog(
        context,
        'Edit Menu Item',
        [
          TextField(
              controller: c,
              decoration: const InputDecoration(
                  labelText: 'Menu Item', border: OutlineInputBorder())),
        ],
        () => _showSnackBar(context, '✅ Menu updated!'));
  }

  void _editTransportDialog(BuildContext context) {
    final c1 = TextEditingController(text: '7:00 AM');
    final c2 = TextEditingController(text: '40 Tk');
    _showDialog(
        context,
        'Edit Bus Schedule',
        [
          TextField(
              controller: c1,
              decoration: const InputDecoration(
                  labelText: 'Timing', border: OutlineInputBorder())),
          const SizedBox(height: 10),
          TextField(
              controller: c2,
              decoration: const InputDecoration(
                  labelText: 'Fare', border: OutlineInputBorder())),
        ],
        () => _showSnackBar(context, '✅ Schedule updated!'));
  }

  void _addNoticeDialog(BuildContext context) {
    final c1 = TextEditingController();
    final c2 = TextEditingController();
    _showDialog(
        context,
        'Post New Notice',
        [
          TextField(
              controller: c1,
              decoration: const InputDecoration(
                  labelText: 'Title', border: OutlineInputBorder())),
          const SizedBox(height: 10),
          TextField(
              controller: c2,
              maxLines: 3,
              decoration: const InputDecoration(
                  labelText: 'Description', border: OutlineInputBorder())),
        ],
        () => _showSnackBar(context, '✅ Notice posted!'));
  }

  void _editCalendarDialog(BuildContext context) {
    final c = TextEditingController(text: 'January - May 2026');
    _showDialog(
        context,
        'Update Calendar',
        [
          TextField(
              controller: c,
              decoration: const InputDecoration(
                  labelText: 'Semester Dates', border: OutlineInputBorder())),
        ],
        () => _showSnackBar(context, '✅ Calendar updated!'));
  }

  void _editDressCodeDialog(BuildContext context) {
    final c =
        TextEditingController(text: AppConstants.dressCode['male_summer']);
    _showDialog(
        context,
        'Update Dress Code',
        [
          TextField(
              controller: c,
              maxLines: 3,
              decoration: const InputDecoration(
                  labelText: 'Dress Code', border: OutlineInputBorder())),
        ],
        () => _showSnackBar(context, '✅ Dress code updated!'));
  }

  void _showDialog(BuildContext context, String title, List<Widget> fields,
      VoidCallback onSave) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title,
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Column(mainAxisSize: MainAxisSize.min, children: fields),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel', style: GoogleFonts.poppins())),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              onSave();
            },
            child: Text('Save', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.success),
    );
  }
}