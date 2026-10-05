import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../backend/auth_redirect.dart';
import '../backend/repositories.dart';

const _green = Color(0xFF1E6B4E);
const _ink = Color(0xFF17201B);
const _muted = Color(0xFF69716C);
const _canvas = Color(0xFFF8F9F7);

/// Social sign-in also creates an account on the first successful sign-in.
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, this.auth});

  /// Null only when this screen is shown inside the public design gallery.
  final AuthRepository? auth;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _showEmail = false;
  bool _register = false;
  bool _busy = false;
  bool _showPassword = false;
  String? _notice;
  bool _noticeIsError = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _setNotice(String message, {bool error = false}) {
    if (!mounted) return;
    setState(() {
      _notice = message;
      _noticeIsError = error;
    });
  }

  Future<void> _social(OAuthProvider provider) async {
    if (_busy) return;
    if (widget.auth == null) {
      _setNotice('디자인 미리보기예요. Supabase 설정을 넣으면 로그인이 연결됩니다.');
      return;
    }
    setState(() {
      _busy = true;
      _notice = null;
    });
    try {
      final launched = await widget.auth!.signInWithOAuth(provider);
      if (!launched) {
        _setNotice('로그인 창을 열지 못했어요. 다시 시도해 주세요.', error: true);
      }
      // A browser launch is not a session. AuthGate waits for the callback.
    } catch (_) {
      _setNotice('로그인을 시작하지 못했어요. 연결과 로그인 설정을 확인해 주세요.', error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _submitEmail() async {
    if (_busy || !_formKey.currentState!.validate()) return;
    if (widget.auth == null) {
      _setNotice('디자인 미리보기예요. Supabase 설정을 넣으면 로그인이 연결됩니다.');
      return;
    }
    setState(() {
      _busy = true;
      _notice = null;
    });
    try {
      if (_register) {
        final response = await widget.auth!.signUp(
          _email.text,
          _password.text,
          redirectTo: authRedirectUrl,
        );
        if (response.session == null) {
          _setNotice('확인 메일을 보냈어요. 이메일 인증을 마치면 로그인할 수 있어요.');
        }
      } else {
        await widget.auth!.signIn(_email.text, _password.text);
      }
    } on RepositoryException {
      _setNotice('인증에 실패했어요. 입력 내용과 이메일 인증 상태를 확인해 주세요.', error: true);
    } catch (_) {
      _setNotice('연결할 수 없어요. 잠시 후 다시 시도해 주세요.', error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _resetPassword() async {
    final email = _email.text.trim();
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
      _setNotice('먼저 올바른 이메일 주소를 입력해 주세요.', error: true);
      return;
    }
    if (widget.auth == null) {
      _setNotice('디자인 미리보기예요. Supabase 설정을 넣으면 메일을 보낼 수 있어요.');
      return;
    }
    setState(() {
      _busy = true;
      _notice = null;
    });
    try {
      await widget.auth!.resetPassword(email, redirectTo: authRedirectUrl);
      _setNotice('비밀번호 재설정 메일을 보냈어요. 메일함을 확인해 주세요.');
    } catch (_) {
      _setNotice('메일을 보내지 못했어요. 잠시 후 다시 시도해 주세요.', error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _canvas,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: _green,
                        borderRadius: BorderRadius.circular(17),
                      ),
                      child: const Icon(
                        Icons.route_rounded,
                        color: Colors.white,
                        size: 29,
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'NextMate',
                    style: TextStyle(
                      color: _green,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 9),
                  const Text(
                    '여행의 다음 순간까지\n가볍게 연결해요',
                    style: TextStyle(
                      color: _ink,
                      fontSize: 29,
                      height: 1.22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    '처음 한 번만 로그인하면 다음부터는 바로 여행 화면으로 들어갈 수 있어요.',
                    style: TextStyle(color: _muted, fontSize: 14, height: 1.5),
                  ),
                  const SizedBox(height: 32),
                  _SocialButton(
                    label: 'Google로 계속',
                    symbol: 'G',
                    onPressed: _busy
                        ? null
                        : () => _social(OAuthProvider.google),
                  ),
                  const SizedBox(height: 11),
                  _SocialButton(
                    label: 'Apple로 계속',
                    symbol: '●',
                    dark: true,
                    onPressed: _busy
                        ? null
                        : () => _social(OAuthProvider.apple),
                  ),
                  const SizedBox(height: 22),
                  const Row(
                    children: [
                      Expanded(child: Divider()),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text('또는', style: TextStyle(color: _muted)),
                      ),
                      Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 15),
                  if (!_showEmail)
                    OutlinedButton(
                      onPressed: _busy
                          ? null
                          : () => setState(() => _showEmail = true),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                        foregroundColor: _green,
                      ),
                      child: const Text('이메일로 계속'),
                    )
                  else ...[
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _register ? '이메일로 가입' : '이메일로 로그인',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: _busy
                              ? null
                              : () => setState(() {
                                  _register = !_register;
                                  _notice = null;
                                }),
                          child: Text(_register ? '로그인' : '회원가입'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _email,
                            enabled: !_busy,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.email],
                            decoration: const InputDecoration(
                              labelText: '이메일',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) =>
                                RegExp(
                                  r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
                                ).hasMatch(value?.trim() ?? '')
                                ? null
                                : '올바른 이메일을 입력해 주세요.',
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _password,
                            enabled: !_busy,
                            obscureText: !_showPassword,
                            autofillHints: [
                              _register
                                  ? AutofillHints.newPassword
                                  : AutofillHints.password,
                            ],
                            decoration: InputDecoration(
                              labelText: '비밀번호',
                              border: const OutlineInputBorder(),
                              suffixIcon: IconButton(
                                tooltip: _showPassword ? '비밀번호 숨기기' : '비밀번호 보기',
                                onPressed: () => setState(
                                  () => _showPassword = !_showPassword,
                                ),
                                icon: Icon(
                                  _showPassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if ((value ?? '').isEmpty) {
                                return '비밀번호를 입력해 주세요.';
                              }
                              if (_register && value!.length < 8) {
                                return '비밀번호는 8자 이상 입력해 주세요.';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: _busy ? null : _submitEmail,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                        backgroundColor: _green,
                      ),
                      child: _busy
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(_register ? '가입하기' : '로그인'),
                    ),
                    if (!_register)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _busy ? null : _resetPassword,
                          child: const Text('비밀번호를 잊으셨나요?'),
                        ),
                      ),
                  ],
                  if (_notice != null) ...[
                    const SizedBox(height: 16),
                    Semantics(
                      liveRegion: true,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _noticeIsError
                              ? const Color(0xFFFBEAE7)
                              : const Color(0xFFE8F1EC),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _notice!,
                          style: TextStyle(
                            color: _noticeIsError
                                ? const Color(0xFF9A3025)
                                : _green,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.label,
    required this.symbol,
    required this.onPressed,
    this.dark = false,
  });

  final String label;
  final String symbol;
  final VoidCallback? onPressed;
  final bool dark;

  @override
  Widget build(BuildContext context) => OutlinedButton(
    onPressed: onPressed,
    style: OutlinedButton.styleFrom(
      minimumSize: const Size.fromHeight(54),
      backgroundColor: dark ? _ink : Colors.white,
      foregroundColor: dark ? Colors.white : _ink,
      side: BorderSide(color: dark ? _ink : const Color(0xFFDDE3DE)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          symbol,
          style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
        ),
        const SizedBox(width: 13),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
      ],
    ),
  );
}

class PasswordRecoveryScreen extends StatefulWidget {
  const PasswordRecoveryScreen({
    super.key,
    required this.auth,
    required this.onCompleted,
  });

  final AuthRepository auth;
  final VoidCallback onCompleted;

  @override
  State<PasswordRecoveryScreen> createState() => _PasswordRecoveryScreenState();
}

class _PasswordRecoveryScreenState extends State<PasswordRecoveryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _password = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_busy || !_formKey.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await widget.auth.updatePassword(_password.text);
      if (mounted) widget.onCompleted();
    } catch (_) {
      if (mounted) setState(() => _error = '비밀번호를 변경하지 못했어요. 다시 시도해 주세요.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: _canvas,
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 430),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.lock_reset_rounded, color: _green, size: 44),
                  const SizedBox(height: 16),
                  const Text(
                    '새 비밀번호 설정',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '이메일 인증이 완료됐어요. 새 비밀번호를 입력해 주세요.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 22),
                  TextFormField(
                    controller: _password,
                    obscureText: true,
                    autofillHints: const [AutofillHints.newPassword],
                    decoration: const InputDecoration(
                      labelText: '새 비밀번호',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => (value?.length ?? 0) < 8
                        ? '비밀번호는 8자 이상 입력해 주세요.'
                        : null,
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(_error!, style: const TextStyle(color: Colors.red)),
                  ],
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: _busy ? null : _save,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      backgroundColor: _green,
                    ),
                    child: Text(_busy ? '변경 중…' : '비밀번호 변경'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
