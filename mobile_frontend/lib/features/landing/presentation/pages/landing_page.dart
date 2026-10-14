import 'package:flutter/material.dart';

import '../widgets/background_blobs.dart';
import '../widgets/landing_action_zone.dart';
import '../widgets/landing_hero.dart';
import '../widgets/landing_top_bar.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key, this.onStart});

  final ValueChanged<BuildContext>? onStart;

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _mascotController;
  late final Animation<double> _mascotAnimation;

  @override
  void initState() {
    super.initState();
    _mascotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _mascotAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: 0.105), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.105, end: -0.105), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -0.105, end: 0.07), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.07, end: -0.07), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -0.07, end: 0), weight: 1),
    ]).animate(_mascotController);
  }

  @override
  void dispose() {
    _mascotController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: ClipRect(
      child: Stack(
        fit: StackFit.expand,
        children: [
          const BackgroundBlobs(),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const LandingTopBar(),
                        LandingHero(
                          onMascotTap: () => _mascotController.forward(from: 0),
                          mascotAnimation: _mascotAnimation,
                        ),
                        LandingActionZone(
                          onPrimaryTap: () => widget.onStart?.call(context),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
