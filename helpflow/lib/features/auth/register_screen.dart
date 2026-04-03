import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/validators.dart';
import 'auth_provider.dart';

/// 회원가입 화면
/// 이메일·비밀번호·역할을 입력받아 AuthNotifier.register()를 호출합니다.
/// 회원가입 성공 시 자동 로그인되어 /dashboard로 이동합니다.
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  /// 선택된 역할 값
  String _role = 'user';

  /// 비밀번호 숨김 여부
  bool _obscurePassword = true;

  /// 비밀번호 확인 숨김 여부
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  /// 회원가입 버튼 핸들러 — 폼 유효성 통과 시 register() 호출
  Future<void> _onRegisterPressed() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await ref.read(authProvider.notifier).register(
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
          role: _role,
        );
  }

  /// 비밀번호 확인 검증 — _passwordCtrl과 일치 여부 확인
  String? _validateConfirm(String? value) {
    if (value == null || value.isEmpty) return '비밀번호 확인을 입력해주세요.';
    if (value != _passwordCtrl.text) return '비밀번호가 일치하지 않습니다.';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authProvider).isLoading;

    // 회원가입 실패 시 SnackBar로 오류 표시
    ref.listen<AsyncValue<AuthUser?>>(authProvider, (_, next) {
      if (next is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('회원가입 실패: ${next.error}'),
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
            // 데스크탑 폼 너비 제한
            constraints: const BoxConstraints(maxWidth: 400),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 제목
                  Text(
                    '회원가입',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'HelpFlow 계정을 만들어 시작하세요',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  // ── 이메일 입력 ──────────────────────────────
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

                  // ── 비밀번호 입력 ────────────────────────────
                  TextFormField(
                    controller: _passwordCtrl,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: '비밀번호',
                      prefixIcon: const Icon(Icons.lock_outlined),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () =>
                            setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    validator: AppValidators.compose([
                      (v) => AppValidators.required(v, fieldName: '비밀번호'),
                      AppValidators.minLength(6, fieldName: '비밀번호'),
                    ]),
                  ),
                  const SizedBox(height: 16),

                  // ── 비밀번호 확인 입력 ───────────────────────
                  TextFormField(
                    controller: _confirmCtrl,
                    obscureText: _obscureConfirm,
                    decoration: InputDecoration(
                      labelText: '비밀번호 확인',
                      prefixIcon: const Icon(Icons.lock_outlined),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirm
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () =>
                            setState(() => _obscureConfirm = !_obscureConfirm),
                      ),
                    ),
                    validator: _validateConfirm,
                  ),
                  const SizedBox(height: 24),

                  // ── 역할 선택 SegmentedButton ────────────────
                  Text(
                    '역할 선택',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  _RoleSelector(
                    selected: _role,
                    onChanged: (v) => setState(() => _role = v),
                  ),
                  const SizedBox(height: 32),

                  // ── 회원가입 버튼 ────────────────────────────
                  FilledButton(
                    onPressed: isLoading ? null : _onRegisterPressed,
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('회원가입'),
                  ),
                  const SizedBox(height: 16),

                  // ── 로그인 화면으로 이동 링크 ─────────────────
                  TextButton(
                    onPressed: () => context.go('/login'),
                    child: const Text('이미 계정이 있으신가요? 로그인'),
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

// ── 역할 선택 위젯 ────────────────────────────────────────────
/// user / agent / admin 역할을 SegmentedButton으로 선택하는 위젯
class _RoleSelector extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const _RoleSelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<String>(
      segments: const [
        ButtonSegment(value: 'user', label: Text('사용자'), icon: Icon(Icons.person_outline)),
        ButtonSegment(value: 'agent', label: Text('에이전트'), icon: Icon(Icons.support_agent)),
        ButtonSegment(value: 'admin', label: Text('관리자'), icon: Icon(Icons.admin_panel_settings_outlined)),
      ],
      selected: {selected},
      onSelectionChanged: (set) {
        if (set.isNotEmpty) onChanged(set.first);
      },
    );
  }
}

// [파일 요약]
// 회원가입 화면입니다.
// RegisterScreen: ConsumerStatefulWidget — 이메일·비밀번호·역할 입력 폼
// _RoleSelector: user/agent/admin 역할을 SegmentedButton으로 선택
// 비밀번호 확인 로직은 _validateConfirm()에서 _passwordCtrl과 비교합니다.
// 회원가입 성공 시 authProvider.register()가 자동 로그인 처리합니다.
// Firestore 연동 시 register() 내부에서 Firebase 호출로 교체합니다.
