import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'demo@kainatledger.com');
  final _passwordController = TextEditingController(text: 'Password123');
  bool _obscurePassword = true;
  bool _rememberMe = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(authProvider.notifier).login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

    if (success && mounted) {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFEDF5FD),
      body: Stack(
        children: [
          // 1. Ambient Glass Decorative Elements (Background)
          // Top Left Luminous Azure-Indigo Sphere
          Positioned(
            top: -80,
            left: -60,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF3B82F6).withValues(alpha: 0.35),
                    const Color(0xFF6366F1).withValues(alpha: 0.18),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Center Right Electric Cyan Ambient Glow (intersects right behind the form)
          Positioned(
            top: 180,
            right: -80,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF06B6D4).withValues(alpha: 0.32),
                    const Color(0xFF38BDF8).withValues(alpha: 0.14),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Center Left Soft Purple Glow
          Positioned(
            top: 360,
            left: -70,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF8B5CF6).withValues(alpha: 0.22),
                    const Color(0xFFA855F7).withValues(alpha: 0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Bottom Luminous Royal Blue Sphere
          Positioned(
            bottom: -70,
            right: 10,
            child: Container(
              width: 320,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF2563EB).withValues(alpha: 0.26),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // 2. Main Login Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Central 3D Glass Logo Card: K + Dompet Emblem
                      ClipRRect(
                        borderRadius: BorderRadius.circular(32),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                          child: Container(
                            width: 104,
                            height: 104,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.white.withValues(alpha: 0.65),
                                  Colors.white.withValues(alpha: 0.35),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(32),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.90),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF2563EB).withValues(alpha: 0.18),
                                  blurRadius: 28,
                                  offset: const Offset(0, 10),
                                ),
                                BoxShadow(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  blurRadius: 2,
                                  offset: const Offset(0, -1),
                                ),
                              ],
                            ),
                            child: Center(
                              child: CustomPaint(
                                size: const Size(64, 64),
                                painter: _KainatWalletLogoPainter(),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const Gap(24),

                      // 4. Headline Titles
                      const Text(
                        'Welcome Back',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                          letterSpacing: -0.6,
                        ),
                      ),
                      const Gap(4),
                      const Text(
                        'Sign in to continue',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const Gap(28),

                      // 5. Glassmorphic Form Card
                      ClipRRect(
                        borderRadius: BorderRadius.circular(32),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 26),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.white.withValues(alpha: 0.48),
                                  Colors.white.withValues(alpha: 0.22),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(32),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.85),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF1E293B).withValues(alpha: 0.10),
                                  blurRadius: 36,
                                  offset: const Offset(0, 16),
                                  spreadRadius: -4,
                                ),
                                BoxShadow(
                                  color: const Color(0xFF3B82F6).withValues(alpha: 0.08),
                                  blurRadius: 20,
                                  offset: const Offset(0, 6),
                                ),
                                BoxShadow(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  blurRadius: 2,
                                  offset: const Offset(0, -1),
                                ),
                              ],
                            ),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  // Username / Email Glass Pill Input
                                  _GlassPillInput(
                                    controller: _emailController,
                                    hintText: 'Username or Email',
                                    prefixIcon: Icons.person_outline,
                                    keyboardType: TextInputType.emailAddress,
                                    validator: (val) {
                                      if (val == null || val.trim().isEmpty) {
                                        return 'Email tidak boleh kosong';
                                      }
                                      return null;
                                    },
                                  ),
                                  const Gap(16),

                                  // Password Glass Pill Input
                                  _GlassPillInput(
                                    controller: _passwordController,
                                    hintText: 'Password',
                                    prefixIcon: Icons.lock_outline,
                                    obscureText: _obscurePassword,
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                        size: 20,
                                        color: const Color(0xFF94A3B8),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        });
                                      },
                                    ),
                                    validator: (val) {
                                      if (val == null || val.isEmpty) {
                                        return 'Password tidak boleh kosong';
                                      }
                                      return null;
                                    },
                                  ),
                                  const Gap(16),

                                  // Remember Me & Forgot Password
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          SizedBox(
                                            width: 22,
                                            height: 22,
                                            child: Checkbox(
                                              value: _rememberMe,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              activeColor: const Color(0xFF2563EB),
                                              onChanged: (val) {
                                                setState(() {
                                                  _rememberMe = val ?? true;
                                                });
                                              },
                                            ),
                                          ),
                                          const Gap(8),
                                          const Text(
                                            'Remember Me',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                              color: Color(0xFF334155),
                                            ),
                                          ),
                                        ],
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Kredensial demo: demo@kainatledger.com / Password123'),
                                            ),
                                          );
                                        },
                                        child: const Text(
                                          'Forgot Password?',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF2563EB),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Gap(20),

                                  // Glowing Gradient Pill Login Button
                                  _GlowingLoginButton(
                                    isLoading: authState.status == AuthStatus.loading,
                                    onPressed: _handleLogin,
                                  ),
                                  const Gap(20),

                                  // Register option (Clean auth navigation)
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        "Belum punya akun? ",
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF64748B),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () => context.go('/register'),
                                        borderRadius: BorderRadius.circular(8),
                                        child: const Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                                          child: Text(
                                            'Daftar Sekarang',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFF2563EB),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _KainatWalletLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Left Vertical Spine of K (Wallet Hinge / Card Spine)
    final spineRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.16, h * 0.14, w * 0.22, h * 0.72),
      const Radius.circular(8),
    );
    final spinePaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF1E3A8A),
          Color(0xFF2563EB),
          Color(0xFF4F46E5),
        ],
      ).createShader(Rect.fromLTWH(w * 0.16, h * 0.14, w * 0.22, h * 0.72));

    // Spine stitch line
    final stitchPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.45)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // 2. Upper Diagonal Arm of K (Card Eject / Wallet Credit Card)
    final upperCardPath = Path();
    upperCardPath.moveTo(w * 0.36, h * 0.48);
    upperCardPath.lineTo(w * 0.65, h * 0.20);
    upperCardPath.quadraticBezierTo(w * 0.72, h * 0.14, w * 0.78, h * 0.20);
    upperCardPath.lineTo(w * 0.84, h * 0.26);
    upperCardPath.quadraticBezierTo(w * 0.88, h * 0.32, w * 0.82, h * 0.38);
    upperCardPath.lineTo(w * 0.52, h * 0.62);
    upperCardPath.close();

    final cardPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF0284C7),
          Color(0xFF38BDF8),
        ],
      ).createShader(Rect.fromLTWH(w * 0.36, h * 0.14, w * 0.52, h * 0.48));

    // Card chip accent
    final chipPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;

    // 3. Lower Diagonal Leg of K (Wallet Leather Flap / Pocket)
    final lowerFlapPath = Path();
    lowerFlapPath.moveTo(w * 0.36, h * 0.52);
    lowerFlapPath.lineTo(w * 0.55, h * 0.42);
    lowerFlapPath.lineTo(w * 0.78, h * 0.70);
    lowerFlapPath.quadraticBezierTo(w * 0.84, h * 0.76, w * 0.78, h * 0.84);
    lowerFlapPath.lineTo(w * 0.72, h * 0.88);
    lowerFlapPath.quadraticBezierTo(w * 0.65, h * 0.92, w * 0.58, h * 0.84);
    lowerFlapPath.close();

    final flapPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF4338CA),
          Color(0xFF6366F1),
        ],
      ).createShader(Rect.fromLTWH(w * 0.36, h * 0.42, w * 0.48, h * 0.50));

    // 4. Center Gold Ledger Coin / Clasp
    final coinPaint = Paint()
      ..shader = const RadialGradient(
        colors: [
          Color(0xFFFEF08A),
          Color(0xFFF59E0B),
          Color(0xFFD97706),
        ],
      ).createShader(Rect.fromCircle(center: Offset(w * 0.45, h * 0.50), radius: w * 0.10));

    final coinBorder = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final starPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Draw elements
    canvas.drawRRect(spineRect, spinePaint);
    canvas.drawLine(Offset(w * 0.22, h * 0.22), Offset(w * 0.22, h * 0.78), stitchPaint);

    canvas.drawPath(upperCardPath, cardPaint);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.62, h * 0.24, w * 0.10, h * 0.08),
        const Radius.circular(2),
      ),
      chipPaint,
    );

    canvas.drawPath(lowerFlapPath, flapPaint);

    // Coin at junction
    canvas.drawCircle(Offset(w * 0.45, h * 0.50), w * 0.09, coinPaint);
    canvas.drawCircle(Offset(w * 0.45, h * 0.50), w * 0.09, coinBorder);

    // Mini sparkle inside coin
    final starPath = Path();
    starPath.moveTo(w * 0.45, h * 0.45);
    starPath.lineTo(w * 0.46, h * 0.49);
    starPath.lineTo(w * 0.50, h * 0.50);
    starPath.lineTo(w * 0.46, h * 0.51);
    starPath.lineTo(w * 0.45, h * 0.55);
    starPath.lineTo(w * 0.44, h * 0.51);
    starPath.lineTo(w * 0.40, h * 0.50);
    starPath.lineTo(w * 0.44, h * 0.49);
    starPath.close();
    canvas.drawPath(starPath, starPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _GlassPillInput extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const _GlassPillInput({
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  State<_GlassPillInput> createState() => _GlassPillInputState();
}

class _GlassPillInputState extends State<_GlassPillInput> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: _isFocused
            ? Colors.white.withValues(alpha: 0.65)
            : Colors.white.withValues(alpha: 0.40),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: _isFocused
              ? const Color(0xFF3B82F6).withValues(alpha: 0.85)
              : Colors.white.withValues(alpha: 0.80),
          width: _isFocused ? 1.6 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: _isFocused
                ? const Color(0xFF3B82F6).withValues(alpha: 0.15)
                : const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: _isFocused ? 16 : 10,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.7),
            blurRadius: 1,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: TextFormField(
        focusNode: _focusNode,
        controller: widget.controller,
        obscureText: widget.obscureText,
        keyboardType: widget.keyboardType,
        validator: widget.validator,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF0F172A),
        ),
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Color(0xFF64748B),
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 18, right: 12),
            child: Icon(
              widget.prefixIcon,
              size: 20,
              color: _isFocused ? const Color(0xFF2563EB) : const Color(0xFF64748B),
            ),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 48),
          suffixIcon: widget.suffixIcon != null
              ? Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: widget.suffixIcon,
                )
              : null,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }
}

class _GlowingLoginButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const _GlowingLoginButton({
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 54,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xFF3B82F6),
            Color(0xFF1D4ED8),
          ],
        ),
        borderRadius: BorderRadius.circular(35),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withValues(alpha: 0.45),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(35),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 36), // Balanced spacer
                isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                    size: 18,
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
