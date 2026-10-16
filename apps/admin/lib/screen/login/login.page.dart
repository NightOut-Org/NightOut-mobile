import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nightoutadmin/extensions/context.extension.dart';
import 'package:nightoutadmin/library/loading.dart';
import 'package:nightoutadmin/models/auth/auth.models.dart';
import 'package:nightoutadmin/modules/controller/auth.ctrl.dart';
import 'package:nightout_core/nightout_core.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _otp = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _otp.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final auth = ref.watch(authCtrl);
    final step = auth.phase == LoginPhase.credentials ? '1/3' : '2/3';
    final banner = _banner(auth);

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      behavior: HitTestBehavior.translucent,
      child: Scaffold(
        backgroundColor: colors.background,
        body: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                colors.heroVia,
                colors.background,
              ],
              stops: const [0, 0.42],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: context.maxWidthPadding),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 4, 12, 0),
                    child: Row(
                      children: [
                        const NightOutThemeModeMenu(),
                        const Spacer(),
                        Text(
                          'NIGHT MODE · STEP $step',
                          style: NightOutText.sans(
                            fontSize: 11,
                            letterSpacing: 1.1,
                            color: colors.goldText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
                      children: [
                        ShaderMask(
                          shaderCallback: (bounds) {
                            return LinearGradient(
                              colors: [colors.titleFrom, colors.titleTo],
                            ).createShader(bounds);
                          },
                          child: Text(
                            'Admin Pass',
                            style: NightOutText.display(
                              context.textTheme.headlineMedium,
                              colors,
                            ).copyWith(fontSize: 36, color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'สำหรับผู้ดูแลระบบ',
                          style: NightOutText.sans(fontSize: 13, color: colors.muted),
                        ),
                        const SizedBox(height: 28),
                        if (auth.phase == LoginPhase.credentials) ...[
                          Text(
                            'ล็อกอินเข้าห้องทำงาน',
                            style: NightOutText.sans(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: colors.text,
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (banner != null) ...[
                            _ErrorBanner(message: banner),
                            const SizedBox(height: 16),
                          ],
                          _FieldLabel('อีเมล'),
                          TextField(
                            key: const Key('email-field'),
                            controller: _email,
                            keyboardType: TextInputType.emailAddress,
                            autofillHints: const [AutofillHints.username],
                            textInputAction: TextInputAction.next,
                            onChanged: (_) => _editCredentials(),
                            decoration: const InputDecoration(hintText: 'name@nightout.co'),
                          ),
                          const SizedBox(height: 16),
                          _FieldLabel('รหัสผ่าน'),
                          TextField(
                            key: const Key('password-field'),
                            controller: _password,
                            obscureText: _obscure,
                            autofillHints: const [AutofillHints.password],
                            textInputAction: TextInputAction.done,
                            onChanged: (_) => _editCredentials(),
                            onSubmitted: (_) => _submitPassword(),
                            decoration: InputDecoration(
                              hintText: 'รหัสผ่าน',
                              suffixIcon: IconButton(
                                onPressed: () => setState(() => _obscure = !_obscure),
                                icon: PhosphorIcon(
                                  _obscure ? PhosphorIconsRegular.eye : PhosphorIconsRegular.eyeSlash,
                                  color: colors.muted,
                                ),
                              ),
                            ),
                          ),
                        ] else if (auth.phase == LoginPhase.enroll) ...[
                          Text(
                            'ผูกแอป Authenticator',
                            style: NightOutText.sans(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: colors.text,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'เพิ่มบัญชี NightOut Admin ในแอป แล้วกรอกรหัส 6 หลัก',
                            style: NightOutText.sans(fontSize: 13, color: colors.muted),
                          ),
                          const SizedBox(height: 20),
                          const _StepTitle(index: '1', title: 'ติดตั้งแอป Authenticator'),
                          const SizedBox(height: 10),
                          _SecretBox(secret: auth.enrollment?.secret ?? ''),
                          const SizedBox(height: 20),
                          const _StepTitle(index: '2', title: 'กรอกรหัส 6 หลักจากแอป'),
                          const SizedBox(height: 12),
                          _OtpBoxes(controller: _otp, invalid: false, onChanged: (_) {}),
                        ] else ...[
                          Text(
                            'ยืนยันตัวตนอีกครั้ง',
                            style: NightOutText.sans(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: colors.text,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'กรอกรหัส 6 หลักจากแอป Authenticator',
                            style: NightOutText.sans(fontSize: 13, color: colors.muted),
                          ),
                          if (banner != null) ...[
                            const SizedBox(height: 16),
                            _ErrorBanner(message: banner),
                          ],
                          const SizedBox(height: 16),
                          _OtpBoxes(
                            controller: _otp,
                            invalid: auth.codeInvalid,
                            onChanged: (_) {},
                          ),
                        ],
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                    child: _BottomActions(
                      auth: auth,
                      otp: _otp,
                      onPassword: _submitPassword,
                      onCode: () => _run(() async {
                        await ref.read(authCtrl.notifier).submitCode(_otp.text);
                        if (!mounted) return;
                        if (ref.read(authCtrl).codeInvalid) _otp.clear();
                      }),
                      onSkip: () => _run(() => ref.read(authCtrl.notifier).skipEnroll()),
                      onResetCode: () {
                        _otp.clear();
                        ref.read(authCtrl.notifier).resetCode();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String? _banner(AuthState auth) {
    if (auth.phase == LoginPhase.credentials && auth.credentialsInvalid) {
      return 'อีเมลหรือรหัสผ่านไม่ถูกต้อง';
    }
    if (auth.phase == LoginPhase.verify && auth.codeInvalid) {
      return 'รหัสไม่ถูกต้อง';
    }
    return auth.notice;
  }

  void _editCredentials() {
    ref.read(authCtrl.notifier).clearCredentialError();
  }

  void _submitPassword() {
    final email = _email.text.trim();
    final password = _password.text;
    if (email.isEmpty || password.isEmpty) {
      ref.read(authCtrl.notifier).submitPassword(email: email, password: password);
      return;
    }
    _run(() => ref.read(authCtrl.notifier).submitPassword(email: email, password: password));
  }

  Future<void> _run(Future<void> Function() action) async {
    FocusManager.instance.primaryFocus?.unfocus();
    Loading.show();
    try {
      await action();
    } finally {
      Loading.close();
    }
  }
}

class _BottomActions extends StatelessWidget {
  const _BottomActions({
    required this.auth,
    required this.otp,
    required this.onPassword,
    required this.onCode,
    required this.onSkip,
    required this.onResetCode,
  });

  final AuthState auth;
  final TextEditingController otp;
  final VoidCallback onPassword;
  final Future<void> Function() onCode;
  final VoidCallback onSkip;
  final VoidCallback onResetCode;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return ListenableBuilder(
      listenable: otp,
      builder: (context, _) {
        final ready = otp.text.length == 6 && !auth.busy;
        if (auth.phase == LoginPhase.credentials) {
          return Column(
            children: [
              Text(
                'ครั้งแรก ระบบจะให้ผูกแอป Authenticator',
                textAlign: TextAlign.center,
                style: NightOutText.sans(fontSize: 12, color: colors.muted),
              ),
              const SizedBox(height: 12),
              _GoldButton(
                key: const Key('login-submit'),
                label: auth.busy ? 'กำลังเข้าสู่ระบบ' : 'เข้าสู่ระบบ',
                loading: auth.busy,
                onPressed: auth.busy ? null : onPassword,
              ),
            ],
          );
        }
        if (auth.phase == LoginPhase.enroll) {
          return Column(
            children: [
              _GoldButton(
                key: const Key('otp-submit'),
                label: auth.busy ? 'กำลังยืนยัน' : 'ยืนยันการผูก',
                loading: auth.busy,
                onPressed: ready ? () => onCode() : null,
              ),
              TextButton(onPressed: auth.busy ? null : onSkip, child: const Text('ไม่ผูกตอนนี้')),
            ],
          );
        }
        return Column(
          children: [
            _GoldButton(
              key: const Key('otp-submit'),
              label: auth.busy ? 'กำลังยืนยัน' : 'ยืนยัน',
              loading: auth.busy,
              onPressed: ready ? () => onCode() : null,
            ),
            TextButton(
              onPressed: auth.busy ? null : onResetCode,
              child: Text('ใช้รหัสอื่น', style: TextStyle(color: colors.muted)),
            ),
          ],
        );
      },
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: NightOutText.fieldLabel(context.colors)),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colors.crowdFull.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(NightOutRadius.base),
        border: Border.all(color: colors.crowdFull),
      ),
      child: Text(
        message,
        style: NightOutText.sans(fontSize: 13, color: colors.crowdFull),
      ),
    );
  }
}

class _StepTitle extends StatelessWidget {
  const _StepTitle({required this.index, required this.title});

  final String index;
  final String title;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      children: [
        Container(
          width: 22,
          height: 22,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: colors.gold),
          ),
          child: Text(
            index,
            style: NightOutText.sans(fontSize: 12, fontWeight: FontWeight.w700, color: colors.goldText),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: NightOutText.sans(fontSize: 14, fontWeight: FontWeight.w600, color: colors.text),
          ),
        ),
      ],
    );
  }
}

class _SecretBox extends StatelessWidget {
  const _SecretBox({required this.secret});

  final String secret;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final grouped = groupSecret(secret);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(NightOutRadius.base),
        border: Border.all(color: colors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: Text(
                grouped,
                style: NightOutText.sans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: colors.goldText,
                ),
              ),
            ),
            IconButton(
              tooltip: 'คัดลอกรหัส',
              onPressed: secret.isEmpty
                  ? null
                  : () async {
                      await Clipboard.setData(ClipboardData(text: secret.replaceAll(' ', '')));
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('คัดลอกรหัสแล้ว')),
                      );
                    },
              icon: PhosphorIcon(PhosphorIconsRegular.copy, color: colors.goldText),
            ),
          ],
        ),
      ),
    );
  }
}

