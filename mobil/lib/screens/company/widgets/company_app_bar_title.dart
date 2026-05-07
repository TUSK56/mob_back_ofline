// Top app bar identity: company logo/PFP + name (tabs: home, chat, jobs, stats, profile).

import 'package:flutter/material.dart';

import '../../../app/router/app_router.dart';
import '../../../shared/l10n/app_localizations.dart';
import '../../../shared/state/company_store.dart';
import '../../../shared/utils/image_helper.dart';

class CompanyAppBarIdentity extends StatelessWidget {
  const CompanyAppBarIdentity({super.key, this.avatarSize = 40});

  /// Diameter-style size (same as CircleAvatar diameter).
  final double avatarSize;

  @override
  Widget build(BuildContext context) {
    final store = CompanyStore.instance;
    final t = AppLocalizations.of(context);
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final provider = getAppImageProvider(store.companyProfileImage);
        final name = store.companyName.trim().isNotEmpty
            ? store.companyName
            : (t.isAr ? 'شركة' : 'Company');

        return InkWell(
          onTap: () => Navigator.of(context).pushNamed(AppRoutes.companyProfileOverview),
          borderRadius: BorderRadius.circular(12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: avatarSize / 2,
                backgroundColor:
                    Theme.of(context).colorScheme.surfaceContainerHighest,
                backgroundImage: provider,
                child: provider == null
                    ? Icon(
                        Icons.business,
                        color: Theme.of(context).colorScheme.primary,
                        size: avatarSize * 0.45,
                      )
                    : null,
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  name,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
