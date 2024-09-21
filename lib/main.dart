import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:country_picker/country_picker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Nationality Predictor',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: NationalityScreen(),
    );
  }
}

class NationalityScreen extends StatefulWidget {
  @override
  _NationalityScreenState createState() => _NationalityScreenState();
}

class _NationalityScreenState extends State<NationalityScreen> {
  final TextEditingController _controller = TextEditingController();
  List _predictions = [];
  bool _isLoading = false;

  Future<void> fetchNationalities(String name) async {
    setState(() {
      _isLoading = true;
    });

    final response = await http.get(
      Uri.parse('https://api.nationalize.io?name=$name'),
    );

    if (response.statusCode == 200) {
      setState(() {
        _predictions = json.decode(response.body)['country'];
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nationality Predictor'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Enter a name',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    String name = _controller.text.trim();
                    if (name.isNotEmpty) {
                      fetchNationalities(name);
                    }
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : Expanded(
                    child: _predictions.isEmpty
                        ? Center(child: Text('No data found'))
                        : ListView.builder(
                            itemCount: _predictions.length,
                            itemBuilder: (context, index) {
                              return NationalityTile(
                                countryId: _predictions[index]['country_id'],
                                probability:
                                    _predictions[index]['probability'],
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

class NationalityTile extends StatelessWidget {
  final String countryId;
  final double probability;

  NationalityTile({required this.countryId, required this.probability});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text('Country: ${Country.tryParse(countryId)?.name}'),
        subtitle: Text(
          'Probability: ${(probability * 100).toStringAsFixed(2)}%',
        ),
        leading: CircleAvatar(
          child: Text(countryId),
        ),
      ),
    );
  }
}