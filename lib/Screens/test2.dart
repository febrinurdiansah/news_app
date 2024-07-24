import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:news_app/Model/data.dart';
import 'Detail.dart';

class Test2Screen extends StatefulWidget {
  @override
  State<Test2Screen> createState() => _Test2ScreenState();
}

class _Test2ScreenState extends State<Test2Screen> {
  TextEditingController _searchController = TextEditingController();
  Future<List<SearchData>>? _searchResultsFuture;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: EdgeInsets.only(top: 60, left: 15, right: 15, bottom: 30),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Explorasi",
                  style: TextStyle(fontSize: 26),
                ),
                SizedBox(height: 5),
                Text(
                  "Terus explore dunia dan terus dapatkan informasi terbaru",
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 10),
                Container(
                  height: 30,
                  color: Colors.cyan,
                ),
                TextFormField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: "Pencarian..",
                    border: InputBorder.none,
                    suffixIcon: IconButton(
                      onPressed: () => _performSearch(_searchController.text),
                      icon: Icon(Icons.search),
                    ),
                  ),
                  onFieldSubmitted: (value) {
                    _performSearch(value);
                  },
                ),
                SizedBox(height: 10),
                _buildSearchResults(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _performSearch(String query) {
    setState(() {
      _searchResultsFuture = fetchData(query);
    });
  }

  Widget _buildSearchResults() {
    if (_searchResultsFuture == null) {
      return Center(child: Text("Berita belum dicari"));
    } else {
      return FutureBuilder<List<SearchData>>(
        future: _searchResultsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("Berita pencarian tidak ditemukan."));
          } else {
            List<SearchData> results = snapshot.data!;
            return ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: results.length,
              itemBuilder: (context, index) {
                var result = results[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => 
                        DetailScreen(
                          linkNews: result.link,
                        )
                      ),
                    );
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            width: 118,
                            height: 114,
                            decoration: BoxDecoration(
                              image: DecorationImage(image: NetworkImage(result.image),
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
                                result.title,
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
                                  Text(
                                        result.source,
                                        style: TextStyle(
                                          fontSize: 14,
                                        ),
                                  ),
                                  Text(
                                    result.date,
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
            );
          }
        },
      );
    }
  }

  // Fetch data function
  Future<List<SearchData>> fetchData(String query) async {
    final response = await http.get(Uri.parse('https://node-api-mu-ochre.vercel.app/search?keyword=$query'));

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = jsonDecode(response.body);
      return jsonResponse.map((data) => SearchData.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load API');
    }
  }
}