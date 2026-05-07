// Dark theme preview and related appearance options.

import 'package:flutter/material.dart';

import 'appearance_settings_screen.dart';

class CompanyAppearanceSettingsDarkScreen extends StatelessWidget {
  const CompanyAppearanceSettingsDarkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const CompanyAppearanceSettingsScreen(initialTheme: 'Dark');
  }
}

