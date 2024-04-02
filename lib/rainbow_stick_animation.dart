import 'dart:math' as math;

import 'package:flutter/material.dart';

class RainbowSticksPage extends StatefulWidget {
  const RainbowSticksPage({super.key});

  static PageRoute route() =>
      MaterialPageRoute(builder: (_) => const RainbowSticksPage());

  @override
  State<RainbowSticksPage> createState() => _RainbowSticksPageState();
}

class _RainbowSticksPageState extends State<RainbowSticksPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      upperBound: 0.6,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomPaint(
        painter: _CiclePainter(
          animationController: _animationController,
        ),
        size: MediaQuery.of(context).size,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (_animationController.status == AnimationStatus.completed) {
            _animationController.reverse();
          } else {
            _animationController.forward();
          }
        },
        label: const Text('Animate'),
        icon: const Icon(Icons.play_arrow),
      ),
    );
  }
}

class _CiclePainter extends CustomPainter {
  _CiclePainter({
    required AnimationController animationController,
  })  : _animationController = animationController,
        super(repaint: animationController);
  final AnimationController _animationController;

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = Colors.white60
      ..strokeWidth = 1;
    //inner circle's radius from center
    double innerCircleRadius = 30;
    //outer circle's radius from center
    double outerCircleRaius = 170;
    const circleThreshold = 20;
    //starts from the center of the screen
    final center = size.center(Offset.zero);
    //draw the circles in a loop
    for (var i = 1; i <= circleThreshold; i++) {
      final innerCirclePoint =
      toPolar(center, i, circleThreshold, innerCircleRadius);
      final outerCirclePoint =
      toPolar(center, i, circleThreshold, outerCircleRaius);

      final xCenter = (innerCirclePoint.dx + outerCirclePoint.dx) / 2;
      final yCenter = (innerCirclePoint.dy + outerCirclePoint.dy) / 2;

      double startValue = (i / circleThreshold) * 0.5;
      double endValue = math.min(startValue + 0.1, 1.0);

      final animation = Tween(begin: 0.0, end: 180.radians).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            startValue,
            endValue,
          ),
        ),
      );
      //the below one move and rotates the sticks or line
      //we start from (0, 0), which refers to the screen center
      //Then we translate based on the given value inside translate() function.
      //Positive value inside translate() moves it downward
      //Negative value moves it upward
      canvas
        ..save()
        ..translate(xCenter, yCenter)
        ..rotate(animation.value)
        ..translate(-xCenter, -yCenter);
      //just show the lines
      canvas.drawLine(innerCirclePoint, outerCirclePoint, linePaint);
      //smaller circles
      _drawCircle(canvas, innerCirclePoint, _innerCircleColor(i));
      //bigger circles
      _drawCircle(canvas, outerCirclePoint, _outerCircleColor(i));

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _CiclePainter oldDelegate) => true;
  //inner circles colors
  Color _innerCircleColor(int index) {
    if (index > 0 && index <= 5) {
      return Colors.blue;
    } else if (index > 5 && index <= 10) {
      return Colors.pink;
    } else if (index > 10 && index <= 15) {
      return Colors.cyan;
    } else {
      return Colors.indigo;
    }
  }

  Color _outerCircleColor(int index) {
    if (index > 0 && index <= 5) {
      return Colors.yellowAccent;
    } else if (index > 5 && index <= 10) {
      return Colors.lightGreenAccent;
    } else if (index > 10 && index <= 15) {
      return Colors.redAccent;
    } else {
      return Colors.orangeAccent;
    }
  }

  void _drawCircle(Canvas canvas, Offset offset, Color color) {
    final paint = Paint()..color = color;
    //flutter api for drawing circles
    canvas.drawCircle(offset, 7, paint);
  }
}

extension NumX<T extends num> on T {
  double get radians => (this * math.pi) / 180.0;
  double get stepsInAngle => (math.pi * 2) / this;
/*
    The property is calculated as 2*pi/total
  total represents the total number of steps or divisions around the circle.
     */
}
//this get polar coordinates
Offset toPolar(Offset center, int index, int total, double radius) {
  final theta = index * total.stepsInAngle; //this gets us 18 degrees  for stetpInangle
  //polar coordinates convert to x and y
  //polar coordinates is given in radius and theta (r, theta)
  final dx = radius * math.cos(theta);
  final dy = radius * math.sin(theta);
  //based on the center point move the dx and dy
  return Offset(dx, dy) + center;
}
