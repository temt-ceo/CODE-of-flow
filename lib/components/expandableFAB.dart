import 'package:flutter/material.dart';
import 'dart:math' as math;

const envFlavor = String.fromEnvironment('flavor');

class ExpandableFAB extends StatefulWidget {
  const ExpandableFAB(
      {Key? key, required this.children, required this.distance})
      : super(key: key);

  final List<Widget> children;
  final double distance;

  @override
  ExpandableFABState createState() => ExpandableFABState();
}

class ExpandableFABState extends State<ExpandableFAB>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  bool _open = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
        value: _open ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 250),
        vsync: this);

    _expandAnimation = CurvedAnimation(
        parent: _controller,
        curve: Curves.fastOutSlowIn,
        reverseCurve: Curves.easeOutQuad);
  }

  void _toggle() {
    setState(() {
      _open = !_open;
      if (_open) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: 200.0,
        height: 200.0,
        child: Stack(alignment: Alignment.topLeft, children: [
          // この３つこのファイルの下に書かれている
          _tapToClose(),
          ..._buildExpandableFABButton(),
          _tapToOpen()
        ]));
  }

  // FAB(Floating Animation Button)を再度クリックした時
  Widget _tapToClose() {
    return SizedBox(
        height: 55,
        width: 55,
        child: Center(
            child: Material(
                shape: const CircleBorder(),
                clipBehavior: Clip.antiAlias,
                elevation: 4,
                child: InkWell(
                    onTap: _toggle,
                    child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(Icons.close,
                            color: Theme.of(context).primaryColor))))));
  }

  // FAB(Floating Animation Button)をクリックした時(アニメーション)
  Widget _tapToOpen() {
    return AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        transformAlignment: Alignment.center,
        // x, y, zを指定する
        transform: Matrix4.diagonal3Values(
            // X
            _open ? 0.7 : 1.0,
            _open ? 0.7 : 1.0,
            1.0),
        curve: Curves.easeOut,
        child: AnimatedOpacity(
            opacity: _open ? 0.0 : 1.0,
            curve: Curves.easeInOut,
            duration: const Duration(milliseconds: 250),
            child: Padding(
                padding: const EdgeInsets.fromLTRB(8.0, 8.0, 0.0, 0.0),
                child: SizedBox(
                    height: 40.0,
                    width: 40.0,
                    child: FittedBox(
                        child: FloatingActionButton(
                      shape: const CircleBorder(),
                      onPressed: _toggle,
                      child: const Icon(
                        Icons.import_contacts,
                        size: 20.0,
                      ),
                    ))))));
  }

  List<Widget> _buildExpandableFABButton() {
    final List<Widget> children = <Widget>[];
    final count = widget.children.length;
    final step = 90.0 / (count - 1);

    for (var i = 0, angleInDegrees = 0.0;
        i < count;
        i++, angleInDegrees += step) {
      children.add(_ExpandableFAB(
          directionDegrees: angleInDegrees,
          maxDistance: widget.distance,
          progress: _expandAnimation,
          child: widget.children[i]));
    }

    return children;
  }
}

class _ExpandableFAB extends StatelessWidget {
  const _ExpandableFAB(
      {Key? key,
      required this.directionDegrees,
      required this.maxDistance,
      required this.progress,
      required this.child})
      : super(key: key);

  final double directionDegrees;
  final double maxDistance;
  final Animation<double>? progress;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: progress!,
        builder: (context, child) {
          final offset = Offset.fromDirection(
              // dx, dy
              directionDegrees * (math.pi / 180),
              progress!.value * maxDistance);
          return Positioned(
            left: 4.0 + offset.dx,
            top: 4.0 + offset.dy,
            // 放射状にボタンを表示
            child: Transform.rotate(
                angle: (1.0 - progress!.value) * math.pi / 2, child: child),
          );
        },
        child: FadeTransition(
          opacity: progress!,
          child: child,
        ));
  }
}
