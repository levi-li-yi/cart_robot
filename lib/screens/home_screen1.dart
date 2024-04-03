/*
 * @Author: Levi Li
 * @Date: 2024-04-01 14:03:42
 * @description: 
 */
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:custom_sliding_segmented_control/custom_sliding_segmented_control.dart';

import 'package:cart/theme/custom_theme.dart';
import 'package:cart/widgets/sliver_component.dart';
import 'package:cart/model/home_model.dart';
import 'package:cart/widgets/model_indicator.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  /// 促销事件
  PromotionEvent? promotionEvent;

  /// 是否显示提示消息对话框
  bool showFreeModelNotifyMessage = false;
  ModelIndicator? currentModel;

  List<HomeModelV2> models = [
    HomeModelV2(
      modelId: "openai:gpt-3.5-turbo",
      modelName: 'GPT-3.5',
      type: 'model',
      id: 'openai:gpt-3.5-turbo',
      supportVision: false,
      name: 'GPT-3.5',
      avatarUrl: 'https://ssl.aicode.cc/ai-server/assets/avatar/gpt35.png',
    ),
    HomeModelV2(
      modelId: "openai:gpt-4",
      modelName: 'GPT-4',
      type: 'model',
      id: 'openai:gpt-4',
      supportVision: false,
      name: 'GPT-4',
      avatarUrl:
          'https://ssl.aicode.cc/ai-server/assets/avatar/gpt4-preview.png',
    ),
  ];

  @override
  void initState() {
    setState(() {
      currentModel = ModelIndicator(
        model: models[0],
        iconAndColor: iconAndColors[0],
      );
    });

    super.initState();
  }

  Map<String, ModelIndicator> buildModelIndicators() {
    Map<String, ModelIndicator> map = {};

    for (var i = 0; i < models.length; i++) {
      var model = models[i];
      map[model.id] = ModelIndicator(
        model: model,
        selected: model.id == currentModel?.model.id,
        iconAndColor: iconAndColors[i],
        itemCount: models.length,
      );
    }

    return map;
  }

  @override
  Widget build(BuildContext context) {
    var customColors = Theme.of(context).extension<CustomColors>()!;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SliverSingleComponent(
        title: const Text('首页标题',
            style: TextStyle(fontSize: 12, color: Colors.cyanAccent)),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              print('点击顶部按钮');
            },
          ),
        ],
        backgroundImage: Image.asset(
          customColors.appBarBackgroundImage!,
          fit: BoxFit.cover,
        ),
        appBarExtraWidgets: () {
          return [
            SliverStickyHeader(
              header: const SafeArea(
                header: SafeArea(
                  top: false,
                ),
              ),
              sliver: SliverList(),
            ),
          ];
        },
      ),
    );
  }

  // 顶部聊天区域
  Container buildChatComponents(
    CustomColors customColors,
    BuildContext context,
  ) {
    final indicators = buildModelIndicators();
    return Container(
      color: customColors.backgroundContainerColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 模型选择
          Container(
            margin: const EdgeInsets.only(left: 10, right: 10),
            padding: const EdgeInsets.only(left: 5, right: 5, top: 10),
            child: CustomSlidingSegmentedControl<String>(
              children: indicators,
              padding: 0,
              isStretch: true,
              height: 45,
              innerPadding: const EdgeInsets.all(0),
              decoration: const BoxDecoration(
                color: customColors.columnBlockBackgroundColor?.withAlpha(150),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
