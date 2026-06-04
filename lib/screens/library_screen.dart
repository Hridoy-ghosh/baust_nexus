import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/auth_service.dart';
import '../services/library_service.dart';
import '../models/library_model.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Borrow Form Controllers
  final _userIdCtrl = TextEditingController();
  final _userNameCtrl = TextEditingController();
  final _userDeptCtrl = TextEditingController();
  final _userPhoneCtrl = TextEditingController();
  final _userEmailCtrl = TextEditingController();
  final _userSessionCtrl = TextEditingController();
  final _userSemesterCtrl = TextEditingController();
  
  // State Variables
  String _selectedBookId = '';
  String _selectedBookTitle = '';
  int _selectedBookCopies = 0;
  String _searchQuery = '';
  String _selectedDepartment = 'All';
  String _selectedSortBy = 'Title';
  bool _showOnlyAvailable = false;
  int _currentPage = 0;
  final int _itemsPerPage = 8;
  DateTime _selectedDueDate = DateTime.now().add(const Duration(days: 30));
  String _userRole = 'Student'; // Student or Teacher
  
  final List<String> _sortOptions = ['Title', 'Author', 'Year', 'Copies'];
  final List<String> _departments = ['All', 'CSE', 'EEE', 'ME', 'CE', 'BBA', 'ENG', 'GEN', 'Pharmacy', 'Law'];
  final List<String> _userRoles = ['Student', 'Teacher'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    LibraryService.initBooks();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _userIdCtrl.dispose();
    _userNameCtrl.dispose();
    _userDeptCtrl.dispose();
    _userPhoneCtrl.dispose();
    _userEmailCtrl.dispose();
    _userSessionCtrl.dispose();
    _userSemesterCtrl.dispose();
    super.dispose();
  }

  List<LibraryBook> get _filteredBooks {
    var books = LibraryService.getAvailableBooks();
    
    if (_searchQuery.isNotEmpty) {
      books = books.where((b) => 
        b.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        b.author.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        b.isbn.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }
    
    if (_selectedDepartment != 'All') {
      books = books.where((b) => b.department == _selectedDepartment).toList();
    }
    
    if (_showOnlyAvailable) {
      books = books.where((b) => b.availableCopies > 0).toList();
    }
    
    if (_selectedSortBy == 'Title') {
      books.sort((a, b) => a.title.compareTo(b.title));
    } else if (_selectedSortBy == 'Author') {
      books.sort((a, b) => a.author.compareTo(b.author));
    } else if (_selectedSortBy == 'Year') {
      books.sort((a, b) => b.year.compareTo(a.year));
    } else if (_selectedSortBy == 'Copies') {
      books.sort((a, b) => b.availableCopies.compareTo(a.availableCopies));
    }
    
    return books;
  }

  List<LibraryBook> get _paginatedBooks {
    final start = _currentPage * _itemsPerPage;
    final end = start + _itemsPerPage;
    if (start >= _filteredBooks.length) return [];
    return _filteredBooks.sublist(start, end > _filteredBooks.length ? _filteredBooks.length : end);
  }

  int get _totalPages => (_filteredBooks.length / _itemsPerPage).ceil();

  Future<void> _selectDueDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1A237E),
              onPrimary: Colors.white,
              onSurface: Color(0xFF1A237E),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDueDate) {
      setState(() {
        _selectedDueDate = picked;
      });
    }
  }

  void _borrowBook() {
    if (_selectedBookId.isEmpty) {
      _showSnackbar('Please select a book', Colors.red);
      return;
    }
    if (_userIdCtrl.text.isEmpty) {
      _showSnackbar('Please enter ID', Colors.red);
      return;
    }
    if (_userNameCtrl.text.isEmpty) {
      _showSnackbar('Please enter Full Name', Colors.red);
      return;
    }
    if (_userDeptCtrl.text.isEmpty) {
      _showSnackbar('Please enter Department', Colors.red);
      return;
    }

    // Check max borrow limit (5 for teachers, 3 for students)
    final userBorrowed = LibraryService.getBorrowedRecordsByUser(_userIdCtrl.text);
    final maxBorrow = _userRole == 'Teacher' ? 5 : 3;
    if (userBorrowed.length >= maxBorrow) {
      _showSnackbar('You can borrow maximum $maxBorrow books at a time', Colors.red);
      return;
    }

    final result = LibraryService.borrowBook(
      bookId: _selectedBookId,
      userId: _userIdCtrl.text,
      userName: _userNameCtrl.text,
      userDept: _userDeptCtrl.text,
      userRole: _userRole,
      userPhone: _userPhoneCtrl.text,
      userEmail: _userEmailCtrl.text,
      userSession: _userSessionCtrl.text,
      userSemester: _userSemesterCtrl.text,
      dueDate: _selectedDueDate,
    );

    if (result['success'] == true) {
      setState(() {
        _userIdCtrl.clear();
        _userNameCtrl.clear();
        _userDeptCtrl.clear();
        _userPhoneCtrl.clear();
        _userEmailCtrl.clear();
        _userSessionCtrl.clear();
        _userSemesterCtrl.clear();
        _selectedBookId = '';
        _selectedDueDate = DateTime.now().add(const Duration(days: 30));
      });
      _showSnackbar(result['message'], Colors.green);
    } else {
      _showSnackbar(result['message'], Colors.red);
    }
  }

  void _showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color, duration: const Duration(seconds: 4)),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  String _getRemainingDays(DateTime dueDate) {
    final now = DateTime.now();
    final remaining = dueDate.difference(now).inDays;
    if (remaining < 0) return 'Overdue by ${-remaining} days';
    if (remaining == 0) return 'Due today';
    return '$remaining days left';
  }

  String _getBookIcon(String department) {
    switch (department) {
      case 'CSE': return '💻';
      case 'EEE': return '⚡';
      case 'ME': return '🔧';
      case 'CE': return '🏗️';
      case 'BBA': return '📊';
      case 'ENG': return '📖';
      case 'Pharmacy': return '💊';
      case 'Law': return '⚖️';
      default: return '📚';
    }
  }

  Color _getDepartmentColor(String department) {
    switch (department) {
      case 'CSE': return Colors.blue;
      case 'EEE': return Colors.orange;
      case 'ME': return Colors.red;
      case 'CE': return Colors.green;
      case 'BBA': return Colors.purple;
      case 'ENG': return Colors.teal;
      case 'Pharmacy': return Colors.pink;
      case 'Law': return Colors.brown;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool canBorrow = context.watch<AuthService>().isLoggedIn;
    final borrowedRecords = LibraryService.getBorrowedRecordsByUser(_userIdCtrl.text);
    final totalBooks = LibraryService.getTotalBooks();
    final availableBooks = LibraryService.getAvailableBooksCount();
    final activeCount = LibraryService.getActiveBooks().length;
    final overdueCount = LibraryService.getOverdueBooks().length;
    final returnedCount = LibraryService.getReturnedBooks().length;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: Text('Central Library', 
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 22)),
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          indicatorSize: TabBarIndicatorSize.label,
          tabs: const [
            Tab(text: 'DASHBOARD', icon: Icon(Icons.dashboard, size: 20)),
            Tab(text: 'DETAILS', icon: Icon(Icons.book, size: 20)),
            Tab(text: 'HISTORY', icon: Icon(Icons.history, size: 20)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {}),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDashboardTab(totalBooks, availableBooks, activeCount, overdueCount, returnedCount, canBorrow, borrowedRecords),
          _buildDetailsTab(canBorrow, borrowedRecords),
          _buildHistoryTab(),
        ],
      ),
    );
  }

  // ==================== DASHBOARD TAB ====================
  Widget _buildDashboardTab(int totalBooks, int availableBooks, int activeCount, 
      int overdueCount, int returnedCount, bool canBorrow, List<BorrowRecord> borrowedRecords) {
    final now = DateTime.now();
    final todayBorrowed = LibraryService.getAllRecords().where((r) => 
      r.borrowDate.year == now.year && 
      r.borrowDate.month == now.month && 
      r.borrowDate.day == now.day
    ).length;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1A237E), Color(0xFF3949AB), Color(0xFF5C6BC0)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.local_library, size: 30, color: Colors.white),
                    const SizedBox(width: 10),
                    Text('Central Library',
                      style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  canBorrow ? 'Welcome! Students can borrow 3 books, Teachers can borrow 5 books' : 'Please login to borrow books',
                  style: GoogleFonts.poppins(fontSize: 13, color: Colors.white70),
                ),
                if (canBorrow && borrowedRecords.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Text(
                        '📖 You have ${borrowedRecords.length} book(s) borrowed',
                        style: GoogleFonts.poppins(fontSize: 12, color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 1.4,
            children: [
              _buildStatCard('Total Books', totalBooks.toString(), Icons.library_books, Colors.blue),
              _buildStatCard('Available', availableBooks.toString(), Icons.book, Colors.green),
              _buildStatCard('Borrowed', activeCount.toString(), Icons.bookmark, Colors.orange),
              _buildStatCard('Overdue', overdueCount.toString(), Icons.warning, Colors.red),
              _buildStatCard('Returned', returnedCount.toString(), Icons.check_circle, Colors.teal),
              _buildStatCard("Today's Borrow", todayBorrowed.toString(), Icons.today, Colors.purple),
              _buildStatCard('Active Users', '${LibraryService.getUniqueUsers().length}', Icons.people, Colors.indigo),
              _buildStatCard('Max Borrow', '3/5 per user', Icons.info, Colors.grey),
            ],
          ),
          const SizedBox(height: 80),
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
        boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(height: 8),
          Text(value, style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
          Text(title, style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }

  // ==================== DETAILS TAB ====================
  Widget _buildDetailsTab(bool canBorrow, List<BorrowRecord> borrowedRecords) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Search Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 6, offset: const Offset(0, 2))],
            ),
            child: Column(
              children: [
                TextField(
                  onChanged: (v) => setState(() => _searchQuery = v),
                  decoration: InputDecoration(
                    hintText: 'Search by title, author or ISBN...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: _searchQuery.isNotEmpty 
                      ? IconButton(icon: const Icon(Icons.clear, size: 18), onPressed: () => setState(() => _searchQuery = ''))
                      : null,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedDepartment,
                            isExpanded: true,
                            items: _departments.map((d) => DropdownMenuItem(
                              value: d, 
                              child: Text(d, style: const TextStyle(fontSize: 13)),
                            )).toList(),
                            onChanged: (v) => setState(() => _selectedDepartment = v!),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedSortBy,
                            isExpanded: true,
                            items: _sortOptions.map((s) => DropdownMenuItem(
                              value: s, 
                              child: Text(s, style: const TextStyle(fontSize: 13)),
                            )).toList(),
                            onChanged: (v) => setState(() => _selectedSortBy = v!),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: _showOnlyAvailable ? Colors.green.withOpacity(0.1) : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.filter_alt, size: 16),
                          const SizedBox(width: 6),
                          const Text('Available', style: TextStyle(fontSize: 11)),
                          Switch(
                            value: _showOnlyAvailable,
                            onChanged: (v) => setState(() => _showOnlyAvailable = v),
                            activeColor: Colors.green,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('📚 ${_filteredBooks.length} books found', 
                      style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
                    TextButton(
                      onPressed: () => setState(() {
                        _searchQuery = '';
                        _selectedDepartment = 'All';
                        _showOnlyAvailable = false;
                        _currentPage = 0;
                      }),
                      child: const Text('Reset Filters', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Books Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.65,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
            ),
            itemCount: _paginatedBooks.length,
            itemBuilder: (context, i) {
              final book = _paginatedBooks[i];
              final isAvailable = book.availableCopies > 0;
              return GestureDetector(
                onTap: () => _showBookDetailsDialog(book),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 6, offset: const Offset(0, 3))],
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final cardWidth = constraints.maxWidth;
                      final imageHeight = cardWidth * 0.52;
                      final iconSize = cardWidth * 0.28;
                      final horizontalPadding = cardWidth * 0.06;
                      
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            height: imageHeight,
                            margin: EdgeInsets.all(horizontalPadding),
                            decoration: BoxDecoration(
                              color: _getDepartmentColor(book.department).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Center(
                              child: Text(_getBookIcon(book.department), style: TextStyle(fontSize: iconSize)),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                            child: Text(
                              book.title,
                              style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                            child: Text(
                              book.author,
                              style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                            child: Row(
                              children: [
                                const Icon(Icons.content_copy, size: 12, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text('${book.availableCopies}/${book.totalCopies}',
                                    style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w500)),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: _getDepartmentColor(book.department).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(book.department, 
                                    style: TextStyle(fontSize: 9, color: _getDepartmentColor(book.department), fontWeight: FontWeight.w500)),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            decoration: BoxDecoration(
                              color: isAvailable ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                isAvailable ? 'AVAILABLE' : 'NOT AVAILABLE',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: isAvailable ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: cardWidth * 0.06),
                        ],
                      );
                    }
                  ),
                ),
              );
            },
          ),
          
          // Pagination
          if (_totalPages > 1)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: _currentPage > 0 ? () => setState(() => _currentPage--) : null,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF1A237E), Color(0xFF3949AB)]),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Text('${_currentPage + 1} / $_totalPages',
                        style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: _currentPage < _totalPages - 1 ? () => setState(() => _currentPage++) : null,
                  ),
                ],
              ),
            ),

          // Borrow Book Section
          if (canBorrow) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 8, offset: const Offset(0, 4))],
                border: Border.all(color: Colors.blue.shade100, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFF1A237E), Color(0xFF3949AB)]),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.bookmark_add, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Text('Borrow a Book', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Role Selection
                  Row(
                    children: [
                      const Text('Role:', style: TextStyle(fontSize: 14)),
                      const SizedBox(width: 12),
                      ..._userRoles.map((role) => Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: ChoiceChip(
                          label: Text(role, style: const TextStyle(fontSize: 12)),
                          selected: _userRole == role,
                          onSelected: (selected) {
                            if (selected) setState(() => _userRole = role);
                          },
                          selectedColor: const Color(0xFF1A237E),
                          labelStyle: TextStyle(color: _userRole == role ? Colors.white : Colors.black87),
                        ),
                      )),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // Book Selection
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButtonFormField<String>(
                        value: _selectedBookId.isEmpty ? null : _selectedBookId,
                        isExpanded: true,
                        hint: const Text('Select a book', style: TextStyle(fontSize: 14)),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                        items: LibraryService.getAvailableBooks().where((b) => b.availableCopies > 0).map((b) {
                          return DropdownMenuItem(
                            value: b.id,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Text('${b.title} (${b.author})', style: const TextStyle(fontSize: 13)),
                            ),
                          );
                        }).toList(),
                        onChanged: (v) {
                          setState(() {
                            _selectedBookId = v!;
                            final book = LibraryService.getAvailableBooks().firstWhere((b) => b.id == v);
                            _selectedBookTitle = book.title;
                            _selectedBookCopies = book.availableCopies;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // User ID
                  TextField(
                    controller: _userIdCtrl,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      labelText: _userRole == 'Student' ? 'Student ID' : 'Teacher ID',
                      hintText: _userRole == 'Student' ? 'e.g., 2020XXXXX' : 'e.g., T-001',
                      prefixIcon: const Icon(Icons.badge, size: 20),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Full Name
                  TextField(
                    controller: _userNameCtrl,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      labelText: 'Full Name',
                      prefixIcon: const Icon(Icons.person, size: 20),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Department
                  TextField(
                    controller: _userDeptCtrl,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      labelText: 'Department',
                      prefixIcon: const Icon(Icons.business, size: 20),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Session (for students) or optional
                  if (_userRole == 'Student')
                    TextField(
                      controller: _userSessionCtrl,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        labelText: 'Session',
                        hintText: 'e.g., 2020-2021',
                        prefixIcon: const Icon(Icons.school, size: 20),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      ),
                    ),
                  if (_userRole == 'Student') const SizedBox(height: 12),
                  
                  // Semester (for students) or optional
                  if (_userRole == 'Student')
                    TextField(
                      controller: _userSemesterCtrl,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        labelText: 'Semester',
                        hintText: 'e.g., 8th Semester',
                        prefixIcon: const Icon(Icons.grade, size: 20),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      ),
                    ),
                  if (_userRole == 'Student') const SizedBox(height: 12),
                  
                  // Phone
                  TextField(
                    controller: _userPhoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      hintText: 'e.g., 017XXXXXXXX',
                      prefixIcon: const Icon(Icons.phone, size: 20),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Email
                  TextField(
                    controller: _userEmailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email Address',
                      hintText: 'user@baust.edu.bd',
                      prefixIcon: const Icon(Icons.email, size: 20),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Due Date Selection
                  InkWell(
                    onTap: _selectDueDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 22, color: Color(0xFF1A237E)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Return Date', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
                                const SizedBox(height: 2),
                                Text(_formatDate(_selectedDueDate),
                                  style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500)),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_drop_down, size: 24),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Borrow Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _borrowBook,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 2,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.bookmark_add, color: Colors.white, size: 22),
                          const SizedBox(width: 10),
                          Text('BORROW BOOK', 
                            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 6)],
              ),
              child: Row(
                children: [
                  const Icon(Icons.lock_outline, color: Colors.grey, size: 40),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Please login to borrow books from the library.',
                      style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700]),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Current Borrowed Books
          if (canBorrow && borrowedRecords.isNotEmpty) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 6)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('📖 Currently Borrowed Books (${borrowedRecords.length})',
                      style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  ...borrowedRecords.map((record) {
                    final isOverdue = record.isOverdue;
                    final remaining = _getRemainingDays(record.dueDate);
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: isOverdue ? Colors.red.shade50 : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isOverdue ? Colors.red.shade200 : Colors.grey.shade200),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 45,
                                  height: 45,
                                  decoration: BoxDecoration(
                                    color: isOverdue ? Colors.red.withOpacity(0.1) : Colors.blue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(isOverdue ? Icons.warning : Icons.book, 
                                    size: 22, color: isOverdue ? Colors.red : Colors.blue),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(record.bookTitle, 
                                        style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 4),
                                      Text('Token: ${record.token}', 
                                        style: GoogleFonts.poppins(fontSize: 11, color: Colors.blue)),
                                    ],
                                  ),
                                ),
                                if (isOverdue)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text('Fine: ৳${record.calculatedFine.toStringAsFixed(0)}',
                                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text('Borrowed: ${_formatDate(record.borrowDate)}', 
                                  style: GoogleFonts.poppins(fontSize: 11)),
                                const SizedBox(width: 16),
                                const Icon(Icons.event, size: 14, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text('Return by: ${_formatDate(record.dueDate)}', 
                                  style: GoogleFonts.poppins(fontSize: 11, 
                                    color: isOverdue ? Colors.red : Colors.green, fontWeight: FontWeight.w500)),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                              decoration: BoxDecoration(
                                color: isOverdue ? Colors.red.withOpacity(0.1) : Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.timer, size: 14, color: isOverdue ? Colors.red : Colors.blue),
                                  const SizedBox(width: 6),
                                  Text(remaining,
                                    style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold,
                                      color: isOverdue ? Colors.red : Colors.blue)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  void _showBookDetailsDialog(LibraryBook book) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Text(_getBookIcon(book.department), style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(book.title, 
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
                maxLines: 2,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _detailRow('Author', book.author),
            _detailRow('Department', book.department),
            _detailRow('Year', book.year),
            _detailRow('ISBN', book.isbn),
            _detailRow('Total Copies', book.totalCopies.toString()),
            _detailRow('Available Copies', book.availableCopies.toString(),
                color: book.availableCopies > 0 ? Colors.green : Colors.red),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            style: TextButton.styleFrom(foregroundColor: const Color(0xFF1A237E)),
            child: const Text('CLOSE', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text('$label:', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.grey)),
          ),
          Expanded(
            child: Text(value, style: GoogleFonts.poppins(fontSize: 13, color: color ?? Colors.black87)),
          ),
        ],
      ),
    );
  }

  // ==================== HISTORY TAB ====================
  Widget _buildHistoryTab() {
    final String userId = _userIdCtrl.text;
    
    final userRecords = LibraryService.getUserAllRecords(userId);
    
    if (userRecords.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 100, color: Colors.grey.shade300),
            const SizedBox(height: 20),
            Text('No borrowing history',
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.grey)),
            const SizedBox(height: 8),
            Text('Enter your ID and borrow books to see history',
                style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: userRecords.length,
      itemBuilder: (context, i) {
        final record = userRecords[i];
        final isReturned = record.status == 'returned';
        final isOverdue = record.isOverdue;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 6, offset: const Offset(0, 2))],
            border: Border.all(
              color: isReturned ? Colors.green.shade100 : (isOverdue ? Colors.red.shade100 : Colors.blue.shade100),
              width: 1.5,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 55,
                      height: 55,
                      decoration: BoxDecoration(
                        color: isReturned ? Colors.green.withOpacity(0.1) : (isOverdue ? Colors.red.withOpacity(0.1) : Colors.blue.withOpacity(0.1)),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        isReturned ? Icons.check_circle : (isOverdue ? Icons.warning : Icons.book),
                        color: isReturned ? Colors.green : (isOverdue ? Colors.red : Colors.blue),
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(record.bookTitle,
                            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text('Token: ${record.token}',
                            style: GoogleFonts.poppins(fontSize: 12, color: Colors.blue, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: isReturned ? Colors.green.withOpacity(0.1) : (isOverdue ? Colors.red.withOpacity(0.1) : Colors.orange.withOpacity(0.1)),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isReturned ? 'DELIVERED' : (isOverdue ? 'OVERDUE' : 'ACTIVE'),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isReturned ? Colors.green : (isOverdue ? Colors.red : Colors.orange),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.person_outline, size: 16, color: Colors.grey),
                          const SizedBox(width: 8),
                          Text('${record.userName} (${record.userId})', style: const TextStyle(fontSize: 13)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.business, size: 16, color: Colors.grey),
                          const SizedBox(width: 8),
                          Text(record.userDept, style: const TextStyle(fontSize: 13)),
                        ],
                      ),
                      if (record.userPhone != null && record.userPhone!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Row(
                            children: [
                              const Icon(Icons.phone, size: 16, color: Colors.grey),
                              const SizedBox(width: 8),
                              Text(record.userPhone!, style: const TextStyle(fontSize: 13)),
                            ],
                          ),
                        ),
                      if (record.userEmail != null && record.userEmail!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Row(
                            children: [
                              const Icon(Icons.email, size: 16, color: Colors.grey),
                              const SizedBox(width: 8),
                              Text(record.userEmail!, style: const TextStyle(fontSize: 13)),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                          const SizedBox(width: 8),
                          Text('Borrow Date: ${_formatDate(record.borrowDate)}',
                            style: const TextStyle(fontSize: 13)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.event, size: 16, color: isOverdue ? Colors.red : Colors.orange),
                          const SizedBox(width: 8),
                          Text('Return by: ${_formatDate(record.dueDate)}',
                            style: TextStyle(fontSize: 13, color: isOverdue ? Colors.red : Colors.orange, fontWeight: FontWeight.w500)),
                        ],
                      ),
                      if (isReturned && record.returnDate != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Row(
                            children: [
                              const Icon(Icons.event_available, size: 16, color: Colors.green),
                              const SizedBox(width: 8),
                              Text('Delivered: ${_formatDate(record.returnDate!)}',
                                style: const TextStyle(fontSize: 13, color: Colors.green)),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                
                if (!isReturned && isOverdue)
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Late Fine:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                        Text('৳${record.calculatedFine.toStringAsFixed(0)}',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red)),
                      ],
                    ),
                  ),
                
                if (!isReturned && !isOverdue)
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.timer, size: 18, color: Colors.blue),
                        const SizedBox(width: 8),
                        Text(_getRemainingDays(record.dueDate),
                          style: const TextStyle(fontSize: 13, color: Colors.blue, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                
                if (record.fine != null && record.fine! > 0 && isReturned)
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text('Fine Paid: ৳${record.fine!.toStringAsFixed(0)}',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.orange)),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}