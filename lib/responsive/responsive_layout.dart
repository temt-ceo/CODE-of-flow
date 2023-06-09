import 'package:flutter/material.dart';
import 'package:CodeOfFlow/responsive/dimensions.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget mobileBody;
  final Widget mobileBodyHorizen;
  final Widget desktopBody;

  const ResponsiveLayout(
      {super.key,
      required this.mobileBody,
      required this.mobileBodyHorizen,
      required this.desktopBody});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth <= mobileWidth &&
          constraints.maxHeight > constraints.maxWidth) {
        return mobileBody;
      } else if (constraints.maxWidth < mobileWidth &&
          constraints.maxHeight < mobileHeight) {
        return mobileBodyHorizen;
      } else {
        return desktopBody;
      }
    });
  }
}
