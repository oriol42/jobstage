import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/theme_provider.dart';
import '../theme/adaptive_colors.dart';

class AdaptiveCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? borderRadius;
  final bool useGradient;
  final List<BoxShadow>? customShadows;

  const AdaptiveCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.useGradient = false,
    this.customShadows,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDarkMode = themeProvider.isDarkMode;

        return Container(
          margin: margin,
          padding: padding ?? const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: useGradient ? null : AdaptiveColors.getCard(isDarkMode),
            gradient: useGradient
                ? AdaptiveColors.getCardGradient(isDarkMode)
                : null,
            borderRadius: BorderRadius.circular(borderRadius ?? 16),
            border: isDarkMode
                ? Border.all(color: AdaptiveColors.darkDivider, width: 1)
                : null,
            boxShadow:
                customShadows ??
                [
                  BoxShadow(
                    color: isDarkMode
                        ? AdaptiveColors.darkPrimary.withValues(alpha: 0.2)
                        : Colors.black.withValues(alpha: 0.1),
                    blurRadius: isDarkMode ? 12 : 8,
                    offset: const Offset(0, 4),
                  ),
                ],
          ),
          child: this.child,
        );
      },
    );
  }
}

class AdaptiveText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const AdaptiveText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDarkMode = themeProvider.isDarkMode;

        return Text(
          text,
          style:
              style?.copyWith(
                color: style?.color ?? AdaptiveColors.getOnSurface(isDarkMode),
              ) ??
              TextStyle(color: AdaptiveColors.getOnSurface(isDarkMode)),
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: overflow,
        );
      },
    );
  }
}

class AdaptiveContainer extends StatelessWidget {
  final Widget? child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final Color? color;
  final Decoration? decoration;
  final AlignmentGeometry? alignment;

  const AdaptiveContainer({
    super.key,
    this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.color,
    this.decoration,
    this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDarkMode = themeProvider.isDarkMode;

        return Container(
          width: width,
          height: height,
          padding: padding,
          margin: margin,
          alignment: alignment,
          decoration:
              decoration ??
              BoxDecoration(
                color: color ?? AdaptiveColors.getCard(isDarkMode),
                borderRadius: BorderRadius.circular(12),
                border: isDarkMode
                    ? Border.all(color: AdaptiveColors.darkDivider, width: 1)
                    : null,
              ),
          child: this.child,
        );
      },
    );
  }
}
