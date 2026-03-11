import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

enum ButtonType {
  primary,    // Filled - main actions
  secondary,  // Outlined - secondary actions
  ghost,      // Text only - subtle actions
  danger,     // Red - destructive actions
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
      duration: Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
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

  // Responsive sizing
  double _getResponsiveHeight(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double scale = width / 375;

    switch (widget.size) {
      case ButtonSize.small:
        return (36 * scale).clamp(36, 44);
      case ButtonSize.medium:
        return (40 * scale).clamp(48, 56);
      case ButtonSize.large:
        return (48 * scale).clamp(48, 56);
    }
  }

  double _getFontSize(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double scale = width / 375;

    switch (widget.size) {
      case ButtonSize.small:
        return (15 * scale).clamp(15, 19);
      case ButtonSize.medium:
        return (17 * scale).clamp(17, 21);
      case ButtonSize.large:
        return (21 * scale).clamp(21, 25);
    }
  }

  EdgeInsets _getPadding() {
    switch (widget.size) {
      case ButtonSize.small:
        return EdgeInsets.symmetric(horizontal: 14, vertical: 4);
      case ButtonSize.medium:
        return EdgeInsets.symmetric(horizontal: 18, vertical: 5);
      case ButtonSize.large:
        return EdgeInsets.symmetric(horizontal: 20, vertical: 6);
    }
  }

  double _getIconSize() {
    switch (widget.size) {
      case ButtonSize.small:  return 18;
      case ButtonSize.medium: return 20;
      case ButtonSize.large:  return 22;
    }
  }


  Border? _getBorder() {
    switch (widget.type) {
      case ButtonType.secondary:
        return Border.all(
          color: widget.color!,
          width: 1.5,
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
          duration: Duration(milliseconds: 200),
          opacity: isDisabled ? 0.5 : 1.0,
          child: Container(
            height: height,
            width: screenWidth > 600 ? 300 : screenWidth * 0.6,
            padding: _getPadding(),
            decoration: BoxDecoration(
              color: widget.bgcolor,
              borderRadius: BorderRadius.circular(12),
              border: _getBorder(),
              boxShadow: (widget.type == ButtonType.primary && !isDisabled)
                  ? [
                BoxShadow(
                  color: widget.color,
                  blurRadius: 12,
                  offset: Offset(0, 7),
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
                  strokeWidth: 2,
                  color: widget.color,
                ),
              ),
            )
                : Row(
              mainAxisSize: widget.fullWidth ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.leadingIcon != null) ...[
                  Icon(widget.leadingIcon, size: _getIconSize(), color: widget.color, fontWeight: FontWeight.bold,),
                  SizedBox(width: 8),
                ],
                Text(
                  widget.text,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                    color: widget.color,
                    letterSpacing: 0.3,
                  ),
                ),
                if (widget.trailingIcon != null) ...[
                  SizedBox(width: 8),
                  Icon(widget.trailingIcon, size: _getIconSize(), color: widget.color,fontWeight: FontWeight.bold,),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}