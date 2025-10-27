import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../Model/data.dart';
import 'Detail.dart';

class ExploreScreen extends StatefulWidget {
  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final List<NewsItem> _newsItems = [];
  final int _itemsPerPage = 20;
  int _currentPage = 0;
  bool _isLoading = false;
  bool _hasMore = true;
  late final String mainSource = MainSource().source;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadMoreNews();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMoreNews();
    }
  }

  Future<void> _loadMoreNews() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final newItems = await fetchData(_currentPage, _itemsPerPage);

      setState(() {
        _newsItems.addAll(newItems);
        _currentPage++;
        _hasMore = newItems.length == _itemsPerPage;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error loading more news: $e');
    }
  }

  Future<List<NewsItem>> fetchData(int page, int limit) async {
    final response = await http.get(
        Uri.parse('$mainSource/terbaru?page=$page&limit=$limit')
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      List<dynamic> mergerApi = jsonResponse['merger_api'];
      return mergerApi.map((data) => NewsItem.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load API');
    }
  }

  Widget _buildFeaturedNews() {
    if (_newsItems.isEmpty) return SizedBox();

    return Container(
      width: double.infinity,
      height: 200,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.grey.shade200
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children:  [
            _newsItems[0].image.isNotEmpty
            ? Image.network(
              _newsItems[0].image,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: Icon(
                    Icons.image_not_supported_outlined,
                    size: 50,
                    color: Colors.grey,
                  ),
                );
              },
            )
            : const Center(
              child: Icon(
                Icons.image_not_supported_outlined,
                size: 50,
                color: Colors.grey,
              ),
            ),
            Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.8),
                    Colors.transparent
                  ]
              )
            ),
            child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(4)
                      ),
                      child: Text(
                        'TERBARU',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                    SizedBox(height: 8,),
                    Text(
                      _newsItems[0].title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8,),
                    Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey.shade300
                          ),
                          child: _newsItems[0].icImage.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.network(
                                  _newsItems[0].icImage,
                                  fit: BoxFit.cover,
                                )
                          ) : const Icon(Icons.source, size: 14, color: Colors.grey,)
                        ),
                        SizedBox(width: 8,),
                        Text(
                          _newsItems[0].source,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12
                          ),
                        ),
                        SizedBox(width: 16,),
                        Text(
                          _newsItems[0].pubTime,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 12
                          ),
                        )
                      ],
                    )
                  ],
                ),
            ),
          ),
        ]
        ),
      ),
    );
  }

  Widget _buildNewsItem(NewsItem item, int index) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 2
            )
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(
                builder: (context) => DetailScreen(linkNews: item.link),
              )
            );
          },
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            height: 1.4
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 12,),
                        Row(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.grey.shade300
                              ),
                              child: item.icImage.isNotEmpty
                                ? Image.network(
                                  item.icImage,
                                  fit: BoxFit.cover,
                              ) : Icon(Icons.source, size: 14,)
                            ),
                            SizedBox(width: 8,),
                            Text(
                              item.source,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500
                              ),
                            ),
                            SizedBox(width: 16,),
                            Icon(
                              Icons.access_time,
                              size: 14,
                              color: Colors.grey.shade500,
                            ),
                            SizedBox(width: 4,),
                            Text(
                              item.pubTime,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500
                              ),
                            )
                          ],
                        )
                      ],
                    )
                ),
                SizedBox(width: 12,),
                if (item.image.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(item.image),
                          fit: BoxFit.cover
                        ),
                        color: Colors.grey.shade200
                      ),
                    ),
                  )
              ],
            )
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Divider(
        color: Colors.grey.shade300,
        height: 1,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
            "Berita Terbaru",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      body: _newsItems.isEmpty && _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (_newsItems.isNotEmpty) _buildFeaturedNews(),

                Expanded(
                    child: RefreshIndicator(
                        onRefresh: () async {
                          setState(() {
                            _newsItems.clear();
                            _currentPage = 0;
                            _hasMore = true;
                          });
                          await _loadMoreNews();
                        },
                      child: ListView.separated(
                        controller: _scrollController,
                        physics: AlwaysScrollableScrollPhysics(),
                        itemCount: _newsItems.length + (_hasMore ? 1 : 0),
                        separatorBuilder: (context, index) => _buildDivider(),
                        itemBuilder: (context, index) {
                          if (index == 0 && _newsItems.isNotEmpty) {
                            return SizedBox();
                          } else if ( index < _newsItems.length) {
                            final adjustedIndex = _newsItems.length > 1 ? index : 0;
                            return _buildNewsItem(_newsItems[adjustedIndex], adjustedIndex);
                          } else {
                            return _buildLoadingIndicator();
                          }
                        },
                      ),
                    )
                )
              ],
      )
    );
  }

  Widget _buildLoadingIndicator() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: _isLoading
            ? CircularProgressIndicator()
            : _hasMore
            ? SizedBox()
            : Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Tidak ada berita lagi',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
          );
  }
}
//
