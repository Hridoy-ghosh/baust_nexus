import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../config/app_colors.dart';
import '../config/app_constants.dart';

class AcademicResourcesScreen extends StatefulWidget {
  const AcademicResourcesScreen({super.key});
  @override
  State<AcademicResourcesScreen> createState() => _AcademicResourcesScreenState();
}

class _AcademicResourcesScreenState extends State<AcademicResourcesScreen> {
  String _dept = 'All';
  String _level = 'All';
  String _term = 'All';
  String _type = 'All';
  final _titleCtrl = TextEditingController();
  final _courseCtrl = TextEditingController();
  String _uploadType = 'Book';

  final List<String> _allTypes = [
    'All', 'Book', 'Slide', 'Class Note', 'Lab Manual', 'Assignment',
    'Previous Year', 'Project Report', 'PPT', 'Excel', 'TXT', 'PDF'
  ];

  final List<Map<String, dynamic>> _resources = [
    {'title': 'Introduction to C Programming', 'course': 'CSE 1101', 'type': 'Book', 'dept': 'CSE', 'level': 'Level 1', 'term': 'Term I', 'author': 'Tamim Shahriar', 'size': '2.5 MB'},
    {'title': 'Data Structures Lecture Slides', 'course': 'CSE 2101', 'type': 'Slide', 'dept': 'CSE', 'level': 'Level 2', 'term': 'Term I', 'author': 'Prof. Rahman', 'size': '1.8 MB'},
    {'title': 'Digital Logic Design Lab Manual', 'course': 'CSE 2102', 'type': 'Lab Manual', 'dept': 'CSE', 'level': 'Level 2', 'term': 'Term I', 'author': 'CSE Dept', 'size': '3.2 MB'},
    {'title': 'Circuit Analysis Class Notes', 'course': 'EEE 1101', 'type': 'Class Note', 'dept': 'EEE', 'level': 'Level 1', 'term': 'Term I', 'author': 'Dr. Karim', 'size': '4.1 MB'},
    {'title': 'Thermodynamics Assignment', 'course': 'ME 2101', 'type': 'Assignment', 'dept': 'ME', 'level': 'Level 2', 'term': 'Term I', 'author': 'Prof. Hasan', 'size': '1.2 MB'},
    {'title': 'CSE Previous Year 2024', 'course': 'CSE 3201', 'type': 'Previous Year', 'dept': 'CSE', 'level': 'Level 3', 'term': 'Term II', 'author': 'Exam Dept', 'size': '5.0 MB'},
    {'title': 'Structural Analysis Project Report', 'course': 'CE 3101', 'type': 'Project Report', 'dept': 'CE', 'level': 'Level 3', 'term': 'Term I', 'author': 'CE Dept', 'size': '3.8 MB'},
    {'title': 'Database Management PPT', 'course': 'CSE 3101', 'type': 'PPT', 'dept': 'CSE', 'level': 'Level 3', 'term': 'Term I', 'author': 'Prof. Ahmed', 'size': '2.1 MB'},
    {'title': 'Student Data Excel Sheet', 'course': 'ICT 2101', 'type': 'Excel', 'dept': 'ICT', 'level': 'Level 2', 'term': 'Term I', 'author': 'ICT Dept', 'size': '1.5 MB'},
    {'title': 'Networking Notes TXT', 'course': 'CSE 3201', 'type': 'TXT', 'dept': 'CSE', 'level': 'Level 3', 'term': 'Term II', 'author': 'Dr. Kabir', 'size': '0.5 MB'},
    {'title': 'Digital Electronics PDF', 'course': 'EEE 2101', 'type': 'PDF', 'dept': 'EEE', 'level': 'Level 2', 'term': 'Term I', 'author': 'EEE Dept', 'size': '6.2 MB'},
  ];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _courseCtrl.dispose();
    super.dispose();
  }

  void _uploadResource() {
    if (_titleCtrl.text.isNotEmpty && _courseCtrl.text.isNotEmpty) {
      setState(() {
        _resources.insert(0, {
          'title': _titleCtrl.text,
          'course': _courseCtrl.text,
          'type': _uploadType,
          'dept': 'CSE',
          'level': 'Level 1',
          'term': 'Term I',
          'author': 'You',
          'size': 'New',
        });
      });
      _titleCtrl.clear();
      _courseCtrl.clear();
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ $_uploadType uploaded successfully!'), backgroundColor: AppColors.success),
      );
    }
  }

  void _downloadResource(String title, String type) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          const Icon(Icons.downloading, color: Colors.white),
          const SizedBox(width: 10),
          Expanded(child: Text('📥 Downloading $type: $title')),
        ]),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthService>().currentUser;
    final canUpload = user?.role == 'teacher' || user?.role == 'admin';

    final filtered = _resources.where((r) {
      if (_dept != 'All' && r['dept'] != _dept) return false;
      if (_level != 'All' && r['level'] != _level) return false;
      if (_term != 'All' && r['term'] != _term) return false;
      if (_type != 'All' && r['type'] != _type) return false;
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: Text('Academic Resources', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        actions: [
          if (canUpload)
            IconButton(
              icon: const Icon(Icons.upload_file),
              onPressed: () => _showUploadDialog(),
              tooltip: 'Upload Resource',
            ),
        ],
      ),
      body: Column(children: [
        // Filter Bar
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(children: [
              _filterChip('Department', _dept, AppConstants.departments.map((d) => d['name'].toString()).toList(), (v) => setState(() => _dept = v)),
              const SizedBox(width: 6),
              _filterChip('Level', _level, ['All', 'Level 1', 'Level 2', 'Level 3', 'Level 4'], (v) => setState(() => _level = v)),
              const SizedBox(width: 6),
              _filterChip('Term', _term, ['All', 'Term I', 'Term II'], (v) => setState(() => _term = v)),
              const SizedBox(width: 6),
              _filterChip('Type', _type, _allTypes, (v) => setState(() => _type = v)),
            ]),
          ),
        ),

        // Resources List
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.folder_off, size: 80, color: Colors.grey.shade300),
                    const SizedBox(height: 16),
                    Text('No resources found', style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey)),
                    Text('Try changing filters', style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey)),
                  ]),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: filtered.length,
                  itemBuilder: (context, i) {
                    final r = filtered[i];
                    final type = r['type'].toString();
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      child: ListTile(
                        leading: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(_getTypeIcon(type), style: const TextStyle(fontSize: 22)),
                          ),
                        ),
                        title: Text(
                          r['title'].toString(),
                          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '📚 ${r['course']} • 🎓 ${r['level']} ${r['term']}',
                              style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary),
                            ),
                            Text(
                              '📂 $type • 📏 ${r['size']} • 👤 ${r['author']}',
                              style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey),
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.download_rounded, color: AppColors.primary, size: 28),
                          onPressed: () => _downloadResource(r['title'].toString(), type),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ]),
    );
  }

  Widget _filterChip(String label, String value, List<String> options, Function(String) onSelect) {
    return PopupMenuButton<String>(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: onSelect,
      child: Chip(
        label: Text('$label: $value', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w500)),
        backgroundColor: value == 'All' ? Colors.grey.shade100 : AppColors.primary.withOpacity(0.1),
        labelStyle: TextStyle(
          color: value == 'All' ? AppColors.textSecondary : AppColors.primary,
          fontSize: 11,
        ),
        side: BorderSide.none,
      ),
      itemBuilder: (context) => options.map((o) => PopupMenuItem(
        value: o,
        child: Text(o, style: GoogleFonts.poppins(fontSize: 13)),
      )).toList(),
    );
  }

  String _getTypeIcon(String type) {
    switch (type) {
      case 'Book': return '📘';
      case 'Slide': return '📊';
      case 'Class Note': return '📝';
      case 'Lab Manual': return '📗';
      case 'Assignment': return '📋';
      case 'Previous Year': return '📄';
      case 'Project Report': return '📑';
      case 'PPT': return '📙';
      case 'Excel': return '📈';
      case 'TXT': return '📃';
      case 'PDF': return '📕';
      default: return '📁';
    }
  }

  void _showUploadDialog() {
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Row(children: [
            const Icon(Icons.upload_file, color: AppColors.primary),
            const SizedBox(width: 8),
            Text('Upload Resource', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          ]),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(
                controller: _titleCtrl,
                decoration: InputDecoration(
                  labelText: 'Resource Title',
                  hintText: 'e.g., C Programming Notes',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  prefixIcon: const Icon(Icons.title),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _courseCtrl,
                decoration: InputDecoration(
                  labelText: 'Course Code',
                  hintText: 'e.g., CSE 1101',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  prefixIcon: const Icon(Icons.book),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _uploadType,
                decoration: InputDecoration(
                  labelText: 'Resource Type',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  prefixIcon: const Icon(Icons.category),
                ),
                items: _allTypes.where((t) => t != 'All').map((t) => DropdownMenuItem(
                  value: t,
                  child: Row(children: [
                    Text(_getTypeIcon(t), style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                    Text(t, style: GoogleFonts.poppins()),
                  ]),
                )).toList(),
                onChanged: (v) => setDialogState(() => _uploadType = v!),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(children: [
                  const Icon(Icons.info, color: AppColors.info, size: 16),
                  const SizedBox(width: 6),
                  Expanded(child: Text('Supported: Book, Slide, PDF, Word, Excel, PPT, TXT, Lab Manual, Assignment, Previous Year', style: GoogleFonts.poppins(fontSize: 10, color: AppColors.info))),
                ]),
              ),
            ]),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel', style: GoogleFonts.poppins()),
            ),
            ElevatedButton.icon(
              onPressed: _uploadResource,
              icon: const Icon(Icons.cloud_upload, size: 18),
              label: Text('Upload', style: GoogleFonts.poppins(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}