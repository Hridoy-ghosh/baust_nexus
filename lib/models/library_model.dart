import 'package:intl/intl.dart';

class LibraryBook {
  final String id;
  final String title;
  final String author;
  final String department;
  final String year;
  final int totalCopies;
  int availableCopies;
  final String isbn;

  LibraryBook({
    required this.id,
    required this.title,
    required this.author,
    required this.department,
    required this.year,
    required this.totalCopies,
    required this.availableCopies,
    required this.isbn,
  });
}

class BorrowRecord {
  final String id;
  final String bookId;
  final String bookTitle;
  final String userId;
  final String userName;
  final String userDept;
  final String userRole;
  final DateTime borrowDate;
  final DateTime dueDate;
  final DateTime? returnDate;
  final String token;
  final String status;
  final double? fine;
  final String? userPhone;
  final String? userEmail;
  final String? userSession;
  final String? userSemester;

  BorrowRecord({
    required this.id,
    required this.bookId,
    required this.bookTitle,
    required this.userId,
    required this.userName,
    required this.userDept,
    required this.userRole,
    required this.borrowDate,
    required this.dueDate,
    this.returnDate,
    required this.token,
    required this.status,
    this.fine,
    this.userPhone,
    this.userEmail,
    this.userSession,
    this.userSemester,
  });

  int get daysOverdue {
    if (status == 'returned') return 0;
    final now = DateTime.now();
    if (now.isBefore(dueDate)) return 0;
    return now.difference(dueDate).inDays;
  }

  double get calculatedFine {
    return (daysOverdue * 5.0);
  }

  bool get isOverdue => daysOverdue > 0;

  Duration get remainingDays {
    final now = DateTime.now();
    if (now.isAfter(dueDate)) {
      return Duration.zero;
    }
    return dueDate.difference(now);
  }

  String get formattedBorrowDate => DateFormat('dd/MM/yyyy').format(borrowDate);
  String get formattedDueDate => DateFormat('dd/MM/yyyy').format(dueDate);
  String? get formattedReturnDate => returnDate != null ? DateFormat('dd/MM/yyyy').format(returnDate!) : null;
}