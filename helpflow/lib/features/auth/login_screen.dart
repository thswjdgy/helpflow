import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/validators.dart';
import 'auth_provider.dart';

/// 로그인 화면 위젯
/// 이메일/비밀번호 입력 폼을 제공하고, AuthNotifier.signIn() 을 호출한다.
/// 인증 성공 시 go_router redirect 에 의해 /dashboard 로 자동 이동한다.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

/// LoginScreen 의 상태 클래스
/// 폼 검증, 텍스트 컨트롤러, 로딩/오류 처리를 담당한다.
class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true; // 비밀번호 숨김 여부

  /// 연속 로그인 실패 횟수 (3회 초과 시 잠금)
  int _failCount = 0;

  /// 잠금 해제 시각 (null이면 잠금 없음)
  DateTime? _lockedUntil;

  @override
  void dispose() {
    // 컨트롤러 메모리 해제
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  /// 현재 잠금 상태 여부 확인
  bool get _isLocked =>
      _lockedUntil != null && DateTime.now().isBefore(_lockedUntil!);

  /// 잠금 남은 시간(초) 반환
  int get _lockSecondsLeft =>
      _isLocked ? _lockedUntil!.difference(DateTime.now()).inSeconds + 1 : 0;

  /// 로그인 버튼 핸들러 — 잠금 확인 후 폼 검증, 실패 시 카운터 증가
  Future<void> _onLoginPressed() async {
    if (_isLocked) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    await ref.read(authProvider.notifier).signIn(
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
        );

    // 로그인 결과 확인 — 실패 시 카운터 증가
    final result = ref.read(authProvider);
    if (result is AsyncError) {
      setState(() {
        _failCount++;
        // 3회 연속 실패 시 30초 잠금
        if (_failCount >= 3) {
          _lockedUntil = DateTime.now().add(const Duration(seconds: 30));
          _failCount = 0;
        }
      });
    } else {
      // 성공 시 카운터 초기화
      setState(() => _failCount = 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authProvider).isLoading;

    // 로그인 실패 시 SnackBar 로 오류 표시
    ref.listen<AsyncValue<AuthUser?>>(authProvider, (_, next) {
      if (next is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('로그인 실패: ${next.error}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: ConstrainedBox(
            // 데스크탑에서 폼 너비 제한
            constraints: const BoxConstraints(maxWidth: 400),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── 앱 타이틀 ──────────────────────────────────
                  Text(
                    AppStrings.appName,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppStrings.appTagline,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),

                  // ── 이메일 입력 ────────────────────────────────
                  TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: '이메일',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    validator: AppValidators.email,
                  ),
                  const SizedBox(height: 16),

                  // ── 비밀번호 입력 ──────────────────────────────
                  TextFormField(
                    controller: _passwordCtrl,
                    obscureText: _obscure,
                    decoration: InputDecoration(
                      labelText: '비밀번호',
                      prefixIcon: const Icon(Icons.lock_outlined),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscure
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        // 비밀번호 표시/숨김 토글
                        onPressed: () =>
                            setState(() => _obscure = !_obscure),
                      ),
                    ),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? '비밀번호를 입력하세요' : null,
                  ),
                  const SizedBox(height: 32),

                  // 로그인 실패 횟수 안내 (1~2회)
                  if (_failCount > 0 && !_isLocked)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        '로그인 실패 $_failCount/3회 — 3회 실패 시 30초 잠금',
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.warning),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  // 잠금 중 안내
                  if (_isLocked)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        '로그인이 잠겼습니다. $_lockSecondsLeft초 후 다시 시도하세요.',
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.error),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  // ── 로그인 버튼 ────────────────────────────────
                  FilledButton(
                    // 로딩 중 또는 잠금 중이면 버튼 비활성화
                    onPressed: (isLoading || _isLocked) ? null : _onLoginPressed,
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('로그인'),
                  ),
                  const SizedBox(height: 16),

                  // ── 회원가입 링크 ──────────────────────────────
                  TextButton(
                    onPressed: () => context.go('/register'),
                    child: const Text('계정이 없으신가요? 회원가입'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// [파일 요약]
// 파일명: login_screen.dart
// 역할: 이메일/비밀번호 로그인 화면 UI 및 폼 처리
// 주요 클래스/함수: LoginScreen, _LoginScreenState
// 연관 파일: auth_provider.dart, app_router.dart
// 보안: AppValidators.email() 정규식 검증, 3회 실패 → 30초 잠금 (_failCount, _lockedUntil)
// ============================================================
