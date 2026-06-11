import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class CatLoading extends StatefulWidget {
  final double size;
  final Color? color;

  const CatLoading({
    super.key,
    this.size = 50,
    this.color,
  });

  @override
  State<CatLoading> createState() => _CatLoadingState();
}

class _CatLoadingState extends State<CatLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0, end: 15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, -_animation.value),
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                color: widget.color ?? AppColors.orange.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '🐱',
                  style: TextStyle(fontSize: widget.size * 0.6),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
