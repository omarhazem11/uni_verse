import 'package:flutter/material.dart';

/// Vertical counterpart to [HorizontalScrollHint] — wraps a
/// vertically-scrollable child with fading chevron badges at the top/bottom
/// edges. Used by the drawing toolbar now that it's a side panel instead of
/// a horizontal bottom bar.
class VerticalScrollHint extends StatefulWidget {
  final Widget Function(BuildContext context, ScrollController controller) builder;
  final Color fadeColor;
  final Color badgeColor;
  final Color iconColor;

  const VerticalScrollHint({
    super.key,
    required this.builder,
    this.fadeColor = Colors.white,
    this.badgeColor = const Color(0xE61A1033),
    this.iconColor = Colors.white,
  });

  @override
  State<VerticalScrollHint> createState() => _VerticalScrollHintState();
}

class _VerticalScrollHintState extends State<VerticalScrollHint> {
  final _controller = ScrollController();
  bool _showTop = false;
  bool _showBottom = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_updateHints);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateHints());
  }

  void _updateHints() {
    if (!mounted || !_controller.hasClients) return;
    final pos = _controller.position;
    final top = pos.pixels > 2;
    final bottom = pos.pixels < pos.maxScrollExtent - 2;
    if (top != _showTop || bottom != _showBottom) {
      setState(() { _showTop = top; _showBottom = bottom; });
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
          left: 0, right: 0, top: 0,
          child: IgnorePointer(
            child: AnimatedOpacity(
              opacity: _showTop ? 1 : 0,
              duration: const Duration(milliseconds: 200),
              child: _Hint(
                isBottom: false, fadeColor: widget.fadeColor,
                badgeColor: widget.badgeColor, iconColor: widget.iconColor,
              ),
            ),
          ),
        ),
        Positioned(
          left: 0, right: 0, bottom: 0,
          child: IgnorePointer(
            child: AnimatedOpacity(
              opacity: _showBottom ? 1 : 0,
              duration: const Duration(milliseconds: 200),
              child: _Hint(
                isBottom: true, fadeColor: widget.fadeColor,
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
  final bool isBottom;
  final Color fadeColor;
  final Color badgeColor;
  final Color iconColor;

  const _Hint({
    required this.isBottom,
    required this.fadeColor,
    required this.badgeColor,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      padding: EdgeInsets.only(top: isBottom ? 0 : 8, bottom: isBottom ? 8 : 0),
      alignment: isBottom ? Alignment.bottomCenter : Alignment.topCenter,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: isBottom ? Alignment.topCenter : Alignment.bottomCenter,
          end: isBottom ? Alignment.bottomCenter : Alignment.topCenter,
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
          isBottom ? Icons.expand_more_rounded : Icons.expand_less_rounded,
          size: 20,
          color: iconColor,
        ),
      ),
    );
  }
}
