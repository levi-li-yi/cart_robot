/*
 * @Author: Levi Li
 * @Date: 2024-04-03 15:46:53
 * @description: 
 */
enum PromotionEventClickButtonType {
  none,
  url,
  inAppRoute;

  static PromotionEventClickButtonType fromName(String typeName) {
    switch (typeName) {
      case 'url':
        return PromotionEventClickButtonType.url;
      case 'in_app_route':
        return PromotionEventClickButtonType.inAppRoute;
      default:
        return PromotionEventClickButtonType.none;
    }
  }

  String toName() {
    switch (this) {
      case PromotionEventClickButtonType.url:
        return 'url';
      case PromotionEventClickButtonType.inAppRoute:
        return 'in_app_route';
      default:
        return 'none';
    }
  }
}

class PromotionEvent {
  String? title;
  String content;
  PromotionEventClickButtonType clickButtonType;
  String? clickValue;
  String? clickButtonColor;
  String? backgroundImage;
  String? textColor;
  bool closeable;
  int? maxCloseDurationInDays;

  PromotionEvent({
    this.title,
    required this.content,
    required this.clickButtonType,
    this.clickValue,
    this.clickButtonColor,
    this.backgroundImage,
    this.textColor,
    required this.closeable,
    this.maxCloseDurationInDays,
  });

  toJson() => {
        'title': title,
        'content': content,
        'click_button_type': clickButtonType.toName(),
        'click_value': clickValue,
        'click_button_color': clickButtonColor,
        'background_image': backgroundImage,
        'text_color': textColor,
        'closeable': closeable,
        'max_close_duration_in_days': maxCloseDurationInDays,
      };

  static PromotionEvent fromJson(Map<String, dynamic> json) {
    return PromotionEvent(
      title: json['title'],
      content: json['content'],
      clickButtonType: PromotionEventClickButtonType.fromName(
          json['click_button_type'] ?? ''),
      clickValue: json['click_value'],
      clickButtonColor: json['click_button_color'],
      backgroundImage: json['background_image'],
      textColor: json['text_color'],
      closeable: json['closeable'] ?? false,
      maxCloseDurationInDays: json['max_close_duration_in_days'],
    );
  }
}

/// 自定义首页模型
class HomeModelV2 {
  /// 类型：model/room_gallery/rooms/room_enterprise
  String type;
  String id;
  String name;
  String? avatarUrl;
  String? modelId;
  String? modelName;
  bool supportVision;

  HomeModelV2({
    required this.type,
    required this.id,
    required this.name,
    required this.supportVision,
    this.modelId,
    this.modelName,
    this.avatarUrl,
  });

  String get uniqueKey {
    return '$type|$id';
  }

  static HomeModelV2 fromJson(Map<String, dynamic> json) {
    return HomeModelV2(
      type: json['type'],
      id: json['id'],
      name: json['name'],
      modelId: json['model_id'],
      modelName: json['model_name'],
      supportVision: json['support_vision'] ?? false,
      avatarUrl: json['avatar_url'],
    );
  }

  toJson() => {
        'id': id,
        'type': type,
        'name': name,
        'model_id': modelId,
        'model_name': modelName,
        'support_vision': supportVision,
        'avatar_url': avatarUrl,
      };
}
