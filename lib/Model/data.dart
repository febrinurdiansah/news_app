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
    final List<dynamic> jsonCategories = json['category'];
    final List<String> categories = jsonCategories.map((category) => category.toString()).toList();
    return PubliserData(
      id: json['id'],
      name: json['name'],
      icImage: json['icon_url'],
      category: categories,
    );
  }
}

class NewDataNews {
  final String id;
  final String title;
  final String image;
  final String icImage;
  final String source;
  final String pubTime;
  final String link;

  NewDataNews({
    required this.id,
    required this.title,
    required this.image,
    required this.icImage,
    required this.source,
    required this.pubTime,
    required this.link,
  });

  factory NewDataNews.fromJson(Map<String, dynamic> json) {
    return NewDataNews(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      image: json['image'] ?? '',
      icImage: json['icon_url'] ?? '',
      source: json['name'] ?? '',
      pubTime: json['date'] ?? '',
      link: json['link'] ?? '',
    );
  }
}

class TrenDataNews {
  final int id;
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
    final List<dynamic> jsonCategories = json['category'] ?? '';
    final List<String> categories = jsonCategories.map((category) => category.toString()).toList();
    return TrenDataNews(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      image: json['image'] ?? '',
      icImage: json['icon_url'] ?? '',
      source: json['source'] ?? '',
      pubTime: json['date'] ?? '',
      link: json['link'] ?? '',
      category: categories,
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


// untuk test 1
// class SearchData {
//   final String source;
//   final String title;
//   final String date;
//   final String link;
//   final String image;
//   final int timestamp;
//   final DateTime dateTime; // New field for DateTime

//   SearchData({
//     required this.source,
//     required this.title,
//     required this.date,
//     required this.link,
//     required this.image,
//     required this.timestamp,
//     required this.dateTime,
//   });

//   factory SearchData.fromJson(Map<String, dynamic> json) {
//     return SearchData(
//       source: json['source'],
//       title: json['title'],
//       date: json['date'],
//       link: json['link'],
//       image: json['image'],
//       timestamp: json['timestamp'],
//       dateTime: DateTime.fromMillisecondsSinceEpoch(json['timestamp']),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'source': source,
//       'title': title,
//       'date': date,
//       'link': link,
//       'image': image,
//       'timestamp': timestamp,
//       'dateTime': dateTime.toIso8601String(), // Convert DateTime to String
//     };
//   }
// }

