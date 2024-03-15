/*
 * @Author: Levi Li
 * @Date: 2024-03-15 10:52:06
 * @description: 
 */

class Setting {
  final String? version;
  final String? locale;

  Setting({this.version, this.locale});

  // toJson
  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'locale': locale,
    };
  }

  // fromJson
  static Setting fromJson(Map<String, dynamic> json) {
    return Setting(
      version: json['version'],
      locale: json['locale'],
    );
  }
}
