import 'package:intl/intl.dart';
import '../models/library_model.dart';

class LibraryService {
  static List<LibraryBook> _books = [];
  static List<BorrowRecord> _borrowHistory = [];

  static void initBooks() {
    if (_books.isNotEmpty) return;
    
    _books = [
      LibraryBook(id: '1', title: 'Introduction to Algorithms', author: 'Thomas H. Cormen', department: 'CSE', year: '2022', totalCopies: 5, availableCopies: 3, isbn: '978-0-262-03384-8'),
      LibraryBook(id: '2', title: 'Digital Logic Design', author: 'M. Morris Mano', department: 'CSE', year: '2021', totalCopies: 4, availableCopies: 2, isbn: '978-0-13-335-633-0'),
      LibraryBook(id: '3', title: 'Circuit Analysis', author: 'William H. Hayt', department: 'EEE', year: '2020', totalCopies: 6, availableCopies: 4, isbn: '978-0-07-338057-9'),
      LibraryBook(id: '4', title: 'Engineering Mechanics', author: 'J. L. Meriam', department: 'ME', year: '2023', totalCopies: 5, availableCopies: 5, isbn: '978-0-470-61408-6'),
      LibraryBook(id: '5', title: 'Thermodynamics', author: 'Yunus A. Cengel', department: 'ME', year: '2022', totalCopies: 4, availableCopies: 1, isbn: '978-0-07-339817-4'),
      LibraryBook(id: '6', title: 'Structural Analysis', author: 'R. C. Hibbeler', department: 'CE', year: '2021', totalCopies: 3, availableCopies: 2, isbn: '978-0-13-605886-5'),
      LibraryBook(id: '7', title: 'Database Systems', author: 'Ramez Elmasri', department: 'CSE', year: '2023', totalCopies: 5, availableCopies: 3, isbn: '978-0-13-459411-4'),
      LibraryBook(id: '8', title: 'Power Electronics', author: 'Muhammad H. Rashid', department: 'EEE', year: '2020', totalCopies: 4, availableCopies: 2, isbn: '978-0-13-591174-6'),
      LibraryBook(id: '9', title: 'Data Structures', author: 'Mark Allen Weiss', department: 'CSE', year: '2023', totalCopies: 5, availableCopies: 4, isbn: '978-0-13-440829-3'),
      LibraryBook(id: '10', title: 'Computer Networks', author: 'Andrew S. Tanenbaum', department: 'CSE', year: '2022', totalCopies: 4, availableCopies: 2, isbn: '978-0-13-359535-4'),
      LibraryBook(id: '11', title: 'Operating Systems', author: 'Abraham Silberschatz', department: 'CSE', year: '2021', totalCopies: 5, availableCopies: 3, isbn: '978-0-470-12872-5'),
      LibraryBook(id: '12', title: 'Web Technologies', author: 'Noel Kalicharan', department: 'CSE', year: '2023', totalCopies: 4, availableCopies: 4, isbn: '978-0-13-312836-2'),
      LibraryBook(id: '13', title: 'Microprocessors', author: 'Barry Brey', department: 'EEE', year: '2022', totalCopies: 5, availableCopies: 3, isbn: '978-0-13-119649-0'),
      LibraryBook(id: '14', title: 'Signals and Systems', author: 'Alan V. Oppenheim', department: 'EEE', year: '2021', totalCopies: 4, availableCopies: 2, isbn: '978-0-13-814757-0'),
      LibraryBook(id: '15', title: 'Control Systems Engineering', author: 'Norman S. Nise', department: 'EEE', year: '2023', totalCopies: 4, availableCopies: 4, isbn: '978-1-118-17049-9'),
      LibraryBook(id: '16', title: 'Fluid Mechanics', author: 'Frank M. White', department: 'ME', year: '2022', totalCopies: 3, availableCopies: 1, isbn: '978-0-07-380516-8'),
      LibraryBook(id: '17', title: 'Machine Design', author: 'Robert L. Norton', department: 'ME', year: '2021', totalCopies: 4, availableCopies: 3, isbn: '978-0-07-297578-0'),
      LibraryBook(id: '18', title: 'Concrete Design', author: 'Arthur H. Nilson', department: 'CE', year: '2023', totalCopies: 3, availableCopies: 2, isbn: '978-0-13-294266-9'),
      LibraryBook(id: '19', title: 'Soil Mechanics', author: 'Donald P. Coduto', department: 'CE', year: '2022', totalCopies: 4, availableCopies: 2, isbn: '978-0-13-323331-1'),
      LibraryBook(id: '20', title: 'Surveying', author: 'Jack C. McCormac', department: 'CE', year: '2021', totalCopies: 3, availableCopies: 2, isbn: '978-0-470-46857-6'),
      LibraryBook(id: '21', title: 'Accounting Principles', author: 'Jerry J. Weygandt', department: 'BBA', year: '2023', totalCopies: 4, availableCopies: 3, isbn: '978-1-118-34599-9'),
      LibraryBook(id: '22', title: 'Business Management', author: 'Stephen P. Robbins', department: 'BBA', year: '2022', totalCopies: 5, availableCopies: 4, isbn: '978-0-13-610830-5'),
      LibraryBook(id: '23', title: 'Financial Analysis', author: 'Barbara Fridson', department: 'BBA', year: '2021', totalCopies: 4, availableCopies: 2, isbn: '978-0-13-367333-8'),
      LibraryBook(id: '24', title: 'English Literature', author: 'M.H. Abrams', department: 'ENG', year: '2023', totalCopies: 5, availableCopies: 3, isbn: '978-0-393-97286-2'),
      LibraryBook(id: '25', title: 'Physics Fundamentals', author: 'Halliday & Resnick', department: 'GEN', year: '2022', totalCopies: 5, availableCopies: 4, isbn: '978-1-118-05329-0'),
      LibraryBook(id: '26', title: 'Chemistry Essentials', author: 'Ralph H. Petrucci', department: 'GEN', year: '2021', totalCopies: 4, availableCopies: 2, isbn: '978-0-13-240765-4'),
      LibraryBook(id: '27', title: 'Mathematics Calculus', author: 'James Stewart', department: 'GEN', year: '2023', totalCopies: 5, availableCopies: 3, isbn: '978-1-285-74062-1'),
      LibraryBook(id: '28', title: 'Artificial Intelligence', author: 'Stuart Russell', department: 'CSE', year: '2023', totalCopies: 4, availableCopies: 4, isbn: '978-0-13-461099-3'),
      LibraryBook(id: '29', title: 'Machine Learning', author: 'Tom M. Mitchell', department: 'CSE', year: '2022', totalCopies: 3, availableCopies: 2, isbn: '978-0-07-042807-2'),
      LibraryBook(id: '30', title: 'Cyber Security', author: 'William Stallings', department: 'CSE', year: '2023', totalCopies: 4, availableCopies: 3, isbn: '978-0-13-479753-6'),
    ];
  }

