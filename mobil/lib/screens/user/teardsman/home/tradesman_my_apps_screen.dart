import 'package:flutter/material.dart';
import 'package:graduationproject/shared/l10n/app_localizations.dart';

class TradesmanMyAppsScreen extends StatelessWidget {
  const TradesmanMyAppsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(
          t.tr(en: 'My Applications', ar: 'قائمة الأعمال'),
          style: const TextStyle(
            color: Color(0xFF011931), 
            fontWeight: FontWeight.w900,
            fontSize: 22,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isAr ? 'شاهد حالة أعمالك المنشورة وإحصائيات المتقدمين' : 'View the status of your posted works and applicant stats',
              style: const TextStyle(color: Colors.black45, fontSize: 13, height: 1.5),
            ),
            const SizedBox(height: 30),
            
            // Stats Row (Optional but adds value to UI)
            Row(
              children: [
                _buildSimpleStat(isAr ? 'الأعمال النشطة' : 'Active Works', '0', Colors.blue),
                const SizedBox(width: 12),
                _buildSimpleStat(isAr ? 'المتقدمين' : 'Applicants', '0', Colors.orange),
              ],
            ),
            const SizedBox(height: 30),
            
            // Table Header with better styling
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF011931).withOpacity(0.03),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  _buildHeaderCell('ROLES', flex: 2, align: TextAlign.start),
                  _buildHeaderCell('RATE'),
                  _buildHeaderCell('STATUS'),
                  _buildHeaderCell('APPLICANTS'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            
            // Empty State Row / Container
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.withOpacity(0.1)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(Icons.assignment_late_outlined, size: 48, color: Colors.grey.withOpacity(0.3)),
                  const SizedBox(height: 16),
                  Text(
                    isAr ? 'لا توجد أعمال منشورة بعد.' : 'No posted works yet.',
                    style: const TextStyle(
                      color: Colors.black38,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isAr ? 'ابدأ بإضافة عملك الأول ليظهر هنا' : 'Start by adding your first work to see it here',
                    style: TextStyle(color: Colors.grey.withOpacity(0.6), fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleStat(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 11, color: Colors.black54, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCell(String label, {int flex = 1, TextAlign align = TextAlign.center}) {
    return Expanded(
      flex: flex,
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF011931),
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
        textAlign: align,
      ),
    );
  }
}
