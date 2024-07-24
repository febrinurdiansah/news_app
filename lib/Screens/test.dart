// import 'package:dynamic_searchbar/dynamic_searchbar.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:news_app/Model/data.dart';
// import 'Detail.dart';

// class TestScreen extends StatefulWidget {
//   @override
//   State<TestScreen> createState() => _TestScreenState();
// }

// class _TestScreenState extends State<TestScreen> {
//   TextEditingController _searchController = TextEditingController();
//   List<SearchData> _searchResults = [];
//   List<Map<String, dynamic>> _filteredResults = [];

//   final List<FilterAction> newsFilters = [
//     FilterAction(
//       title: 'Source',
//       field: 'source',
//       type: FilterType.selectionFilter,
//     ),
//     FilterAction(
//       title: 'Date',
//       field: 'dateTime', // Use dateTime field for date filter
//       type: FilterType.dateRangeFilter,
//       dateRange: DateTimeRange(
//         start: DateTime(2023, 1, 1),
//         end: DateTime.now(),
//       ),
//     ),
//   ];

//   final List<SortAction> newsSort = [
//     SortAction(
//       title: 'Date ASC',
//       field: 'dateTime', // Use dateTime field for sorting
//     ),
//     SortAction(
//       title: 'Date DESC',
//       field: 'dateTime',
//       order: OrderType.desc,
//     ),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return CustomScrollView(
//       slivers: [
//         SliverPadding(
//           padding: EdgeInsets.only(top: 60, left: 15, right: 15, bottom: 30),
//           sliver: SliverToBoxAdapter(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   "Explorasi",
//                   style: TextStyle(fontSize: 26),
//                 ),
//                 SizedBox(height: 5),
//                 Text(
//                   "Terus explore dunia dan terus dapatkan informasi terbaru",
//                   style: TextStyle(fontSize: 16),
//                 ),
//                 SizedBox(height: 10),
//                 Container(
//                   height: 30,
//                   color: Colors.cyan,
//                 ),
//                 TextFormField(
//                   controller: _searchController,
//                   decoration: InputDecoration(
//                     hintText: "Pencarian..",
//                     border: InputBorder.none,
//                     suffixIcon: IconButton(
//                       onPressed: () => _performSearch(_searchController.text),
//                       icon: Icon(Icons.search),
//                     ),
//                   ),
//                   onFieldSubmitted: (value) {
//                     _performSearch(value);
//                   },
//                 ),
//                 SizedBox(height: 10),
//                 SearchField(
//                   disableFilter: false,
//                   filters: newsFilters,
//                   sorts: newsSort,
//                   initialData: _searchResults.map((e) => e.toJson()).toList(),
//                   onChanged: (List<dynamic> data) => setState(() {
//                     _filteredResults = List<Map<String, dynamic>>.from(data);
//                   }),
//                   onFilter: (Map filters) => print(filters),
//                 ),
//                 SizedBox(height: 10),
//                 _buildSearchResults(),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   void _performSearch(String query) async {
//     final results = await fetchData(query);
//     setState(() {
//       _searchResults = results;
//       _filteredResults = results.map((e) => e.toJson()).toList();
//     });
//   }

//   Widget _buildSearchResults() {
//     if (_filteredResults.isEmpty) {
//       return Center(child: Text("Berita belum dicari"));
//     } else {
//       return ListView.builder(
//         shrinkWrap: true,
//         physics: NeverScrollableScrollPhysics(),
//         itemCount: _filteredResults.length,
//         itemBuilder: (context, index) {
//           var result = _filteredResults[index];
//           return GestureDetector(
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => DetailScreen(
//                     linkNews: result['link'],
//                   ),
//                 ),
//               );
//             },
//             child: Container(
//               margin: EdgeInsets.symmetric(vertical: 10),
//               child: Row(
//                 children: [
//                   ClipRRect(
//                     borderRadius: BorderRadius.circular(8),
//                     child: Container(
//                       width: 118,
//                       height: 114,
//                       decoration: BoxDecoration(
//                         image: DecorationImage(
//                           image: NetworkImage(result['image']),
//                           fit: BoxFit.cover,
//                         ),
//                       ),
//                     ),
//                   ),
//                   SizedBox(width: 10),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           result['title'],
//                           maxLines: 2,
//                           overflow: TextOverflow.ellipsis,
//                           style: TextStyle(
//                             fontSize: 18,
//                           ),
//                         ),
//                         SizedBox(height: 20),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text(
//                               result['source'],
//                               style: TextStyle(
//                                 fontSize: 14,
//                               ),
//                             ),
//                             Text(
//                               result['date'],
//                               style: TextStyle(
//                                 fontSize: 12,
//                               ),
//                             )
//                           ],
//                         )
//                       ],
//                     ),
//                   )
//                 ],
//               ),
//             ),
//           );
//         },
//       );
//     }
//   }

//   Future<List<SearchData>> fetchData(String query) async {
//     final response = await http.get(Uri.parse('https://node-api-mu-ochre.vercel.app/search?keyword=$query'));
//     if (response.statusCode == 200) {
//       List<dynamic> jsonResponse = jsonDecode(response.body);
//       return jsonResponse.map((data) => SearchData.fromJson(data)).toList();
//     } else {
//       throw Exception('Failed to load API');
//     }
//   }
// }
