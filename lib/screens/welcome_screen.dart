import 'dart:math' show pi, sin, cos;
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/reader_provider.dart';

const _coral = Color(0xFFFF5A4E);
const _coralDeep = Color(0xFFE8362A);
const _sun = Color(0xFFFFD23F);
const _violet = Color(0xFF7C5CFF);
const _ink = Color(0xFF1E1B2E);
const _cream = Color(0xFFFFF6EC);
const _muted = Color(0xFF8A8398);

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  String? _bookPath;
  Uint8List? _bookBytes;
  String? _bookName;
  String? _musicPath;
  Uint8List? _musicBytes;
  String? _musicName;
  bool _isLoading = false;

  late final AnimationController _floatCtrl;
  late final AnimationController _entranceCtrl;
  late final AnimationController _shimmerCtrl;
  late final AnimationController _pulseCtrl;

  bool get _bookReady => kIsWeb ? _bookBytes != null : _bookPath != null;

  @override
  void initState() {
    super.initState();
    _floatCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 20))
      ..repeat();
    _entranceCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400));
    _shimmerCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 4))
      ..repeat();
    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400))
      ..repeat(reverse: true);
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _entranceCtrl.forward());
  }

  @override
  void dispose() {
    _floatCtrl.dispose();
    _entranceCtrl.dispose();
    _shimmerCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickBook() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt'],
      withData: kIsWeb,
    );
    if (result == null) return;
    final file = result.files.single;
    setState(() {
      _bookName = file.name;
      if (kIsWeb) {
        _bookBytes = file.bytes;
        _bookPath = null;
      } else {
        _bookPath = file.path;
        _bookBytes = null;
      }
    });
  }

  Future<void> _pickMusic() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      withData: kIsWeb,
    );
    if (result == null) return;
    final file = result.files.single;
    setState(() {
      _musicName = file.name;
      if (kIsWeb) {
        _musicBytes = file.bytes;
        _musicPath = null;
      } else {
        _musicPath = file.path;
        _musicBytes = null;
      }
    });
  }

  Future<void> _startReading() async {
    if (!_bookReady) return;
    setState(() => _isLoading = true);
    final provider = context.read<ReaderProvider>();
    if (kIsWeb) {
      await provider.loadBookFromBytes(_bookBytes!, _bookName!);
    } else {
      await provider.loadBookFromPath(_bookPath!, _bookName!);
    }
    bool musicOk = true;
    if (kIsWeb && _musicBytes != null) {
      musicOk = await provider.loadMusicFromBytes(_musicBytes!);
    } else if (!kIsWeb && _musicPath != null) {
      musicOk = await provider.loadMusic(_musicPath!);
    }
    if (!musicOk && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('音频加载失败，请使用 mp3/flac/wav 等标准格式'),
          backgroundColor: _ink,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Widget _entrance({
    required int index,
    required Widget child,
    double offsetY = 24,
  }) {
    final start = index * 0.10;
    final end = (start + 0.55).clamp(0.0, 1.0);
    final curve = CurvedAnimation(
      parent: _entranceCtrl,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );
    return AnimatedBuilder(
      animation: curve,
      builder: (context, child) {
        final v = curve.value;
        return Opacity(
          opacity: v,
          child: Transform.translate(
              offset: Offset(0, offsetY * (1 - v)), child: child),
        );
      },
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cream,
      body: Stack(
        children: [
          _AnimatedBlobs(controller: _floatCtrl),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  _entrance(index: 0, child: _buildTopBar()),
                  const SizedBox(height: 18),
                  _entrance(
                    index: 1,
                    offsetY: 30,
                    child: _HeroSection(
                      floatCtrl: _floatCtrl,
                      shimmerCtrl: _shimmerCtrl,
                      pulseCtrl: _pulseCtrl,
                    ),
                  ),
                  const SizedBox(height: 28),
                  _entrance(
                    index: 2,
                    child: _UploadCard(
                      icon: Icons.book_outlined,
                      title: '选择小说文件',
                      subtitle: _bookName ?? '支持 .txt 格式',
                      accent: _coral,
                      isSelected: _bookReady,
                      onTap: _pickBook,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _entrance(
                    index: 3,
                    child: _UploadCard(
                      icon: Icons.music_note_outlined,
                      title: '添加背景音乐',
                      subtitle: _musicName ?? '可选 · 让阅读更有氛围',
                      accent: _violet,
                      isSelected:
                          kIsWeb ? _musicBytes != null : _musicPath != null,
                      onTap: _pickMusic,
                      optional: true,
                    ),
                  ),
                  const SizedBox(height: 22),
                  _entrance(index: 4, child: const _StatsStrip()),
                  const SizedBox(height: 22),
                  _entrance(
                    index: 5,
                    child: _BouncyButton(
                      onTap: _bookReady && !_isLoading ? _startReading : null,
                      isLoading: _isLoading,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _entrance(
                    index: 6,
                    child: const Center(
                      child: Text(
                        '数据全部存储在本地 · 隐私无忧',
                        style: TextStyle(
                            fontSize: 11, color: _muted, letterSpacing: 0.3),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(8, 6, 12, 6),
          decoration: BoxDecoration(
            color: _ink,
            borderRadius: BorderRadius.circular(100),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: _sun,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        color: _sun.withValues(alpha: 0.6), blurRadius: 10)
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                '书房',
                style: TextStyle(
                  color: _cream,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: _ink.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: const Icon(Icons.search_rounded, size: 18, color: _ink),
        ),
      ],
    );
  }
}

// ── Animated blob background ──────────────────────────────────────────────────

class _AnimatedBlobs extends StatelessWidget {
  final AnimationController controller;
  const _AnimatedBlobs({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) => CustomPaint(
        painter: _BlobPainter(t: controller.value),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _BlobPainter extends CustomPainter {
  final double t;
  _BlobPainter({required this.t});

  void _drawBlob(Canvas canvas, Size size, double cx, double cy, double r,
      Color color, double blur) {
    final paint = Paint()
      ..color = color
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, blur);
    canvas.drawCircle(
        Offset(cx * size.width, cy * size.height), r, paint);
  }

  @override
  void paint(Canvas canvas, Size size) {
    _drawBlob(canvas, size,
        -0.15 + sin(t * 2 * pi * 0.7) * 0.12,
        -0.06 + sin(t * 2 * pi * 0.7 + 0.5) * 0.10,
        140, const Color(0x60FFD23F), 50);
    _drawBlob(canvas, size,
        1.1 + sin(t * 2 * pi * 0.8 + 1.0) * 0.10,
        0.10 + sin(t * 2 * pi * 0.8) * 0.14,
        160, const Color(0x50FF5A4E), 50);
    _drawBlob(canvas, size,
        0.08 + sin(t * 2 * pi * 0.9 + 2.0) * 0.08,
        0.42 + sin(t * 2 * pi * 0.9) * 0.10,
        100, const Color(0x3D7C5CFF), 40);
    _drawBlob(canvas, size,
        0.92 + sin(t * 2 * pi * 1.0 + 3.0) * 0.10,
        0.74 + sin(t * 2 * pi * 1.0 + 1.0) * 0.10,
        120, const Color(0x403DDC97), 40);
    _drawBlob(canvas, size,
        0.18 + sin(t * 2 * pi * 1.1 + 4.0) * 0.08,
        0.88 + sin(t * 2 * pi * 1.1) * 0.06,
        90, const Color(0x35FFD23F), 40);
  }

  @override
  bool shouldRepaint(_BlobPainter old) => old.t != t;
}

// ── Hero section ──────────────────────────────────────────────────────────────

class _HeroSection extends StatelessWidget {
  final AnimationController floatCtrl;
  final AnimationController shimmerCtrl;
  final AnimationController pulseCtrl;

  const _HeroSection({
    required this.floatCtrl,
    required this.shimmerCtrl,
    required this.pulseCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _BookStack(controller: floatCtrl),
        const SizedBox(height: 18),
        _TagPill(pulseCtrl: pulseCtrl),
        const SizedBox(height: 14),
        _ShimmerHeadline(shimmerCtrl: shimmerCtrl),
        const SizedBox(height: 12),
        const Text(
          '上传你的小说，配上喜欢的音乐，开启沉浸式阅读',
          style: TextStyle(fontSize: 14, color: _muted, height: 1.5),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// ── Book stack illustration ───────────────────────────────────────────────────

class _BookStack extends StatelessWidget {
  final AnimationController controller;
  const _BookStack({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final t = controller.value;
        final yFloat = sin(t * 2 * pi * 0.25) * 8.0;
        final angle1 = (-4 + sin(t * 2 * pi * 1.0) * 2) * pi / 180;
        final angle2 = (8 + sin(t * 2 * pi * 20 / 14 + 1) * 2) * pi / 180;
        final angle3 = (-12 + sin(t * 2 * pi * 20 / 16 + 2) * 2) * pi / 180;
        final orbitAngle = t * 2 * pi * (20 / 30);

        return Transform.translate(
          offset: Offset(0, yFloat),
          child: SizedBox(
            width: 200,
            height: 200,
            child: Stack(
              children: [
                // Orbiting dots
                Transform.rotate(
                  angle: orbitAngle,
                  child: SizedBox(
                    width: 200,
                    height: 200,
                    child: Stack(
                      children: [
                        Positioned(
                            top: 0,
                            left: 95,
                            child: _Dot(color: _sun, size: 8)),
                        Positioned(
                            bottom: 0,
                            left: 35,
                            child: _Dot(
                                color: const Color(0xFF3DDC97), size: 8)),
                        Positioned(
                            top: 80,
                            right: 0,
                            child: _Dot(color: _violet, size: 8)),
                      ],
                    ),
                  ),
                ),
                // Book 3 – back, violet spine
                Positioned(
                  bottom: 24,
                  left: 56,
                  child: Transform.rotate(
                    angle: angle3,
                    child: _BookTile(
                        width: 100,
                        height: 140,
                        spineColor: _violet),
                  ),
                ),
                // Book 2 – middle, mint spine
                Positioned(
                  bottom: 16,
                  left: 28,
                  child: Transform.rotate(
                    angle: angle2,
                    child: _BookTile(
                        width: 110,
                        height: 150,
                        spineColor: const Color(0xFF3DDC97)),
                  ),
                ),
                // Book 1 – front hero
                Positioned(
                  bottom: 8,
                  left: 40,
                  child: Transform.rotate(
                    angle: angle1,
                    child: const _HeroBook(width: 120, height: 160),
                  ),
                ),
                // Sparkles
                Positioned(
                  top: 10,
                  right: 10,
                  child: _Sparkle(color: _sun, size: 20),
                ),
                Positioned(
                  bottom: 30,
                  left: 2,
                  child: _Sparkle(color: _coral, size: 14),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Dot extends StatelessWidget {
  final Color color;
  final double size;
  const _Dot({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _BookTile extends StatelessWidget {
  final double width;
  final double height;
  final Color spineColor;

  const _BookTile(
      {required this.width,
      required this.height,
      required this.spineColor});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: _ink.withValues(alpha: 0.18),
                blurRadius: 40,
                offset: const Offset(0, 20)),
            BoxShadow(
                color: _ink.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, 8)),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 8, color: spineColor),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 4,
                    width: width * 0.55,
                    decoration: BoxDecoration(
                      color: _ink.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 4,
                    width: width * 0.38,
                    decoration: BoxDecoration(
                      color: _ink.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroBook extends StatelessWidget {
  final double width;
  final double height;
  const _HeroBook({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [_coral, Color(0xFFFF8A6E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: _ink.withValues(alpha: 0.18),
                blurRadius: 40,
                offset: const Offset(0, 20)),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 8, color: _coralDeep),
            Expanded(
              child: Stack(
                children: [
                  // Bookmark ribbon
                  Positioned(
                    top: -2,
                    right: 18,
                    child: ClipPath(
                      clipper: _BookmarkClipper(),
                      child:
                          Container(width: 16, height: 36, color: _sun),
                    ),
                  ),
                  // Text
                  const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'READ',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 3,
                          ),
                        ),
                        Text(
                          'EVERY DAY',
                          style: TextStyle(
                            fontSize: 7,
                            fontWeight: FontWeight.w700,
                            color: Colors.white70,
                            letterSpacing: 3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookmarkClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path()
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width / 2, size.height * 0.8)
      ..lineTo(0, size.height)
      ..close();
  }

  @override
  bool shouldReclip(_) => false;
}

class _Sparkle extends StatelessWidget {
  final Color color;
  final double size;
  const _Sparkle({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _SparklePainter(color: color),
    );
  }
}

class _SparklePainter extends CustomPainter {
  final Color color;
  const _SparklePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final cx = size.width / 2;
    final cy = size.height / 2;
    final outer = size.width / 2;
    final inner = outer * 0.25;
    final path = Path();
    for (int i = 0; i < 8; i++) {
      final angle = i * pi / 4 - pi / 2;
      final r = i.isEven ? outer : inner;
      final x = cx + r * cos(angle);
      final y = cy + r * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_SparklePainter old) => old.color != color;
}

// ── Tag pill with pulse dot ───────────────────────────────────────────────────

class _TagPill extends StatelessWidget {
  final AnimationController pulseCtrl;
  const _TagPill({required this.pulseCtrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: _coral.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: pulseCtrl,
            builder: (context, _) {
              final scale = 0.6 + pulseCtrl.value * 0.6;
              final opacity = 1.0 - pulseCtrl.value * 0.6;
              return Transform.scale(
                scale: scale,
                child: Opacity(
                  opacity: opacity,
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                        color: _coral, shape: BoxShape.circle),
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
          const Text(
            '今日推荐 · 一万字治愈系小说',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: _coralDeep,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shimmer gradient headline ─────────────────────────────────────────────────

class _ShimmerHeadline extends StatelessWidget {
  final AnimationController shimmerCtrl;
  const _ShimmerHeadline({required this.shimmerCtrl});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          '翻开下一页，',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w900,
            color: _ink,
            height: 1.15,
            letterSpacing: -0.5,
          ),
          textAlign: TextAlign.center,
        ),
        AnimatedBuilder(
          animation: shimmerCtrl,
          builder: (context, child) {
            final t = shimmerCtrl.value;
            final x = -2.0 + t * 4.0;
            return ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                begin: Alignment(x, 0),
                end: Alignment(x + 1.5, 0),
                colors: const [_coral, _violet, _coral],
                stops: const [0, 0.5, 1],
                tileMode: TileMode.mirror,
              ).createShader(bounds),
              child: child,
            );
          },
          child: const Text(
            '遇见 不一样 的世界',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              height: 1.15,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

// ── Stats strip ───────────────────────────────────────────────────────────────

class _StatsStrip extends StatelessWidget {
  const _StatsStrip();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        _StatCard(n: '3.2k', label: '本地藏书', color: _coral),
        SizedBox(width: 10),
        _StatCard(n: '48h', label: '本月阅读', color: _violet),
        SizedBox(width: 10),
        _StatCard(n: '🔥 12', label: '连续天数', color: _sun),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String n;
  final String label;
  final Color color;

  const _StatCard(
      {required this.n, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: _ink.withValues(alpha: 0.05),
              blurRadius: 14,
              offset: const Offset(0, 4),
            )
          ],
          border:
              Border.all(color: _ink.withValues(alpha: 0.08), width: 1.5),
        ),
        child: Column(
          children: [
            Text(
              n,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: color,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                  fontSize: 10, color: _muted, letterSpacing: 0.4),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Upload card ───────────────────────────────────────────────────────────────

class _UploadCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color accent;
  final bool isSelected;
  final VoidCallback onTap;
  final bool optional;

  const _UploadCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.isSelected,
    required this.onTap,
    this.optional = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      curve: Curves.elasticOut,
      transform: Matrix4.translationValues(0, isSelected ? -2 : 0, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isSelected ? accent : Colors.transparent,
          width: 2,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                    color: accent.withValues(alpha: 0.20),
                    blurRadius: 30,
                    offset: const Offset(0, 14)),
                BoxShadow(
                    color: accent.withValues(alpha: 0.10),
                    spreadRadius: 4,
                    blurRadius: 0),
              ]
            : [
                BoxShadow(
                    color: _ink.withValues(alpha: 0.06),
                    blurRadius: 20,
                    offset: const Offset(0, 6)),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          splashColor: accent.withValues(alpha: 0.08),
          highlightColor: accent.withValues(alpha: 0.05),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? accent
                        : accent.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    icon,
                    size: 22,
                    color: isSelected ? Colors.white : accent,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: isSelected ? accent : _ink,
                            ),
                          ),
                          if (optional) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color:
                                    Colors.black.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                '可选',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: _muted,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style:
                            const TextStyle(fontSize: 12, color: _muted),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? accent
                        : Colors.black.withValues(alpha: 0.04),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isSelected ? Icons.check_rounded : Icons.add_rounded,
                    size: 14,
                    color: isSelected ? Colors.white : _muted,
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

// ── CTA button with shine ─────────────────────────────────────────────────────

class _BouncyButton extends StatefulWidget {
  final VoidCallback? onTap;
  final bool isLoading;

  const _BouncyButton({required this.onTap, required this.isLoading});

  @override
  State<_BouncyButton> createState() => _BouncyButtonState();
}

class _BouncyButtonState extends State<_BouncyButton>
    with TickerProviderStateMixin {
  late final AnimationController _pressCtrl;
  late final AnimationController _shineCtrl;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      lowerBound: 0.96,
      upperBound: 1.0,
      value: 1.0,
    );
    _shineCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    )..repeat();
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    _shineCtrl.dispose();
    super.dispose();
  }

  void _onTapDown(_) {
    if (widget.onTap != null) _pressCtrl.reverse();
  }

  void _onTapUp(_) {
    if (widget.onTap != null) _pressCtrl.forward();
  }

  void _onTapCancel() {
    if (widget.onTap != null) _pressCtrl.forward();
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _pressCtrl,
        builder: (context, child) =>
            Transform.scale(scale: _pressCtrl.value, child: child),
        child: Opacity(
          opacity: enabled ? 1.0 : 0.5,
          child: SizedBox(
            height: 60,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Gradient background
                  Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [_coral, _coralDeep],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _coral.withValues(alpha: 0.42),
                          blurRadius: 30,
                          offset: const Offset(0, 12),
                        )
                      ],
                    ),
                  ),
                  // Inset bottom shadow
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: 4,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.12)
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Shine sweep
                  if (enabled)
                    AnimatedBuilder(
                      animation: _shineCtrl,
                      builder: (context, _) {
                        final t = _shineCtrl.value;
                        final progress = t < 0.6 ? t / 0.6 : 1.0;
                        final x = -2.0 + progress * 4.5;
                        return Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment(x, 0),
                              end: Alignment(x + 0.4, 0),
                              colors: [
                                Colors.transparent,
                                Colors.white
                                    .withValues(alpha: 0.30),
                                Colors.transparent,
                              ],
                              stops: const [0, 0.5, 1],
                              tileMode: TileMode.clamp,
                            ),
                          ),
                        );
                      },
                    ),
                  // Label
                  Center(
                    child: widget.isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '开始阅读',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: 0.4,
                                ),
                              ),
                              SizedBox(width: 10),
                              Icon(Icons.arrow_forward_rounded,
                                  color: Colors.white, size: 20),
                            ],
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
}
