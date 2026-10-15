import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/profile.dart';

class ProfileAvatar extends StatelessWidget {
  final Profile profile;
  final double radius;
  final bool isSelected;
  final VoidCallback? onTap;

  const ProfileAvatar({
    super.key,
    required this.profile,
    this.radius = 20,
    this.isSelected = false,
    this.onTap,
  });

  Color _getBgColor() {
    switch (profile.relation) {
      case 'me':
        return AppColors.primary;
      case 'father':
        return const Color(0xFF2E5B53);
      case 'mother':
        return const Color(0xFF9E6240);
      default:
        return AppColors.secondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final avatar = Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: isSelected
            ? Border.all(color: AppColors.accentGold, width: 2.5)
            : Border.all(color: Colors.white, width: 1.5),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: AppColors.primary.withAlpha(50),
                  blurRadius: 6,
                  spreadRadius: 1,
                )
              ]
            : null,
      ),
      child: CircleAvatar(
        radius: radius,
        backgroundColor: _getBgColor(),
        child: Text(
          profile.name.isNotEmpty ? profile.name[0].toUpperCase() : 'P',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: radius * 0.9,
          ),
        ),
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius * 2),
        child: avatar,
      );
    }
    return avatar;
  }
}
