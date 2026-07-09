import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

class UniCardData {
  final String name;
  final String location;
  final String emoji;
  final Color color;

  const UniCardData({
    required this.name,
    required this.location,
    required this.emoji,
    required this.color,
  });
}

const previewUniversities = [
  UniCardData(name: 'Cairo University', location: 'Giza', emoji: '🏛️', color: AppColors.violet),
  UniCardData(name: 'AUC', location: 'New Cairo', emoji: '🎓', color: AppColors.coral),
  UniCardData(name: 'Ain Shams', location: 'Cairo', emoji: '☀️', color: AppColors.amber),
  UniCardData(name: 'Alexandria Uni', location: 'Alexandria', emoji: '🌊', color: AppColors.mint),
  UniCardData(name: 'GUC', location: 'New Cairo', emoji: '🔬', color: AppColors.violet),
  UniCardData(name: 'Mansoura Uni', location: 'Mansoura', emoji: '⚕️', color: AppColors.coral),
];

const _delays = [
  Duration.zero,
  Duration(milliseconds: 400),
  Duration(milliseconds: 800),
  Duration(milliseconds: 200),
  Duration(milliseconds: 600),
  Duration(milliseconds: 1000),
];

const _durations = [
  Duration(milliseconds: 2800),
  Duration(milliseconds: 3200),
  Duration(milliseconds: 2600),
  Duration(milliseconds: 3000),
  Duration(milliseconds: 2900),
  Duration(milliseconds: 3100),
];

class UniCardGrid extends StatelessWidget {
  const UniCardGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int row = 0; row < 3; row++) ...[
          Row(
            children: [
              Expanded(
                child: AnimatedUniCard(
                  data: previewUniversities[row * 2],
                  delay: _delays[row * 2],
                  duration: _durations[row * 2],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AnimatedUniCard(
                  data: previewUniversities[row * 2 + 1],
                  delay: _delays[row * 2 + 1],
                  duration: _durations[row * 2 + 1],
                ),
              ),
            ],
          ),
          if (row < 2) const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class AnimatedUniCard extends StatefulWidget {
  final UniCardData data;
  final Duration duration;
  final Duration delay;

  const AnimatedUniCard({
    super.key,
    required this.data,
    required this.duration,
    required this.delay,
  });

  @override
  State<AnimatedUniCard> createState() => _AnimatedUniCardState();
}

class _AnimatedUniCardState extends State<AnimatedUniCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _floatAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _floatAnim = Tween<double>(begin: 0, end: -8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    Future.delayed(widget.delay, () {
      if (mounted) _controller.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Transform.translate(
        offset: Offset(0, _floatAnim.value),
        child: child,
      ),
      child: Container(
        height: 62,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: widget.data.color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: widget.data.color.withValues(alpha: 0.35),
            width: 1.2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: widget.data.color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(widget.data.emoji,
                    style: const TextStyle(fontSize: 18)),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.data.name,
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    widget.data.location,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: AppColors.muted,
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
