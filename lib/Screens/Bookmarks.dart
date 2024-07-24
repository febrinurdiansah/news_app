import 'package:flutter/material.dart';
import 'package:news_app/Widgets/Card.dart';

class BookmarksScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(top: 60, left: 15, right: 15, bottom: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Bookmarks",
                style: TextStyle(
                  fontSize: 26
                  ),
                ),
                SizedBox(height: 5,),
                Text("Curated collection of favorite reads",
                style: TextStyle(
                  fontSize: 16
                  ),
                )
              ],
            ),
          ),
        ),
        // VerticalScrollNews()
      ],
    );
  }
}