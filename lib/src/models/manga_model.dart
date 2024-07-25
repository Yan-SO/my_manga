class MangaModel {
  final int? id;
  final String title;
  final String? imgUrl;
  final String? urlManga;
  final double chaptersRead;
  final double totalChapters;
  final DateTime lastRead;

  MangaModel({
    this.urlManga,
    this.id,
    required this.title,
    required this.chaptersRead,
    required this.totalChapters,
    required this.lastRead,
    this.imgUrl,
  });

  @override
  String toString() {
    return 'MangaModel{id: $id, title: $title, imgUrl: $imgUrl, urlManga: $urlManga, chaptersRead: $chaptersRead, totalChapters: $totalChapters, lastRead: $lastRead}';
  }

  MangaModel copyWith({
    String? urlManga,
    int? id,
    String? title,
    double? chaptersRead,
    double? totalChapters,
    DateTime? lastRead,
    String? imgUrl,
  }) {
    return MangaModel(
      urlManga: urlManga ?? this.urlManga,
      id: id ?? this.id,
      title: title ?? this.title,
      chaptersRead: chaptersRead ?? this.chaptersRead,
      totalChapters: totalChapters ?? this.totalChapters,
      lastRead: lastRead ?? this.lastRead,
      imgUrl: imgUrl ?? this.imgUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'imgUrl': imgUrl,
      'urlManga': urlManga,
      'chaptersRead': chaptersRead,
      'totalChapters': totalChapters,
      'lastRead': lastRead.toIso8601String(),
    };
  }

  factory MangaModel.fromJson(Map<String, dynamic> json) {
    return MangaModel(
      id: json['id'],
      title: json['title'],
      imgUrl: json['imgUrl'],
      urlManga: json['urlManga'],
      chaptersRead: json['chaptersRead'],
      totalChapters: json['totalChapters'],
      lastRead: DateTime.parse(json['lastRead']),
    );
  }
}
