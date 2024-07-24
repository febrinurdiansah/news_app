import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:news_app/Model/data.dart';
import 'package:news_app/Screens/Detail.dart';
import 'package:news_app/Screens/LatestNews.dart';
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

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          title: Text("Satu Berita"),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(100),
            child: PubliserWidget(),
          ),
        ),
        SliverToBoxAdapter(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Berita Trending",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold
                        ),
                      ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(
                          builder: (context) => TrendingScreen(),
                          ));
                      },
                      child: Text("Lihat Semua",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold
                          ),
                        ),
                    ),
                  ],
                ),
              ),
              TrendingWidget(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Berita Terbaru",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold
                        ),
                      ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(
                          builder: (context) => ExploreScreen(),
                          ));
                      },
                      child: Text("Lihat Semua",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold
                          ),
                        ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        LatestNewsScroll()
      ],
    );
  }
}

class TrendingWidget extends StatefulWidget {

  @override
  State<TrendingWidget> createState() => _TrendingWidgetState();
}

class _TrendingWidgetState extends State<TrendingWidget> {
  late Future<List<TrenDataNews>> futureData;

  @override
  void initState() {
    super.initState();
    futureData = fetchData();
  }

  Future<List<TrenDataNews>> fetchData() async {
    final response =
      await http.get(Uri.parse('https://node-api-mu-ochre.vercel.app/trending'));

    if (response.statusCode == 200 ){
      List<dynamic> jsonResponse = jsonDecode(response.body);
      return jsonResponse.map((data) => TrenDataNews.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load API');
    }
  }


  @override
Widget build(BuildContext context) {
  return FutureBuilder<List<TrenDataNews>>(
    future: futureData, 
    builder: (context, AsyncSnapshot<List<TrenDataNews>> snapshot) {
      if (snapshot.hasData) {
        return Container(
          padding: EdgeInsets.only(left: 15, top: 10),
          height: 285,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: snapshot.data!.length > 5 ? 5 : snapshot.data!.length,
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
                  width: 301,
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              width: 285,
                              height: 161,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: NetworkImage(item.image),
                                  fit: BoxFit.cover
                                  )
                              ),
                            ),
                          ),
                          Positioned(
                            top: 15, 
                            left: 20,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(5),
                              child: Container(
                                height: 27,
                                color: Colors.blueGrey,
                                padding: EdgeInsets.all(5),
                                child: Text(
                                  item.category.isNotEmpty ? item.category[0] : '',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(15),
                        child: Text(item.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 18
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: Image.network(
                                      item.icImage.isNotEmpty ? item.icImage : '',
                                      errorBuilder: (context, error, stackTrace) {
                                        return Image.asset('assets/icons/ic_no_img.png');
                                      },
                                    ),
                                  ),
                                ),
                                SizedBox(width: 5,),
                                Container(
                                  width: 100,
                                  child: Text(
                                    item.source,
                                    style: TextStyle(
                                      fontSize: 14,
                                      overflow: TextOverflow.ellipsis
                                    ),
                                  ),
                                )
                              ],
                            ),
                            Text(item.pubTime,
                              style: TextStyle(
                                fontSize: 12
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
        return Text('Error: ${snapshot.error}');
      } else {
        return CircularProgressIndicator();
      }
    },
  );
}
}