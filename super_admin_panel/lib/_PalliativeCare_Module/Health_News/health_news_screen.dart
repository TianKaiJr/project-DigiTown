import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:super_admin_panel/_Panchayat_Module/widgets/custom_appbar.dart';
import 'package:super_admin_panel/___Core/Theme/app_pallete.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

class HealthNewsScreen extends StatefulWidget {
  @override
  _HealthNewsScreenState createState() => _HealthNewsScreenState();
}

class _HealthNewsScreenState extends State<HealthNewsScreen> {
  List articles = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchHealthNews();
  }

  Future<void> fetchHealthNews() async {
    final apiKey = dotenv.env['NEWSAPI_KEY']; // Load API key from .env
    final url = Uri.parse(
        'https://newsapi.org/v2/top-headlines?category=health&country=us&apiKey=$apiKey');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          articles = data['articles'];
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load news");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Error fetching news: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: ("Health News & Awareness"),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : articles.isEmpty
              ? Center(child: Text("No news available"))
              : ListView.builder(
                  padding: EdgeInsets.all(8),
                  itemCount: articles.length,
                  itemBuilder: (context, index) {
                    final article = articles[index];
                    return Card(
                      color: AppPallete.cardColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      elevation: 3,
                      child: ListTile(
                        contentPadding: EdgeInsets.all(10),
                        leading: article['urlToImage'] != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  article['urlToImage'],
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Icon(Icons.health_and_safety,
                                size: 50, color: Colors.green),
                        title: Text(article['title'],
                            maxLines: 2, overflow: TextOverflow.ellipsis),
                        subtitle: Text(article['source']['name'] ?? "Unknown"),
                        onTap: () => _openArticle(article['url']),
                      ),
                    );
                  },
                ),
    );
  }

  void _openArticle(String url) async {
    Uri uri = Uri.parse(url);

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      print("Could not launch $url");
    }
  }
}
