import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/auth_service.dart';
import '../services/library_service.dart';
import '../models/library_model.dart';
import 'query_board_screen.dart';

class LibraryAdminPanel extends StatefulWidget {
  const LibraryAdminPanel({super.key});

  @override
  State<LibraryAdminPanel> createState() => _LibraryAdminPanelState();
}

class _LibraryAdminPanelState extends State<LibraryAdminPanel> {
  int _selectedIndex = -1; // -1 = no box selected, 0 = Library, 1 = Query

  Future<void> _logout() async {
    final auth = Provider.of<AuthService>(context, listen: false);
    await auth.signOut();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  void _goBack() {
    setState(() {
      _selectedIndex = -1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthService>(context).currentUser;
    
    if (user?.role != 'admin') {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Access Denied'),
          backgroundColor: Colors.red,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.lock, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('Only Admin can access Library panel'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Go Back'),
            ),
          ]),
        ),
      );
    }

    // যদি কোনো বক্স সিলেক্ট করা থাকে
    if (_selectedIndex != -1) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F6FA),
        appBar: AppBar(
          title: Text(
            _selectedIndex == 0 ? 'Library Management' : 'Query Board',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20),
          ),
          backgroundColor: const Color(0xFF1A237E),
          centerTitle: true,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: _goBack,
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              onPressed: _logout,
            ),
          ],
        ),
        body: _selectedIndex == 0
            ? const LibraryManagementContent()
            : const QueryBoardScreen(),
      );
    }

    // বক্স সিলেক্ট করা না থাকলে ২টা বক্স দেখাবে
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: Text('Library Admin Panel',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20),
        ),
        backgroundColor: const Color(0xFF1A237E),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _logout,
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          // Welcome Card
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1A237E), Color(0xFF3949AB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  width: 55,
                  height: 55,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(Icons.local_library, size: 30, color: Color(0xFF1A237E)),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome,',
                        style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70),
                      ),
                      Text(
                        user?.name ?? 'Library Admin',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'ADMIN • LIBRARY',
                        style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          // Two Boxes
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _buildServiceCard(
                    icon: Icons.local_library,
                    title: 'Library',
                    subtitle: 'Management',
                    color: const Color(0xFF2196F3),
                    onTap: () => setState(() => _selectedIndex = 0),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildServiceCard(
                    icon: Icons.question_answer,
                    title: 'Query',
                    subtitle: 'Board',
                    color: const Color(0xFF4CAF50),
                    onTap: () => setState(() => _selectedIndex = 1),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
          border: Border.all(color: Colors.grey.shade200, width: 1.5),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1A237E),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== LIBRARY MANAGEMENT CONTENT (আপনার আগের কোড) ====================
class LibraryManagementContent extends StatefulWidget {
  const LibraryManagementContent({super.key});

  @override
  State<LibraryManagementContent> createState() => _LibraryManagementContentState();
}

class _LibraryManagementContentState extends State<LibraryManagementContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  String _filterStatus = 'All';
  
  final TextEditingController _bookTitleCtrl = TextEditingController();
  final TextEditingController _bookAuthorCtrl = TextEditingController();
  final TextEditingController _bookDeptCtrl = TextEditingController();
  final TextEditingController _bookYearCtrl = TextEditingController();
  final TextEditingController _bookTotalCopiesCtrl = TextEditingController();
  final TextEditingController _bookIsbnCtrl = TextEditingController();

  final List<String> _statusFilter = ['All', 'Active', 'Delivered'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    LibraryService.initBooks();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _bookTitleCtrl.dispose();
    _bookAuthorCtrl.dispose();
    _bookDeptCtrl.dispose();
    _bookYearCtrl.dispose();
    _bookTotalCopiesCtrl.dispose();
    _bookIsbnCtrl.dispose();
    super.dispose();
  }

  void _showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color, duration: const Duration(seconds: 2)),
    );
  }

  void _addBook() {
    if (_bookTitleCtrl.text.isEmpty ||
        _bookAuthorCtrl.text.isEmpty ||
        _bookDeptCtrl.text.isEmpty ||
        _bookYearCtrl.text.isEmpty ||
        _bookTotalCopiesCtrl.text.isEmpty) {
      _showSnackbar('Please fill all fields', Colors.red);
      return;
    }

    final newBook = LibraryBook(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _bookTitleCtrl.text,
      author: _bookAuthorCtrl.text,
      department: _bookDeptCtrl.text,
      year: _bookYearCtrl.text,
      totalCopies: int.parse(_bookTotalCopiesCtrl.text),
      availableCopies: int.parse(_bookTotalCopiesCtrl.text),
      isbn: _bookIsbnCtrl.text.isEmpty ? 'N/A' : _bookIsbnCtrl.text,
    );

    LibraryService.addBook(newBook);
    _bookTitleCtrl.clear();
    _bookAuthorCtrl.clear();
    _bookDeptCtrl.clear();
    _bookYearCtrl.clear();
    _bookTotalCopiesCtrl.clear();
    _bookIsbnCtrl.clear();

    setState(() {});
    _showSnackbar('Book added successfully', Colors.green);
  }

  void _deliverBook(String recordId, String bookId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Return Book'),
        content: const Text('Confirm book return?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final result = LibraryService.deliverBook(recordId, bookId);
              setState(() {});
              Navigator.pop(ctx);
              _showSnackbar(result['message'], result['success'] ? Colors.green : Colors.red);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('RETURN', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _deleteRecord(String recordId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Record'),
        content: const Text('Are you sure?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              LibraryService.deleteRecord(recordId);
              setState(() {});
              Navigator.pop(ctx);
              _showSnackbar('Record deleted', Colors.orange);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _deleteBook(String bookId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Book'),
        content: const Text('Delete this book?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              LibraryService.deleteBook(bookId);
              setState(() {});
              Navigator.pop(ctx);
              _showSnackbar('Book deleted', Colors.orange);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final allRecords = LibraryService.getAllRecords();
    final activeBooks = LibraryService.getActiveBooks();
    final overdueBooks = LibraryService.getOverdueBooks();
    final deliveredBooks = LibraryService.getReturnedBooks();
    final allBooks = LibraryService.getAvailableBooks();
    final totalFine = LibraryService.getTotalFineCollected();
    final todayFine = LibraryService.getTodayFine();
    const primaryColor = Color(0xFF1A237E);

    List<BorrowRecord> filteredRecords = [];
    if (_filterStatus == 'Active') {
      filteredRecords = activeBooks;
    } else if (_filterStatus == 'Delivered') {
      filteredRecords = deliveredBooks;
    } else {
      filteredRecords = allRecords;
    }

    if (_searchQuery.isNotEmpty) {
      filteredRecords = filteredRecords.where((r) =>
        r.bookTitle.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        r.userName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        r.userId.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        r.token.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: AppBar(
          backgroundColor: primaryColor,
          elevation: 0,
          bottom: TabBar(
            controller: _tabController,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
            tabs: const [
              Tab(text: '📊 DETAILS'),
              Tab(text: '📋 RECORDS'),
              Tab(text: '⚠️ DUE'),
              Tab(text: '📚 MANAGE'),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDashboardTab(totalFine, todayFine, activeBooks.length, overdueBooks.length, 
              deliveredBooks.length, allBooks.length, allRecords.length, primaryColor),
          _buildAllRecordsTab(filteredRecords),
          _buildOverdueTab(overdueBooks),
          _buildManageBooksTab(allBooks, totalFine),
        ],
      ),
    );
  }

  Widget _buildDashboardTab(double totalFine, double todayFine, int activeCount, 
      int overdueCount, int deliveredCount, int totalBooks, int totalRecords, Color primaryColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Income Summary Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1A237E), Color(0xFF3949AB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.today, size: 18, color: Colors.white70),
                          const SizedBox(width: 6),
                          Text('TODAY\'S FINE', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w500)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text('৳${todayFine.toStringAsFixed(0)}', 
                        style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('collected today', style: TextStyle(color: Colors.white70, fontSize: 11)),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 70,
                  color: Colors.white30,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Icon(Icons.attach_money, size: 18, color: Colors.white70),
                          const SizedBox(width: 6),
                          Text('TOTAL FINE', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w500)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text('৳${totalFine.toStringAsFixed(0)}', 
                        style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('total collected', style: TextStyle(color: Colors.white70, fontSize: 11)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Stats Grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.4,
            children: [
              _buildStatCard('Active Books', activeCount.toString(), Icons.book, Colors.blue),
              _buildStatCard('Overdue Books', overdueCount.toString(), Icons.warning, Colors.red),
              _buildStatCard('Returned', deliveredCount.toString(), Icons.check_circle, Colors.green),
              _buildStatCard('Total Books', totalBooks.toString(), Icons.library_books, primaryColor),
              _buildStatCard('Total Records', totalRecords.toString(), Icons.receipt, Colors.indigo),
              _buildStatCard('Active Users', '${LibraryService.getUniqueUsers().length}', Icons.people, Colors.brown),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: color),
          const SizedBox(height: 6),
          Text(value, style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          Text(title, style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildAllRecordsTab(List<BorrowRecord> records) {
    if (records.isEmpty) {
      return const Center(child: Text('No records found'));
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (v) => setState(() => _searchQuery = v),
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _filterStatus,
                    items: _statusFilter.map((s) => DropdownMenuItem(
                      value: s, 
                      child: Text(s, style: const TextStyle(fontSize: 13)),
                    )).toList(),
                    onChanged: (v) => setState(() => _filterStatus = v!),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: records.length,
            itemBuilder: (context, i) {
              final record = records[i];
              final isReturned = record.status == 'returned';
              final daysOverdue = record.daysOverdue;
              final fine = daysOverdue * 5;
              
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ExpansionTile(
                  title: Text(record.bookTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('User: ${record.userName} (${record.userId})'),
                      Text('Token: ${record.token}', style: const TextStyle(color: Colors.blue)),
                      if (!isReturned && daysOverdue > 0)
                        Text('Fine: ৳$fine', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  trailing: isReturned
                      ? const Chip(label: Text('RETURNED'), backgroundColor: Colors.green)
                      : ElevatedButton(
                          onPressed: () => _deliverBook(record.id, record.bookId),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                          child: const Text('RETURN', style: TextStyle(color: Colors.white)),
                        ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.calendar_today, size: 14, color: Colors.blue),
                              const SizedBox(width: 8),
                              Text('Borrow Date: ', style: TextStyle(fontSize: 12)),
                              Text(_formatDate(record.borrowDate), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.warning_amber, size: 14, color: Colors.orange),
                              const SizedBox(width: 8),
                              Text('Due Date: ', style: TextStyle(fontSize: 12)),
                              Text(_formatDate(record.dueDate), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.orange)),
                            ],
                          ),
                          if (daysOverdue > 0) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.error, size: 14, color: Colors.red),
                                const SizedBox(width: 8),
                                Text('Overdue by: ', style: TextStyle(fontSize: 12)),
                                Text('$daysOverdue days', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.red)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.money, size: 14, color: Colors.red),
                                const SizedBox(width: 8),
                                Text('Fine Amount: ', style: TextStyle(fontSize: 12)),
                                Text('৳$fine', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.red)),
                              ],
                            ),
                          ],
                          if (record.returnDate != null) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.check_circle, size: 14, color: Colors.green),
                                const SizedBox(width: 8),
                                Text('Returned Date: ', style: TextStyle(fontSize: 12)),
                                Text(_formatDate(record.returnDate!), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.green)),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOverdueTab(List<BorrowRecord> overdueBooks) {
    if (overdueBooks.isEmpty) {
      return const Center(child: Text('No overdue books'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: overdueBooks.length,
      itemBuilder: (context, i) {
        final record = overdueBooks[i];
        final fine = record.daysOverdue * 5;
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            leading: Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.warning, color: Colors.red),
            ),
            title: Text(record.bookTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('User: ${record.userName} (${record.userId})', style: const TextStyle(fontSize: 12)),
                Text('Borrowed: ${_formatDate(record.borrowDate)}', style: const TextStyle(fontSize: 11)),
                Text('Due: ${_formatDate(record.dueDate)}', style: const TextStyle(fontSize: 11, color: Colors.red)),
                Text('Overdue by: ${record.daysOverdue} days', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.red)),
                Text('Fine: ৳$fine', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.red)),
              ],
            ),
            trailing: ElevatedButton(
              onPressed: () => _deliverBook(record.id, record.bookId),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('RETURN', style: TextStyle(color: Colors.white)),
            ),
          ),
        );
      },
    );
  }

  Widget _buildManageBooksTab(List<LibraryBook> allBooks, double totalFine) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Total Fine Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Colors.orange, Colors.deepOrange]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total Fine Collected', style: TextStyle(color: Colors.white)),
                    const Text('From overdue books', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
                Text('৳${totalFine.toStringAsFixed(0)}', 
                  style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Add Book Form
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                TextField(
                  controller: _bookTitleCtrl,
                  decoration: InputDecoration(labelText: 'Book Title', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _bookAuthorCtrl,
                  decoration: InputDecoration(labelText: 'Author', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _bookDeptCtrl,
                        decoration: InputDecoration(labelText: 'Department', border: OutlineInputBorder()),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _bookYearCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(labelText: 'Year', border: OutlineInputBorder()),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _bookTotalCopiesCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(labelText: 'Total Copies', border: OutlineInputBorder()),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _bookIsbnCtrl,
                        decoration: InputDecoration(labelText: 'ISBN', border: OutlineInputBorder()),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _addBook,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: const Text('ADD BOOK', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Book List
          Text('Book List (${allBooks.length})', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...allBooks.map((book) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(book.title, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold)),
                      Text('${book.author} | ${book.department} | ${book.year}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Text('${book.availableCopies}/${book.totalCopies}',
                      style: TextStyle(color: book.availableCopies > 0 ? Colors.green : Colors.red)),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteBook(book.id),
                    ),
                  ],
                ),
              ],
            ),
          )),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}