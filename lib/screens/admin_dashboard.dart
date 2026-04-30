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

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});
  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> with SingleTickerProviderStateMixin {
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
    final pending = auth.getPendingUsers();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: Text('Admin Dashboard', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: () { auth.signOut(); Navigator.pushReplacementNamed(context, '/login'); }),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: Colors.white,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Pending', icon: Icon(Icons.pending, size: 20)),
            Tab(text: 'Edit', icon: Icon(Icons.edit, size: 20)),
            Tab(text: 'All Features', icon: Icon(Icons.dashboard, size: 20)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Pending Approvals
          pending.isEmpty
              ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.check_circle, size: 80, color: AppColors.success.withOpacity(0.5)), const SizedBox(height: 16), Text('No pending requests!', style: GoogleFonts.poppins(fontSize: 18, color: Colors.grey))]))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: pending.length,
                  itemBuilder: (context, i) {
                    final u = pending[i];
                    return Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      child: ListTile(
                        leading: CircleAvatar(backgroundColor: AppColors.warning.withOpacity(0.1), child: Text(u.name[0].toUpperCase(), style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: AppColors.warning))),
                        title: Text(u.name, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                        subtitle: Text('${u.role.toUpperCase()} • ${u.department ?? 'N/A'} • ${u.email}', style: GoogleFonts.poppins(fontSize: 11)),
                        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                          IconButton(icon: const Icon(Icons.check_circle, color: AppColors.success, size: 28), onPressed: () => auth.approveUser(u.id)),
                          IconButton(icon: const Icon(Icons.cancel, color: AppColors.error, size: 28), onPressed: () => auth.rejectUser(u.id)),
                        ]),
                      ),
                    );
                  },
                ),
          
          // Tab 2: Edit Options
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFFF6F00), Color(0xFFFF8F00)]), borderRadius: BorderRadius.circular(18)),
                child: Row(children: [CircleAvatar(radius: 28, backgroundColor: Colors.white24, child: const Text('✏️', style: TextStyle(fontSize: 22))), const SizedBox(width: 12), Expanded(child: Text('Edit Campus Info', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)))]),
              ),
              const SizedBox(height: 20),
              _editCard(Icons.local_library, 'Edit Library Hours', 'Update opening/closing times', AppColors.success, () => _editLibraryDialog(context)),
              _editCard(Icons.restaurant, 'Edit Cafeteria Menu', 'Update daily/weekly menu & prices', AppColors.error, () => _editCafeteriaDialog(context)),
              _editCard(Icons.directions_bus, 'Edit Bus Schedule', 'Update routes, timings & fares', AppColors.info, () => _editTransportDialog(context)),
              _editCard(Icons.campaign, 'Post New Notice', 'Add academic/exam/event notices', AppColors.warning, () => _addNoticeDialog(context)),
              _editCard(Icons.calendar_today, 'Update Academic Calendar', 'Update semester dates & holidays', AppColors.primary, () => _editCalendarDialog(context)),
              _editCard(Icons.checkroom, 'Update Dress Code', 'Modify dress code guidelines', Colors.purple, () => _editDressCodeDialog(context)),
            ]),
          ),
          
          // Tab 3: All Features
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFC62828), Color(0xFFE53935)]), borderRadius: BorderRadius.circular(18)),
                child: Row(children: [CircleAvatar(radius: 28, backgroundColor: Colors.white24, child: const Text('A', style: TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold))), const SizedBox(width: 12), Text('Admin Controls', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white))]),
              ),
              const SizedBox(height: 20),
              GridView.count(crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 1.1, children: [
                _featureCard(Icons.people, 'Manage\nUsers', AppColors.primary, () => _tabController.animateTo(0)),
                _featureCard(Icons.edit, 'Edit\nCampus Info', Colors.orange, () => _tabController.animateTo(1)),
                _featureCard(Icons.menu_book, 'Academic\nResources', AppColors.cse, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AcademicResourcesScreen()))),
                _featureCard(Icons.campaign, 'Notice\nBoard', AppColors.warning, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NoticeBoardScreen()))),
                _featureCard(Icons.local_library, 'Library', AppColors.success, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LibraryScreen()))),
                _featureCard(Icons.directions_bus, 'Transport', AppColors.info, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TransportScreen()))),
                _featureCard(Icons.restaurant, 'Cafeteria', AppColors.error, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CafeteriaScreen()))),
                _featureCard(Icons.question_answer, 'Query\nBoard', AppColors.ict, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const QueryBoardScreen()))),
                _featureCard(Icons.calculate, 'CGPA\nCalculator', const Color(0xFF4A148C), () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CGPACalculatorScreen()))),
                _featureCard(Icons.trending_up, 'Progress\nTracker', const Color(0xFF37474F), () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProgressTrackerScreen()))),
              ]),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _featureCard(IconData icon, String title, Color color, VoidCallback onTap) {
    return Card(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(16), child: Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), gradient: LinearGradient(colors: [Colors.white, color.withOpacity(0.05)])), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, size: 28, color: color)), const SizedBox(height: 8), Text(title, textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600))]))));
  }

  Widget _editCard(IconData icon, String title, String subtitle, Color color, VoidCallback onTap) {
    return Card(margin: const EdgeInsets.only(bottom: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), child: ListTile(leading: Container(width: 45, height: 45, decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: color)), title: Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)), subtitle: Text(subtitle, style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey)), trailing: const Icon(Icons.chevron_right), onTap: onTap));
  }

  // Edit Library Dialog
  void _editLibraryDialog(BuildContext context) {
    final ctrl1 = TextEditingController(text: '8:00 AM - 5:00 PM');
    final ctrl2 = TextEditingController(text: 'Administration Building, Ground Floor');
    showDialog(context: context, builder: (ctx) => AlertDialog(title: Text('Edit Library Info', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)), content: Column(mainAxisSize: MainAxisSize.min, children: [
      TextField(controller: ctrl1, decoration: const InputDecoration(labelText: 'Hours', border: OutlineInputBorder())),
      const SizedBox(height: 10),
      TextField(controller: ctrl2, decoration: const InputDecoration(labelText: 'Location', border: OutlineInputBorder())),
    ]), actions: [
      TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel')),
      ElevatedButton(onPressed: () { Navigator.pop(ctx); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Library info updated!'), backgroundColor: AppColors.success)); }, child: Text('Save')),
    ]));
  }

  // Edit Cafeteria Dialog
  void _editCafeteriaDialog(BuildContext context) {
    final ctrl = TextEditingController(text: 'Porota, Dal, Egg, Tea - 45 Tk');
    showDialog(context: context, builder: (ctx) => AlertDialog(title: Text('Edit Menu Item', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)), content: Column(mainAxisSize: MainAxisSize.min, children: [
      TextField(controller: ctrl, decoration: const InputDecoration(labelText: 'Menu Item', border: OutlineInputBorder())),
    ]), actions: [
      TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel')),
      ElevatedButton(onPressed: () { Navigator.pop(ctx); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Menu updated!'), backgroundColor: AppColors.success)); }, child: Text('Save')),
    ]));
  }

  // Edit Transport Dialog
  void _editTransportDialog(BuildContext context) {
    final ctrl1 = TextEditingController(text: '7:00 AM');
    final ctrl2 = TextEditingController(text: '40 Tk');
    showDialog(context: context, builder: (ctx) => AlertDialog(title: Text('Edit Bus Schedule', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)), content: Column(mainAxisSize: MainAxisSize.min, children: [
      TextField(controller: ctrl1, decoration: const InputDecoration(labelText: 'Timing', border: OutlineInputBorder())),
      const SizedBox(height: 10),
      TextField(controller: ctrl2, decoration: const InputDecoration(labelText: 'Fare', border: OutlineInputBorder())),
    ]), actions: [
      TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel')),
      ElevatedButton(onPressed: () { Navigator.pop(ctx); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Schedule updated!'), backgroundColor: AppColors.success)); }, child: Text('Save')),
    ]));
  }

  // Add Notice Dialog
  void _addNoticeDialog(BuildContext context) {
    final ctrl1 = TextEditingController();
    final ctrl2 = TextEditingController();
    showDialog(context: context, builder: (ctx) => AlertDialog(title: Text('Post New Notice', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)), content: Column(mainAxisSize: MainAxisSize.min, children: [
      TextField(controller: ctrl1, decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder())),
      const SizedBox(height: 10),
      TextField(controller: ctrl2, maxLines: 3, decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder())),
    ]), actions: [
      TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel')),
      ElevatedButton(onPressed: () { Navigator.pop(ctx); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Notice posted!'), backgroundColor: AppColors.success)); }, child: Text('Post')),
    ]));
  }

  // Edit Calendar Dialog
  void _editCalendarDialog(BuildContext context) {
    final ctrl = TextEditingController(text: 'January - May 2026');
    showDialog(context: context, builder: (ctx) => AlertDialog(title: Text('Update Calendar', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)), content: Column(mainAxisSize: MainAxisSize.min, children: [
      TextField(controller: ctrl, decoration: const InputDecoration(labelText: 'Semester Dates', border: OutlineInputBorder())),
    ]), actions: [
      TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel')),
      ElevatedButton(onPressed: () { Navigator.pop(ctx); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Calendar updated!'), backgroundColor: AppColors.success)); }, child: Text('Save')),
    ]));
  }

  // Edit Dress Code Dialog
  void _editDressCodeDialog(BuildContext context) {
    final ctrl = TextEditingController(text: AppConstants.dressCode['male_summer']);
    showDialog(context: context, builder: (ctx) => AlertDialog(title: Text('Update Dress Code', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)), content: Column(mainAxisSize: MainAxisSize.min, children: [
      TextField(controller: ctrl, maxLines: 3, decoration: const InputDecoration(labelText: 'Dress Code', border: OutlineInputBorder())),
    ]), actions: [
      TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel')),
      ElevatedButton(onPressed: () { Navigator.pop(ctx); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Dress code updated!'), backgroundColor: AppColors.success)); }, child: Text('Save')),
    ]));
  }
}