import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:diplomaapp/src/utils/other.dart';

class AnimatedLotusLoader extends StatefulWidget {
  final double size;

  const AnimatedLotusLoader({super.key, this.size = 24});

  @override
  State<AnimatedLotusLoader> createState() => _AnimatedLotusLoaderState();
}

class _AnimatedLotusLoaderState extends State<AnimatedLotusLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Map<String, String>? _petals;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    )..repeat();

    _loadSvg();
  }

  Future<void> _loadSvg() async {
    final svgText = await rootBundle.loadString(
      'assets/logo_gradient.svg',
    );

    setState(() {
      _petals = splitSvgByPathId(svgText);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_petals == null) {
      return SizedBox(
        width: widget.size,
        height: widget.size,
      );
    }

    final animations = List.generate(_petals!.length, (i) {
      final start = i * 0.14;
      return CurvedAnimation(
        parent: _controller,
        curve: Interval(start, start + 0.14, curve: Curves.easeInOut),
      );
    });

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        children: _petals!.values
            .toList()
            .asMap()
            .entries
            .map(
              (e) => AnimatedPetal(
                animation: animations[e.key],
                svg: e.value,
              ),
            )
            .toList(),
      ),
    );
  }
}

class AnimatedPetal extends StatelessWidget {
  final Animation<double> animation;
  final String svg;

  const AnimatedPetal({
    super.key,
    required this.animation,
    required this.svg,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animation,
      child: ScaleTransition(
        scale: Tween(begin: 0.9, end: 1.0).animate(
          CurvedAnimation(
            parent: animation,
            curve: Curves.easeOut,
          ),
        ),
        child: SvgPicture.string(svg),
      ),
    );
  }
}
