import 'dart:ui';
import 'package:flutter/material.dart';
import '../../services/sfx_service.dart';
import '../../theme/app_colors.dart';

class PrimaryButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final double? minWidth;
  final double height;
  final IconData? icon;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.minWidth,
    this.height = 52.0,
    this.icon,
  });

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTapDown: widget.onPressed == null ? null : (_) => setState(() => _pressed = true),
      onTapUp: widget.onPressed == null ? null : (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 100),
        scale: _pressed ? 0.96 : 1.0,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          constraints: BoxConstraints(minWidth: widget.minWidth ?? double.infinity, minHeight: widget.height),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: widget.onPressed != null
                  ? cs.primaryGradient
                  : [cs.surfaceContainerHighest, cs.surfaceContainerHighest],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: widget.onPressed != null
                ? [
                    BoxShadow(color: cs.primaryGlow, blurRadius: 16, offset: const Offset(0, 4)),
                    BoxShadow(color: cs.primary.withValues(alpha: 0.1), blurRadius: 4),
                  ]
                : [],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: widget.onPressed == null
                  ? null
                  : () {
                      SfxService().playClick();
                      widget.onPressed!();
                    },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: widget.minWidth != null ? MainAxisSize.min : MainAxisSize.max,
                  children: [
                    if (widget.icon != null) ...[
                      Icon(widget.icon, color: cs.onPrimary, size: 20),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      widget.label,
                      style: TextStyle(
                        color: widget.onPressed != null ? cs.onPrimary : cs.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
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
    final cs = Theme.of(context).colorScheme;
    return OutlinedButton(
      onPressed: onPressed == null
          ? null
          : () {
              SfxService().playClick();
              onPressed!();
            },
      style: OutlinedButton.styleFrom(
        minimumSize: Size(minWidth ?? double.infinity, height),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.4)),
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
        backgroundColor: cs.error.withValues(alpha: 0.15),
        foregroundColor: cs.error,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        elevation: 0,
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
    );
  }
}

/// Glassmorphism card surface
class CardSurface extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double? width;
  final bool glowing;

  const CardSurface({super.key, required this.child, this.padding = const EdgeInsets.all(16), this.width, this.glowing = false});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: width,
          padding: padding,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: cs.cardGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: cs.glassBorder, width: 1),
            boxShadow: [
              BoxShadow(color: cs.shadow.withAlpha(20), blurRadius: 24, offset: const Offset(0, 8)),
              if (glowing) BoxShadow(color: cs.primaryGlow, blurRadius: 32, spreadRadius: -4),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class OverlayScaffold extends StatelessWidget {
  final Widget child;
  final double? width;
  final EdgeInsetsGeometry padding;
  final bool scrollable;
  final double bottomSafeSpace;

  const OverlayScaffold({super.key, required this.child, this.width, this.padding = const EdgeInsets.all(20), this.scrollable = true, this.bottomSafeSpace = 96.0});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final maxW = (w - 32.0).clamp(280.0, 760.0);
    final effectiveWidth = (width ?? maxW) > maxW ? maxW : (width ?? maxW);

    Widget card = SafeArea(
      minimum: EdgeInsets.fromLTRB(12, 12, 12, bottomSafeSpace),
      child: CardSurface(width: effectiveWidth, padding: padding, child: child),
    );

    if (scrollable) {
      return Center(child: SingleChildScrollView(child: card));
    }
    return Center(child: card);
  }
}

/// A glowing icon badge used in menus
class GlowBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;

  const GlowBadge({super.key, required this.icon, required this.color, this.size = 48});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.15),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 16, spreadRadius: -2),
        ],
      ),
      child: Icon(icon, color: color, size: size * 0.5),
    );
  }
}

/// Animated stat pill with label and value
class StatPill extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;

  const StatPill({super.key, required this.label, required this.value, this.icon});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: cs.glassBackground,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: cs.glassBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: cs.primary),
            const SizedBox(width: 6),
          ],
          Text('$label ', style: TextStyle(color: cs.textMuted, fontWeight: FontWeight.w500, fontSize: 12)),
          Text(value, style: TextStyle(color: cs.textPrimary, fontWeight: FontWeight.w800, fontSize: 13)),
        ],
      ),
    );
  }
}
