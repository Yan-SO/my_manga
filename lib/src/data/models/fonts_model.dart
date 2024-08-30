class FontsModel {
  final int? id;
  final String fontName;
  final int children;
  final String? imgUrl;
  String? urlFont;

  FontsModel({
    this.id,
    required this.fontName,
    this.imgUrl,
    required this.children,
    this.urlFont,
  });

  FontsModel copyWith({
    int? id,
    String? fontName,
    int? children,
    String? imgUrl,
    String? urlFont,
  }) {
    return FontsModel(
      id: id ?? this.id,
      fontName: fontName ?? this.fontName,
      children: children ?? this.children,
      imgUrl: imgUrl ?? this.imgUrl,
      urlFont: urlFont ?? this.urlFont,
    );
  }

  FontsModel updateUrlFont(String? newUrlfonte) {
    return FontsModel(
      id: id,
      imgUrl: imgUrl,
      urlFont: newUrlfonte,
      fontName: fontName,
      children: children,
    );
  }

  @override
  String toString() {
    return 'FontsModel{id: $id, fontName: $fontName, children: $children, imgUrl: $imgUrl, urlFont: $urlFont}';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fontName': fontName,
      'children': children,
      'imgUrl': imgUrl,
      'urlFont': urlFont,
    };
  }

  factory FontsModel.fromJson(Map<String, dynamic> json) {
    return FontsModel(
      id: json['id'],
      fontName: json['fontName'],
      children: json['children'],
      imgUrl: json['imgUrl'],
      urlFont: json['urlFont'],
    );
  }
}
