import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/auth_provider.dart';
import '../../features/auth/login_screen.dart';
import '../../views/dashboard/dashboard_screen.dart';
import '../../views/layout/main_layout.dart';
import '../../views/reports/reports_screen.dart';
import '../../views/settings/settings_screen.dart';
import '../../views/tickets/ticket_detail_screen.dart';
import '../../views/tickets/ticket_form_screen.dart';
import '../../views/tickets/ticket_list_screen.dart';
import 'router_notifier.dart';

/// go_router 인스턴스를 Riverpod Provider 로 제공
/// - RouterNotifier 를 refreshListenable 로 등록해 인증 상태 변화 시 redirect 재실행
/// - 비로그인 → /login, 로그인 상태 → /dashboard 로 자동 분기
final routerProvider = Provider<GoRouter>((ref) {
  // 인증 상태 변화를 GoRouter 에 전달하는 ChangeNotifier
  final notifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    initialLocation: '/login', // 앱 시작 지점 (인증 확인 전 로그인 화면)
    refreshListenable: notifier, // 인증 변경 시 redirect 재평가 트리거
    debugLogDiagnostics: false,

    /// 인증 상태 기반 리다이렉트 함수
    /// 매 네비게이션마다 호출되어 로그인 여부에 따라 경로 결정
    redirect: (BuildContext context, GoRouterState state) {
      final authState = ref.read(authProvider);

      // 인증 상태 로딩 중이면 현재 화면 유지 (리다이렉트 보류)
      if (authState.isLoading) return null;

      final isLoggedIn = authState.valueOrNull != null;
      final isOnLogin = state.uri.path == '/login';

      // 로그인 안 됨 + 로그인 화면이 아니면 → 로그인 화면으로
      if (!isLoggedIn && !isOnLogin) return '/login';
      // 이미 로그인 + 로그인 화면이면 → 대시보드로
      if (isLoggedIn && isOnLogin) return '/dashboard';

      return null; // 리다이렉트 없음
    },

    routes: [
      // ── 로그인 화면 (ShellRoute 밖 — 사이드바/탑바 없음) ──
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),

      // ── ShellRoute: MainLayout(사이드바+탑바)를 공유하는 쉘 ──
      ShellRoute(
        builder: (BuildContext context, GoRouterState state, Widget child) {
          // 현재 경로를 MainLayout 에 전달해 사이드바 활성 항목 표시
          return MainLayout(
            currentLocation: state.uri.path,
            child: child,
          );
        },
        routes: [
          // ── 대시보드 ────────────────────────────────────────
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),

          // ── 티켓 목록 + 하위 라우트 ─────────────────────────
          GoRoute(
            path: '/tickets',
            builder: (context, state) => const TicketListScreen(),
            routes: [
              // 새 티켓 (/tickets/new) — :id 보다 먼저 선언해 충돌 방지
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

          // ── 리포트 ──────────────────────────────────────────
          GoRoute(
            path: '/reports',
            builder: (context, state) => const ReportsScreen(),
          ),

          // ── 설정 ────────────────────────────────────────────
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
    ],

    // ── 에러 페이지 ────────────────────────────────────────────
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
});

// ============================================================
// [파일 요약]
// 파일명: app_router.dart
// 역할: go_router 기반 라우팅 설정 + Riverpod 인증 상태 연동 리다이렉트
// 주요 클래스/함수: routerProvider
// 연관 파일: router_notifier.dart, auth_provider.dart, login_screen.dart, main_layout.dart
// ============================================================
