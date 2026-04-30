import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/app_colors.dart';
import '../config/app_constants.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});
  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final _idCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _deptCtrl = TextEditingController();
  String _selectedBook = 'Introduction to Algorithms';

  final List<Map<String, String>> _availableBooks = [
    {'title': 'Introduction to Algorithms', 'author': 'Thomas H. Cormen', 'dept': 'CSE', 'year': '2022'},
    {'title': 'Digital Logic Design', 'author': 'M. Morris Mano', 'dept': 'CSE', 'year': '2021'},
    {'title': 'Circuit Analysis', 'author': 'William H. Hayt', 'dept': 'EEE', 'year': '2020'},
    {'title': 'Engineering Mechanics', 'author': 'J. L. Meriam', 'dept': 'ME', 'year': '2023'},
    {'title': 'Thermodynamics', 'author': 'Yunus A. Cengel', 'dept': 'ME', 'year': '2022'},
    {'title': 'Structural Analysis', 'author': 'R. C. Hibbeler', 'dept': 'CE', 'year': '2021'},
    {'title': 'Database Systems', 'author': 'Ramez Elmasri', 'dept': 'CSE', 'year': '2023'},
    {'title': 'Power Electronics', 'author': 'Muhammad H. Rashid', 'dept': 'EEE', 'year': '2020'},
  ];

  final List<Map<String, String>> _borrowedBooks = [];

  @override
  void dispose() {
    _idCtrl.dispose();
    _nameCtrl.dispose();
    _deptCtrl.dispose();
    super.dispose();
  }

  void _borrowBook() {
    if (_idCtrl.text.isNotEmpty && _nameCtrl.text.isNotEmpty && _deptCtrl.text.isNotEmpty) {
      setState(() {
        _borrowedBooks.add({
          'book': _selectedBook,
          'id': _idCtrl.text,
          'name': _nameCtrl.text,
          'dept': _deptCtrl.text,
          'date': DateTime.now().toString().substring(0, 10),
        });
      });
      _idCtrl.clear();
      _nameCtrl.clear();
      _deptCtrl.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ "$_selectedBook" borrowed successfully!'), backgroundColor: AppColors.success),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(title: Text('Library', style: GoogleFonts.poppins(fontWeight: FontWeight.w600))),
      body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF1A237E), Color(0xFF3949AB)]), borderRadius: BorderRadius.circular(18)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [const Icon(Icons.local_library, color: Colors.white, size: 28), const SizedBox(width: 10), Text(AppConstants.libraryInfo['name']!, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white))]),
            const SizedBox(height: 10),
            _info(Icons.location_on, AppConstants.libraryInfo['location']!),
            _info(Icons.access_time, 'Sat-Thu: 8:00 AM - 5:00 PM | Fri: Closed'),
            _info(Icons.book, '${AppConstants.libraryInfo['totalBooks']} Books Available'),
            _info(Icons.wifi, AppConstants.libraryInfo['wifi']!),
          ]),
        ),
        const SizedBox(height: 20),

        // Available Books
        Text('📚 Available Books', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _availableBooks.length,
            itemBuilder: (context, i) {
              final book = _availableBooks[i];
              return Container(
                width: 200,
                margin: const EdgeInsets.only(right: 10),
                child: Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('📘', style: const TextStyle(fontSize: 30)),
                      const SizedBox(height: 8),
                      Text(book['title']!, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Text('Author: ${book['author']}', style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey)),
                      Text('Dept: ${book['dept']} • ${book['year']}', style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey)),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: AppColors.success.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                        child: Text('Available', style: GoogleFonts.poppins(fontSize: 10, color: AppColors.success, fontWeight: FontWeight.bold)),
                      ),
                    ]),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),

        // Borrow Book
        Text('📋 Borrow a Book', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(children: [
              DropdownButtonFormField<String>(
                value: _selectedBook,
                decoration: InputDecoration(labelText: 'Select Book', prefixIcon: const Icon(Icons.book), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                items: _availableBooks.map((b) => DropdownMenuItem(value: b['title'], child: Text(b['title']!, style: GoogleFonts.poppins(fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis))).toList(),
                onChanged: (v) => setState(() => _selectedBook = v!),
              ),
              const SizedBox(height: 10),
              TextField(controller: _idCtrl, decoration: InputDecoration(labelText: 'Student/Teacher ID', prefixIcon: const Icon(Icons.badge), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
              const SizedBox(height: 10),
              TextField(controller: _nameCtrl, decoration: InputDecoration(labelText: 'Full Name', prefixIcon: const Icon(Icons.person), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
              const SizedBox(height: 10),
              TextField(controller: _deptCtrl, decoration: InputDecoration(labelText: 'Department', prefixIcon: const Icon(Icons.business), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
              const SizedBox(height: 12),
              SizedBox(width: double.infinity, child: ElevatedButton.icon(onPressed: _borrowBook, icon: const Icon(Icons.bookmark_add), label: Text('Borrow Book', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)), style: ElevatedButton.styleFrom(backgroundColor: AppColors.success, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))))),
            ]),
          ),
        ),

        if (_borrowedBooks.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text('📖 Borrowed Books (${_borrowedBooks.length})', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ..._borrowedBooks.map((b) => Card(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), child: ListTile(leading: CircleAvatar(backgroundColor: AppColors.success.withOpacity(0.1), child: const Icon(Icons.book, color: AppColors.success)), title: Text(b['book']!, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13)), subtitle: Text('ID: ${b['id']} • ${b['name']} • ${b['dept']} • ${b['date']}', style: GoogleFonts.poppins(fontSize: 10)))))],
        const SizedBox(height: 20),
      ])),
    );
  }

  Widget _info(IconData icon, String text) => Padding(padding: const EdgeInsets.symmetric(vertical: 2), child: Row(children: [Icon(icon, color: Colors.white70, size: 15), const SizedBox(width: 8), Expanded(child: Text(text, style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70)))]));
}