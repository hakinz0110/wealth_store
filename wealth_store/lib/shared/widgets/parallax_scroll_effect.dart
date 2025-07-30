import 'package:flutter/material.dart';

class ParallaxScrollEffect extends StatefulWidget {
  final Widget child;
  final double parallaxFactor;
  final bool enabled;
  
  const ParallaxScrollEffect({
    super.key,
    required this.child,
    this.parallaxFactor = 0.5,
    this.enabled = true,
  });

  @override
  State<ParallaxScrollEffect> createState() => _ParallaxScrollEffectState();
}

class _ParallaxScrollEffectState extends State<ParallaxScrollEffect> {
  double _offset = 0.0;

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return widget.child;
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollUpdateNotification) {
          setState(() {
            _offset = notification.metrics.pixels * widget.parallaxFactor;
          });
        }
        return false;
      },
      child: Transform.translate(
        offset: Offset(0, -_offset),
        child: widget.child,
      ),
    );
  }
}

class ParallaxListView extends StatefulWidget {
  final List<Widget> children;
  final double parallaxFactor;
  final ScrollController? controller;
  final EdgeInsetsGeometry? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  
  const ParallaxListView({
    super.key,
    required this.children,
    this.parallaxFactor = 0.3,
    this.controller,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
  });

  @override
  State<ParallaxListView> createState() => _ParallaxListViewState();
}

class _ParallaxListViewState extends State<ParallaxListView> {
  late ScrollController _scrollController;
  double _scrollOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.controller ?? ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _scrollController.dispose();
    } else {
      _scrollController.removeListener(_onScroll);
    }
    super.dispose();
  }

  void _onScroll() {
    setState(() {
      _scrollOffset = _scrollController.offset;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      padding: widget.padding,
      shrinkWrap: widget.shrinkWrap,
      physics: widget.physics,
      itemCount: widget.children.length,
      itemBuilder: (context, index) {
        final parallaxOffset = _scrollOffset * widget.parallaxFactor * (index + 1) * 0.1;
        
        return Transform.translate(
          offset: Offset(0, -parallaxOffset),
          child: widget.children[index],
        );
      },
    );
  }
}

class ParallaxBackground extends StatefulWidget {
  final Widget background;
  final Widget foreground;
  final double parallaxFactor;
  final ScrollController? controller;
  
  const ParallaxBackground({
    super.key,
    required this.background,
    required this.foreground,
    this.parallaxFactor = 0.5,
    this.controller,
  });

  @override
  State<ParallaxBackground> createState() => _ParallaxBackgroundState();
}

class _ParallaxBackgroundState extends State<ParallaxBackground> {
  late ScrollController _scrollController;
  double _scrollOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.controller ?? ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _scrollController.dispose();
    } else {
      _scrollController.removeListener(_onScroll);
    }
    super.dispose();
  }

  void _onScroll() {
    setState(() {
      _scrollOffset = _scrollController.offset;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Parallax background
        Positioned.fill(
          child: Transform.translate(
            offset: Offset(0, _scrollOffset * widget.parallaxFactor),
            child: widget.background,
          ),
        ),
        // Foreground content
        SingleChildScrollView(
          controller: _scrollController,
          child: widget.foreground,
        ),
      ],
    );
  }
}