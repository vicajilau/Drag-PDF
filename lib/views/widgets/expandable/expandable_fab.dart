import 'package:flutter/material.dart';
import 'dart:math' as math;

@immutable
class ExpandableFab extends StatefulWidget {
  const ExpandableFab({
    super.key,
    this.initialOpen = false,
    required this.distance,
    required this.children,
  });

  final bool initialOpen;
  final double distance;
  final List<Widget> children;

  @override
  State<ExpandableFab> createState() => ExpandableFabState();
}

class ExpandableFabState extends State<ExpandableFab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _expandAnimation;
  bool _open = false;



  @override
  void initState() {
    super.initState();
    _open = widget.initialOpen;
    _controller = AnimationController(
      value: _open ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      curve: Curves.fastOutSlowIn,
      reverseCurve: Curves.easeOutQuad,
      parent: _controller,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void toggle() {
    setState(() {
      _open = !_open;
      if (_open) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  void close() {
    setState(() {
      _open = false;
      _controller.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        alignment: Alignment.bottomRight,
        clipBehavior: Clip.none,
        children: [
          _buildTapToCloseFab(),
          ..._buildExpandingActionButtons(),
          _buildTapToOpenFab(),
        ],
      ),
    );
  }

  Widget _buildTapToCloseFab() {
    return IgnorePointer(
      ignoring: !_open,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.fastOutSlowIn,
        width: _open ? 56.0 : 0.0,
        height: _open ? 56.0 : 0.0,
        child: FloatingActionButton(
          onPressed: toggle,
          child: const Icon(Icons.close),
        ),
      ),
    );
  }

  Widget _buildTapToOpenFab() {
    return IgnorePointer(
      ignoring: _open,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.fastOutSlowIn,
        width: !_open ? 56.0 : 0.0,
        height: !_open ? 56.0 : 0.0,
        child: FloatingActionButton(
          onPressed: toggle,
          child: const Icon(Icons.create),
        ),
      ),
    );
  }

  List<Widget> _buildExpandingActionButtons() {
    final children = <Widget>[];
    final count = widget.children.length;
    final step = 90.0 / (count - 1);
    for (
      var i = 0, angleInDegrees = 0.0;
      i < count;
      i++, angleInDegrees += step
    ) {
      children.add(
        _ExpandingActionButton(
          directionInDegrees: angleInDegrees,
          maxDistance: widget.distance,
          progress: _expandAnimation,
          child: widget.children[i],
        ),
      );
    }
    return children;
  }
}

class _ExpandingActionButton extends StatelessWidget {
  const _ExpandingActionButton({
    required this.directionInDegrees,
    required this.maxDistance,
    required this.progress,
    required this.child,
  });

  final double directionInDegrees;
  final double maxDistance;
  final Animation<double> progress;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final angleInRadians = directionInDegrees * (math.pi / 180.0);
    return AnimatedBuilder(
      animation: progress,
      builder: (context, child) {
        final offset = Offset.fromDirection(
          angleInRadians,
          progress.value * maxDistance,
        );
        return Positioned(
          right: 4.0 + offset.dx,
          bottom: 4.0 + offset.dy,
          child: Transform.rotate(
            angle: (1.0 - progress.value) * math.pi / 2,
            child: child,
          ),
        );
      },
      child: FadeTransition(opacity: progress, child: child),
    );
  }
}

class ActionButton extends StatelessWidget {
  const ActionButton({super.key, required this.onPressed, required this.icon});

  final VoidCallback onPressed;
  final Widget icon;

  @override
  Widget build(BuildContext context) {
    return Material(
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      color: Theme.of(context).colorScheme.secondary,
      elevation: 4.0,
      child: IconButton(onPressed: onPressed, icon: icon, color: Colors.white),
    );
  }
}
