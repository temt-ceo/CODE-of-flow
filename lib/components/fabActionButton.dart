import 'package:flutter/material.dart';

class FABActionButton extends StatelessWidget {
  const FABActionButton(
      {Key? key,
      required this.onPressed,
      required this.icon,
      required this.tooltip})
      : super(key: key);

  final VoidCallback? onPressed;
  final Icon icon;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        color: theme.colorScheme.secondary,
        elevation: 4.0,
        child: IconButton(
          onPressed: onPressed,
          icon: icon,
          tooltip: tooltip,
        ));
  }
}
