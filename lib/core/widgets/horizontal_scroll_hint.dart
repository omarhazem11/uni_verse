import 'package:flutter/material.dart';

/// Wraps a horizontally-scrollable child with fading chevron badges at the
/// left/right edges so the user knows there's more content off-screen.
/// The right hint appears as soon as the content overflows; both hints
/// track scroll position via a ScrollController the [builder] attaches to
/// its own SingleChildScrollView.
class HorizontalScrollHint extends StatefulWidget {
  final Widget Function(BuildContext context, ScrollController controller) builder;
  final Color fadeColor;
  final Color badgeColor;
  final Color iconColor;

  const HorizontalScrollHint({
    super.key,
    required this.builder,
    this.fadeColor = Colors.white,
    this.badgeColor = const Color(0xE61A1033),
    this.iconColor = Colors.white,
  });

  @override
  State<HorizontalScrollHint> createState() => _HorizontalScrollHintState();
}

class _HorizontalScrollHintState extends State<HorizontalScrollHint> {
  final _controller = ScrollController();
  bool _showLeft = false;
  bool _showRight = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_updateHints);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateHints());
  }

  void _updateHints() {
    if (!mounted || !_controller.hasClients) return;
    final pos = _controller.position;
    final left = pos.pixels > 2;
    final right = pos.pixels < pos.maxScrollExtent - 2;
    if (left != _showLeft || right != _showRight) {
      setState(() { _showLeft = left; _showRight = right; });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.builder(context, _controller),
        Positioned(
          left: 0, top: 0, bottom: 0,
          child: IgnorePointer(
            child: AnimatedOpacity(
              opacity: _showLeft ? 1 : 0,
              duration: const Duration(milliseconds: 200),
              child: _Hint(
                isRight: false, fadeColor: widget.fadeColor,
                badgeColor: widget.badgeColor, iconColor: widget.iconColor,
              ),
            ),
          ),
        ),
        Positioned(
          right: 0, top: 0, bottom: 0,
          child: IgnorePointer(
            child: AnimatedOpacity(
              opacity: _showRight ? 1 : 0,
              duration: const Duration(milliseconds: 200),
              child: _Hint(
                isRight: true, fadeColor: widget.fadeColor,
                badgeColor: widget.badgeColor, iconColor: widget.iconColor,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Hint extends StatelessWidget {
  final bool isRight;
  final Color fadeColor;
  final Color badgeColor;
  final Color iconColor;

  const _Hint({
    required this.isRight,
    required this.fadeColor,
    required this.badgeColor,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      padding: EdgeInsets.only(left: isRight ? 0 : 8, right: isRight ? 8 : 0),
      alignment: isRight ? Alignment.centerRight : Alignment.centerLeft,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: isRight ? Alignment.centerLeft : Alignment.centerRight,
          end: isRight ? Alignment.centerRight : Alignment.centerLeft,
          colors: [fadeColor.withValues(alpha: 0), fadeColor.withValues(alpha: 0.85)],
        ),
      ),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: badgeColor,
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 1))],
        ),
        child: Icon(
          isRight ? Icons.chevron_right_rounded : Icons.chevron_left_rounded,
          size: 20,
          color: iconColor,
        ),
      ),
    );
  }
}
