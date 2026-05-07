import 'package:flutter/material.dart';
import '../../../app/router/app_router.dart';
import '../../../shared/l10n/app_localizations.dart';
import '../../../shared/state/recruitment_sync_store.dart';
import '../../../shared/utils/image_helper.dart';

class AnalysisScreen extends StatelessWidget {
  const AnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final store = RecruitmentSyncStore.instance;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar Icons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ListenableBuilder(
                    listenable: store,
                    builder: (context, _) {
                      final p = getAppImageProvider(store.profileImage);
                      return InkWell(
                        onTap: () => Navigator.of(context).pushNamed(AppRoutes.userEditProfile),
                        borderRadius: BorderRadius.circular(20),
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: Theme.of(context).cardColor,
                          backgroundImage: p,
                          child: p == null ? const Icon(Icons.person, size: 22) : null,
                        ),
                      );
                    },
                  ),
                  Row(
                    children: [
                      _buildTopIconButton(context, Icons.add),
                      const SizedBox(width: 12),
                      _buildTopIconButton(context, Icons.notifications_none, hasBadge: false),
                      const SizedBox(width: 12),
                      _buildTopIconButton(context, Icons.settings_outlined),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // Total Jobs Applied Card
              _buildStatCard(
                context,
                title: t.tr(en: "Total Jobs Applied", ar: "إجمالي الوظائف المقدمة"),
                value: "45",
                icon: Icons.description_outlined,
              ),
              const SizedBox(height: 16),
              // Jobs Applied Status Card
              _buildChartCard(context, t),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopIconButton(BuildContext context, IconData icon, {bool hasBadge = false}) {
    return Stack(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF0D2D4D)
                : Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
            border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.12)),
          ),
          child: Icon(icon, color: Theme.of(context).colorScheme.onSurface, size: 22),
        ),
        if (hasBadge)
          Positioned(
            right: 12,
            top: 10,
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, {required String title, required String value, required IconData icon}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.transparent
            : Theme.of(context).colorScheme.surface,
        border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.12)),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                value,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 64, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Icon(
            icon,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.12),
            size: 80,
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard(BuildContext context, AppLocalizations t) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.transparent
            : Theme.of(context).colorScheme.surface,
        border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.12)),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Column(
        children: [
          Text(
            t.tr(en: "Jobs Applied Status", ar: "حالة الوظائف المقدمة"),
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 30),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 180,
                width: 180,
                child: CircularProgressIndicator(
                  value: 0.6,
                  strokeWidth: 28,
                  backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
                ),
              ),
              SizedBox(
                height: 180,
                width: 180,
                child: CircularProgressIndicator(
                  value: 0.4,
                  strokeWidth: 28,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blueGrey.withValues(alpha: 0.3)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          _buildLegendItem(context, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7), text: "100%", subtext: t.tr(en: "Unsuitable", ar: "غير مناسب")),
        ],
      ),
    );
  }

  Widget _buildLegendItem(BuildContext context, {required Color color, required String text, required String subtext}) {
    return Padding(
      padding: const EdgeInsets.only(left: 40),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                text,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                subtext,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54), fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
