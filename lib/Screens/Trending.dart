import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../Model/data.dart';
import 'Detail.dart';

class TrendingScreen extends StatefulWidget {
  @override
  State<TrendingScreen> createState() => _TrendingScreenState();
}

class _TrendingScreenState extends State<TrendingScreen> {
  late Future<List<TrenDataNews>> futureData;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    futureData = fetchData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<List<TrenDataNews>> fetchData() async {
    final response = await http.get(Uri.parse('https://node-api-mu-ochre.vercel.app/trending'));

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = jsonDecode(response.body);
      return jsonResponse.map((data) => TrenDataNews.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load API');
    }
  }

  Widget _buildTrendingBadge(int index) {
    if (index < 3) {
      List<Color> badgeColors = [
        Colors.orange,
        Colors.red,
        Colors.purple
      ];

      List<IconData> badgeIcons = [
        Icons.local_fire_department,
        Icons.trending_up,
        Icons.star
      ];

      return Positioned(
          top: 8,
          left: 8,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: badgeColors[index],
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12.withOpacity(0.2),
                  blurRadius: 4,
                  offset: Offset(0, 2)
                )
              ]
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  badgeIcons[index],
                  color: Colors.white,
                  size: 12,
                ),
                SizedBox(width: 4,),
                Text(
                  'Trending ${index + 1}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold
                  ),
                )
              ],
            ),
          )
      );
    }
    return SizedBox();
  }

  Widget _buildNewsCard(TrenDataNews item, int index) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.1),
            blurRadius: 12,
            offset: Offset(0, 4)
          )
        ]
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(
                builder: (context) => DetailScreen(linkNews: item.link),
            ));
          },
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //Image
                  if (item.image.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16)
                      ),
                      child: Container(
                        width: double.infinity,
                        height: 160,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                              image: NetworkImage(item.image),
                              fit: BoxFit.cover
                          )
                        ),
                      ),
                    ),
                  //Content
                  Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              height: 1.4,
                              color: Colors.grey.shade800
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 12,),
                          Row(
                            children: [
                              //Source Icon + Name
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.grey.shade100,
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                    width: 1
                                  )
                                ),
                                child: ClipOval(
                                  child: item.icImage.isNotEmpty
                                      ? Image.network(
                                          item.icImage,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Icon(
                                              Icons.article,
                                              size: 16,
                                              color: Colors.grey.shade500,
                                            );
                                          },
                                        )
                                      : Icon(
                                          Icons.article,
                                          size: 16,
                                          color: Colors.grey.shade500,
                                      )
                                ),
                              ),
                              SizedBox(width: 8,),
                              Expanded(
                                  child: Text(
                                    item.source,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey.shade700
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  )
                              ),
                              //Time + Engagement
                              Row(
                                children: [
                                  Icon(
                                    Icons.schedule,
                                    size: 14,
                                    color: Colors.grey.shade500,
                                  ),
                                  SizedBox(width: 4,),
                                  Text(
                                    item.pubTime,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600
                                    ),
                                  )
                                ],
                              )
                            ],
                          )
                        ],
                      )
                  )
                ],
              ),
              _buildTrendingBadge(index)
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompactNewsCard(TrenDataNews item, int index) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200!,
          width: 1
        )
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(
                  builder: (context) => DetailScreen(linkNews: item.link))
            );
          },
          child: Padding(
              padding: EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //Nurmber indicator
                  Container(
                    width: 24,
                    height: 24,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: index < 3
                          ? [Colors.orange, Colors.red, Colors.purple][index]
                          : Colors.grey.shade300,
                      shape: BoxShape.circle
                    ),
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                  SizedBox(width: 12,),
                  //Content
                  Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              height: 1.3
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 6,),
                          Row(
                            children: [
                              Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                      image: NetworkImage(item.icImage),
                                      fit: BoxFit.cover
                                  )
                                ),
                              ),
                              SizedBox(width: 6,),
                              Text(
                                item.source,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade600
                                ),
                              ),
                              SizedBox(width: 12,),
                              Icon(
                                Icons.schedule,
                                size: 12,
                                color: Colors.grey.shade500,
                              ),
                              SizedBox(width: 2,),
                              Text(
                                item.pubTime,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade600
                                ),
                              )
                            ],
                          )
                        ],
                      )
                  )
                ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          'Trending News',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.grey.shade800
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      body: FutureBuilder<List<TrenDataNews>>(
        future: futureData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16,),
                  Text(
                    'Memuat berita trending...',
                    style: TextStyle(
                      color: Colors.grey.shade600
                    ),
                  )
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  SizedBox(height: 16,),
                  Text(
                    'Gagal memuat data',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600
                    ),
                  ),
                  SizedBox(height: 8,),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        futureData = fetchData();
                      });
                    },
                    child: Text('Coba lagi')
                  )
                ],
              ),
            );
          } else if (snapshot.hasData) {
            final data = snapshot.data!;

            return RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  futureData = fetchData();
                });
              },
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  //Header
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.trending_up,
                            color: Colors.orange,
                            size: 24,
                          ),
                          SizedBox(width: 8,),
                          Text(
                            'Sedang Trending',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade800
                            ),
                          ),
                          SizedBox(height: 4,),
                          Text(
                            'Berita paling populer saat ini',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600
                            ),
                          )
                        ],
                      ),
                    ),
                  ),

                  //Top 3 Trending (Card Style)
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index < 3 && index < data.length) {
                          return _buildNewsCard(data[index], index);
                        }
                        return SizedBox();
                      },
                      childCount: data.length >= 3 ? 3 : data.length
                    ),
                  ),

                  //Divider
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Divider(
                        color: Colors.grey.shade300,
                        thickness: 1,
                      ),
                    ),
                  ),

                  // More Trending (Compact style)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text(
                        'Lainnya',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700
                        ),
                      ),
                    ),
                  ),

                  // Remaining item in compact style
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final actualIndex = index + 3;
                        if (actualIndex < data.length) {
                          return _buildCompactNewsCard(data[actualIndex], actualIndex);
                        }
                        return SizedBox();
                      },
                      childCount: data.length > 3 ? data.length - 3 : 0
                    ),
                  ),

                  // Bottom padding
                  SliverToBoxAdapter(
                    child: SizedBox(height: 16,),
                  )
                ],
              )
            );
          } else {
            return Center(
              child: Text('Tidak ada data'),
            );
          }
        },
      ),
    );
  }
}