  static List<LibraryBook> getAvailableBooks() => _books;
  static List<BorrowRecord> getAllRecords() => _borrowHistory;
  static int getTotalBooks() => _books.fold(0, (sum, b) => sum + b.totalCopies);
  static int getAvailableBooksCount() => _books.fold(0, (sum, b) => sum + b.availableCopies);
  static List<String> getUniqueUsers() => _borrowHistory.map((r) => r.userId).toSet().toList();

  static List<BorrowRecord> getActiveBooks() {
    return _borrowHistory.where((record) => record.status == 'borrowed').toList();
  }

  static List<BorrowRecord> getOverdueBooks() {
    final now = DateTime.now();
    return _borrowHistory.where((record) =>
        record.status == 'borrowed' && record.dueDate.isBefore(now)).toList();
  }

  static List<BorrowRecord> getReturnedBooks() {
    return _borrowHistory.where((record) => record.status == 'returned').toList();
  }

  static List<BorrowRecord> getBorrowedRecordsByUser(String userId) {
    if (userId.isEmpty) return [];
    return _borrowHistory.where((record) =>
        record.userId == userId && record.status == 'borrowed').toList();
  }

  static List<BorrowRecord> getUserAllRecords(String userId) {
    if (userId.isEmpty) return [];
    return _borrowHistory.where((record) => record.userId == userId).toList();
  }

  static List<BorrowRecord> getRecentRecords(int limit) {
    final list = List<BorrowRecord>.from(_borrowHistory);
    list.sort((a, b) => b.borrowDate.compareTo(a.borrowDate));
    return list.take(limit).toList();
  }

  static void addBook(LibraryBook book) {
    _books.add(book);
  }

  static void deleteBook(String bookId) {
    _books.removeWhere((b) => b.id == bookId);
  }

