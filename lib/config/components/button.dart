import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

enum ButtonType {
  primary,    // Filled - main actions
  secondary,  // Outlined - secondary actions
  ghost,      // Text only - subtle actions
  danger,     // Red - destructive actions
  glass,      // Frosted Glassmorphism
}

enum ButtonSize {
  small,
  medium,
  large,
}

class AppButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  final ButtonSize size;
  final Color color;
  final Color bgcolor;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final bool isLoading;
  final bool fullWidth;

  const AppButton(
      this.text, {
        super.key,
        this.onPressed,
        this.type = ButtonType.primary,
        this.size = ButtonSize.medium,
        required this.color,
        required this.bgcolor,
        this.leadingIcon,
        this.trailingIcon,
        this.isLoading = false,
        this.fullWidth = true,
      });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(_) {
    if (widget.onPressed != null && !widget.isLoading) {
      _controller.forward();
      HapticFeedback.lightImpact();
    }
  }

  void _onTapUp(_) => _controller.reverse();
  void _onTapCancel() => _controller.reverse();

  double _getResponsiveHeight(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double scale = width / 375;

    switch (widget.size) {
      case ButtonSize.small:
        return (38 * scale).clamp(38, 44);
      case ButtonSize.medium:
        return (46 * scale).clamp(46, 52);
      case ButtonSize.large:
        return (52 * scale).clamp(52, 60);
    }
  }

  double _getFontSize(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double scale = width / 375;

    switch (widget.size) {
      case ButtonSize.small:
        return (14 * scale).clamp(13, 16);
      case ButtonSize.medium:
        return (15 * scale).clamp(14, 18);
      case ButtonSize.large:
        return (16 * scale).clamp(16, 20);
    }
  }

  EdgeInsets _getPadding() {
    switch (widget.size) {
      case ButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 14, vertical: 6);
      case ButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 18, vertical: 8);
      case ButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 10);
    }
  }

  double _getIconSize() {
    switch (widget.size) {
      case ButtonSize.small:
        return 18;
      case ButtonSize.medium:
        return 20;
      case ButtonSize.large:
        return 22;
    }
  }

  Border? _getBorder() {
    switch (widget.type) {
      case ButtonType.secondary:
        return Border.all(
          color: widget.color,
          width: 1.5,
        );
      case ButtonType.glass:
        return Border.all(
          color: Colors.white.withValues(alpha: 0.35),
          width: 1.2,
        );
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = _getResponsiveHeight(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final fontSize = _getFontSize(context);
    final isDisabled = widget.onPressed == null;

    final isGlass = widget.type == ButtonType.glass;

    Widget buttonContent = Container(
      height: height,
      width: widget.fullWidth ? (screenWidth > 600 ? 340 : screenWidth * 0.7) : null,
      padding: _getPadding(),
      decoration: BoxDecoration(
        color: isGlass ? widget.bgcolor.withValues(alpha: 0.8) : widget.bgcolor,
        borderRadius: BorderRadius.circular(16),
        border: _getBorder(),
        boxShadow: (!isDisabled && widget.type != ButtonType.ghost)
            ? [
          BoxShadow(
            color: widget.bgcolor.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          )
        ]
            : null,
      ),
      child: widget.isLoading
          ? Center(
        child: SizedBox(
          height: height * 0.4,
          width: height * 0.4,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: widget.color,
          ),
        ),
      )
          : Row(
        mainAxisSize: widget.fullWidth ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (widget.leadingIcon != null) ...[
            Icon(widget.leadingIcon, size: _getIconSize(), color: widget.color),
            const SizedBox(width: 8),
          ],
          Text(
            widget.text,
            style: GoogleFonts.plusJakartaSans(
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              color: widget.color,
              letterSpacing: 0.2,
            ),
          ),
          if (widget.trailingIcon != null) ...[
            const SizedBox(width: 8),
            Icon(widget.trailingIcon, size: _getIconSize(), color: widget.color),
          ],
        ],
      ),
    );

    if (isGlass) {
      buttonContent = ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: buttonContent,
        ),
      );
    }

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: (!isDisabled && !widget.isLoading) ? widget.onPressed : null,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        ),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: isDisabled ? 0.5 : 1.0,
          child: buttonContent,
        ),
      ),
    );
  }
}

/// Ultra-Modern Glassmorphic Floating Action Capsule Button
class GlassActionButton extends StatefulWidget {
  final String text;
  final IconData icon;
  final VoidCallback onPressed;
  final Color accentColor;
  final double? width;

  const GlassActionButton({
    super.key,
    required this.text,
    required this.icon,
    required this.onPressed,
    required this.accentColor,
    this.width,
  });

  @override
  State<GlassActionButton> createState() => _GlassActionButtonState();
}

class _GlassActionButtonState extends State<GlassActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.94).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 600;

    return GestureDetector(
      onTapDown: (_) {
        _controller.forward();
        HapticFeedback.mediumImpact();
      },
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onPressed,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: widget.accentColor.withValues(alpha: 0.45),
                blurRadius: 22,
                spreadRadius: 1,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                width: widget.width ?? (isWide ? 260 : screenWidth * 0.62),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      widget.accentColor.withValues(alpha: 0.92),
                      Color.lerp(widget.accentColor, Colors.black, 0.15)!.withValues(alpha: 0.88),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.22),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.35),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        widget.icon,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        widget.text,
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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