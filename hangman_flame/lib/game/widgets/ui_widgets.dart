import 'package:flutter/material.dart';
import '../../services/sfx_service.dart';
import '../../theme/app_colors.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final double? minWidth;
  final double height;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.minWidth,
    this.height = 50.0,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed == null
          ? null
          : () {
              SfxService().playClick();
              onPressed!();
            },
      style: ElevatedButton.styleFrom(
        minimumSize: Size(minWidth ?? double.infinity, height),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        elevation: 2,
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }
}

class SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final double? minWidth;
  final double height;

  const SecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.minWidth,
    this.height = 48.0,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed == null
          ? null
          : () {
              SfxService().playClick();
              onPressed!();
            },
      style: OutlinedButton.styleFrom(
        minimumSize: Size(minWidth ?? double.infinity, height),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 16),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }
}

class DangerButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final double? minWidth;
  final double height;

  const DangerButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.minWidth,
    this.height = 48.0,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return FilledButton(
      onPressed: onPressed == null
          ? null
          : () {
              SfxService().playClick();
              onPressed!();
            },
      style: FilledButton.styleFrom(
        minimumSize: Size(minWidth ?? double.infinity, height),
        backgroundColor: cs.error,
        foregroundColor: cs.onError,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 16),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
    );
  }
}

class CardSurface extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double? width;

  const CardSurface({super.key, required this.child, this.padding = const EdgeInsets.all(16), this.width});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: width,
      padding: padding,
      decoration: BoxDecoration(
        color: cs.surface3,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: cs.shadow.withAlpha(31), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: child,
    );
  }
}

class OverlayScaffold extends StatelessWidget {
  final Widget child;
  final double? width;
  final EdgeInsetsGeometry padding;
  final bool scrollable;
  final double bottomSafeSpace;

  const OverlayScaffold({super.key, required this.child, this.width, this.padding = const EdgeInsets.all(16), this.scrollable = true, this.bottomSafeSpace = 96.0});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final maxW = (w - 48.0).clamp(280.0, 760.0);
    final effectiveWidth = (width ?? maxW) > maxW ? maxW : (width ?? maxW);

    Widget card = SafeArea(
      minimum: EdgeInsets.fromLTRB(16, 12, 16, bottomSafeSpace),
      child: CardSurface(width: effectiveWidth, padding: padding, child: child),
    );

    if (scrollable) {
      return Center(child: SingleChildScrollView(child: card));
    }
    return Center(child: card);
  }
}
