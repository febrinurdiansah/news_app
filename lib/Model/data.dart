//Source Link
class MainSource{
  final String source = "http://10.0.2.2:4000";
}

// Model classes
class PubliserData {
  final String id;
  final String name;
  final String icImage;
  final List<String> category;

  PubliserData({
    required this.id,
    required this.name,
    required this.icImage,
    required this.category,
  });

  factory PubliserData.fromJson(Map<String, dynamic> json) {
    List<String> categoriesList = [];

    if (json['categories'] != null) {
      if(json['categories'] is List) {
        for (var item in json['categories']) {
          if (item is String) {
            categoriesList.add(item);
          } else if (item is Map<String, dynamic>) {
            categoriesList.add(item['name'] ?? '');
          }
        }
      }
    }

    return PubliserData(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      icImage: json['icon_url'] ?? '',
      category: categoriesList,
    );
  }
}

class NewsItem {
  final String id;
  final String title;
  final String image;
  final String icImage;
  final String source;
  final String pubTime;
  final String link;

  NewsItem({
    required this.id,
    required this.title,
    required this.image,
    required this.icImage,
    required this.source,
    required this.pubTime,
    required this.link,
  });

  factory NewsItem.fromJson(Map<String, dynamic> json) {
    return NewsItem(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      image: json['image'] ?? '',
      icImage: json['icon_url'] ?? '',
      source: json['name'] ?? json['source'] ?? '',
      pubTime: json['date'] ?? json['pubTime'] ?? '',
      link: json['link'] ?? '',
    );
  }
}

class TrenDataNews {
  final String id;
  final String title;
  final String image;
  final String icImage;
  final String source;
  final String pubTime;
  final String link;
  final List<String> category;

  TrenDataNews({
    required this.id,
    required this.title,
    required this.image,
    required this.icImage,
    required this.source,
    required this.pubTime,
    required this.link,
    required this.category
  });

  factory TrenDataNews.fromJson(Map<String, dynamic> json) {
    return TrenDataNews(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      image: json['thumbnail'] ?? '',
      icImage: json['sourceIcon'] ?? '',
      source: json['source'] ?? '',
      pubTime: json['date'] ?? '',
      link: json['url'] ?? '',
      category: [],
    );
  }
}

class SearchData {
  final String title;
  final String image;
  final String source;
  final String date;
  final String link;
  final int timestamp;

  SearchData({required this.title, required this.image, required this.source, required this.date, required this.link, required this.timestamp});

  factory SearchData.fromJson(Map<String, dynamic> json) {
    return SearchData(
      title: json['title'] ?? '',
      image: json['image'] ?? '',
      source: json['source'] ?? '',
      date: json['date'] ?? '',
      link: json['link'] ?? '',
      timestamp: json['timestamp'] ?? '',
    );
  }
}
