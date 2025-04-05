import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:super_admin_panel/_Panchayat_Module/widgets/custom_appbar.dart';

class MedicineSearchScreen extends StatefulWidget {
  @override
  _MedicineSearchScreenState createState() => _MedicineSearchScreenState();
}

class _MedicineSearchScreenState extends State<MedicineSearchScreen> {
  TextEditingController _searchController = TextEditingController();
  Map<String, dynamic>? _medicineData;
  bool _isLoading = false;
  String _errorMessage = "";

  Future<void> fetchMedicineData(String medicineName) async {
    setState(() {
      _isLoading = true;
      _errorMessage = "";
    });

    try {
      final response = await http.get(Uri.parse(
          'https://api.fda.gov/drug/label.json?search=openfda.brand_name:$medicineName&limit=1'));

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        if (data["results"] != null && data["results"].isNotEmpty) {
          setState(() {
            _medicineData = data["results"][0];
          });
        } else {
          setState(() {
            _errorMessage = "No data found for \"$medicineName\".";
          });
        }
      } else {
        setState(() {
          _errorMessage = "Failed to fetch data. Please try again.";
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "An error occurred: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget generateSummaryWidget(Map<String, dynamic> data) {
    String brandName = data["openfda"]?["brand_name"]?[0] ?? "Unknown";
    String manufacturer =
        data["openfda"]?["manufacturer_name"]?[0] ?? "Unknown";
    String purpose = data["purpose"]?[0] ?? "No specific purpose mentioned.";
    String warnings = data["warnings"]?[0] ?? "No warnings available.";

    List<String> warningPoints = warnings
        .split(RegExp(r"\n|•"))
        .where((w) => w.trim().isNotEmpty)
        .toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Report Title
            Center(
              child: Text(
                "🏥 MEDICINE REPORT",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
            ),
            Divider(thickness: 2, color: Colors.white),

            SizedBox(height: 10),

            // Brand Name
            Text(
              "🩺 Brand Name:",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            Text(
              brandName,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 10),

            // Manufacturer
            Text(
              "🏭 Manufacturer:",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            Text(
              manufacturer,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 10),

            // Purpose
            Text(
              "🎯 Purpose:",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
            ),
            Text(
              purpose,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 20),

            // Warnings Section
            Text(
              "⚠️ WARNINGS & PRECAUTIONS",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.redAccent,
              ),
            ),
            Divider(thickness: 2, color: Colors.redAccent),
            SizedBox(height: 10),

            // Warning Points List
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: warningPoints
                  .map((warning) => Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("🔸 ",
                                style:
                                    TextStyle(fontSize: 20, color: Colors.red)),
                            Expanded(
                              child: Text(
                                warning,
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Medicine Usage Finder",
        // backgroundColor: Colors.black87,
      ),
      // backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Enter Medicine Name",
                hintStyle: TextStyle(color: Colors.white70),
                filled: true,
                fillColor: Colors.grey[900],
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 10),

            // Search Button
            ElevatedButton(
              onPressed: () {
                if (_searchController.text.isNotEmpty) {
                  fetchMedicineData(_searchController.text);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              ),
              child: Text(
                "🔍 Search",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 20),

            // Loading Indicator
            if (_isLoading) CircularProgressIndicator(),

            // Error Message
            if (_errorMessage.isNotEmpty)
              Text(
                _errorMessage,
                style: TextStyle(color: Colors.redAccent, fontSize: 18),
              ),

            // Medicine Details Display
            if (_medicineData != null)
              Expanded(child: generateSummaryWidget(_medicineData!)),
          ],
        ),
      ),
    );
  }
}
