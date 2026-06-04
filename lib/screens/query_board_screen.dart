import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../config/app_colors.dart';
import '../config/app_constants.dart';

class QueryBoardScreen extends StatefulWidget {
  const QueryBoardScreen({super.key});
  @override
  State<QueryBoardScreen> createState() => _QueryBoardScreenState();
}

class _QueryBoardScreenState extends State<QueryBoardScreen> {
  String _categoryFilter = 'All';
  String _deptFilter = 'All';
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  
  final List<Map<String, dynamic>> _queries = [
    {'id': 1, 'title': 'CGPA calculation help', 'desc': 'How to calculate CGPA for all semesters?', 'category': 'academic', 'dept': 'CSE', 'postedBy': 'Karim', 'role': 'Student (L2T1)', 'time': '2h ago', 'replies': [{'id': 1, 'text': 'Use the formula...', 'by': 'Senior Student', 'role': 'Student (L3T1)', 'userId': 'u2'}], 'status': 'open', 'userId': 'u1'},
    {'id': 2, 'title': 'Bus schedule for Rangpur?', 'desc': 'What time does the bus leave for Rangpur on Thursday?', 'category': 'campus', 'dept': 'EEE', 'postedBy': 'Rahima', 'role': 'Teacher', 'time': '5h ago', 'replies': [{'id': 1, 'text': '6:30 AM', 'by': 'Transport Admin', 'role': 'Admin (Transport)', 'userId': 'u3'}], 'status': 'resolved', 'userId': 'u2'},
    {'id': 3, 'title': 'Need CSE 2101 notes', 'desc': 'Can anyone share Data Structures notes? PDF preferred.', 'category': 'academic', 'dept': 'CSE', 'postedBy': 'Tanvir', 'role': 'Student (L2T2)', 'time': '1d ago', 'replies': [{'id': 1, 'text': 'Check academic resources', 'by': 'Teacher', 'role': 'Lecturer', 'userId': 'u4'}], 'status': 'open', 'userId': 'u3'},
  ];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _addQuery(String category, String dept, String roleInfo) {
    if (_titleCtrl.text.isNotEmpty && _descCtrl.text.isNotEmpty) {
      final user = context.read<AuthService>().currentUser;
      setState(() {
        _queries.insert(0, {
          'id': DateTime.now().millisecondsSinceEpoch,
          'title': _titleCtrl.text,
          'desc': _descCtrl.text,
          'category': category,
          'dept': dept,
          'postedBy': user?.name ?? 'Anonymous',
          'role': roleInfo,
          'time': 'Just now',
          'replies': [],
          'status': 'open',
          'userId': user?.id ?? 'unknown',
        });
      });
      _titleCtrl.clear();
      _descCtrl.clear();
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Query posted!'), backgroundColor: AppColors.success)
      );
    }
  }

  void _deleteQuery(int index, int queryId) {
    final user = context.read<AuthService>().currentUser;
    final query = _queries[index];
    
    // Check if user can delete: original poster or admin
    if (query['userId'] != user?.id && user?.role != 'admin') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Only the poster or admin can delete'), backgroundColor: AppColors.error)
      );
      return;
    }

    setState(() {
      _queries.removeWhere((q) => q['id'] == queryId);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ Query deleted'), backgroundColor: AppColors.success)
    );
  }

  void _deleteReply(int queryIndex, int replyId) {
    final user = context.read<AuthService>().currentUser;
    final reply = _queries[queryIndex]['replies'].firstWhere((r) => r['id'] == replyId);
    
    // Check if user can delete
    if (reply['userId'] != user?.id && user?.role != 'admin' && user?.role != 'teacher') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Only the author, teachers or admin can delete'), backgroundColor: AppColors.error)
      );
      return;
    }

    setState(() {
      _queries[queryIndex]['replies'].removeWhere((r) => r['id'] == replyId);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ Reply deleted'), backgroundColor: AppColors.success)
    );
  }

  void _addReply(int queryIndex, String replyText, String roleInfo) {
    final user = context.read<AuthService>().currentUser;
    setState(() {
      _queries[queryIndex]['replies'].insert(0, {
        'id': DateTime.now().millisecondsSinceEpoch,
        'text': replyText,
        'by': user?.name ?? 'Anonymous',
        'role': roleInfo,
        'userId': user?.id ?? 'unknown',
      });
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ Reply added!'), backgroundColor: AppColors.success)
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthService>().currentUser;
    
    final filtered = _queries.where((q) {
      final categoryMatch = _categoryFilter == 'All' || q['category'] == _categoryFilter;
      final deptMatch = _deptFilter == 'All' || q['dept'] == _deptFilter;
      return categoryMatch && deptMatch;
    }).toList();
    
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: Text('Query Board', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(user),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add),
        label: Text('Ask Question', style: GoogleFonts.poppins()),
      ),
      body: Column(children: [
        // Category Filter
        SizedBox(
          height: 50,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            children: ['All', 'academic', 'campus', 'technical'].map((f) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: FilterChip(
                label: Text(f.toUpperCase(), style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: _categoryFilter == f ? Colors.white : AppColors.textSecondary)),
                selected: _categoryFilter == f,
                onSelected: (_) => setState(() => _categoryFilter = f),
                backgroundColor: Colors.grey.shade100,
                selectedColor: AppColors.primary,
              ),
            )).toList(),
          ),
        ),
        
        // Department Filter
        SizedBox(
          height: 50,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            children: ['All', ...AppConstants.departments.map((d) => d['name'].toString())].map((d) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: FilterChip(
                label: Text(d, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: _deptFilter == d ? Colors.white : AppColors.textSecondary)),
                selected: _deptFilter == d,
                onSelected: (_) => setState(() => _deptFilter = d),
                backgroundColor: Colors.grey.shade100,
                selectedColor: AppColors.info,
              ),
            )).toList(),
          ),
        ),

        // Queries List
        Expanded(
          child: filtered.isEmpty
            ? Center(child: Text('No queries found', style: GoogleFonts.poppins(color: Colors.grey)))
            : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: filtered.length,
                itemBuilder: (context, i) {
                  final q = filtered[i];
                  final canDelete = user?.id == q['userId'] || user?.role == 'admin';
                  
                  return InkWell(
                    onTap: () => _showQueryDetails(context, q, i),
                    child: Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                                child: Text(q['postedBy'].toString()[0].toUpperCase(), style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 12)),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(q['postedBy'].toString(), style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600)),
                                    Text(q['role'].toString(), style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey)),
                                  ],
                                ),
                              ),
                              Text(q['time'].toString(), style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey)),
                              if (canDelete)
                                PopupMenuButton(
                                  itemBuilder: (ctx) => [
                                    PopupMenuItem(
                                      onTap: () => _deleteQuery(filtered.indexOf(q), q['id']),
                                      child: Row(children: [
                                        const Icon(Icons.delete, size: 18, color: AppColors.error),
                                        const SizedBox(width: 8),
                                        const Text('Delete'),
                                      ]),
                                    ),
                                  ],
                                ),
                            ]),
                            const SizedBox(height: 8),
                            Text(q['title'].toString(), style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(q['desc'].toString(), style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary), maxLines: 2, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 8),
                            Row(children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: q['status'] == 'open' ? AppColors.success.withValues(alpha: 0.1) : AppColors.info.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  q['status'].toString().toUpperCase(),
                                  style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: q['status'] == 'open' ? AppColors.success : AppColors.info),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Chip(label: Text(q['dept'], style: GoogleFonts.poppins(fontSize: 10))),
                              const Spacer(),
                              const Icon(Icons.chat_bubble_outline, size: 14, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text('${q['replies'].length}', style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey)),
                            ]),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
        ),
      ]),
    );
  }

  void _showQueryDetails(BuildContext context, Map<String, dynamic> q, int queryIndex) {
    final user = context.read<AuthService>().currentUser;
    String selectedReplyRole = 'Student';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text(q['title'], style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Posted by: ${q['postedBy']} (${q['role']})', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
                Text('Department: ${q['dept']}', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 8),
                Text(q['desc'], style: GoogleFonts.poppins(fontSize: 14)),
                const SizedBox(height: 16),
                Text('Replies (${q['replies'].length})', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                if (q['replies'].isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text('No replies yet', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
                  )
                else
                  ...q['replies'].asMap().entries.map<Widget>((entry) {
                    final r = entry.value;
                    final canDeleteReply = user?.id == r['userId'] || user?.role == 'admin' || user?.role == 'teacher';
                    
                    return Card(
                      margin: const EdgeInsets.only(top: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('${r['by']} (${r['role']})', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600)),
                                      Text(r['text'], style: GoogleFonts.poppins(fontSize: 12)),
                                    ],
                                  ),
                                ),
                                if (canDeleteReply)
                                  IconButton(
                                    icon: const Icon(Icons.delete, size: 16, color: AppColors.error),
                                    onPressed: () {
                                      _deleteReply(queryIndex, r['id']);
                                      Navigator.pop(ctx);
                                    },
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
            if (user != null)
              ElevatedButton(
                onPressed: () => _showAddReplyDialog(ctx, queryIndex, user, selectedReplyRole, setState),
                child: const Text('Add Reply'),
              ),
          ],
        ),
      ),
    );
  }

  void _showAddReplyDialog(BuildContext ctx, int queryIndex, var user, String selectedReplyRole, Function setState) {
    final replyCtrl = TextEditingController();
    showDialog(
      context: ctx,
      builder: (context) => StatefulBuilder(
        builder: (ctx2, setState2) => AlertDialog(
          title: Text('Add Reply', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: selectedReplyRole,
                items: _getRoleOptions(user).map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                onChanged: (v) => setState2(() => selectedReplyRole = v!),
                decoration: InputDecoration(labelText: 'Your Role', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: replyCtrl,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Write your reply...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx2), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                _addReply(queryIndex, replyCtrl.text, selectedReplyRole);
                Navigator.pop(ctx2);
                Navigator.pop(ctx);
              },
              child: const Text('Post Reply'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddDialog(dynamic user) {
    String selectedCategory = 'academic';
    String selectedDept = 'CSE';
    String selectedRole = _getRoleOptions(user).first;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text('Ask a Question', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: selectedCategory,
                  items: ['academic', 'campus', 'technical'].map((c) => DropdownMenuItem(value: c, child: Text(c.toUpperCase()))).toList(),
                  onChanged: (v) => setState(() => selectedCategory = v!),
                  decoration: InputDecoration(labelText: 'Category', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedDept,
                  items: AppConstants.departments.map((d) => DropdownMenuItem(value: d['name'].toString(), child: Text(d['name'].toString()))).toList(),
                  onChanged: (v) => setState(() => selectedDept = v!),
                  decoration: InputDecoration(labelText: 'Department', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedRole,
                  items: _getRoleOptions(user).map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                  onChanged: (v) => setState(() => selectedRole = v!),
                  decoration: InputDecoration(labelText: 'Your Role', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _titleCtrl,
                  decoration: InputDecoration(hintText: 'Question Title', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _descCtrl,
                  maxLines: 4,
                  decoration: InputDecoration(hintText: 'Question Description', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () => _addQuery(selectedCategory, selectedDept, selectedRole),
              child: const Text('Post Question'),
            ),
          ],
        ),
      ),
    );
  }

  List<String> _getRoleOptions(dynamic user) {
    if (user == null) return ['Guest'];
    
    switch (user.role) {
      case 'student':
        final level = user.level ?? 'Level 1';
        final term = user.term ?? 'Term I';
        return ['Student ($level$term)', 'Senior Student', 'Junior Student', 'Anonymous'];
      case 'teacher':
        final designation = user.designation ?? 'Lecturer';
        return [designation, 'Anonymous'];
      case 'admin':
        return ['Admin', 'Cafe Admin', 'Library Admin', 'Anonymous'];
      default:
        return ['Guest'];
    }
  }
}
