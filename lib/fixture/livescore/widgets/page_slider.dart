import 'package:flutter/material.dart';

class PageSlider extends StatefulWidget {
  final Widget child;
  final bool opened;
  final double xScale;
  final double yScale;
  final Duration duration = const Duration(milliseconds: 500);
  final Curve openAnimationCurve = const ElasticOutCurve(0.9);
  final Curve closeAnimationCurve = const ElasticInCurve(0.9);

  const PageSlider({
    Key key,
    @required this.child,
    @required this.opened,
    @required this.xScale,
    @required this.yScale,
  }) : super(key: key);

  @override
  _PageSliderState createState() => _PageSliderState();
}

class _PageSliderState extends State<PageSlider>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _offset = Tween<Offset>(
      begin: Offset(0.0, 0.0),
      end: Offset(-widget.xScale * 0.01, -widget.yScale * 0.01),
    ).animate(
      CurvedAnimation(
        curve: Interval(
          0,
          1,
          curve: widget.openAnimationCurve,
        ),
        reverseCurve: Interval(
          0,
          1,
          curve: widget.closeAnimationCurve,
        ),
        parent: _animationController,
      ),
    );
  }

  @override
  void didUpdateWidget(PageSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    widget.opened
        ? _animationController.forward()
        : _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offset,
      child: widget.child,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
