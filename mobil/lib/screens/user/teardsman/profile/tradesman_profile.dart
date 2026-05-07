import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:graduationproject/shared/utils/image_helper.dart';
import 'package:graduationproject/shared/l10n/app_localizations.dart';
import 'package:graduationproject/screens/user/teardsman/setting/settings.dart';
import 'package:graduationproject/screens/user/home/recruitment_user_shell_screen.dart';
import 'package:graduationproject/app/router/app_router.dart';
import 'package:graduationproject/shared/state/recruitment_sync_store.dart';

class TradesmanProfile extends StatefulWidget {
  const TradesmanProfile({super.key});

  @override
  State<TradesmanProfile> createState() => _TradesmanProfileState();
}

class _TradesmanProfileState extends State<TradesmanProfile> {
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final store = RecruitmentSyncStore.instance;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: AnimatedBuilder(
        animation: store,
        builder: (context, _) {
          return SingleChildScrollView(
            child: Column(
              children: [
            // Edge-to-edge Top Cover Section
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 220,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF011931), Color(0xFF49769F)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
                // App Bar Icons
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 40), // Placeholder
                        Text(
                          t.tr(en: "Profile", ar: "البروفايل"),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                        IconButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const Settings()),
                          ),
                          icon: const Icon(Icons.settings_outlined, color: Colors.white, size: 28),
                        ),
                      ],
                    ),
                  ),
                ),
                // Profile Avatar Centered
                Positioned(
                  bottom: -60,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 5))],
                      ),
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: Theme.of(context).cardColor,
                        backgroundImage: getAppImageProvider(store.profileImage),
                        child: store.profileImage == null 
                            ? const Icon(Icons.person, size: 70, color: Color(0xFF49769F)) 
                            : null,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 75),

            // User Primary Info (Name and Edit Button)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!isAr) ...[
                    _buildEditButton(context, t),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Text(
                      store.currentUserName.isEmpty ? "No Name" : store.currentUserName,
                      textAlign: isAr ? TextAlign.right : TextAlign.left,
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 24, fontWeight: FontWeight.w900),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isAr) ...[
                    const SizedBox(width: 12),
                    _buildEditButton(context, t),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              store.currentUserTitle.isEmpty ? "Service Provider" : store.currentUserTitle,
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 16, fontWeight: FontWeight.w700),
            ),
            
            const SizedBox(height: 35),

            // Main Content Area
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  // Mode Switch Button
                  ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(t.tr(en: "Switching Mode...", ar: "جاري التبديل...")),
                          backgroundColor: const Color(0xFFFF7A2A),
                        ),
                      );
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const RecruitmentUserShellScreen()),
                      );
                    },
                    icon: const Icon(Icons.swap_horiz, color: Colors.white),
                    label: Text(t.tr(en: "Switch to Job Seeker", ar: "التبديل إلى وضع الباحث عن عمل")),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF7A2A),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 5,
                      shadowColor: const Color(0xFFFF7A2A).withOpacity(0.4),
                    ),
                  ),
                  
                  const SizedBox(height: 30),

                  // About Me Card
                  _buildFullWidthCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader(t.aboutMe, Icons.info_outline),
                        const SizedBox(height: 12),
                        Text(
                          store.currentUserAbout.isEmpty ? "No info provided yet." : store.currentUserAbout,
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), fontSize: 14, height: 1.5),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Contact Details Card
                  _buildFullWidthCard(
                    child: Column(
                      children: [
                        _buildInfoRow(t.emailAddress, store.currentUserEmail, Icons.email_outlined),
                        const Divider(height: 32),
                        _buildInfoRow(t.phoneNumber, store.currentUserPhone, Icons.phone_android_outlined),
                        const Divider(height: 32),
                        _buildInfoRow(t.address, store.currentUserLocation, Icons.location_on_outlined),
                        const Divider(height: 32),
                        _buildInfoRow(t.tr(en: "Skills", ar: "المهارات"), store.currentUserSkills.join(', '), Icons.psychology_outlined),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Gallery Section
                  if (store.portfolioImages.isNotEmpty) ...[
                    _buildFullWidthCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionHeader(t.tr(en: "Portfolio Gallery", ar: "معرض الأعمال"), Icons.image_outlined),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 110,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: store.portfolioImages.length,
                              itemBuilder: (context, index) {
                                final path = store.portfolioImages[index];
                                return Container(
                                  margin: const EdgeInsets.only(right: 12),
                                  width: 110,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: Colors.grey.shade100),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: Image(
                                      image: getAppImageProvider(path) ?? const AssetImage('assets/placeholder.png'),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Social Links
                  if (store.socialLinks.isNotEmpty) ...[
                    _buildFullWidthCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionHeader(t.socialLinks, Icons.link),
                          const SizedBox(height: 16),
                          ...store.socialLinks.map((link) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: InkWell(
                              onTap: () async {
                                String url = link['url'] ?? '';
                                if (url.isNotEmpty) {
                                  if (!url.startsWith('http')) url = 'https://$url';
                                  final uri = Uri.parse(url);
                                  if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
                                }
                              },
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                                    child: Icon(Icons.link_rounded, color: Theme.of(context).colorScheme.primary, size: 18),
                                  ),
                                  const SizedBox(width: 12),
                                  Text("${link['platform']}: ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Theme.of(context).colorScheme.onSurface)),
                                  Expanded(child: Text(link['url'] ?? "", style: TextStyle(color: Theme.of(context).colorScheme.primary, decoration: TextDecoration.underline), overflow: TextOverflow.ellipsis)),
                                ],
                              ),
                            ),
                          )),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Education Section
                  if (store.currentUserEducation.isNotEmpty) ...[
                    _buildFullWidthCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionHeader(t.education, Icons.school_outlined),
                          const SizedBox(height: 16),
                          ...store.currentUserEducation.map((edu) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                                  child: Icon(Icons.school, color: Theme.of(context).colorScheme.primary, size: 20),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(edu['institution'] ?? "", style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                                      Text("${edu['degree']} • ${edu['duration']}", style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.38), fontSize: 12)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )),
                        ],
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      );
        },
      ),
    );
  }

  Widget _buildEditButton(BuildContext context, AppLocalizations t) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed(AppRoutes.userEditProfile),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF007BFF), // اللون الأزرق
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF007BFF).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.edit, color: Colors.white, size: 14),
            const SizedBox(width: 6),
            Text(
              t.editProfile,
              style: const TextStyle(
                color: Colors.white, 
                fontSize: 12, 
                fontWeight: FontWeight.bold
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFullWidthCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: child,
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary, size: 22),
        const SizedBox(width: 10),
        Text(title, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: Theme.of(context).colorScheme.onSurface)),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.38), fontSize: 11, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(
                value.isEmpty ? "Not provided" : value,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
