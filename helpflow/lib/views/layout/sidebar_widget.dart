import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_colors.dart';

/// 사이드바 네비게이션 항목 데이터 모델
class _NavItem {
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final String route;

  const _NavItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.route,
  });
}

/// 앱 좌측 사이드바 네비게이션 위젯
/// isCollapsed=false → 아이콘 + 레이블 (데스크탑, 너비 240)
/// isCollapsed=true  → 아이콘만 표시 (태블릿 미니 레일, 너비 64)
class SidebarWidget extends StatelessWidget {
  /// 현재 활성화된 경로 (탑-레벨 경로 기준으로 비교)
  final String currentLocation;

  /// 접힌 상태 여부 (태블릿 미니 레일 모드)
  final bool isCollapsed;

  /// Drawer 내부에서 사용 시 닫기 콜백
  final VoidCallback? onClose;

  const SidebarWidget({
    super.key,
    required this.currentLocation,
    this.isCollapsed = false,
    this.onClose,
  });

  // ── 네비게이션 항목 목록 ──────────────────────────────────────
  static const List<_NavItem> _navItems = [
    _NavItem(
      label: AppStrings.navDashboard,
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard,
      route: '/dashboard',
    ),
    _NavItem(
      label: AppStrings.navTickets,
      icon: Icons.confirmation_number_outlined,
      selectedIcon: Icons.confirmation_number,
      route: '/tickets',
    ),
    _NavItem(
      label: AppStrings.navSettings,
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings,
      route: '/settings',
    ),
  ];

  /// 현재 경로가 해당 항목의 활성 경로인지 확인
  bool _isActive(String itemRoute) {
    if (itemRoute == '/dashboard') {
      return currentLocation == '/dashboard' || currentLocation == '/';
    }
    return currentLocation.startsWith(itemRoute);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // 가로 너비: 접힌 상태(64) or 펼친 상태(240)
    final double sidebarW =
        isCollapsed ? AppSizes.railWidth : AppSizes.sidebarWidth;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      width: sidebarW,
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.light
            ? AppColors.sidebarLight
            : AppColors.sidebarDark,
        border: Border(
          right: BorderSide(
            color: colorScheme.outlineVariant,
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 앱 로고/이름 영역 ───────────────────────────────
          _buildHeader(context, colorScheme),

          const Divider(height: 1),

          // ── 네비게이션 항목 목록 ───────────────────────────
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: _navItems.map((item) {
                return _NavItemTile(
                  item: item,
                  isActive: _isActive(item.route),
                  isCollapsed: isCollapsed,
                  onTap: () {
                    onClose?.call(); // Drawer면 닫기
                    context.go(item.route);
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  /// 사이드바 상단 헤더 (로고 + 앱 이름)
  Widget _buildHeader(BuildContext context, ColorScheme colorScheme) {
    return SizedBox(
      height: AppSizes.topBarHeight,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isCollapsed ? 0 : 16,
        ),
        child: isCollapsed
            ? Center(
                // 접힌 상태: 아이콘만
                child: Icon(
                  Icons.support_agent,
                  color: colorScheme.primary,
                  size: 28,
                ),
              )
            : Row(
                children: [
                  Icon(Icons.support_agent, color: colorScheme.primary, size: 28),
                  const SizedBox(width: 10),
                  Text(
                    AppStrings.appName,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.primary,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// 개별 네비게이션 항목 타일 위젯
class _NavItemTile extends StatelessWidget {
  final _NavItem item;
  final bool isActive;
  final bool isCollapsed;
  final VoidCallback onTap;

  const _NavItemTile({
    required this.item,
    required this.isActive,
    required this.isCollapsed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // 활성 상태 배경색 및 텍스트/아이콘 색상
    final backgroundColor =
        isActive ? colorScheme.primaryContainer : Colors.transparent;
    final foregroundColor =
        isActive ? colorScheme.onPrimaryContainer : colorScheme.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(AppSizes.radiusSm),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSizes.radiusSm),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isCollapsed ? 0 : 12,
              vertical: 12,
            ),
            child: isCollapsed
                // 접힌 상태: 아이콘만 중앙 정렬
                ? Center(
                    child: Tooltip(
                      message: item.label,
                      child: Icon(
                        isActive ? item.selectedIcon : item.icon,
                        color: foregroundColor,
                        size: AppSizes.iconNavSize,
                      ),
                    ),
                  )
                // 펼친 상태: 아이콘 + 레이블
                : Row(
                    children: [
                      Icon(
                        isActive ? item.selectedIcon : item.icon,
                        color: foregroundColor,
                        size: AppSizes.iconNavSize,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight:
                              isActive ? FontWeight.w600 : FontWeight.w400,
                          color: foregroundColor,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

// [파일 요약]
// 앱 좌측 사이드바 네비게이션 위젯입니다.
// isCollapsed에 따라 아이콘+레이블(데스크탑) ↔ 아이콘만(태블릿) 전환을 AnimatedContainer로 처리합니다.
// 현재 경로(currentLocation)를 기반으로 활성 항목을 강조 표시합니다.
// Drawer 내부에서도 사용 가능하도록 onClose 콜백을 지원합니다.
