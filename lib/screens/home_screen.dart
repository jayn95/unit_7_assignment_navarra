import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_expanded_tile/flutter_expanded_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // The url for the API is setup outside the FutureBuilder since it causes error.
  final String url = 'https://api.disneyapi.dev/character';

  Future<http.Response> fetchData() async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) {
      throw Exception('Failed to load data');
    }
    return response;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Unit 7 - API Calls"),
      ),
      body: FutureBuilder<http.Response>(
        // setup the URL for your API here

        // Instead of setting up the url in here, the function fetchData() is called
        // which contains all the data from the API
        future: fetchData(),
        builder: (context, snapshot) {
          // Consider 3 cases here
          // when the process is ongoing
          // return CircularProgressIndicator();
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error! ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('Nothing to show'));
          }

          // when the process is completed:
          final Map<String, dynamic> responseBody =
              json.decode(snapshot.data!.body);
          final int statusCode = snapshot.data!.statusCode;
          if (statusCode > 299) {
            return Center(child: Text('Server error: $statusCode'));
          }

          final List<dynamic> characters = responseBody['data'];

          // successful
          // Use the library here
          return ExpandedTileList.builder(
            itemCount: characters.length,
            itemBuilder: (BuildContext context, int index,
                ExpandedTileController controller) {
              final character = characters[index];
              String title = character['name'] ?? 'No name available';
              String description =
                  character['sourceUrl'] ?? 'No description available';
              String imageUrl =
                  character['imageUrl'] ?? 'https://via.placeholder.com/150';

              return ExpandedTile(
                controller: controller,
                title: Text(title),
                content: Column(
                  children: [
                    Image.network(
                      imageUrl,
                      height: 300,
                      width: 300,
                      fit: BoxFit.cover,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(description),
                    ),
                  ],
                ),
              );
            },
          );
          // The error 'return Text()' is removed since it is a dead code.
        },
      ),
    );
  }
}
