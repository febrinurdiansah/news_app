import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../Model/data.dart';
import 'Detail.dart';

void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

class PubliserScreen extends StatelessWidget {
  final String source;
  final String namePub;
  final String image;
  final List<String> categories;

  const PubliserScreen({Key? key, required this.source, required this.namePub, required this.image, required this.categories})
      : super(key: key);

  String capitalize(String s) => s.split(' ').map((word) {
        return word[0].toUpperCase() + word.substring(1);
      }).join(' ');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: DefaultTabController(
        length: categories.length,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Diterbitkan oleh",
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            namePub,
                            style: TextStyle(
                              fontSize: 34,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Container(
                        width: 130,
                        height: 120,
                        decoration: BoxDecoration(
                          image: DecorationImage(image: NetworkImage(image)),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: TabBar(
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                indicatorColor: Colors.blueAccent,
                automaticIndicatorColorAdjustment: true,
                tabs: categories
                    .map((category) => Tab(text: capitalize(category)))
                    .toList(),
              ),
            ),
            ListTabbarWidget(source: source, categories: categories),
          ],
        ),
      ),
    );
  }
}


class ListTabbarWidget extends StatelessWidget {
  final String source;
  final List<String> categories;

  const ListTabbarWidget({
    Key? key,
    required this.source,
    required this.categories,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      child: TabBarView(
        children: categories.map((category) {
          return TabBarScrollWidget(source: source, category: category);
        }).toList(),
      ),
    );
  }
}


class TabBarScrollWidget extends StatefulWidget {
  final String source;
  final String category;

  const TabBarScrollWidget({
    Key? key,
    required this.source,
    required this.category,
  }) : super(key: key);

  @override
  State<TabBarScrollWidget> createState() => _TabBarScrollWidgetState();
}

class _TabBarScrollWidgetState extends State<TabBarScrollWidget> {
  late Future<List<NewDataNews>> futureData;

  @override
  void initState() {
    super.initState();
    futureData = fetchData();
  }

  Future<List<NewDataNews>> fetchData() async {
    final url = 'https://node-api-mu-ochre.vercel.app/${widget.source}/${widget.category}';
    print('Fetching data from: $url');

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        List<dynamic> dataNews = jsonResponse['data_news'];
        print('Data fetched successfully: ${dataNews.length} items');
        return dataNews.map((data) => NewDataNews.fromJson(data)).toList();
      } else {
        print('Failed to load API with status code: ${response.statusCode}');
        throw Exception('Failed to load API');
      }
    } catch (e) {
      print('Exception caught: $e');
      throw Exception('Failed to load API');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<NewDataNews>>(
      future: futureData,
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
                            image: item.image.isNotEmpty
                                ? DecorationImage(image: NetworkImage(item.image), fit: BoxFit.cover)
                                : null,
                            color: item.image.isEmpty ? Colors.grey : null,
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
                              style: TextStyle(fontSize: 18),
                            ),
                            SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: Container(
                                        width: 24,
                                        height: 24,
                                      ),
                                    ),
                                    SizedBox(width: 5),
                                  ],
                                ),
                                Text(item.pubTime, style: TextStyle(fontSize: 12)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }
}



