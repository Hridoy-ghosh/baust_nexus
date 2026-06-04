import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/app_colors.dart';

class NoticeBoardScreen extends StatefulWidget {
  const NoticeBoardScreen({super.key});
  @override
  State<NoticeBoardScreen> createState() => _NoticeBoardScreenState();
}

class _NoticeBoardScreenState extends State<NoticeBoardScreen> {
  String _filter = 'All';
  final List<Map<String, dynamic>> _notices = [
    {
      'title': 'Mid-term Exam Schedule',
      'desc':
          'Summer 2026 mid-term exam starts March 15. Check detailed schedule on notice board.',
      'type': 'exam',
      'priority': 'high',
      'date': '2026-03-01',
      'postedBy': 'Exam Controller'
    },
    {
      'title': 'Blood Donation Camp',
      'desc':
          'Blood donation camp on March 21 at university auditorium. All students & faculty invited.',
      'type': 'event',
      'priority': 'medium',
      'date': '2026-03-10',
      'postedBy': 'Student Welfare'
    },
    {
      'title': 'WiFi Maintenance',
      'desc':
          'Campus WiFi under maintenance on Saturday 2PM-5PM. Sorry for inconvenience.',
      'type': 'urgent',
      'priority': 'urgent',
      'date': '2026-02-28',
      'postedBy': 'IT Department'
    },
    {
      'title': 'Admission Open Summer 2026',
      'desc':
          'Admission open for Summer 2026. Last date June 11, 2026. Apply at admission.baust.edu.bd',
      'type': 'admission',
      'priority': 'high',
      'date': '2026-04-01',
      'postedBy': 'Admission Office'
    },
    {
      'title': 'Library Hours Extended',
      'desc':
          'Library open 8AM-5PM during exam period for student convenience.',
      'type': 'academic',
      'priority': 'medium',
      'date': '2026-03-05',
      'postedBy': 'Library Admin'
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _filter == 'All'
        ? _notices
        : _notices.where((n) => n['type'] == _filter.toLowerCase()).toList();
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
          title: Text('Notice Board',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600))),
      body: Column(children: [
        SizedBox(
            height: 55,
            child: ListView(
                scrollDirection: Axis.horizontal,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                children: [
                  'All',
                  'Exam',
                  'Event',
                  'Urgent',
                  'Academic',
                  'Admission'
                ]
                    .map((f) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: FilterChip(
                            label: Text(f,
                                style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: _filter == f
                                        ? Colors.white
                                        : AppColors.textSecondary)),
                            selected: _filter == f,
                            onSelected: (_) => setState(() => _filter = f),
                            backgroundColor: Colors.grey.shade100,
                            selectedColor: AppColors.primary)))
                    .toList())),
        Expanded(
            child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: filtered.length,
                itemBuilder: (context, i) {
                  final n = filtered[i];
                  return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(children: [
                                  Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                          color: n['priority'] == 'urgent'
                                              ? AppColors.error
                                                  .withValues(alpha: 0.1)
                                              : AppColors.info
                                                  .withValues(alpha: 0.1),
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      child: Text(
                                          n['type'].toString().toUpperCase(),
                                          style: GoogleFonts.poppins(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: n['priority'] == 'urgent'
                                                  ? AppColors.error
                                                  : AppColors.info))),
                                  const Spacer(),
                                  Text(n['date'],
                                      style: GoogleFonts.poppins(
                                          fontSize: 11, color: Colors.grey))
                                ]),
                                const SizedBox(height: 8),
                                Text(n['title'],
                                    style: GoogleFonts.poppins(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Text(n['desc'],
                                    style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: AppColors.textSecondary),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 6),
                                Row(children: [
                                  Icon(Icons.person,
                                      size: 14, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text(n['postedBy'],
                                      style: GoogleFonts.poppins(
                                          fontSize: 11, color: Colors.grey))
                                ]),
                              ])));
                })),
      ]),
    );
  }
}
