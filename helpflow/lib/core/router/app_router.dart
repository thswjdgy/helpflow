import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../views/layout/main_layout.dart';
import '../../views/dashboard/dashboard_screen.dart';
import '../../views/tickets/ticket_list_screen.dart';
import '../../views/tickets/ticket_detail_screen.dart';
import '../../views/tickets/ticket_form_screen.dart';
import '../../views/settings/settings_screen.dart';

/// go_router 기반 앱 라우팅 설정
/// ShellRoute로 사이드바/탑바를 모든 하위 라우트에서 공유
class AppRouter {
  AppRouter._(); // 인스턴스 생성 방지

  /// 앱 전체에서 사용하는 GoRouter 인스턴스 (싱글톤)
  static final GoRouter router = GoRouter(
    initialLocation: '/dashboard',
    debugLogDiagnostics: false,
    routes: [
      // ── ShellRoute: MainLayout(사이드바+탑바)를 공유하는 쉘 ──
      ShellRoute(
        builder: (BuildContext context, GoRouterState state, Widget child) {
          // state.uri.path를 MainLayout에 전달하여 현재 경로 기반 UI 업데이트
          return MainLayout(
            currentLocation: state.uri.path,
            child: child,
          );
        },
        routes: [
          // ── 대시보드 ──────────────────────────────────────
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),

          // ── 티켓 목록 + 하위 라우트 ───────────────────────
          GoRoute(
            path: '/tickets',
            builder: (context, state) => const TicketListScreen(),
            routes: [
              // 새 티켓 작성 (/tickets/new)
              // 주의: :id보다 먼저 선언해야 'new'가 파라미터로 잘못 해석되지 않음
              GoRoute(
                path: 'new',
                builder: (context, state) => const TicketFormScreen(),
              ),

              // 티켓 상세 (/tickets/:id)
              GoRoute(
                path: ':id',
                builder: (context, state) {
                  final ticketId = state.pathParameters['id'] ?? '';
                  return TicketDetailScreen(ticketId: ticketId);
                },
              ),
            ],
          ),

          // ── 설정 ──────────────────────────────────────────
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
    ],

    // ── 에러 페이지 ──────────────────────────────────────────
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              '페이지를 찾을 수 없습니다',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(state.uri.toString()),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => context.go('/dashboard'),
              child: const Text('대시보드로 이동'),
            ),
          ],
        ),
      ),
    ),
  );
}

// [파일 요약]
// go_router v14 기반 앱 라우팅 설정입니다.
// ShellRoute로 MainLayout(사이드바+탑바)을 모든 화면에서 공유하며,
// 경로 구조: /dashboard, /tickets, /tickets/new, /tickets/:id, /settings
// /tickets/new는 :id 파라미터 충돌 방지를 위해 :id보다 먼저 선언합니다.
