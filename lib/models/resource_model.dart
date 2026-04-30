class ResourceModel {
  final String id;
  final String title;
  final String description;
  final String department;
  final String level;
  final String term;
  final String course;
  final String type; // book, slide, pdf, lab_manual, assignment, project_report, ppt, excel, txt
  final String fileUrl;
  final String fileName;
  final String fileExtension;
  final int fileSize;
  final DateTime uploadedAt;
  final String uploadedBy;
  final String uploaderName;
  final int downloads;

  ResourceModel({
    required this.id,
    required this.title,
    required this.description,
    required this.department,
    required this.level,
    required this.term,
    required this.course,
    required this.type,
    required this.fileUrl,
    required this.fileName,
    this.fileExtension = '',
    this.fileSize = 0,
    required this.uploadedAt,
    required this.uploadedBy,
    this.uploaderName = '',
    this.downloads = 0,
  });
}