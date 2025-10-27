import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:news_app/Model/data.dart';
import 'package:news_app/Screens/Detail.dart';
import 'package:news_app/Screens/Publiser.dart';
import 'package:url_launcher/url_launcher.dart';


void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

//Not used(maybe)
class LatestNewsScroll extends StatefulWidget {
  late final MainSource source;

  @override
  State<LatestNewsScroll> createState() => _LatestNewsScrollState();
}
class _LatestNewsScrollState extends State<LatestNewsScroll> {
  late Future<List<NewsItem>> futureData;

  @override
  void initState() {
    super.initState();
    futureData = fetchData();
  }

  Future<List<NewsItem>> fetchData() async {
    final response =
        await http.get(Uri.parse('${widget.source}/berita'));

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      List<dynamic> mergerApi = jsonResponse['merger_api'];
      return mergerApi
          .map((data) => NewsItem.fromJson(data))
          .toList();
    } else {
      throw Exception('Failed to load API');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: futureData,
      builder: (context, AsyncSnapshot<List<NewsItem>> snapshot) {
        if (snapshot.hasData) {
          return SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                final item = snapshot.data![index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          if (kIsWeb) {
                            _launchURL(item.link);
                            Navigator.pop(context);
                            return Container();
                          } else {
                            return DetailScreen(linkNews: item.link);
                          }
                        },
                      ),
                    );
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            width: 118,
                            height: 114,
                            decoration: BoxDecoration(
                              image: DecorationImage(image: NetworkImage(item.image),
                              fit: BoxFit.cover
                              )
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 18,
                                ),
                              ),
                              SizedBox(height: 20),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: Container(
                                          width: 24,
                                          height: 24,
                                          decoration: BoxDecoration(
                                            image: DecorationImage(image: NetworkImage(item.icImage))
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 5),
                                      Text(
                                        item.source,
                                        style: TextStyle(
                                          fontSize: 14,
                                        ),
                                      )
                                    ],
                                  ),
                                  Text(
                                    item.pubTime,
                                    style: TextStyle(
                                      fontSize: 12,
                                    ),
                                  )
                                ],
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
              childCount: snapshot.data!.length > 10 ? 10 : snapshot.data!.length,
            ),
          );
        } else if (snapshot.hasError) {
          return SliverToBoxAdapter(
            child: Center(
              child: Text('Error: ${snapshot.error}'),
            ),
          );
        } else {
          return SliverToBoxAdapter(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }
}

//Not used(maybe)
class PubliserWidget extends StatefulWidget {
  late final MainSource source;

  @override
  State<PubliserWidget> createState() => _PubliserWidgetState();
}
class _PubliserWidgetState extends State<PubliserWidget> {
  late Future<List<PubliserData>> futureData;

  @override
  void initState() {
    super.initState();
    futureData = fetchData();
  }

  Future<List<PubliserData>> fetchData() async {
    final response =
      await http.get(Uri.parse('${widget.source}/publiser'));

    if (response.statusCode == 200 ){
      Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      List<dynamic> publiserApi = jsonResponse['publiser_all'];
      return publiserApi
        .map((data) => PubliserData.fromJson(data))
        .toList();
    } else {
      throw Exception('Failed to load API');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: futureData,
      builder: (context, AsyncSnapshot<List<PubliserData>> snapshot) {
        if (snapshot.hasData) {
          return Container(
            height: 80,
            margin: EdgeInsets.only(left: 15, bottom: 10),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final item = snapshot.data![index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context) =>
                            PubliserScreen(
                              source: item.id,
                              namePub: item.name,
                              image: item.icImage,
                              categories: item.category,
                            ),
                      )
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.black,
                          width: 0.5
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(40)),
                        image: DecorationImage(
                          image: NetworkImage(item.icImage),
                          fit: BoxFit.cover
                          )
                      ),
                    ),
                  ),
                );
              },
            )
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}

//Not used (maybe)
class ExploreNewsScroll extends StatefulWidget {
  @override
  State<ExploreNewsScroll> createState() => _ExploreNewsScrollState();
}
class _ExploreNewsScrollState extends State<ExploreNewsScroll> {
  late Future<List<NewsItem>> futureData;

  @override
  void initState() {
    super.initState();
    futureData = fetchData();
  }

  Future<List<NewsItem>> fetchData() async {
    final response =
        await http.get(Uri.parse('https://node-api-mu-ochre.vercel.app/explore'));

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      List<dynamic> mergerApi = jsonResponse['merger_api'];
      return mergerApi
          .map((data) => NewsItem.fromJson(data))
          .toList();
    } else {
      throw Exception('Failed to load API');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: futureData,
      builder: (context, AsyncSnapshot<List<NewsItem>> snapshot) {
        if (snapshot.hasData) {
          return SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                final item = snapshot.data![index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          if (kIsWeb) {
                            _launchURL(item.link);
                            Navigator.pop(context);
                            return Container();
                          } else {
                            return DetailScreen(linkNews: item.link);
                          }
                        },
                      ),
                    );
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            width: 118,
                            height: 114,
                            decoration: BoxDecoration(
                              image: DecorationImage(image: NetworkImage(item.image),
                              fit: BoxFit.cover
                              )
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 18,
                                ),
                              ),
                              SizedBox(height: 20),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: Container(
                                          width: 24,
                                          height: 24,
                                          decoration: BoxDecoration(
                                            image: DecorationImage(image: NetworkImage(item.icImage))
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 5),
                                      Text(
                                        item.source,
                                        style: TextStyle(
                                          fontSize: 14,
                                        ),
                                      )
                                    ],
                                  ),
                                  Text(
                                    item.pubTime,
                                    style: TextStyle(
                                      fontSize: 12,
                                    ),
                                  )
                                ],
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
              childCount: snapshot.data!.length,
            ),
          );
        } else if (snapshot.hasError) {
          return SliverToBoxAdapter(
            child: Center(
              child: Text('Error: ${snapshot.error}'),
            ),
          );
        } else {
          return SliverToBoxAdapter(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }
}