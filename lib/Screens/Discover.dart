import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:news_app/Model/data.dart';
import 'package:url_launcher/url_launcher.dart';
import 'Detail.dart';

void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

class DiscoverScreen extends StatefulWidget {
  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  TextEditingController _searchController = TextEditingController();
  Future<List<SearchData>>? _searchResultsFuture;
  String _selectedTime = 'Waktu';
  String _selectedSource = 'Sumber';

  final List<String> _timeFilters = ['Waktu', 'Hari Ini', 'Kemarin', '2 Hari Terakhir', '7 Hari Terakhir'];
  final List<String> _sources = ['Sumber', 'Antara', 'CNN', 'CNBC', 'Kumparan', 'Okezone', 'Republika', 'Tempo', 'Tribun']; 

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
                Row(
                  children: [
                    DropdownButton<String>(
                      value: _selectedTime,
                      items: _timeFilters.map((String time) {
                        return DropdownMenuItem<String>(
                          value: time,
                          child: Text(time),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedTime = newValue!;
                          _filterResults();
                        });
                      },
                    ),
                    SizedBox(width: 20),
                    DropdownButton<String>(
                      value: _selectedSource,
                      items: _sources.map((String source) {
                        return DropdownMenuItem<String>(
                          value: source,
                          child: Text(source),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedSource = newValue!;
                          _filterResults();
                        });
                      },
                    ),
                  ],
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

  void _filterResults() {
    setState(() {
      // Trigger the UI to refresh and apply the filter
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
            results = _applyFilters(results);
            if (results.isEmpty) {
              return Center(child: Text("Berita tidak ditemukan."));
            }
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
                      MaterialPageRoute(
                        builder: (context) {
                          if (kIsWeb) {
                            _launchURL(result.link);
                            Navigator.pop(context);
                            return Container();
                          } else {
                            return DetailScreen(linkNews: result.link);
                          }
                        },
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


  List<SearchData> _applyFilters(List<SearchData> results) {
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    DateTime yesterday = today.subtract(Duration(days: 1));
    DateTime twoDaysAgo = today.subtract(Duration(days: 2));
    DateTime lastWeek = today.subtract(Duration(days: 7));

    if (_selectedTime != 'Waktu') {
      results = results.where((result) {
        DateTime resultTime = DateTime.fromMillisecondsSinceEpoch(result.timestamp);
        switch (_selectedTime) {
          case 'Hari Ini':
            return resultTime.isAfter(today);
          case 'Kemarin':
            return resultTime.isAfter(yesterday) && resultTime.isBefore(today);
          case '2 Hari Terakhir':
            return resultTime.isAfter(twoDaysAgo) && resultTime.isBefore(today);
          case '7 Hari Terakhir':
            return resultTime.isAfter(lastWeek) && resultTime.isBefore(today);
          default:
            return true;
        }
      }).toList();
    }

    if (_selectedSource != 'Sumber') {
      results = results.where((result) => result.source == _selectedSource).toList();
    }

    return results;
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
