import 'package:flutter/material.dart';
import 'package:graduationproject/shared/l10n/app_localizations.dart';
import 'package:graduationproject/shared/state/recruitment_sync_store.dart';
import '../Tradesman_Messages/chat_tradesman.dart';

class JobApplicantsScreen extends StatefulWidget {
  final String? jobId;
  final String jobTitle;
  final String? initialDesc;
  final String? initialBudget;
  final List<String>? initialDays;
  const JobApplicantsScreen({
    super.key, 
    this.jobId, 
    required this.jobTitle, 
    this.initialDesc, 
    this.initialBudget, 
    this.initialDays
  });

  @override
  State<JobApplicantsScreen> createState() => _JobApplicantsScreenState();
}

class _JobApplicantsScreenState extends State<JobApplicantsScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _activeTabIndex = 0; // 0 for Applicants, 1 for Job Details
  bool _isEditing = false;

  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _budgetController;
  late List<String> _selectedDays;
  
  final List<String> _allDays = ["Saturday", "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday"];

  @override
  void initState() {
    super.initState();
    final store = RecruitmentSyncStore.instance;
    
    // Try to find the real job data if jobId is provided but initial data is missing
    RecruitmentJob? existingJob;
    if (widget.jobId != null && widget.jobId!.isNotEmpty) {
      try {
        existingJob = store.jobs.firstWhere((j) => j.id == widget.jobId);
      } catch (_) {
        existingJob = null;
      }
    }

    _titleController = TextEditingController(text: existingJob?.title ?? widget.jobTitle);
    _descController = TextEditingController(text: widget.initialDesc ?? "");
    _budgetController = TextEditingController(text: existingJob?.salaryRange ?? widget.initialBudget ?? "");
    _selectedDays = List.from(existingJob?.tags ?? widget.initialDays ?? []);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _titleController.dispose();
    _descController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
    });
    if (!_isEditing) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("تم حفظ التعديلات بنجاح")),
      );
    }
  }

  void _showDeleteDialog() {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isAr ? "حذف الوظيفة" : "Delete Job"),
        content: Text(isAr ? "هل أنت متأكد من رغبتك في حذف هذا المنشور نهائياً؟" : "Are you sure you want to permanently delete this post?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isAr ? "إلغاء" : "Cancel", style: const TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); 
              Navigator.pop(context); 
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("تم حذف المنشور")),
              );
            },
            child: Text(isAr ? "حذف" : "Delete", style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final store = RecruitmentSyncStore.instance;

    // Real applicants filtered by jobId
    final realApplicants = store.applications.where((app) => app.jobId == widget.jobId).toList();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black87, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        actions: [
          if (_activeTabIndex == 1) ...[
            if (_isEditing)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                    onPressed: _showDeleteDialog,
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: _isEditing ? Colors.green.shade50 : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: Icon(_isEditing ? Icons.check : Icons.edit_outlined, 
                      color: _isEditing ? Colors.green : Colors.black87, size: 20),
                  onPressed: _toggleEdit,
                ),
              ),
            ),
          ],
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _isEditing && _activeTabIndex == 1
                  ? TextField(
                      controller: _titleController,
                      style: const TextStyle(color: Color(0xFF6366F1), fontSize: 24, fontWeight: FontWeight.w900),
                      decoration: const InputDecoration(border: InputBorder.none, hintText: "Job Title"),
                    )
                  : Text(
                    _titleController.text.isEmpty ? (isAr ? "بدون عنوان" : "Untitled") : _titleController.text,
                    style: const TextStyle(
                      color: Color(0xFF6366F1),
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isAr ? 'عام • لمرة واحدة • ${realApplicants.length} متقدمين' : 'General • one-time • ${realApplicants.length} applicants',
                    style: const TextStyle(color: Colors.black38, fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 10),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  _buildTab(t.tr(en: "Applicants", ar: "المتقدمين"), 0),
                  const SizedBox(width: 32),
                  _buildTab(t.tr(en: "Job Details", ar: "تفاصيل العمل"), 1),
                ],
              ),
            ),
            const Divider(height: 1, thickness: 1, color: Color(0xFFF3F4F6)),
            
            const SizedBox(height: 30),

            _activeTabIndex == 0 ? _buildApplicantsView(isAr, t, realApplicants) : _buildJobDetailsView(isAr, t),
            
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildApplicantsView(bool isAr, AppLocalizations t, List<RecruitmentApplication> applicants) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 16,
            runSpacing: 16,
            children: [
              Text(
                isAr ? 'إجمالي المتقدمين: ${applicants.length}' : 'Total Applicants: ${applicants.length}',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF011931)),
              ),
              Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxWidth: 300),
                height: 45,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: isAr ? 'البحث في المتقدمين...' : 'Search applicants...',
                    hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                    prefixIcon: const Icon(Icons.search, size: 18, color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6), width: 1.5)),
            ),
            child: Row(
              children: [
                _buildHeaderCell(isAr ? 'المتقدم' : 'Applicant', flex: 2, align: isAr ? TextAlign.right : TextAlign.left),
                _buildHeaderCell(isAr ? 'التواصل' : 'Contact'),
                _buildHeaderCell(isAr ? 'الحالة' : 'Status'),
                _buildHeaderCell(isAr ? 'الإجراءات' : 'Actions', align: isAr ? TextAlign.left : TextAlign.right),
              ],
            ),
          ),
        ),
        if (applicants.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 60),
              child: Column(
                children: [
                  Icon(Icons.people_outline, size: 40, color: Colors.grey.shade200),
                  const SizedBox(height: 16),
                  Text(
                    isAr ? 'لا يوجد متقدمين حتى الآن' : 'No applicants yet',
                    style: const TextStyle(
                      color: Colors.black26,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: applicants.length,
            itemBuilder: (context, index) {
              final app = applicants[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: Colors.grey.shade100,
                            child: const Icon(Icons.person, size: 20, color: Colors.grey),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              app.userName,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: IconButton(
                        icon: const Icon(Icons.chat_outlined, color: Color(0xFF49769F), size: 20),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatTradesman(
                                name: app.userName,
                                image: "https://static.vecteezy.com/system/resources/thumbnails/009/292/244/small/default-avatar-icon-of-social-media-user-vector.jpg", 
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          app.status,
                          style: const TextStyle(color: Colors.blue, fontSize: 10, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.phone_outlined, color: Colors.green, size: 20),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("${t.tr(en: 'Phone Number:', ar: 'رقم الهاتف:')} ${app.phone ?? 'N/A'}")),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildJobDetailsView(bool isAr, AppLocalizations t) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailSection(
            icon: Icons.description_outlined,
            title: t.tr(en: "Description", ar: "الوصف"),
            content: _descController.text,
            controller: _descController,
            isMultiLine: true,
          ),
          const SizedBox(height: 24),
          _buildDetailSection(
            icon: Icons.payments_outlined,
            title: t.tr(en: "Rate / Budget", ar: "السعر / الميزانية"),
            content: _budgetController.text,
            controller: _budgetController,
          ),
          const SizedBox(height: 24),
          _buildDetailSection(
            icon: Icons.calendar_today_outlined,
            title: t.tr(en: "Posted Date", ar: "تاريخ النشر"),
            content: DateTime.now().toString().split(' ')[0],
            isEditable: false,
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: const Color(0xFFF0F3FF), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.access_time_outlined, color: Color(0xFF49769F), size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t.tr(en: "Work Days", ar: "أيام العمل"), style: const TextStyle(color: Colors.black38, fontSize: 13, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    _isEditing
                    ? Wrap(
                        spacing: 8,
                        children: _allDays.map((day) {
                          bool selected = _selectedDays.contains(day);
                          return FilterChip(
                            label: Text(day, style: const TextStyle(fontSize: 12)),
                            selected: selected,
                            onSelected: (val) {
                              setState(() {
                                if (val) {
                                  _selectedDays.add(day);
                                } else {
                                  _selectedDays.remove(day);
                                }
                              });
                            },
                            selectedColor: const Color(0xFF6366F1).withOpacity(0.2),
                            checkmarkColor: const Color(0xFF6366F1),
                          );
                        }).toList(),
                      )
                    : Text(_selectedDays.isEmpty ? (isAr ? "غير محدد" : "None selected") : _selectedDays.join(", "), 
                        style: const TextStyle(color: Color(0xFF011931), fontSize: 15, fontWeight: FontWeight.w600, height: 1.4)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection({
    required IconData icon, 
    required String title, 
    required String content, 
    TextEditingController? controller,
    bool isEditable = true,
    bool isMultiLine = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: const Color(0xFFF0F3FF), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: const Color(0xFF49769F), size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.black38, fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              _isEditing && isEditable && controller != null
              ? TextField(
                  controller: controller,
                  maxLines: isMultiLine ? null : 1,
                  style: const TextStyle(color: Color(0xFF011931), fontSize: 15, fontWeight: FontWeight.w600),
                  decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.symmetric(vertical: 8)),
                )
              : Text(content, style: const TextStyle(color: Color(0xFF011931), fontSize: 15, fontWeight: FontWeight.w600, height: 1.4)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTab(String label, int index) {
    bool isActive = _activeTabIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _activeTabIndex = index;
          if (_activeTabIndex == 0) _isEditing = false;
        });
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isActive ? const Color(0xFF6366F1) : Colors.black45,
              fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 12),
          if (isActive)
            Container(
              height: 3,
              width: 45,
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1),
                borderRadius: BorderRadius.circular(10),
              ),
            )
          else
            const SizedBox(height: 3),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String label, {int flex = 1, TextAlign align = TextAlign.center}) {
    return Expanded(
      flex: flex,
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.black26,
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
        textAlign: align,
      ),
    );
  }
}
