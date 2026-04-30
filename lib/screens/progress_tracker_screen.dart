import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/app_colors.dart';

class ProgressTrackerScreen extends StatelessWidget {
  const ProgressTrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> semesters = [
      {'name': 'L1T1', 'credits': 20, 'cgpa': 3.75, 'status': 'Completed'},
      {'name': 'L1T2', 'credits': 20, 'cgpa': 3.65, 'status': 'Completed'},
      {'name': 'L2T1', 'credits': 22, 'cgpa': 3.50, 'status': 'Completed'},
      {'name': 'L2T2', 'credits': 23, 'cgpa': 3.80, 'status': 'Completed'},
      {'name': 'L3T1', 'credits': 24, 'cgpa': 0, 'status': 'Ongoing'},
      {'name': 'L3T2', 'credits': 23, 'cgpa': 0, 'status': 'Upcoming'},
      {'name': 'L4T1', 'credits': 14, 'cgpa': 0, 'status': 'Upcoming'},
      {'name': 'L4T2', 'credits': 14, 'cgpa': 0, 'status': 'Upcoming'},
    ];
    
    final completed = semesters.where((s) => s['status'] == 'Completed').fold<int>(0, (sum, s) => sum + (s['credits'] as int));
    final total = 160;
    final cgpaList = [3.75, 3.65, 3.50, 3.80];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(title: Text('Progress Tracker', style: GoogleFonts.poppins(fontWeight: FontWeight.w600))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          // Overall Progress
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF1A237E), Color(0xFF3949AB)]), borderRadius: BorderRadius.circular(20)),
            child: Column(children: [
              Text('Overall Progress', style: GoogleFonts.poppins(fontSize: 16, color: Colors.white70)),
              const SizedBox(height: 20),
              Stack(alignment: Alignment.center, children: [
                SizedBox(width: 150, height: 150, child: CircularProgressIndicator(value: completed / total, strokeWidth: 10, backgroundColor: Colors.white24, valueColor: const AlwaysStoppedAnimation<Color>(Colors.white))),
                Column(children: [
                  Text('${(completed / total * 100).toStringAsFixed(1)}%', style: GoogleFonts.poppins(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white)),
                  Text('$completed/$total', style: GoogleFonts.poppins(fontSize: 13, color: Colors.white70)),
                ]),
              ]),
              const SizedBox(height: 16),
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                _stat('Completed', '$completed cr', AppColors.success),
                _stat('Remaining', '${total - completed} cr', AppColors.warning),
                _stat('CGPA', '3.68', Colors.white),
              ]),
            ]),
          ),
          
          const SizedBox(height: 20),
          
          // CGPA Graph
          Text('📈 CGPA Trend', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  ...cgpaList.map((cgpa) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Column(children: [
                        Container(
                          height: cgpa * 30,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [AppColors.primary, AppColors.primaryLight]),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(cgpa.toString(), style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold)),
                      ]),
                    ),
                  )),
                ]),
                const SizedBox(height: 12),
                Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: ['L1T1', 'L1T2', 'L2T1', 'L2T2'].map((t) => Text(t, style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey))).toList()),
              ]),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Semester List
          Text('📋 Semester Progress', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ...semesters.map((s) => Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: ListTile(
              leading: Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: (s['status'] == 'Completed' ? AppColors.success : s['status'] == 'Ongoing' ? AppColors.info : Colors.grey).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  s['status'] == 'Completed' ? Icons.check_circle : s['status'] == 'Ongoing' ? Icons.play_circle : Icons.lock,
                  color: s['status'] == 'Completed' ? AppColors.success : s['status'] == 'Ongoing' ? AppColors.info : Colors.grey,
                ),
              ),
              title: Text(s['name'].toString(), style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              subtitle: Text('${s['credits']} credits${s['status'] == 'Completed' ? ' • CGPA: ${s['cgpa']}' : ''}', style: GoogleFonts.poppins(fontSize: 12)),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: (s['status'] == 'Completed' ? AppColors.success : s['status'] == 'Ongoing' ? AppColors.info : Colors.grey).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(s['status'].toString(), style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: s['status'] == 'Completed' ? AppColors.success : s['status'] == 'Ongoing' ? AppColors.info : Colors.grey)),
              ),
            ),
          )),
          const SizedBox(height: 20),
        ]),
      ),
    );
  }

  Widget _stat(String label, String value, Color color) => Column(children: [
    Text(value, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
    Text(label, style: GoogleFonts.poppins(fontSize: 11, color: color.withOpacity(0.7))),
  ]);
}