import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Centers content with a max width of 480px on wide screens (web/desktop).
/// On mobile (or narrow windows), renders full-width with no constraints.
class ResponsiveWrapper extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final Color? backgroundColor;

  const ResponsiveWrapper({
    super.key,
    required this.child,
    this.maxWidth = 480,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = kIsWeb && screenWidth > maxWidth;

    if (!isWide) return child;

    return Container(
      color: backgroundColor ?? const Color(0xFFECF0EC),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Material(
            elevation: 4,
            child: child,
          ),
        ),
      ),
    );
  }
}
