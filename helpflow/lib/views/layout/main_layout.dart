import 'package:flutter/material.dart';
import '../../core/constants/app_sizes.dart';
import 'sidebar_widget.dart';
import 'top_bar_widget.dart';

/// 앱 전체 레이아웃 쉘 위젯 (go_router ShellRoute에서 사용)
/// 반응형 3단계 레이아웃을 구현:
///   - 데스크탑 (≥1024px): SidebarWidget 항상 고정
///   - 태블릿  (≥ 600px): 아이콘만 보이는 미니 레일 (isCollapsed=true)
///   - 모바일  (< 600px): Scaffold Drawer
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
          // ── 모바일 레이아웃 ────────────────────────────────────
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
/// Scaffold Drawer + 탑바 + 컨텐츠
class _MobileLayout extends StatelessWidget {
  final Widget child;
  final String currentLocation;

  const _MobileLayout({required this.child, required this.currentLocation});

  @override
  Widget build(BuildContext context) {
    // Drawer를 프로그래밍 방식으로 열기 위한 GlobalKey
    final scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: scaffoldKey,

      // Drawer: SidebarWidget을 전체 너비로 표시
      drawer: SidebarWidget(
        currentLocation: currentLocation,
        isCollapsed: false,
        onClose: () => Navigator.of(context).pop(), // Drawer 닫기
      ),

      // 상단 탑바 (햄버거 메뉴 버튼 포함)
      appBar: TopBarWidget(
        currentLocation: currentLocation,
        onMenuPressed: () => scaffoldKey.currentState?.openDrawer(),
      ),

      // 실제 화면 컨텐츠
      body: child,
    );
  }
}

// [파일 요약]
// go_router ShellRoute와 연동하는 반응형 레이아웃 쉘 위젯입니다.
// LayoutBuilder로 화면 너비를 감지하여 데스크탑/태블릿/모바일 레이아웃을 분기합니다.
// - 데스크탑(≥1024px): 풀 사이드바 고정
// - 태블릿(≥600px): 아이콘만 보이는 미니 레일
// - 모바일(<600px): Scaffold Drawer
