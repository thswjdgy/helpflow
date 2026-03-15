import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../providers/theme_provider.dart';

/// 앱 상단 탑바 위젯
/// - 현재 페이지 제목 자동 표시 (경로 기반)
/// - 새 티켓 FilledButton
/// - 다크모드 토글 아이콘 버튼
/// ConsumerWidget으로 themeProvider를 구독
class TopBarWidget extends ConsumerWidget implements PreferredSizeWidget {
  /// 현재 경로 (MainLayout에서 전달)
  final String currentLocation;

  /// 모바일 Drawer 열기 콜백 (모바일 레이아웃에서만 사용)
  final VoidCallback? onMenuPressed;

  const TopBarWidget({
    super.key,
    required this.currentLocation,
    this.onMenuPressed,
  });

  /// AppBar preferred 높이
  @override
  Size get preferredSize => const Size.fromHeight(AppSizes.topBarHeight);

  /// 현재 경로에 해당하는 페이지 제목 반환
  String _getPageTitle() {
    if (currentLocation.startsWith('/tickets/new')) {
      return AppStrings.ticketFormTitleNew;
    } else if (currentLocation.startsWith('/tickets/') &&
        currentLocation.length > '/tickets/'.length) {
      return AppStrings.ticketDetailTitle;
    } else if (currentLocation.startsWith('/tickets')) {
      return AppStrings.ticketListTitle;
    } else if (currentLocation.startsWith('/settings')) {
      return AppStrings.settingsTitle;
    } else {
      return AppStrings.dashboardTitle;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 다크모드 상태 구독
    final isDark = ref.watch(themeProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // 티켓 작성/상세 화면에서는 새 티켓 버튼 숨김
    final showNewTicketButton = !currentLocation.startsWith('/tickets/');

    return AppBar(
      backgroundColor: colorScheme.surface,
      surfaceTintColor: colorScheme.surfaceTint,
      elevation: 0,
      scrolledUnderElevation: 1,

      // 모바일에서만 햄버거 메뉴 버튼 표시
      leading: onMenuPressed != null
          ? IconButton(
              icon: const Icon(Icons.menu),
              onPressed: onMenuPressed,
              tooltip: '메뉴 열기',
            )
          : null,
      automaticallyImplyLeading: false,

      // 현재 페이지 제목
      title: Text(
        _getPageTitle(),
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: colorScheme.onSurface,
        ),
      ),

      actions: [
        // 새 티켓 버튼 (티켓 상세/수정 화면 제외)
        if (showNewTicketButton)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilledButton.icon(
              onPressed: () => context.go('/tickets/new'),
              icon: const Icon(Icons.add, size: 18),
              label: const Text(AppStrings.newTicket),
            ),
          ),

        // 다크모드 토글 버튼
        IconButton(
          icon: Icon(isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
          tooltip: isDark ? '라이트 모드로 전환' : '다크 모드로 전환',
          onPressed: () {
            ref.read(themeProvider.notifier).toggle();
          },
        ),

        const SizedBox(width: 8),
      ],
    );
  }
}

// [파일 요약]
// 앱 상단 탑바 위젯입니다.
// 현재 경로(currentLocation)에서 페이지 제목을 자동으로 결정하고,
// 새 티켓 FilledButton과 다크모드 토글 버튼을 제공합니다.
// Riverpod ConsumerWidget으로 themeProvider를 구독하여 다크모드 아이콘을 동기화합니다.
