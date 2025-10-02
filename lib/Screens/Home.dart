import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:news_app/Model/data.dart';
import 'package:news_app/Screens/Detail.dart';
import 'package:news_app/Screens/LatestNews.dart';
import 'package:news_app/Screens/Publiser.dart';
import 'package:news_app/Screens/Trending.dart';
import 'package:news_app/Widgets/Card.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

void _launchURL(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

class HomeScreen extends StatelessWidget {
  late final String mainSource = MainSource().source;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.blue,
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(50),
              child: PubliserWidget(
                source: mainSource,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Berita Trending",
                        style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                            color: Colors.blue.shade700
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(
                            builder: (context) => TrendingScreen(),
                          ));
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(16)
                          ),
                          child: Text("Lihat Semua >",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.blue.shade500
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                TrendingWidget(
                  source: mainSource,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Berita Terbaru",
                        style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                            color: Colors.blue.shade700
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(
                            builder: (context) => ExploreScreen(),
                          ));
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(20)
                          ),
                          child: Text("Lihat Semua >",
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue.shade700
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          LatestNewsScroll(
            source: mainSource,
          )
        ],
      ),
    );
  }
}

class PubliserWidget extends StatefulWidget {
  final String source;

  const PubliserWidget({required this.source});

  @override
  State<PubliserWidget> createState() => _PubliserWidgetState();
}

class _PubliserWidgetState extends State<PubliserWidget> {
  late Future<List<PubliserData>> futurePublisers;

  @override
  void initState() {
    super.initState();
    futurePublisers = fetchPublisers();
  }

  Future<List<PubliserData>> fetchPublisers() async {
    final response = await http.get(Uri.parse('${widget.source}/publiser'));

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      List<dynamic> publisers = jsonResponse['publiser_all'];
      return publisers.map((data) => PubliserData.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load publishers');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<PubliserData>>(
      future: futurePublisers,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Container(
            height: 100,
            margin: EdgeInsets.only(left: 10),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final publiser = snapshot.data![index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(
                            builder:  (context) => PubliserScreen(
                              source: publiser.id,
                              namePub: publiser.name,
                              image: publiser.icImage,
                              categories: publiser.category,
                            ),
                        )
                    );
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          width: 3,
                          color: Colors.white
                      )
                    ),
                    child: CircleAvatar(
                      radius: 40,
                      backgroundImage: NetworkImage(publiser.icImage),
                    ),
                  ),
                );
              },
            ),
          );
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }
}

class TrendingWidget extends StatefulWidget {
  final String source;

  const TrendingWidget({required this.source});

  @override
  State<TrendingWidget> createState() => _TrendingWidgetState();
}

class _TrendingWidgetState extends State<TrendingWidget> {
  late Future<List<TrenDataNews>> futureTrending;

  @override
  void initState() {
    super.initState();
    futureTrending = fetchTrending();
  }

  Future<List<TrenDataNews>> fetchTrending() async {
    final response = await http.get(Uri.parse('${widget.source}/trending'));

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = jsonDecode(response.body);
      return jsonResponse.map((data) => TrenDataNews.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load trending news');
    }
  }


  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<TrenDataNews>>(
      future: futureTrending,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Container(
            height: 285,
            child: ListView.builder(
              padding: EdgeInsets.only(left: 15, top: 10),
              scrollDirection: Axis.horizontal,
              itemCount: snapshot.data!.length > 5 ? 5 : snapshot.data!.length,
              itemBuilder: (context, index) {
                final item = snapshot.data![index];
                return GestureDetector(
                  onTap: () {
                    if (kIsWeb) {
                      _launchURL(item.link);
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailScreen(linkNews: item.link),
                        ),
                      );
                    }
                  },
                  child: Container(
                    width: 301,
                    margin: EdgeInsets.only(right: 15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.15),
                          blurRadius: 10,
                          offset: Offset(0, 4)
                        )
                      ]
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                          //Image
                          ClipRRect(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(12)
                            ),
                            child: Container(
                              width: double.infinity,
                              height: 161,
                              child: Image.network(item.image,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.broken_image, size: 40, color: Colors.grey.shade400)
                                        ],
                                      ),
                                    );
                                  },
                              ),
                            ),
                          ),
                        //Title
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
                          child: Text(
                            item.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 16,
                              fontWeight: FontWeight.w600,
                              height: 1.3
                            ),
                          ),
                        ),
                        //Footer
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  //Logo
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      image: DecorationImage(
                                        image: NetworkImage(item.icImage),
                                        fit: BoxFit.cover
                                      )
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  //Source
                                  Container(
                                    constraints: BoxConstraints(maxHeight: 100),
                                    child: Text(
                                      item.source,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                        fontWeight: FontWeight.w500,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                                //Time badge
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(6)
                                  ),
                                  child: Text(
                                    item.pubTime,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.blue.shade700,
                                      fontWeight: FontWeight.w600
                                    ),
                                  ),
                                )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        } else if (snapshot.hasError) {
          return Container(
            height: 285,
            alignment: Alignment.center,
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.cloud_off,
                  color: Colors.blue.shade300,
                  size: 60,
                ),
                const SizedBox(height: 15,),
                Text('Gagal memuat Berita Trending.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 16,
                    fontWeight: FontWeight.w500
                  ),
                )
              ],
            ),
          );
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }
}

