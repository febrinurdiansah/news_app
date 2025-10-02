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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back,
              color: Colors.black,
            )
        ),
        title: Text(namePub,
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600
          ),
        ),
      ),
      body: categories.isEmpty
          ? _buildNoCategories()
          : _buildWithCategories()
    );
  }

  Widget _buildNoCategories() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.category, size: 60, color: Colors.grey.shade300,),
          SizedBox(height: 16,),
          Text(
            'Tidak ada Kategori',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500
            ),
          ),
          SizedBox(height: 8,),
          Text(
            'Publisher ini belum memiliki kategori',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade400
            ),
          )
        ],
      ),
    );
  }

  Widget _buildWithCategories() {
    return DefaultTabController(
      length: categories.length,
      child: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          //Header
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              padding: EdgeInsets.all(20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //Publiser Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Diterbitkan oleh",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w400
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          namePub,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey.shade800,
                            height: 1.2
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Telusuri berita terkini dari $namePub bedasarkan kategori',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w400
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(width: 16),
                  //Publiser Logo
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey.shade200!,
                        width: 1
                      )
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(image,
                      fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey.shade200,
                            child: Icon(Icons.newspaper, color: Colors.grey.shade400,),
                          );
                        },
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          // Tab Bar
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverAppBarDelegate(
              TabBar(
                isScrollable: true,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicatorColor: Colors.blue.shade600,
                  labelColor: Colors.blue.shade600,
                  unselectedLabelColor: Colors.grey.shade600,
                  labelStyle: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400
                  ),
                  unselectedLabelStyle: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400
                  ),
                  indicatorPadding: EdgeInsets.symmetric(horizontal: 8),
                  tabs: categories.map((category) {
                    return Tab(
                      text: category.split(' ')
                        .map((word) => word.isNotEmpty
                          ? word[0].toUpperCase() + word.substring(1).toLowerCase()
                      : '')
                      .join(' '),
                    );
                  }).toList(),
              )
            ),
          ),
        ];
        },
        body: TabBarView(
            children: categories.map((category) {
              return PublisherNewsByCategory(
                source: source,
                category: category.toLowerCase(),
                  publisherName: namePub
              );
            }).toList(),
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shirnkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}

class PublisherNewsByCategory extends StatefulWidget {
  final String source;
  final String category;
  final String publisherName;

  const PublisherNewsByCategory({
    Key? key,
    required this.source,
    required this.category,
    required this.publisherName
  }) : super(key: key);

  @override
  State<PublisherNewsByCategory> createState() => _PublisherNewsByCategoryState();
}

class _PublisherNewsByCategoryState extends State<PublisherNewsByCategory> {
  late Future<List<NewsItem>> futureNews;
  late final String mainLink = MainSource().source;

  @override
  void initState() {
    super.initState();
    futureNews = fetchNewsByCategoty();
  }

  Future<List<NewsItem>> fetchNewsByCategoty() async {
    try{
      final response = await http.get(
        Uri.parse('${mainLink}/berita/${widget.source}/${widget.category}')
      );
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        List<dynamic> data = jsonResponse['data'];

        return data.map((item) => NewsItem.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load news for ${widget.category}');
      }
    } catch (e) {
      throw Exception('Failed to load news: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<NewsItem>>(
        future: futureNews,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Padding(
                  padding: const EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Padding(
                  padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 50, color: Colors.grey.shade400),
                    SizedBox(height: 16,),
                    Text(
                      'Gagal memuat berita',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600
                      ),
                    ),
                    SizedBox(height: 8,),
                    Text(
                      snapshot.error.toString(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade500
                      ),
                    )
                  ],
                ),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty){
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.article, size: 50, color: Colors.grey.shade300),
                  SizedBox(height: 16),
                  Text(
                    'Tidak ada berita',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade500
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tidak ada berita untuk kategori ${widget.category}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade400
                    ),
                  )
                ],
              ),
            );
          } else {
            return ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final item = snapshot.data![index];
                  return GestureDetector(
                    onTap: () {
                      if (kIsWeb) {
                        _launchURL(item.link);
                      }else {
                        Navigator.push(context, MaterialPageRoute(
                            builder: (context) => DetailScreen(linkNews: item.link),
                        ));
                      }
                    },
                    child: Container(
                      margin: EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: Offset(0, 2)
                          )
                        ]
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Image Section
                          if (item.image.isNotEmpty)
                            ClipRRect(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                              child: Container(
                                width: double.infinity,
                                height: 180,
                                child: Image.network(
                                  item.image,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey.shade200,
                                      child: Icon(Icons.broken_image, color: Colors.grey.shade400,),
                                    );
                                  },
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null ) return child;
                                    return Container(
                                      color: Colors.grey.shade200,
                                      child: Center(child: CircularProgressIndicator()),
                                    );
                                  },
                                ),
                              ),
                            ),
                          //Content Section
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                //Title
                                Text(
                                  item.title,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade800,
                                    height: 1.4
                                  ),
                                ),
                                SizedBox(height: 12),

                                //Footer Section
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    //Source and Time
                                    Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              widget.publisherName,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.blue.shade600,
                                                fontWeight: FontWeight.w500
                                              ),
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              item.pubTime,
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.grey.shade500,
                                                fontWeight: FontWeight.w400
                                              ),
                                            )
                                          ],
                                        )
                                    ),

                                    //Category Badge
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade50,
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: Colors.grey.shade200!
                                        )
                                      ),
                                      child: Text(
                                        widget.category.toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey.shade600,
                                          fontWeight: FontWeight.w500
                                        ),
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
            );
          }
        },
    );
  }
}
