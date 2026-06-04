import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import '../services/auth_service.dart';
import '../utils/web_download_helper.dart'
    if (dart.library.html) '../utils/web_download_helper_web.dart';

class AcademicResourcesScreen extends StatefulWidget {
  const AcademicResourcesScreen({super.key});

  @override
  State<AcademicResourcesScreen> createState() => _AcademicResourcesScreenState();
}

class _AcademicResourcesScreenState extends State<AcademicResourcesScreen>
    with SingleTickerProviderStateMixin {
  
  late TabController _tabController;
  
  // Filters
  String _selectedDept = 'All';
  String _selectedLevel = 'All';
  String _selectedTerm = 'All';
  String _selectedType = 'All';
  
  // Upload Controllers
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _courseController = TextEditingController();
  
  String _uploadType = 'Slide';
  String _uploadDept = 'CSE';
  String _uploadLevel = 'Level 3';
  String _uploadTerm = 'Term I';
  String _uploadSection = 'A';
  
  // Separate file for different upload types
  PlatformFile? _selectedResourceFile;
  PlatformFile? _selectedRoutineFile;
  PlatformFile? _selectedCTFile;
  
  bool _isUploadingResource = false;
  bool _isUploadingRoutine = false;
  bool _isUploadingCT = false;
  
  // Data
  List<Map<String, dynamic>> _resources = [];
  List<Map<String, dynamic>> _routines = [];
  List<Map<String, dynamic>> _ctQuestions = [];
  bool _isLoading = true;
  
  // Search
  final TextEditingController _searchController = TextEditingController();
  
  // Lists
  final List<String> _departments = ['All', 'CSE', 'EEE', 'ME', 'CE', 'BBA', 'ENG'];
  final List<String> _levels = ['All', 'Level 1', 'Level 2', 'Level 3', 'Level 4'];
  final List<String> _terms = ['All', 'Term I', 'Term II'];
  final List<String> _types = ['All', 'Book', 'PDF', 'Slide', 'Class Note', 'Lab Manual', 'Assignment', 'Previous Year Question', 'PPT', 'Excel'];
  final List<String> _uploadTypes = ['Book', 'PDF', 'Slide', 'Class Note', 'Lab Manual', 'Assignment', 'Previous Year Question', 'PPT', 'Excel'];
  final List<String> _sections = ['A', 'B', 'C', 'D'];
  
  final SupabaseClient _supabase = Supabase.instance.client;
  
  bool get _canUpload {
    final user = context.read<AuthService>().currentUser;
    final role = user?.role?.toLowerCase() ?? '';
    return role == 'admin' || role == 'teacher';
  }
  
  bool get _canDeleteEdit {
    final user = context.read<AuthService>().currentUser;
    final role = user?.role?.toLowerCase() ?? '';
    return role == 'admin' || role == 'teacher';
  }
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _canUpload ? 4 : 3, vsync: this);
    _loadAllData();
    _requestPermission();
  }
  
  Future<void> _requestPermission() async {
    if (!kIsWeb && Platform.isAndroid) {
      await Permission.storage.request();
    }
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _courseController.dispose();
    _searchController.dispose();
    super.dispose();
  }
  
  Future<void> _loadAllData() async {
    await Future.wait([
      _loadResources(),
      _loadRoutines(),
      _loadCTQuestions(),
    ]);
  }
  
  Future<void> _loadResources() async {
    if (!mounted) return;
    try {
      final response = await _supabase
          .from('resources')
          .select()
          .order('created_at', ascending: false);
      
      if (mounted) {
        setState(() {
          _resources = response.isNotEmpty ? List<Map<String, dynamic>>.from(response) : [];
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading resources: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }
  
  Future<void> _loadRoutines() async {
    if (!mounted) return;
    try {
      final response = await _supabase
          .from('routines')
          .select()
          .order('created_at', ascending: false);
      
      if (mounted) {
        setState(() {
          _routines = response.isNotEmpty ? List<Map<String, dynamic>>.from(response) : [];
        });
      }
    } catch (e) {
      print('Error loading routines: $e');
      if (mounted) setState(() => _routines = []);
    }
  }
  
  Future<void> _loadCTQuestions() async {
    if (!mounted) return;
    try {
      final response = await _supabase
          .from('ct_questions')
          .select()
          .order('created_at', ascending: false);
      
      if (mounted) {
        setState(() {
          _ctQuestions = response.isNotEmpty ? List<Map<String, dynamic>>.from(response) : [];
        });
      }
    } catch (e) {
      print('Error loading CT questions: $e');
      if (mounted) setState(() => _ctQuestions = []);
    }
  }
  
  // ==================== DELETE FUNCTIONS ====================
  Future<void> _deleteResource(Map<String, dynamic> resource) async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Resource'),
        content: Text('Are you sure you want to delete "${resource['title']}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                final fileUrl = resource['file_url'] as String;
                final fileName = fileUrl.split('/').last;
                await _supabase.storage.from('resources').remove([fileName]);
                await _supabase.from('resources').delete().eq('id', resource['id']);
                await _loadResources();
                _showMessage('Deleted successfully', Colors.green);
              } catch (e) {
                _showMessage('Delete failed: $e', Colors.red);
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
  
  Future<void> _deleteRoutine(Map<String, dynamic> routine) async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Routine'),
        content: Text('Are you sure you want to delete "${routine['title']}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                final fileUrl = routine['file_url'] as String;
                final fileName = fileUrl.split('/').last;
                await _supabase.storage.from('routines').remove([fileName]);
                await _supabase.from('routines').delete().eq('id', routine['id']);
                await _loadRoutines();
                _showMessage('Routine deleted', Colors.green);
              } catch (e) {
                _showMessage('Delete failed: $e', Colors.red);
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
  
  Future<void> _deleteCTQuestion(Map<String, dynamic> ct) async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete CT Question'),
        content: Text('Are you sure you want to delete "${ct['title']}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                final fileUrl = ct['file_url'] as String;
                final fileName = fileUrl.split('/').last;
                await _supabase.storage.from('ct_questions').remove([fileName]);
                await _supabase.from('ct_questions').delete().eq('id', ct['id']);
                await _loadCTQuestions();
                _showMessage('CT Question deleted', Colors.green);
              } catch (e) {
                _showMessage('Delete failed: $e', Colors.red);
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
  
  // ==================== EDIT FUNCTIONS ====================
  Future<void> _editResource(Map<String, dynamic> resource) async {
    final titleController = TextEditingController(text: resource['title']);
    final courseController = TextEditingController(text: resource['course']);
    String newType = resource['type'];
    String newLevel = resource['level'];
    String newTerm = resource['term'];
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Resource'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: courseController,
                decoration: const InputDecoration(labelText: 'Course Code'),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: newType,
                items: _uploadTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (v) => newType = v!,
                decoration: const InputDecoration(labelText: 'Type'),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: newLevel,
                items: _levels.where((l) => l != 'All').map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
                onChanged: (v) => newLevel = v!,
                decoration: const InputDecoration(labelText: 'Level'),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: newTerm,
                items: _terms.where((t) => t != 'All').map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (v) => newTerm = v!,
                decoration: const InputDecoration(labelText: 'Term'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await _supabase.from('resources').update({
                  'title': titleController.text,
                  'course': courseController.text,
                  'type': newType,
                  'level': newLevel,
                  'term': newTerm,
                }).eq('id', resource['id']);
                await _loadResources();
                _showMessage('Updated successfully', Colors.green);
              } catch (e) {
                _showMessage('Update failed: $e', Colors.red);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
  
  // ==================== UPLOAD FUNCTIONS ====================
  Future<void> _pickResourceFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result != null && result.files.isNotEmpty && mounted) {
        setState(() => _selectedResourceFile = result.files.single);
        _showMessage('Selected: ${_selectedResourceFile!.name}', Colors.green);
      }
    } catch (e) {
      _showMessage('Error picking file: $e', Colors.red);
    }
  }
  
  Future<void> _pickRoutineFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result != null && result.files.isNotEmpty && mounted) {
        setState(() => _selectedRoutineFile = result.files.single);
        _showMessage('Selected: ${_selectedRoutineFile!.name}', Colors.green);
      }
    } catch (e) {
      _showMessage('Error picking file: $e', Colors.red);
    }
  }
  
  Future<void> _pickCTFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result != null && result.files.isNotEmpty && mounted) {
        setState(() => _selectedCTFile = result.files.single);
        _showMessage('Selected: ${_selectedCTFile!.name}', Colors.green);
      }
    } catch (e) {
      _showMessage('Error picking file: $e', Colors.red);
    }
  }
  
  Future<void> _uploadResource() async {
    if (_titleController.text.trim().isEmpty) {
      _showMessage('Please enter title', Colors.red);
      return;
    }
    if (_courseController.text.trim().isEmpty) {
      _showMessage('Please enter course code', Colors.red);
      return;
    }
    if (_selectedResourceFile == null) {
      _showMessage('Please select a file', Colors.red);
      return;
    }
    
    setState(() => _isUploadingResource = true);
    final user = context.read<AuthService>().currentUser;
    final userName = user?.name ?? 'Admin';
    
    try {
      final String fileExtension = _selectedResourceFile!.extension ?? 'pdf';
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}_${_titleController.text.trim().replaceAll(' ', '_')}.$fileExtension';
      final fileBytes = _selectedResourceFile!.bytes ?? await File(_selectedResourceFile!.path!).readAsBytes();
      
      await _supabase.storage.from('resources').uploadBinary(fileName, fileBytes);
      final String fileUrl = _supabase.storage.from('resources').getPublicUrl(fileName);
      
      await _supabase.from('resources').insert({
        'title': _titleController.text.trim(),
        'course': _courseController.text.trim(),
        'type': _uploadType,
        'department': _uploadDept,
        'level': _uploadLevel,
        'term': _uploadTerm,
        'file_name': _selectedResourceFile!.name,
        'file_url': fileUrl,
        'file_size': _formatSize(_selectedResourceFile!.size),
        'author': userName,
        'created_at': DateTime.now().toIso8601String(),
      });
      
      _showMessage('Resource uploaded!', Colors.green);
      _titleController.clear();
      _courseController.clear();
      setState(() => _selectedResourceFile = null);
      await _loadResources();
      
    } catch (e) {
      _showMessage('Upload failed: ${e.toString()}', Colors.red);
    } finally {
      if (mounted) setState(() => _isUploadingResource = false);
    }
  }
  
  Future<void> _uploadRoutine() async {
    if (_titleController.text.trim().isEmpty) {
      _showMessage('Please enter title', Colors.red);
      return;
    }
    if (_selectedRoutineFile == null) {
      _showMessage('Please select a file', Colors.red);
      return;
    }
    
    setState(() => _isUploadingRoutine = true);
    final user = context.read<AuthService>().currentUser;
    
    try {
      final String fileExtension = _selectedRoutineFile!.extension ?? 'pdf';
      final String fileName = 'routine_${DateTime.now().millisecondsSinceEpoch}_${_titleController.text.trim().replaceAll(' ', '_')}.$fileExtension';
      final fileBytes = _selectedRoutineFile!.bytes ?? await File(_selectedRoutineFile!.path!).readAsBytes();
      
      // ✅ Check if bucket exists, if not create
      try {
        await _supabase.storage.from('routines').uploadBinary(fileName, fileBytes);
      } catch (e) {
        // Bucket might not exist, try to create it
        print('Upload to routines failed: $e');
        _showMessage('Storage bucket "routines" not found. Please create it in Supabase Dashboard.', Colors.red);
        return;
      }
      
      final String fileUrl = _supabase.storage.from('routines').getPublicUrl(fileName);
      
      await _supabase.from('routines').insert({
        'title': _titleController.text.trim(),
        'level': _uploadLevel,
        'term': _uploadTerm,
        'section': _uploadSection,
        'file_url': fileUrl,
        'file_name': _selectedRoutineFile!.name,
        'file_size': _formatSize(_selectedRoutineFile!.size),
        'uploaded_by': user?.name ?? 'Admin',
        'created_at': DateTime.now().toIso8601String(),
      });
      
      _showMessage('Routine uploaded!', Colors.green);
      _titleController.clear();
      setState(() => _selectedRoutineFile = null);
      await _loadRoutines();
      
    } catch (e) {
      _showMessage('Upload failed: ${e.toString()}', Colors.red);
      print('Upload error: $e');
    } finally {
      if (mounted) setState(() => _isUploadingRoutine = false);
    }
  }
  
  Future<void> _uploadCTQuestion() async {
    if (_titleController.text.trim().isEmpty) {
      _showMessage('Please enter title', Colors.red);
      return;
    }
    if (_courseController.text.trim().isEmpty) {
      _showMessage('Please enter course code', Colors.red);
      return;
    }
    if (_selectedCTFile == null) {
      _showMessage('Please select a file', Colors.red);
      return;
    }
    
    setState(() => _isUploadingCT = true);
    final user = context.read<AuthService>().currentUser;
    
    try {
      final String fileExtension = _selectedCTFile!.extension ?? 'pdf';
      final String fileName = 'ct_${DateTime.now().millisecondsSinceEpoch}_${_titleController.text.trim().replaceAll(' ', '_')}.$fileExtension';
      final fileBytes = _selectedCTFile!.bytes ?? await File(_selectedCTFile!.path!).readAsBytes();
      
      // ✅ Check if bucket exists
      try {
        await _supabase.storage.from('ct_questions').uploadBinary(fileName, fileBytes);
      } catch (e) {
        print('Upload to ct_questions failed: $e');
        _showMessage('Storage bucket "ct_questions" not found. Please create it in Supabase Dashboard.', Colors.red);
        return;
      }
      
      final String fileUrl = _supabase.storage.from('ct_questions').getPublicUrl(fileName);
      
      await _supabase.from('ct_questions').insert({
        'title': _titleController.text.trim(),
        'course': _courseController.text.trim(),
        'level': _uploadLevel,
        'term': _uploadTerm,
        'section': _uploadSection,
        'file_url': fileUrl,
        'file_name': _selectedCTFile!.name,
        'file_size': _formatSize(_selectedCTFile!.size),
        'uploaded_by': user?.name ?? 'Admin',
        'created_at': DateTime.now().toIso8601String(),
      });
      
      _showMessage('CT Question uploaded!', Colors.green);
      _titleController.clear();
      _courseController.clear();
      setState(() => _selectedCTFile = null);
      await _loadCTQuestions();
      
    } catch (e) {
      _showMessage('Upload failed: ${e.toString()}', Colors.red);
      print('Upload error: $e');
    } finally {
      if (mounted) setState(() => _isUploadingCT = false);
    }
  }
  
  // ==================== DOWNLOAD FUNCTION ====================
  Future<void> _downloadFile(String fileUrl, String fileName) async {
  if (fileUrl.isEmpty) {
    _showMessage('No file URL available', Colors.red);
    return;
  }
  
  try {
    _showMessage('Downloading...', Colors.blue);
    
    // URL থেকে সঠিক ফাইলের নাম বের করা
    Uri uri = Uri.parse(fileUrl);
    String path = uri.path;
    String actualFileName = path.split('/').last;
    
    // যদি actualFileName খালি হয়, তাহলে দেওয়া fileName ব্যবহার করব
    if (actualFileName.isEmpty) {
      actualFileName = fileName;
    }
    
    // URL এ encoded characters থাকলে ডিকোড করা
    actualFileName = Uri.decodeComponent(actualFileName);
    
    print('Actual file name: $actualFileName'); // Debug জন্য
    
    // ============ WEB PLATFORM ============
    if (kIsWeb) {
      final response = await http.get(Uri.parse(fileUrl));
      if (response.statusCode == 200) {
        // Content-Type অনুযায়ী blob তৈরি করা
        String? contentType = response.headers['content-type'];
        downloadFileWeb(response.bodyBytes, actualFileName, contentType);
        _showMessage('Download started!', Colors.green);
      } else {
        _showMessage('Download failed: ${response.statusCode}', Colors.red);
      }
      return;
    }
    
    // ============ ANDROID PLATFORM ============
    // Saving to getApplicationDocumentsDirectory() does not require runtime storage permissions.
    
    final dir = await getApplicationDocumentsDirectory();
    final String savePath = '${dir.path}/$actualFileName';
    
    final response = await http.get(Uri.parse(fileUrl));
    
    if (response.statusCode == 200) {
      final file = File(savePath);
      await file.writeAsBytes(response.bodyBytes);
      _showMessage('Download complete!', Colors.green);
      try {
        await OpenFile.open(savePath);
      } catch (e) {
        _showMessage('File saved: $actualFileName', Colors.green);
      }
    } else {
      _showMessage('Download failed: ${response.statusCode}', Colors.red);
    }
  } catch (e) {
    print('Download error: $e');
    _showMessage('Error: ${e.toString()}', Colors.red);
  }
}
  
  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1048576) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / 1048576).toStringAsFixed(1)} MB';
  }
  
  void _showMessage(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  String _getIcon(String type) {
    switch (type) {
      case 'Book': return '📘';
      case 'PDF': return '📕';
      case 'Slide': return '📊';
      case 'Class Note': return '📝';
      case 'Lab Manual': return '📗';
      case 'Assignment': return '📋';
      case 'Previous Year Question': return '📄';
      case 'PPT': return '📙';
      case 'Excel': return '📈';
      default: return '📁';
    }
  }
  
  List<Map<String, dynamic>> get _filteredResources {
    return _resources.where((r) {
      final deptMatch = _selectedDept == 'All' || r['department'] == _selectedDept;
      final levelMatch = _selectedLevel == 'All' || r['level'] == _selectedLevel;
      final termMatch = _selectedTerm == 'All' || r['term'] == _selectedTerm;
      final typeMatch = _selectedType == 'All' || r['type'] == _selectedType;
      final searchMatch = _searchController.text.isEmpty || 
          r['title'].toString().toLowerCase().contains(_searchController.text.toLowerCase()) ||
          r['course'].toString().toLowerCase().contains(_searchController.text.toLowerCase());
      return deptMatch && levelMatch && termMatch && typeMatch && searchMatch;
    }).toList();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: Text('Academic Resources', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 18)),
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          isScrollable: true,
          tabs: [
            const Tab(text: '📚 RESOURCES'),
            const Tab(text: '📅 ROUTINE'),
            const Tab(text: '📝 CT'),
            if (_canUpload) const Tab(text: '📤 UPLOAD'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAllData,
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildResourcesTab(),
          _buildRoutineTab(),
          _buildCTTab(),
          if (_canUpload) _buildUploadTab(),
        ],
      ),
    );
  }
  
  // ==================== RESOURCES TAB ====================
  Widget _buildResourcesTab() {
    final filtered = _filteredResources;
    
    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Search resources...',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(icon: const Icon(Icons.clear, size: 18), onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        })
                      : null,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('Dept', _selectedDept, _departments, (v) => setState(() => _selectedDept = v)),
                    const SizedBox(width: 8),
                    _buildFilterChip('Level', _selectedLevel, _levels, (v) => setState(() => _selectedLevel = v)),
                    const SizedBox(width: 8),
                    _buildFilterChip('Term', _selectedTerm, _terms, (v) => setState(() => _selectedTerm = v)),
                    const SizedBox(width: 8),
                    _buildFilterChip('Type', _selectedType, _types, (v) => setState(() => _selectedType = v)),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : filtered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.folder_open, size: 64, color: Colors.grey.shade400),
                          const SizedBox(height: 16),
                          Text('No resources found', style: GoogleFonts.poppins(color: Colors.grey.shade600)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: filtered.length,
                      itemBuilder: (ctx, i) {
                        final r = filtered[i];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 2,
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            leading: Container(
                              width: 45,
                              height: 45,
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(child: Text(_getIcon(r['type']), style: const TextStyle(fontSize: 22))),
                            ),
                            title: Text(
                              r['title'] ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13),
                            ),
                            subtitle: Text(
                              '${r['course'] ?? ''} • ${r['level'] ?? ''} ${r['term'] ?? ''} • ${r['type'] ?? ''}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(fontSize: 10),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.download, color: Colors.blue, size: 20),
                                  onPressed: () => _downloadFile(r['file_url'] ?? '', r['file_name'] ?? r['title'] ?? 'file'),
                                ),
                                if (_canDeleteEdit) ...[
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.orange, size: 20),
                                    onPressed: () => _editResource(r),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                    onPressed: () => _deleteResource(r),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }
  
  Widget _buildFilterChip(String label, String current, List<String> options, Function(String) onSelected) {
    return FilterChip(
      label: Text(current, style: GoogleFonts.poppins(fontSize: 11)),
      selected: false,
      onSelected: (_) => _showFilterDialog(label, current, options, onSelected),
      backgroundColor: Colors.grey.shade100,
    );
  }
  
  void _showFilterDialog(String label, String current, List<String> options, Function(String) onSelected) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Select $label', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...options.map((opt) => ListTile(
              dense: true,
              title: Text(opt),
              trailing: current == opt ? const Icon(Icons.check, color: Colors.blue) : null,
              onTap: () {
                onSelected(opt);
                Navigator.pop(ctx);
              },
            )),
          ],
        ),
      ),
    );
  }
  
  // ==================== ROUTINE TAB (Student দেখতে পাবে, ডাউনলোড করতে পারবে) ====================
  Widget _buildRoutineTab() {
    if (_routines.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(Icons.schedule, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text('No routines available', style: GoogleFonts.poppins(color: Colors.grey.shade600)),
          ],
        ),
      );
    }
    
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(12),
      itemCount: _routines.length,
      itemBuilder: (context, index) {
        final routine = _routines[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 2,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(child: Icon(Icons.schedule, color: Colors.green, size: 28)),
            ),
            title: Text(
              routine['title'] ?? 'Class Routine',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            subtitle: Text(
              '${routine['level'] ?? ''} ${routine['term'] ?? ''} • Section ${routine['section'] ?? 'A'}',
              style: GoogleFonts.poppins(fontSize: 12),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ✅ সবাই download করতে পারবে
                IconButton(
                  icon: const Icon(Icons.download, color: Colors.green),
                  onPressed: () => _downloadFile(routine['file_url'] ?? '', routine['title'] ?? 'routine'),
                  tooltip: 'Download',
                ),
                // ✅ শুধু Admin/Teacher delete করতে পারবে
                if (_canDeleteEdit)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteRoutine(routine),
                    tooltip: 'Delete',
                  ),
              ],
            ),
            onTap: () => _downloadFile(routine['file_url'] ?? '', routine['title'] ?? 'routine'),
          ),
        );
      },
    );
  }
  
  // ==================== CT TAB (Student দেখতে পাবে, ডাউনলোড করতে পারবে) ====================
  Widget _buildCTTab() {
    if (_ctQuestions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(Icons.quiz, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text('No CT questions available', style: GoogleFonts.poppins(color: Colors.grey.shade600)),
          ],
        ),
      );
    }
    
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(12),
      itemCount: _ctQuestions.length,
      itemBuilder: (context, index) {
        final ct = _ctQuestions[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 2,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(child: Icon(Icons.quiz, color: Colors.orange, size: 28)),
            ),
            title: Text(
              ct['title'] ?? 'CT Question',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            subtitle: Text(
              '${ct['course'] ?? ''} • ${ct['level'] ?? ''} ${ct['term'] ?? ''} • Section ${ct['section'] ?? 'A'}',
              style: GoogleFonts.poppins(fontSize: 12),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ✅ সবাই download করতে পারবে
                IconButton(
                  icon: const Icon(Icons.download, color: Colors.orange),
                  onPressed: () => _downloadFile(ct['file_url'] ?? '', ct['title'] ?? 'ct_question'),
                  tooltip: 'Download',
                ),
                // ✅ শুধু Admin/Teacher delete করতে পারবে
                if (_canDeleteEdit)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteCTQuestion(ct),
                    tooltip: 'Delete',
                  ),
              ],
            ),
            onTap: () => _downloadFile(ct['file_url'] ?? '', ct['title'] ?? 'ct_question'),
          ),
        );
      },
    );
  }
  
  // ==================== UPLOAD TAB ====================
  Widget _buildUploadTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          _buildUploadCard(
            title: '📄 Upload Resource',
            icon: Icons.upload_file,
            color: Colors.blue,
            isUploading: _isUploadingResource,
            selectedFile: _selectedResourceFile,
            onPickFile: _pickResourceFile,
            onUpload: _uploadResource,
            showTitleField: true,
            showCourseField: true,
            showTypeField: true,
            showDeptLevelTerm: true,
            showSectionField: false,
          ),
          const SizedBox(height: 16),
          
          _buildUploadCard(
            title: '📅 Upload Routine',
            icon: Icons.schedule,
            color: Colors.green,
            isUploading: _isUploadingRoutine,
            selectedFile: _selectedRoutineFile,
            onPickFile: _pickRoutineFile,
            onUpload: _uploadRoutine,
            showTitleField: true,
            showCourseField: false,
            showTypeField: false,
            showDeptLevelTerm: true,
            showSectionField: true,
          ),
          const SizedBox(height: 16),
          
          _buildUploadCard(
            title: '📝 Upload CT Question',
            icon: Icons.quiz,
            color: Colors.orange,
            isUploading: _isUploadingCT,
            selectedFile: _selectedCTFile,
            onPickFile: _pickCTFile,
            onUpload: _uploadCTQuestion,
            showTitleField: true,
            showCourseField: true,
            showTypeField: false,
            showDeptLevelTerm: true,
            showSectionField: true,
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
  
  Widget _buildUploadCard({
    required String title,
    required IconData icon,
    required Color color,
    required bool isUploading,
    required PlatformFile? selectedFile,
    required VoidCallback onPickFile,
    required VoidCallback onUpload,
    required bool showTitleField,
    required bool showCourseField,
    required bool showTypeField,
    required bool showDeptLevelTerm,
    required bool showSectionField,
  }) {
    final List<String> departments = ['CSE', 'EEE', 'ME', 'CE', 'BBA', 'ENG'];
    final List<String> levels = ['Level 1', 'Level 2', 'Level 3', 'Level 4'];
    final List<String> terms = ['Term I', 'Term II'];
    final List<String> uploadTypes = ['Book', 'PDF', 'Slide', 'Class Note', 'Lab Manual', 'Assignment', 'Previous Year Question', 'PPT', 'Excel'];
    final List<String> sections = ['A', 'B', 'C', 'D'];
    
    final localTitleController = TextEditingController();
    final localCourseController = TextEditingController();
    
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 4,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: color),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            if (showTitleField) ...[
              TextField(
                controller: localTitleController,
                decoration: const InputDecoration(
                  labelText: 'Title *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            if (showCourseField) ...[
              TextField(
                controller: localCourseController,
                decoration: const InputDecoration(
                  labelText: 'Course Code *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.code),
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            if (showTypeField) ...[
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButtonFormField<String>(
                    value: _uploadType,
                    items: uploadTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                    onChanged: (v) => setState(() => _uploadType = v!),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            if (showDeptLevelTerm) ...[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Department', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 4),
                  DropdownButtonFormField<String>(
                    value: _uploadDept,
                    items: departments.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                    onChanged: (v) => setState(() => _uploadDept = v!),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text('Level', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 4),
                  DropdownButtonFormField<String>(
                    value: _uploadLevel,
                    items: levels.map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
                    onChanged: (v) => setState(() => _uploadLevel = v!),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text('Term', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 4),
                  DropdownButtonFormField<String>(
                    value: _uploadTerm,
                    items: terms.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                    onChanged: (v) => setState(() => _uploadTerm = v!),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                  ),
                  if (showSectionField) ...[
                    const SizedBox(height: 12),
                    const Text('Section', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 4),
                    DropdownButtonFormField<String>(
                      value: _uploadSection,
                      items: sections.map((s) => DropdownMenuItem(value: s, child: Text('Section $s'))).toList(),
                      onChanged: (v) => setState(() => _uploadSection = v!),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 20),
            ],
            
            OutlinedButton.icon(
              onPressed: onPickFile,
              icon: const Icon(Icons.attach_file),
              label: Text(
                selectedFile?.name ?? 'Choose File',
                overflow: TextOverflow.ellipsis,
              ),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            
            if (selectedFile != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green.shade700, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        selectedFile.name,
                        style: TextStyle(fontSize: 12, color: Colors.green.shade700),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(_formatSize(selectedFile.size), style: TextStyle(fontSize: 11, color: Colors.green.shade700)),
                  ],
                ),
              ),
            ],
            
            if (isUploading) ...[
              const SizedBox(height: 16),
              const LinearProgressIndicator(),
              const SizedBox(height: 8),
              Center(child: Text('Uploading... Please wait', style: TextStyle(fontSize: 12, color: Colors.grey.shade600))),
            ],
            
            const SizedBox(height: 20),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isUploading ? null : () {
                  if (showTitleField) {
                    _titleController.text = localTitleController.text;
                  }
                  if (showCourseField) {
                    _courseController.text = localCourseController.text;
                  }
                  onUpload();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('UPLOAD', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}