class _OtpBoxes extends StatelessWidget {
  const _OtpBoxes({
    required this.controller,
    required this.invalid,
    required this.onChanged,
  });

  final TextEditingController controller;
  final bool invalid;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final borderColor = invalid ? colors.crowdFull : colors.border;
    return SizedBox(
      height: 52,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ListenableBuilder(
            listenable: controller,
            builder: (context, _) {
              final text = controller.text;
              return Row(
                children: [
                  for (var i = 0; i < 6; i++)
                    Expanded(
                      child: Container(
                        height: 52,
                        margin: EdgeInsets.only(left: i == 0 ? 0 : 8),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: colors.card,
                          borderRadius: BorderRadius.circular(NightOutRadius.base),
                          border: Border.all(color: borderColor),
                        ),
                        child: Text(
                          i < text.length ? text[i] : '',
                          style: NightOutText.sans(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: invalid ? colors.crowdFull : colors.text,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          Positioned.fill(
            child: TextField(
              key: const Key('otp-field'),
              controller: controller,
              keyboardType: TextInputType.number,
              maxLength: 6,
              showCursor: false,
              enableInteractiveSelection: false,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: const TextStyle(color: Colors.transparent, fontSize: 1),
              decoration: const InputDecoration(
                counterText: '',
                isCollapsed: true,
                filled: true,
                fillColor: Colors.transparent,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
              ),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class _GoldButton extends StatelessWidget {
  const _GoldButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: colors.gold,
          disabledBackgroundColor: colors.card,
          foregroundColor: colors.onGold,
          disabledForegroundColor: colors.muted,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(NightOutRadius.base)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (loading) ...[
              if (reduceMotion)
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: colors.goldText, width: 2),
                  ),
                )
              else
                LoadWidget(colors: [colors.goldText], size: 18, strokeWidth: 2),
              const SizedBox(width: 10),
            ],
            Text(label),
          ],
        ),
      ),
    );
  }
}
