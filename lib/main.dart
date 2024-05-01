import 'dart:async';
import 'package:flutter/material.dart';
import 'package:algolia/algolia.dart';

void main() {
  runApp(MyApp());
  
}

class MyApp extends StatelessWidget {
  final algolia = const Algolia.init(
    applicationId: '927KXQII1J',
    apiKey: '7b2231caa335d18e963b3942a242e0f6',
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Algolia Search App',
      home: SearchScreen(algolia: algolia),
    );
  }
}

class SearchScreen extends StatefulWidget {
  final Algolia algolia;

  SearchScreen({required this.algolia});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> searchResults = [];
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    // _searchController.text = "motor";
    _timer = Timer.periodic(const Duration(milliseconds: 500), (Timer t) {
      searchAlgolia(_searchController.text);
    });
  }

 void setAttributesForFaceting(String category, String price) async {
    Map<String, dynamic> settings = {
      'attributesForFaceting': [category, price]
    };

    await widget.algolia.instance.index('name').facetFilter(settings);
  }
  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void searchAlgolia(String query) async {
    AlgoliaQuerySnapshot snap =
        await widget.algolia.instance.index('name').search(query).getObjects();
    setState(() {
      searchResults = snap.hits;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Algolia Search App'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: Colors.blue, width: 2.0),
                  ),
                  // filled: true,
                  // fillColor: Colors.grey[200],
                  hintText: 'Search',
                  prefixIcon: Icon(Icons.search),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setAttributesForFaceting("","200");
                      print("object");
                    },
                    icon: Icon(Icons.tune),
                  ),
                ),
              ),
            ),
            // ElevatedButton(
            //   onPressed: () {
            //     searchAlgolia(_searchController.text);
            //   },
            //   child: Text('Search'),
            // ),
            Expanded(
              child: ListView.builder(
                itemCount: searchResults.length,
                itemBuilder: (context, index) {
                  AlgoliaObjectSnapshot result = searchResults[index];
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(
                            255, 217, 210, 210), // Example background color
                        borderRadius: BorderRadius.circular(
                            10.0), // Example border radius
                      ),
                      child: ListTile(
                        title: Text(
                          result.data['name'].toString(),
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 17,
                              fontWeight: FontWeight.bold),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(result.data['description']),
                        ),
                        trailing: Text(
                          "Price:- ${result.data['price'].toString()}",
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 17,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
