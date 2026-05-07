// Avatar chip for applicants in lists and chat headers.

import 'package:flutter/material.dart';

import '../../../constants/app_images.dart';

class CompanyApplicantAvatar extends StatelessWidget {
  const CompanyApplicantAvatar({
    super.key,
    required this.seed,
    this.radius = 20,
    this.fit = BoxFit.cover,
  });

  final String seed;
  final double radius;
  final BoxFit fit;

  static const _avatars = [
    AppImages.companyProfile1,
    AppImages.companyProfile2,
    AppImages.companyProfile3,
    AppImages.companyProfile4,
    AppImages.companyProfile5,
    AppImages.companyProfile6,
    AppImages.companyProfile7,
  ];

  @override
  Widget build(BuildContext context) {
    final index = seed.hashCode.abs() % _avatars.length;
    return CircleAvatar(
      radius: radius,
      backgroundImage: AssetImage(_avatars[index]),
    );
  }
}

