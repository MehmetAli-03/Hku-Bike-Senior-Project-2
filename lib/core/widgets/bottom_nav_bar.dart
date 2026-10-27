import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final VoidCallback onQrTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.onQrTap,
  });

  static const Color _primary = Color(0xFF00875A);
  static const Color _inactive = Color(0xFF94A3B8);

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 14,
      shadowColor: Colors.black.withAlpha(60),
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      clipBehavior: Clip.antiAlias,
      padding: EdgeInsets.zero,
      height: 72,
      child: Row(
        children: [
          // 1. Ana Sayfa
          _NavItem(
            icon: Icons.home_outlined,
            activeIcon: Icons.home_rounded,
            label: 'Ana Sayfa',
            selected: currentIndex == 0,
            onTap: () => onTap(0),
          ),
          // 2. Aktif Sürüş
          _NavItem(
            icon: Icons.directions_bike_outlined,
            activeIcon: Icons.directions_bike_rounded,
            label: 'Aktif Sürüş',
            selected: currentIndex == 1,
            onTap: () => onTap(1),
          ),
          const SizedBox(width: 84), // Ortadaki QR FAB boşluğu
          // 3. Geçmiş Yolculuklar
          _NavItem(
            icon: Icons.history_rounded,
            activeIcon: Icons.history_toggle_off_rounded,
            label: 'Geçmiş',
            selected: currentIndex == 3,
            onTap: () => onTap(3),
          ),
          // 4. Profil
          _NavItem(
            icon: Icons.person_outline_rounded,
            activeIcon: Icons.person_rounded,
            label: 'Profil',
            selected: currentIndex == 4,
            onTap: () => onTap(4),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? CustomBottomNavBar._primary : CustomBottomNavBar._inactive;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(selected ? activeIcon : icon, color: color, size: 24),
            const SizedBox(height: 3),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10.5,
                color: color,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 2.5,
              width: selected ? 40 : 0,
              decoration: BoxDecoration(
                color: CustomBottomNavBar._primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}