import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/design_system.dart';
import '../../features/auth/auth_provider.dart';
import '../../providers/theme_provider.dart';

/// 설정 화면
/// 외관(다크모드) 설정과 계정 정보(이메일·역할) + 로그아웃 버튼을 제공합니다.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(HelpFlowSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 외관 설정 섹션
            _AppearanceSection(),
            const SizedBox(height: HelpFlowSpacing.xxl),

            // 계정 정보 + 로그아웃 섹션
            _AccountSection(),
            const SizedBox(height: HelpFlowSpacing.xxl),

            // 데모 계정 프리셋 섹션 (역할 빠른 전환)
            _DemoAccountSection(),
          ],
        ),
      ),
    );
  }
}

// ── 외관 설정 섹션 ────────────────────────────────────────────
/// 다크모드 토글 스위치를 제공하는 카드
class _AppearanceSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 다크모드 상태 구독
    final isDark = ref.watch(themeProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(HelpFlowSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('외관', style: HelpFlowTextStyles.headline3),
            const SizedBox(height: HelpFlowSpacing.md),

            // 다크모드 토글 행
            SwitchListTile(
              title: const Text('다크 모드'),
              subtitle: Text(
                isDark ? '어두운 테마가 적용되어 있습니다' : '밝은 테마가 적용되어 있습니다',
                style: const TextStyle(
                    fontSize: 12, color: HelpFlowColors.gray400),
              ),
              secondary: Icon(
                isDark ? Icons.dark_mode : Icons.light_mode_outlined,
                color: isDark
                    ? Theme.of(context).colorScheme.primary
                    : HelpFlowColors.gray400,
              ),
              value: isDark,
              // themeProvider.toggle()로 라이트/다크 전환
              onChanged: (_) => ref.read(themeProvider.notifier).toggle(),
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }
}

// ── 계정 정보 섹션 ────────────────────────────────────────────
/// 현재 로그인 이메일·역할 표시 + 로그아웃 버튼을 제공하는 카드
class _AccountSection extends ConsumerWidget {
  // 역할 값 → 한국어 레이블 변환
  static String _roleLabel(String role) {
    const map = {'user': '사용자', 'agent': '에이전트', 'admin': '관리자'};
    return map[role] ?? role;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 현재 인증 사용자 정보
    final user = ref.watch(authProvider).valueOrNull;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(HelpFlowSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('계정', style: HelpFlowTextStyles.headline3),
            const SizedBox(height: HelpFlowSpacing.md),
            const Divider(height: 1),
            const SizedBox(height: HelpFlowSpacing.md),

            // 이메일 정보 행
            _InfoRow(
              icon: Icons.email_outlined,
              label: '이메일',
              value: user?.email ?? '-',
            ),
            const SizedBox(height: HelpFlowSpacing.sm),

            // 역할 정보 행
            _InfoRow(
              icon: Icons.badge_outlined,
              label: '역할',
              value: _roleLabel(user?.role ?? 'user'),
            ),
            const SizedBox(height: HelpFlowSpacing.xl),

            // 로그아웃 버튼
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () =>
                    ref.read(authProvider.notifier).signOut(),
                icon: const Icon(Icons.logout, color: AppColors.error),
                label: const Text(
                  '로그아웃',
                  style: TextStyle(color: AppColors.error),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.error),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── 정보 행 위젯 ─────────────────────────────────────────────
/// 아이콘 + 레이블 + 값을 한 줄로 표시하는 재사용 위젯
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: HelpFlowColors.gray400),
        const SizedBox(width: HelpFlowSpacing.sm),
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: const TextStyle(
                fontSize: 13, color: HelpFlowColors.gray400),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}

// ── 데모 계정 프리셋 섹션 ─────────────────────────────────────
/// 관리자·에이전트·사용자 역할로 즉시 전환할 수 있는 데모 계정 버튼 카드
/// authProvider.register()를 호출하여 Hive에 역할을 저장하고 자동 로그인합니다.
class _DemoAccountSection extends ConsumerWidget {
  /// 데모 계정 프리셋 정의 (역할·이메일·레이블·색상)
  static const _presets = [
    _DemoPreset(
      role: 'admin',
      email: 'admin@helpflow.com',
      label: '관리자',
      color: AppColors.error,
      icon: Icons.admin_panel_settings_outlined,
    ),
    _DemoPreset(
      role: 'agent',
      email: 'agent@helpflow.com',
      label: '에이전트',
      color: AppColors.warning,
      icon: Icons.support_agent_outlined,
    ),
    _DemoPreset(
      role: 'user',
      email: 'user@helpflow.com',
      label: '사용자',
      color: AppColors.info,
      icon: Icons.person_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 현재 로그인 역할 (버튼 활성/비활성 표시에 사용)
    final currentRole = ref.watch(authProvider).valueOrNull?.role;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(HelpFlowSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('데모 계정', style: HelpFlowTextStyles.headline3),
            const SizedBox(height: HelpFlowSpacing.sm),
            Text(
              '역할별 UI를 빠르게 확인할 수 있는 프리셋입니다.',
              style: const TextStyle(
                  fontSize: 12, color: HelpFlowColors.gray400),
            ),
            const SizedBox(height: HelpFlowSpacing.md),
            const Divider(height: 1),
            const SizedBox(height: HelpFlowSpacing.md),

            // 역할 프리셋 버튼 목록
            Column(
              children: _presets.map((preset) {
                final isActive = currentRole == preset.role;
                return Padding(
                  padding: const EdgeInsets.only(bottom: HelpFlowSpacing.sm),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      // 현재 역할과 동일하면 비활성
                      onPressed: isActive
                          ? null
                          : () => ref
                              .read(authProvider.notifier)
                              .register(
                                email: preset.email,
                                password: 'demo1234',
                                role: preset.role,
                              ),
                      icon: Icon(preset.icon,
                          size: 18,
                          color: isActive
                              ? HelpFlowColors.gray400
                              : preset.color),
                      label: Text(
                        isActive
                            ? '${preset.label} (현재 역할)'
                            : '${preset.label}로 전환',
                        style: TextStyle(
                          color: isActive
                              ? HelpFlowColors.gray400
                              : preset.color,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: isActive
                              ? HelpFlowColors.gray400.withAlpha(80)
                              : preset.color,
                        ),
                        alignment: Alignment.centerLeft,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

/// 데모 계정 프리셋 데이터 모델
class _DemoPreset {
  final String role;
  final String email;
  final String label;
  final Color color;
  final IconData icon;

  const _DemoPreset({
    required this.role,
    required this.email,
    required this.label,
    required this.color,
    required this.icon,
  });
}

// [파일 요약]
// 설정 화면입니다.
// SettingsScreen      : ConsumerWidget — 외관·계정·데모 섹션 나열
// _AppearanceSection  : 다크모드 SwitchListTile (themeProvider 연동)
// _AccountSection     : 이메일·역할 표시 + 로그아웃 버튼 (authProvider 연동)
// _DemoAccountSection : 관리자·에이전트·사용자 역할 프리셋 버튼 (authProvider.register 호출)
// _InfoRow            : 아이콘+레이블+값 한 줄 표시 재사용 위젯