  static Map<String, dynamic> borrowBook({
    required String bookId,
    required String userId,
    required String userName,
    required String userDept,
    required String userRole,
    String? userPhone,
    String? userEmail,
    String? userSession,
    String? userSemester,
    DateTime? dueDate,
  }) {
    final bookIndex = _books.indexWhere((b) => b.id == bookId);
    if (bookIndex == -1) {
      return {'success': false, 'message': 'Book not found'};
    }

    final book = _books[bookIndex];
    if (book.availableCopies <= 0) {
      return {'success': false, 'message': 'No copies available'};
    }

    final existing = _borrowHistory.firstWhere(
      (r) => r.bookId == bookId && r.userId == userId && r.status == 'borrowed',
      orElse: () => BorrowRecord(
        id: '', bookId: '', bookTitle: '', userId: '', userName: '', userDept: '', userRole: '',
        borrowDate: DateTime.now(), dueDate: DateTime.now(), token: '', status: 'returned',
      ),
    );
    if (existing.status == 'borrowed') {
      return {'success': false, 'message': 'You already borrowed this book'};
    }

    final token = 'LIB${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
    final finalDueDate = dueDate ?? DateTime.now().add(const Duration(days: 30));

    final newRecord = BorrowRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      bookId: book.id,
      bookTitle: book.title,
      userId: userId,
      userName: userName,
      userDept: userDept,
      userRole: userRole,
      borrowDate: DateTime.now(),
      dueDate: finalDueDate,
      token: token,
      status: 'borrowed',
      userPhone: userPhone,
      userEmail: userEmail,
      userSession: userSession,
      userSemester: userSemester,
    );

    _borrowHistory.add(newRecord);
    _books[bookIndex].availableCopies--;

    final dateFormat = DateFormat('dd/MM/yyyy');
    return {'success': true, 'message': '✅ Book borrowed!\n📚 ${book.title}\n🎫 Token: $token\n📅 Borrow: ${dateFormat.format(DateTime.now())}\n📅 Return by: ${dateFormat.format(finalDueDate)}'};
  }

  static Map<String, dynamic> deliverBook(String recordId, String bookId) {
    final recordIndex = _borrowHistory.indexWhere((r) => r.id == recordId);
    if (recordIndex == -1) {
      return {'success': false, 'message': 'Record not found'};
    }

    final record = _borrowHistory[recordIndex];
    if (record.status == 'returned') {
      return {'success': false, 'message': 'Book already delivered'};
    }

    final fine = record.calculatedFine;
    final dateFormat = DateFormat('dd/MM/yyyy');

    final updatedRecord = BorrowRecord(
      id: record.id,
      bookId: record.bookId,
      bookTitle: record.bookTitle,
      userId: record.userId,
      userName: record.userName,
      userDept: record.userDept,
      userRole: record.userRole,
      borrowDate: record.borrowDate,
      dueDate: record.dueDate,
      returnDate: DateTime.now(),
      token: record.token,
      status: 'returned',
      fine: fine,
      userPhone: record.userPhone,
      userEmail: record.userEmail,
      userSession: record.userSession,
      userSemester: record.userSemester,
    );

    _borrowHistory[recordIndex] = updatedRecord;

    final bookIndex = _books.indexWhere((b) => b.id == bookId);
    if (bookIndex != -1) {
      _books[bookIndex].availableCopies++;
    }

    if (fine > 0) {
      return {'success': true, 'message': '✅ Book delivered!\n📅 Delivered: ${dateFormat.format(DateTime.now())}\n💰 Fine: ৳${fine.toStringAsFixed(0)}'};
    } else {
      return {'success': true, 'message': '✅ Book delivered successfully!\n📅 Delivered: ${dateFormat.format(DateTime.now())}'};
    }
  }

  static void deleteRecord(String recordId) {
    final recordIndex = _borrowHistory.indexWhere((r) => r.id == recordId);
    if (recordIndex != -1) {
      final record = _borrowHistory[recordIndex];
      if (record.status == 'borrowed') {
        final bookIndex = _books.indexWhere((b) => b.id == record.bookId);
        if (bookIndex != -1) {
          _books[bookIndex].availableCopies++;
        }
      }
      _borrowHistory.removeAt(recordIndex);
    }
  }

  static double getTotalFineCollected() {
    return _borrowHistory
        .where((r) => r.status == 'returned' && r.fine != null)
        .fold(0.0, (sum, r) => sum + (r.fine ?? 0));
  }

  static double getTodayFine() {
    final today = DateTime.now();
    return _borrowHistory
        .where((r) =>
            r.status == 'returned' &&
            r.returnDate != null &&
            r.returnDate!.year == today.year &&
            r.returnDate!.month == today.month &&
            r.returnDate!.day == today.day &&
            r.fine != null)
        .fold(0.0, (sum, r) => sum + (r.fine ?? 0));
  }
}