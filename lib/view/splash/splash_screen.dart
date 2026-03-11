import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:math' as math;
import 'package:spend_wise/config/color/colors.dart';
import 'package:spend_wise/config/components/textwidgets.dart';
import 'package:spend_wise/viewModel/bloc/theme/theme_bloc.dart';
import '../../config/routes/route_names.dart';
import '../../viewModel/bloc/auth_state/auth_bloc.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {

  late AnimationController _masterController;
  late AnimationController _floatController;
  late AnimationController _shimmerController;
  late AnimationController _particleController;

  // Wallet
  late Animation<double> _walletReveal;
  late Animation<double> _walletRotate;

  // Arrows
  late Animation<double> _incomeArrow;
  late Animation<double> _expenseArrow;
  late Animation<double> _arrowGlow;

  // Text
  late Animation<double> _textReveal;

  // Ambient
  late Animation<double> _float;
  late Animation<double> _shimmer;
  late Animation<double> _particle;

  @override
  void initState() {
    super.initState();

    context.read<AuthBloc>().add(AuthCheckRequested());

    _masterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat(reverse: true);

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..repeat();

    _walletReveal = CurvedAnimation(
      parent: _masterController,
      curve: const Interval(0.0, 0.45, curve: Curves.elasticOut),
    );

    _walletRotate = Tween<double>(begin: -0.15, end: 0.0).animate(
      CurvedAnimation(
        parent: _masterController,
        curve: const Interval(0.0, 0.45, curve: Curves.easeOutCubic),
      ),
    );

    _incomeArrow = CurvedAnimation(
      parent: _masterController,
      curve: const Interval(0.4, 0.72, curve: Curves.elasticOut),
    );

    _expenseArrow = CurvedAnimation(
      parent: _masterController,
      curve: const Interval(0.52, 0.85, curve: Curves.elasticOut),
    );

    _arrowGlow = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _masterController,
        curve: const Interval(0.55, 1.0, curve: Curves.easeOut),
      ),
    );

    _textReveal = CurvedAnimation(
      parent: _masterController,
      curve: const Interval(0.72, 1.0, curve: Curves.easeOutCubic),
    );

    _float = Tween<double>(begin: -8.0, end: 8.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _shimmer = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );

    _particle = _particleController;

    _masterController.forward();

    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) Navigator.pushReplacementNamed(context, RouteNames.authNavigator);
    });
  }

  @override
  void dispose() {
    _masterController.dispose();
    _floatController.dispose();
    _shimmerController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return BlocBuilder<ThemeBloc,ThemeState>(
      builder: (context, state){
        final primary = state.theme[appColors.primaryColor]!;
        final accent = state.theme[appColors.accentColor]!;
        final income = state.theme[appColors.incomeColor]!;
        final expense = state.theme[appColors.expenseColor]!;
        final bg = state.theme[appColors.appBGColor]!;

        return Scaffold(
          backgroundColor: bg,
          body: Stack(
            children: [
              // Mesh gradient background
              Positioned.fill(
                child: CustomPaint(
                  painter: _BackgroundPainter(primary: primary, accent: accent),
                ),
              ),

              // Floating particles
              AnimatedBuilder(
                animation: _particle,
                builder: (context, _) => CustomPaint(
                  size: size,
                  painter: _ParticlePainter(
                    progress: _particle.value,
                    primary: primary,
                    income: income,
                    expense: expense,
                  ),
                ),
              ),

              // Main content
              Center(
                child: AnimatedBuilder(
                  animation: Listenable.merge([
                    _masterController,
                    _floatController,
                    _shimmerController,
                  ]),
                  builder: (context, _) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Central composition
                        Transform.translate(
                          offset: Offset(0, _float.value),
                          child: SizedBox(
                            width: 280,
                            height: 220,
                            child: Stack(
                              clipBehavior: Clip.none,
                              alignment: Alignment.center,
                              children: [

                                // Soft shadow beneath
                                Positioned(
                                  bottom: 10,
                                  child: Transform.scale(
                                    scaleX: _walletReveal.value,
                                    child: Container(
                                      width: 140,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(50),
                                        boxShadow: [
                                          BoxShadow(
                                            color: primary.withOpacity(0.3),
                                            blurRadius: 30,
                                            spreadRadius: 5,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                                // Wallet
                                Transform.rotate(
                                  angle: _walletRotate.value,
                                  child: Transform.scale(
                                    scale: _walletReveal.value,
                                    child: CustomPaint(
                                      size: const Size(150, 110),
                                      painter: _WalletPainter(
                                        primary: primary,
                                        accent: accent,
                                        shimmer: _shimmer.value,
                                      ),
                                    ),
                                  ),
                                ),

                                // Income arrow — top right
                                Positioned(
                                  top: 14,
                                  right: 0,
                                  child: Transform.scale(
                                    scale: _incomeArrow.value,
                                    alignment: Alignment.centerLeft,
                                    child: _IncomeExpenseCard(
                                      isIncome: true,
                                      color: income,
                                      glow: _arrowGlow.value,
                                    ),
                                  ),
                                ),

                                // Expense arrow — bottom left
                                Positioned(
                                  bottom: 14,
                                  left: 0,
                                  child: Transform.scale(
                                    scale: _expenseArrow.value,
                                    alignment: Alignment.centerRight,
                                    child: _IncomeExpenseCard(
                                      isIncome: false,
                                      color: expense,
                                      glow: _arrowGlow.value,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 52),

                        // App name
                        Opacity(
                          opacity: _textReveal.value,
                          child: Transform.translate(
                            offset: Offset(0, 20 * (1 - _textReveal.value)),
                            child: Column(
                              children: [
                                ShaderMask(
                                  shaderCallback: (bounds) => LinearGradient(
                                    colors: [primary, accent],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ).createShader(bounds),
                                  child: const Text(
                                    'SpendWise',
                                    style: TextStyle(
                                      fontSize: 38,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                AppText(
                                  'YOUR MONEY. YOUR CONTROL.',
                                  color: primary.withOpacity(0.45),
                                  type: TextType.transactionAmount,
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );

      }
    );

  }
}

// Custom Wallet Painter

class _WalletPainter extends CustomPainter {
  final Color primary;
  final Color accent;
  final double shimmer;

  _WalletPainter({required this.primary, required this.accent, required this.shimmer});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final r = Radius.circular(18);

    // === WALLET BODY ===
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, h * 0.15, w, h * 0.85),
      r,
    );

    final bodyPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Color.lerp(primary, Colors.white, 0.15)!,
          primary,
          Color.lerp(primary, Colors.black, 0.2)!,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(bodyRect.outerRect);

    canvas.drawRRect(bodyRect, bodyPaint);

    // Inner shadow top edge
    final innerShadow = Paint()
      ..shader = LinearGradient(
        colors: [Colors.black.withOpacity(0.18), Colors.transparent],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, h * 0.15, w, 22));
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(0, h * 0.15, w, 22),
        topLeft: r,
        topRight: r,
      ),
      innerShadow,
    );

    // === FLAP (top fold) ===
    final flapRect = RRect.fromRectAndCorners(
      Rect.fromLTWH(0, 0, w, h * 0.38),
      topLeft: r,
      topRight: r,
      bottomLeft: Radius.zero,
      bottomRight: Radius.zero,
    );
    final flapPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Color.lerp(primary, Colors.white, 0.28)!,
          Color.lerp(primary, Colors.white, 0.08)!,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(flapRect.outerRect);
    canvas.drawRRect(flapRect, flapPaint);

    // Flap bottom fold line
    final foldPaint = Paint()
      ..color = Colors.black.withOpacity(0.12)
      ..strokeWidth = 1.2;
    canvas.drawLine(Offset(0, h * 0.38), Offset(w, h * 0.38), foldPaint);

    // Flap sheen
    final sheenPaint = Paint()
      ..shader = LinearGradient(
        colors: [Colors.transparent, Colors.white.withOpacity(0.18), Colors.transparent],
        stops: const [0.0, 0.5, 1.0],
        begin: Alignment(shimmer - 1, -1),
        end: Alignment(shimmer, 1),
      ).createShader(flapRect.outerRect);
    canvas.drawRRect(flapRect, sheenPaint);

    // === CARD SLOT (horizontal band) ===
    final slotRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.1, h * 0.52, w * 0.8, h * 0.22),
      const Radius.circular(8),
    );
    final slotPaint = Paint()
      ..color = Colors.black.withOpacity(0.18);
    canvas.drawRRect(slotRect, slotPaint);

    // Card peeking out
    final cardRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.12, h * 0.48, w * 0.56, h * 0.2),
      const Radius.circular(6),
    );
    final cardPaint = Paint()
      ..shader = LinearGradient(
        colors: [accent, Color.lerp(accent, Colors.orange, 0.4)!],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(cardRect.outerRect);
    canvas.drawRRect(cardRect, cardPaint);

    // Card chip
    final chipRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.16, h * 0.52, w * 0.12, h * 0.1),
      const Radius.circular(2),
    );
    canvas.drawRRect(chipRect, Paint()..color = Colors.white.withOpacity(0.7));

    // === CLASP / BUTTON ===
    final claspCenter = Offset(w * 0.5, h * 0.175);
    canvas.drawCircle(
      claspCenter,
      9,
      Paint()..color = Colors.black.withOpacity(0.2),
    );
    canvas.drawCircle(
      claspCenter,
      7,
      Paint()
        ..shader = RadialGradient(
          colors: [accent.withOpacity(0.9), Color.lerp(accent, Colors.brown, 0.3)!],
        ).createShader(Rect.fromCircle(center: claspCenter, radius: 7)),
    );
    canvas.drawCircle(
      claspCenter,
      3,
      Paint()..color = Colors.white.withOpacity(0.5),
    );

    // === STITCHING ===
    final stitchPaint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final dashW = 5.0;
    final gap = 4.0;
    double x = w * 0.06;
    while (x < w * 0.94) {
      canvas.drawLine(Offset(x, h * 0.22), Offset(x + dashW, h * 0.22), stitchPaint);
      x += dashW + gap;
    }
  }

  @override
  bool shouldRepaint(_WalletPainter old) => old.shimmer != shimmer;
}

// ── Income / Expense Card

class _IncomeExpenseCard extends StatelessWidget {
  final bool isIncome;
  final Color color;
  final double glow;

  const _IncomeExpenseCard({
    required this.isIncome,
    required this.color,
    required this.glow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.35 * glow),
            blurRadius: 20,
            spreadRadius: 3,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withOpacity(0.15), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon container
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: CustomPaint(
                  painter: _ArrowPainter(isIncome: isIncome, color: color),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isIncome ? 'Income' : 'Expense',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[500],
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isIncome ? '+Rs 2,450' : '-Rs 840',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: color,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Arrow Painter

class _ArrowPainter extends CustomPainter {
  final bool isIncome;
  final Color color;

  _ArrowPainter({required this.isIncome, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    if (isIncome) {
      // Arrow pointing up-right
      final path = Path()
        ..moveTo(cx - 7, cy + 6)
        ..lineTo(cx + 7, cy - 6)
        ..moveTo(cx + 7, cy - 6)
        ..lineTo(cx + 1, cy - 6)
        ..moveTo(cx + 7, cy - 6)
        ..lineTo(cx + 7, cy);
      canvas.drawPath(path, paint);
      // Dot
      canvas.drawCircle(
        Offset(cx - 8, cy + 7),
        2,
        Paint()..color = color.withOpacity(0.5),
      );
    } else {
      // Arrow pointing down-left
      final path = Path()
        ..moveTo(cx + 7, cy - 6)
        ..lineTo(cx - 7, cy + 6)
        ..moveTo(cx - 7, cy + 6)
        ..lineTo(cx - 1, cy + 6)
        ..moveTo(cx - 7, cy + 6)
        ..lineTo(cx - 7, cy);
      canvas.drawPath(path, paint);
      canvas.drawCircle(
        Offset(cx + 8, cy - 7),
        2,
        Paint()..color = color.withOpacity(0.5),
      );
    }
  }

  @override
  bool shouldRepaint(_ArrowPainter old) => false;
}

// Background Painter

class _BackgroundPainter extends CustomPainter {
  final Color primary;
  final Color accent;

  _BackgroundPainter({required this.primary, required this.accent});

  @override
  void paint(Canvas canvas, Size size) {
    // Base
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0xFFF0F2F8),
    );

    // Top blob
    final topBlob = Paint()
      ..shader = RadialGradient(
        colors: [primary.withOpacity(0.12), Colors.transparent],
        radius: 0.8,
      ).createShader(Rect.fromLTWH(-size.width * 0.3, -size.height * 0.2,
          size.width * 1.2, size.height * 0.8));
    canvas.drawOval(
      Rect.fromLTWH(-size.width * 0.1, -size.height * 0.15,
          size.width * 0.8, size.height * 0.5),
      topBlob,
    );

    // Bottom blob
    final bottomBlob = Paint()
      ..shader = RadialGradient(
        colors: [accent.withOpacity(0.09), Colors.transparent],
      ).createShader(Rect.fromLTWH(size.width * 0.2, size.height * 0.6,
          size.width * 0.9, size.height * 0.6));
    canvas.drawOval(
      Rect.fromLTWH(size.width * 0.3, size.height * 0.65,
          size.width * 0.9, size.height * 0.5),
      bottomBlob,
    );
  }

  @override
  bool shouldRepaint(_BackgroundPainter old) => false;
}

// Particle Painter

class _ParticlePainter extends CustomPainter {
  final double progress;
  final Color primary;
  final Color income;
  final Color expense;

  static final List<_Particle> _particles = List.generate(18, (i) {
    final rng = math.Random(i * 37);
    return _Particle(
      x: rng.nextDouble(),
      y: rng.nextDouble(),
      radius: 2.0 + rng.nextDouble() * 3,
      speed: 0.15 + rng.nextDouble() * 0.35,
      phase: rng.nextDouble(),
      colorIndex: i % 3,
    );
  });

  _ParticlePainter({
    required this.progress,
    required this.primary,
    required this.income,
    required this.expense,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in _particles) {
      final t = ((progress * p.speed + p.phase) % 1.0);
      final opacity = math.sin(t * math.pi) * 0.35;
      final y = (p.y - t * 0.4) % 1.0;
      final color = [primary, income, expense][p.colorIndex].withOpacity(opacity);
      canvas.drawCircle(
        Offset(p.x * size.width, y * size.height),
        p.radius,
        Paint()..color = color,
      );
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => old.progress != progress;
}

class _Particle {
  final double x, y, radius, speed, phase;
  final int colorIndex;
  _Particle({
    required this.x,
    required this.y,
    required this.radius,
    required this.speed,
    required this.phase,
    required this.colorIndex,
  });
}