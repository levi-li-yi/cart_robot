/*
 * @Author: Levi Li
 * @Date: 2024-04-02 10:44:19
 * @description: 
 */
import 'package:flutter/material.dart';

import 'package:cart/widgets/image.dart';
import 'package:cart/theme/custom_size.dart';
import 'package:cart/theme/custom_theme.dart';

class SliverSingleComponent extends StatelessWidget {
  final Widget? title;
  final Widget? backgroundImage;
  final List<Widget>? actions;
  final double expendedHeight;
  final List<Widget> Function() appBarExtraWidgets;
  final EdgeInsets? titlePadding;
  final bool centerTitle;

  const SliverSingleComponent({
    super.key,
    required this.title,
    this.backgroundImage,
    this.actions,
    this.expendedHeight = 80,
    required this.appBarExtraWidgets,
    this.titlePadding,
    this.centerTitle = true,
  });

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          automaticallyImplyLeading: false,
          expandedHeight: expendedHeight,
          floating: false,
          pinned: true,
          snap: false,
          primary: true,
          actions: (actions ?? []).isEmpty
              ? null
              : <Widget>[...actions!, const SizedBox(width: 8)],
          backgroundColor: customColors.backgroundContainerColor,
          flexibleSpace: FlexibleSpaceBar(
            title: title,
            centerTitle: centerTitle,
            titlePadding: titlePadding,
            background: ShaderMask(
              shaderCallback: (rect) {
                return const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black, Colors.transparent],
                ).createShader(Rect.fromLTRB(0, 0, rect.width, rect.height));
              },
              blendMode: BlendMode.dstIn,
              child: backgroundImage,
            ),
            expandedTitleScale: 1.1,
          ),
        ),
        ...appBarExtraWidgets()
      ],
    );
  }
}
