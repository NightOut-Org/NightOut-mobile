import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nightout/config.dart';
import 'package:nightout/extensions/context.extension.dart';
import 'package:nightout/modules/controller/auth.ctrl.dart';
import 'package:nightout/router/app.router.dart';
import 'package:nightout_core/nightout_core.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Web `authModal.tsx` (login view) + `authLoginForm.tsx`, email/password only.
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  static final _emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  /// The web renders the auth modal with antd's dark algorithm in both themes,
  /// so everything on the card resolves dark tokens.
  static final _cardTheme = nightOutTheme(Brightness.dark);

  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;
  bool _busy = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_busy || !_form.currentState!.validate()) return;
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _busy = true);
    try {
      await ref.read(customerAuthProvider.notifier).signIn(_email.text.trim(), _password.text);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final glass = context.authColors;
    final auth = ref.watch(customerAuthProvider);
    final error = auth is CustomerSignedOut ? auth.error : null;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: Theme.of(context).appBarTheme.systemOverlayStyle!,
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        behavior: HitTestBehavior.translucent,
        child: Scaffold(
          backgroundColor: colors.background,
          body: Theme(
            data: _cardTheme,
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16 + context.maxWidthPadding,
                    vertical: 24,
                  ),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      // CSS linear-gradient(160deg, …).
                      gradient: LinearGradient(
                        begin: const Alignment(-0.36, -1),
                        end: const Alignment(0.36, 1),
                        colors: [glass.glassFrom, glass.glassTo],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: glass.glassBorder),
                      boxShadow: glass.glassShadow,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 28, 24, 26),
                      child: Form(
                        key: _form,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            GradientTitle(Config.appname, textAlign: TextAlign.center),
                            const SizedBox(height: 20),
                            Text(
                              'ยินดีต้อนรับกลับ',
                              textAlign: TextAlign.center,
                              style: NightOutText.sans(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: glass.onGlass,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'เข้าสู่ระบบเพื่อจองโต๊ะและดูรีวิวจากคนที่ไปจริง',
                              textAlign: TextAlign.center,
                              style: NightOutText.sans(fontSize: 12, color: glass.onGlassMuted),
                            ),
                            const SizedBox(height: 24),
                            _GlassField(
                              key: const Key('email-field'),
                              label: 'อีเมล',
                              controller: _email,
                              icon: PhosphorIconsRegular.envelopeSimple,
                              hint: 'you@email.com',
                              keyboardType: TextInputType.emailAddress,
                              autofillHints: const [AutofillHints.email],
                              textInputAction: TextInputAction.next,
                              validator: (value) =>
                                  _emailPattern.hasMatch(value?.trim() ?? '') ? null : 'กรอกอีเมลให้ถูกต้อง',
                            ),
                            const SizedBox(height: 16),
                            _GlassField(
                              key: const Key('password-field'),
                              label: 'รหัสผ่าน',
                              controller: _password,
                              icon: PhosphorIconsRegular.lock,
                              hint: 'กรอกรหัสผ่านของคุณ',
                              obscureText: _obscure,
                              autofillHints: const [AutofillHints.password],
                              textInputAction: TextInputAction.done,
                              onSubmitted: (_) => _submit(),
                              validator: (value) => (value ?? '').isEmpty ? 'กรอกรหัสผ่าน' : null,
                              suffix: IconButton(
                                tooltip: _obscure ? 'แสดงรหัสผ่าน' : 'ซ่อนรหัสผ่าน',
                                onPressed: () => setState(() => _obscure = !_obscure),
                                icon: PhosphorIcon(
                                  _obscure ? PhosphorIconsRegular.eyeSlash : PhosphorIconsRegular.eye,
                                  size: 18,
                                  color: glass.onGlassMuted,
                                ),
                              ),
                            ),
                            if (error != null) ...[
                              const SizedBox(height: 16),
                              _ErrorBanner(error),
                            ],
                            const SizedBox(height: 20),
                            _GoldButton(
                              label: 'เข้าสู่ระบบ',
                              loading: _busy,
                              onPressed: _submit,
                            ),
                            const SizedBox(height: 24),
                            const _RegisterLink(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RegisterLink extends StatelessWidget {
  const _RegisterLink();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'ยังไม่มีบัญชี ? ',
          style: NightOutText.sans(fontSize: 12, color: context.authColors.onGlassMuted),
        ),
        GestureDetector(
          onTap: () => context.push(AppRoutes.register),
          child: Text(
            'สมัครสมาชิก',
            style: NightOutText.sans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: context.colors.purple,
            ),
          ),
        ),
      ],
    );
  }
}

/// Web `.auth-modal .ant-input-affix-wrapper`: borderless dark fill, purple on focus.
class _GlassField extends StatelessWidget {
  const _GlassField({
    super.key,
    required this.label,
    required this.controller,
    required this.icon,
    required this.hint,
    required this.validator,
    this.suffix,
    this.obscureText = false,
    this.keyboardType,
    this.autofillHints,
    this.textInputAction,
    this.onSubmitted,
  });

  final String label;
  final TextEditingController controller;
  final IconData icon;
  final String hint;
  final FormFieldValidator<String> validator;
  final Widget? suffix;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Iterable<String>? autofillHints;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final glass = context.authColors;
    final radius = BorderRadius.circular(12);
    OutlineInputBorder border(Color color) => OutlineInputBorder(
      borderRadius: radius,
      borderSide: BorderSide(color: color),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text(
            label,
            style: NightOutText.sans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: glass.onGlass,
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          autofillHints: autofillHints,
          textInputAction: textInputAction,
          onFieldSubmitted: onSubmitted,
          validator: validator,
          cursorColor: glass.fieldFocusBorder,
          style: NightOutText.sans(fontSize: 15, color: glass.onGlass),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: NightOutText.sans(fontSize: 15, color: glass.placeholder),
            errorStyle: NightOutText.sans(fontSize: 12, color: colors.crowdFull),
            filled: true,
            fillColor: WidgetStateColor.resolveWith(
              (states) => states.contains(WidgetState.focused) ? glass.fieldFocusFill : glass.fieldFill,
            ),
            prefixIcon: PhosphorIcon(icon, size: 18, color: glass.onGlassMuted),
            suffixIcon: suffix,
            enabledBorder: OutlineInputBorder(borderRadius: radius, borderSide: BorderSide.none),
            focusedBorder: border(glass.fieldFocusBorder),
            errorBorder: border(colors.crowdFull),
            focusedErrorBorder: border(colors.crowdFull),
          ),
        ),
      ],
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.crowdFull.withValues(alpha: NightOutAlpha.subtle),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.crowdFull),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Text(
          message,
          style: NightOutText.sans(fontSize: 13, color: colors.crowdFull),
        ),
      ),
    );
  }
}

/// Web `.auth-modal .btn-gold`.
class _GoldButton extends StatelessWidget {
  const _GoldButton({
    required this.label,
    required this.loading,
    required this.onPressed,
  });

  final String label;
  final bool loading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final glass = context.authColors;
    final radius = BorderRadius.circular(12);

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [glass.buttonFrom, glass.buttonTo],
        ),
        borderRadius: radius,
        boxShadow: glass.buttonShadow,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          key: const Key('login-submit'),
          borderRadius: radius,
          onTap: loading ? null : onPressed,
          child: SizedBox(
            height: 46,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (loading) ...[
                  LoadWidget(colors: [glass.buttonLabel], size: 18, strokeWidth: 2),
                  const SizedBox(width: 10),
                ],
                Text(
                  label,
                  style: NightOutText.sans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: glass.buttonLabel,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
