import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/app_colors.dart';

class QueryBoardScreen extends StatefulWidget {
  const QueryBoardScreen({super.key});
  @override
  State<QueryBoardScreen> createState() => _QueryBoardScreenState();
}

class _QueryBoardScreenState extends State<QueryBoardScreen> {
  String _filter = 'All';
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  
  final List<Map<String, dynamic>> _queries = [
    {'title': 'CGPA calculation help', 'desc': 'How to calculate CGPA for all semesters?', 'category': 'academic', 'postedBy': 'Karim (CSE L2T1)', 'time': '2h ago', 'replies': 3, 'status': 'open'},
    {'title': 'Bus schedule for Rangpur?', 'desc': 'What time does the bus leave for Rangpur on Thursday?', 'category': 'campus', 'postedBy': 'Rahima (EEE L3T1)', 'time': '5h ago', 'replies': 2, 'status': 'resolved'},
    {'title': 'Need CSE 2101 notes', 'desc': 'Can anyone share Data Structures notes? PDF preferred.', 'category': 'academic', 'postedBy': 'Tanvir (CSE L2T2)', 'time': '1d ago', 'replies': 5, 'status': 'open'},
  ];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _addQuery() {
    if (_titleCtrl.text.isNotEmpty && _descCtrl.text.isNotEmpty) {
      setState(() {
        _queries.insert(0, {
          'title': _titleCtrl.text,
          'desc': _descCtrl.text,
          'category': 'academic',
          'postedBy': 'You',
          'time': 'Just now',
          'replies': 0,
          'status': 'open',
        });
      });
      _titleCtrl.clear();
      _descCtrl.clear();
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Query posted!'), backgroundColor: AppColors.success));
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filter == 'All' ? _queries : _queries.where((q) => q['category'] == _filter).toList();
    
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(title: Text('Query Board', style: GoogleFonts.poppins(fontWeight: FontWeight.w600))),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add),
        label: Text('Ask Question', style: GoogleFonts.poppins()),
      ),
      body: Column(children: [
        SizedBox(height: 50, child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), children: ['All', 'academic', 'campus', 'technical'].map((f) => Padding(padding: const EdgeInsets.symmetric(horizontal: 3), child: FilterChip(label: Text(f.toUpperCase(), style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: _filter == f ? Colors.white : AppColors.textSecondary)), selected: _filter == f, onSelected: (_) => setState(() => _filter = f), backgroundColor: Colors.grey.shade100, selectedColor: AppColors.primary))).toList())),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: filtered.length,
            itemBuilder: (context, i) {
              final q = filtered[i];
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      CircleAvatar(radius: 16, backgroundColor: AppColors.primary.withOpacity(0.1), child: Text(q['postedBy'].toString()[0], style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 12))),
                      const SizedBox(width: 8),
                      Expanded(child: Text(q['postedBy'].toString(), style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600))),
                      Text(q['time'].toString(), style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey)),
                    ]),
                    const SizedBox(height: 8),
                    Text(q['title'].toString(), style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(q['desc'].toString(), style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary), maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 8),
                    Row(children: [
                      Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: q['status'] == 'open' ? AppColors.success.withOpacity(0.1) : AppColors.info.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Text(q['status'].toString().toUpperCase(), style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: q['status'] == 'open' ? AppColors.success : AppColors.info))),
                      const Spacer(),
                      const Icon(Icons.chat_bubble_outline, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text('${q['replies']}', style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey)),
                    ]),
                  ]),
                ),
              );
            },
          ),
        ),
      ]),
    );
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Ask a Question', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: _titleCtrl, decoration: InputDecoration(labelText: 'Title', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
          const SizedBox(height: 12),
          TextField(controller: _descCtrl, maxLines: 3, decoration: InputDecoration(labelText: 'Description', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: GoogleFonts.poppins())),
          ElevatedButton(onPressed: _addQuery, style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary), child: Text('Post', style: GoogleFonts.poppins(color: Colors.white))),
        ],
      ),
    );
  }
}