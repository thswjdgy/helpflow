import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/design_system.dart';
import 'sidebar_widget.dart';
import 'top_bar_widget.dart';

/// 앱 전체 레이아웃 쉘 위젯 (go_router ShellRoute에서 사용)
/// 반응형 3단계 레이아웃을 구현:
///   - 데스크탑 (≥1024px): SidebarWidget 항상 고정
///   - 태블릿  (≥ 600px): 아이콘만 보이는 미니 레일 (isCollapsed=true)
///   - 모바일  (< 600px): 하단 NavigationBar (4개 탭)
class MainLayout extends StatelessWidget {
  /// go_router ShellRoute가 전달하는 자식 화면 위젯
  final Widget child;

  /// 현재 활성 경로 (ShellRoute builder에서 state.uri.path로 전달)
  final String currentLocation;

  const MainLayout({
    super.key,
    required this.child,
    required this.currentLocation,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        if (width >= AppSizes.desktopBreakpoint) {
          // ── 데스크탑 레이아웃 ──────────────────────────────────
          return _DesktopLayout(
            currentLocation: currentLocation,
            child: child,
          );
        } else if (width >= AppSizes.tabletBreakpoint) {
          // ── 태블릿 레이아웃 ────────────────────────────────────
          return _TabletLayout(
            currentLocation: currentLocation,
            child: child,
          );
        } else {
          // ── 모바일 레이아웃 (하단 내비게이션 바) ─────────────────
          return _MobileLayout(
            currentLocation: currentLocation,
            child: child,
          );
        }
      },
    );
  }
}

// ── 데스크탑 레이아웃 ────────────────────────────────────────────
/// 좌측 고정 사이드바 + 우측 컨텐츠 영역
class _DesktopLayout extends StatelessWidget {
  final Widget child;
  final String currentLocation;

  const _DesktopLayout({required this.child, required this.currentLocation});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HelpFlowColors.background,
      body: Row(
        children: [
          // 좌측 고정 사이드바 (아이콘 + 레이블)
          SidebarWidget(
            currentLocation: currentLocation,
            isCollapsed: false,
          ),

          // 우측 컨텐츠 영역
          Expanded(
            child: Column(
              children: [
                // 탑바
                TopBarWidget(currentLocation: currentLocation),

                // 실제 화면 컨텐츠
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── 태블릿 레이아웃 ──────────────────────────────────────────────
/// 좌측 미니 레일 (아이콘만) + 우측 컨텐츠 영역
class _TabletLayout extends StatelessWidget {
  final Widget child;
  final String currentLocation;

  const _TabletLayout({required this.child, required this.currentLocation});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HelpFlowColors.background,
      body: Row(
        children: [
          // 좌측 미니 레일 (아이콘만 표시)
          SidebarWidget(
            currentLocation: currentLocation,
            isCollapsed: true,
          ),

          // 우측 컨텐츠 영역
          Expanded(
            child: Column(
              children: [
                TopBarWidget(currentLocation: currentLocation),
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── 모바일 레이아웃 ──────────────────────────────────────────────
/// 탑바 + 컨텐츠 + 하단 NavigationBar (4개 탭)
/// 600px 미만 화면에서만 사용됩니다.
class _MobileLayout extends StatelessWidget {
  final Widget child;
  final String currentLocation;

  const _MobileLayout({required this.child, required this.currentLocation});

  /// 현재 경로에서 하단 탭 선택 인덱스를 계산
  /// 0: 홈(대시보드), 1: 티켓, 2: 리포트, 3: 설정
  static int _getSelectedIndex(String location) {
    if (location.startsWith('/tickets')) return 1;
    if (location.startsWith('/reports')) return 2;
    if (location.startsWith('/settings')) return 3;
    return 0; // 대시보드 (기본값)
  }

  /// 탭 인덱스별 라우트 경로
  static const List<String> _routes = [
    '/dashboard',
    '/tickets',
    '/reports',
    '/settings',
  ];

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _getSelectedIndex(currentLocation);

    return Scaffold(
      backgroundColor: HelpFlowColors.background,

      // 상단 탑바 (햄버거 메뉴 없음 — Drawer 대신 하단 탭 사용)
      appBar: TopBarWidget(currentLocation: currentLocation),

      // 하단 내비게이션 바 — 600px 미만 모바일 전용
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        // 탭 선택 시 해당 라우트로 이동
        onDestinationSelected: (int index) {
          context.go(_routes[index]);
        },
        destinations: const [
          // 홈 — 대시보드
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: '홈',
          ),
          // 티켓 관리
          NavigationDestination(
            icon: Icon(Icons.confirmation_number_outlined),
            selectedIcon: Icon(Icons.confirmation_number),
            label: '티켓',
          ),
          // 리포트 (7~8주차 구현 예정)
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: '리포트',
          ),
          // 설정
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: '설정',
          ),
        ],
      ),

      // 실제 화면 컨텐츠
      body: child,
    );
  }
}

// [파일 요약]
// go_router ShellRoute와 연동하는 반응형 레이아웃 쉘 위젯입니다.
// LayoutBuilder로 화면 너비를 감지하여 3단계 레이아웃을 분기합니다.
// - 데스크탑(≥1024px): 풀 사이드바 고정 + TopBar
// - 태블릿 (≥  600px): 미니 레일(아이콘만) + TopBar
// - 모바일 (<  600px): TopBar + 하단 NavigationBar (홈/티켓/리포트/설정)
// 모든 Scaffold에 HelpFlowColors.background(#FFFFFF) 배경색 적용
