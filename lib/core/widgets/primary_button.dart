import 'package:flutter/material.dart';

/// The big full-width button at the bottom of a screen.
class PrimaryButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String label;
  final IconData? icon;
  final bool isLoading;

  /// Space around the button.
  final EdgeInsetsGeometry padding;

  const PrimaryButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon,
    this.isLoading = false,
    this.padding = const EdgeInsets.fromLTRB(16, 8, 16, 16),
  });

  @override
  Widget build(BuildContext context) {
    final Widget leading = isLoading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          )
        : Icon(icon);

    return SafeArea(
      top: false,
      child: Padding(
        padding: padding,
        child: icon == null && !isLoading
            ? FilledButton(onPressed: onPressed, child: Text(label))
            : FilledButton.icon(
                onPressed: isLoading ? null : onPressed,
                icon: leading,
                label: Text(label),
              ),
      ),
    );
  }
}
