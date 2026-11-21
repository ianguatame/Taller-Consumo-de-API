import 'package:flutter/material.dart';

// Fondo: degradado azul petróleo, cuadrícula de puntos (como un mapa)
// y un resplandor turquesa en la esquina superior.
class AppBackground extends StatelessWidget {
  final Widget child;

  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF0B1F2A), Color(0xFF0F3040), Color(0xFF123C4A)],
              ),
            ),
            child: CustomPaint(painter: _DotGridPainter()),
          ),
        ),
        Positioned(
          top: -120,
          right: -100,
          child: Container(
            width: 320,
            height: 320,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [Color(0x552DD4BF), Color(0x002DD4BF)],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -140,
          left: -120,
          child: Container(
            width: 360,
            height: 360,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [Color(0x33FF6B6B), Color(0x00FF6B6B)],
              ),
            ),
          ),
        ),
        Positioned.fill(child: child),
      ],
    );
  }
}

class _DotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0x1AFFFFFF);
    const gap = 26.0;
    for (double y = gap / 2; y < size.height; y += gap) {
      for (double x = gap / 2; x < size.width; x += gap) {
        canvas.drawCircle(Offset(x, y), 1.2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}