class LatestNewsScroll extends StatefulWidget {
  final String source;

  const LatestNewsScroll({required this.source});

  @override
  State<LatestNewsScroll> createState() => _LatestNewsScrollState();
}

class _LatestNewsScrollState extends State<LatestNewsScroll> {
  late Future<List<NewsItem>> futureLatestNews;

  @override
  void initState() {
    super.initState();
    futureLatestNews = fetchLatestNews();
  }

  Future<List<NewsItem>> fetchLatestNews() async {
    final response = await http.get(Uri.parse('${widget.source}/berita?limit=20'));

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      List<dynamic> data = jsonResponse['data'];
      return data.map((item) => NewsItem.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load latest news');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<NewsItem>>(
      future: futureLatestNews,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final limitData = snapshot.data!.take(5).toList();
          return SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                final item = limitData[index];
                return GestureDetector(
                  onTap: () {
                    if (kIsWeb) {
                      _launchURL(item.link);
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailScreen(linkNews: item.link),
                        ),
                      );
                    }
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 15, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10)
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          ClipRRect(
                              borderRadius: BorderRadius.horizontal(
                                left: Radius.circular(8)
                              ),
                              child: item.image.isEmpty
                                ? Image.asset('assets/icons/ic_no_img.png',
                                  width: 118,
                                  height: 114,
                                  fit: BoxFit.cover,
                              )
                                : Image.network(item.image,
                                  width: 118,
                                  height: 114,
                                  fit: BoxFit.cover,
                              )
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                //title
                                Text(
                                  item.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    height: 1.3
                                  ),
                                ),
                                SizedBox(height: 20),
                                //footer
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    //logo
                                    Row(
                                      children: [
                                        Container(
                                          width: 24,
                                          height: 24,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(4),
                                            image: DecorationImage(
                                              image: NetworkImage(item.icImage),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 5),
                                        //source
                                        Text(
                                          item.source,
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey.shade600,
                                              fontWeight: FontWeight.w500
                                          ),
                                        ),
                                      ],
                                    ),
                                    //time badge
                                    Text(
                                      item.pubTime,
                                      style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
              childCount: limitData.length,
            ),
          );
        } else if (snapshot.hasError) {
          return SliverToBoxAdapter(
            child: Container(
              height: 285,
              alignment: Alignment.center,
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.cloud_off,
                    color: Colors.blue.shade300,
                    size: 60,
                  ),
                  const SizedBox(height: 15,),
                  Text('Gagal memuat Berita Terbaru.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 16,
                        fontWeight: FontWeight.w500
                    ),
                  )
                ],
              ),
            ),
          );
        } else {
          return SliverToBoxAdapter(
            child: Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }
}

// New Screen for Publisher Specific News
class PublisherNewsScreen extends StatefulWidget {
  final String publisherId;
  final String source;

  PublisherNewsScreen({
    required this.publisherId,
    required this.source});

  @override
  State<PublisherNewsScreen> createState() => _PublisherNewsScreenState();
}

class _PublisherNewsScreenState extends State<PublisherNewsScreen> {
  late Future<List<NewsItem>> futurePublisherNews;

  @override
  void initState() {
    super.initState();
    futurePublisherNews = fetchPublisherNews();
  }

  Future<List<NewsItem>> fetchPublisherNews() async {
    final response = await http.get(Uri.parse('${widget.source}/berita/${widget.publisherId}'));

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      List<dynamic> data = jsonResponse['data'];
      return data.map((item) => NewsItem.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load publisher news');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Berita Publisher"),
      ),
      body: FutureBuilder<List<NewsItem>>(
        future: futurePublisherNews,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No data available'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final item = snapshot.data![index];
                return ListTile(
                  leading: Image.network(item.image),
                  title: Text(item.title),
                  subtitle: Text(item.source),
                  onTap: () {
                    if (kIsWeb) {
                      _launchURL(item.link);
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailScreen(linkNews: item.link),
                        ),
                      );
                    }
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}