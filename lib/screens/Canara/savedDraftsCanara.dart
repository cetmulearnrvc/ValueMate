import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:login_screen/screens/Canara/main.dart';

import 'dart:convert';
import 'config.dart';

class SavedDraftsCanara extends StatefulWidget {
  const SavedDraftsCanara({super.key});

  @override
  State<SavedDraftsCanara> createState() => _SavedDraftsCanaraState();
}

class _SavedDraftsCanaraState extends State<SavedDraftsCanara> {
  DateTime date = DateTime(2025, 06, 26);
  List<dynamic> searchResults = [];
  bool isLoading = false;

  Future<void> searchByDate() async {
    setState(() {
      isLoading = true;
      searchResults = []; // Clear previous results
    });

    try {
      final formattedDate = DateFormat('yyyy-MM-dd').format(date);
      final response = await http.post(
        Uri.parse(url3),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'date': formattedDate}),
      );

      debugPrint("send req to back");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          searchResults = data;
        });
      } else {
        debugPrint("some err");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void navigateToValuationForm(Map<String, dynamic> propertyData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PropertyValuationReportPage(
          propertyData:
              propertyData, // Pass the property data to PdfGeneratorScreen
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Canara Bank Drafts'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            ListTile(
              title: const Text('Select Date'),
              subtitle: Text(DateFormat('dd-MM-yyyy').format(date)),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: date,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2200),
                );
                if (picked != null) {
                  setState(() {
                    date = picked;
                  });
                }
              },
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: isLoading ? null : searchByDate,
              label: const Text('Search'),
              icon: const Icon(Icons.search),
            ),
            const SizedBox(height: 20),
            if (isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (searchResults.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: searchResults.length,
                  itemBuilder: (context, index) {
                    final property = searchResults[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        title: Text(
                            'Owner Name: ${property['ownerName']}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                'Bank: Canara Bank'), // Always shows Canara Bank
                            const SizedBox(height: 4),
                            Text(
                              'Location: ${property['propertyAddress']}',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),

                            Text(
                              'Inspection Date: ${DateFormat('dd-MM-yyyy').format(DateTime.parse(property['createdAt']).toLocal()) ?? 'N/A'}',
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                        trailing: const Icon(Icons.arrow_forward),
                        onTap: () => navigateToValuationForm(property),
                      ),
                    );
                  },
                ),
              )
            else if (!isLoading)
              const Expanded(
                child: Center(
                  child: Text('No Canara Bank drafts found'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
