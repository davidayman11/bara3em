import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart'; // Import for launching phone calls

class DataPage extends StatefulWidget {
  @override
  _DataPageState createState() => _DataPageState();
}

class _DataPageState extends State<DataPage> {
  late Future<List<Person>> _futurePersons;
  List<Person> _persons = [];
  List<Person> _filteredPersons = [];
  TextEditingController _searchController = TextEditingController();
  bool _showNotFoundMessage = false;

  @override
  void initState() {
    super.initState();
    _futurePersons = fetchPersons();
  }

  Future<List<Person>> fetchPersons() async {
    try {
      final response = await http.get(Uri.parse('https://shamandorascout.com/api/get-persons-qetaa-baraem'));
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body)['data'];
        return data.map((json) => Person.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load data: $e');
    }
  }

  void _search(String searchText) {
    if (searchText.isEmpty) {
      setState(() {
        _filteredPersons = [];
        _showNotFoundMessage = false;
      });
      return;
    }

    setState(() {
      _filteredPersons = _persons.where((person) =>
      person.firstName.toLowerCase().contains(searchText.toLowerCase()) ||
          person.secondName.toLowerCase().contains(searchText.toLowerCase()) ||
          person.thirdName.toLowerCase().contains(searchText.toLowerCase())).toList();

      _showNotFoundMessage = _filteredPersons.isEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Data Page'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: _search,
              decoration: InputDecoration(
                labelText: 'Search by Name',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _search('');
                  },
                )
                    : null,
                filled: true,
                fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Person>>(
              future: _futurePersons,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No data available'));
                }

                _persons = snapshot.data!;
                List<Person> persons = _filteredPersons.isNotEmpty ? _filteredPersons : _persons;

                if (_showNotFoundMessage) {
                  return Center(child: Text('Name not found'));
                }

                return ListView.builder(
                  itemCount: persons.length,
                  itemBuilder: (context, index) {
                    Person person = persons[index];
                    return Card(
                      elevation: 3,
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: ListTile(
                        title: Text(
                          '${person.firstName} ${person.secondName} ${person.thirdName}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(person.shamandoraCode),
                        trailing: Icon(Icons.keyboard_arrow_right),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PersonDetailPage(person: person),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class PersonDetailPage extends StatelessWidget {
  final Person person;

  const PersonDetailPage({Key? key, required this.person}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Person Detail'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailItem('First Name', person.firstName),
            _buildDetailItem('Second Name', person.secondName),
            _buildDetailItem('Third Name', person.thirdName),
            _buildDetailItem('Shamandora Code', person.shamandoraCode),
            _buildDetailItem('Fourth Name', person.fourthName),
            _buildDetailItem('Qetaa Name', person.qetaaName),
            _buildDetailItem('Scout Joining Year', person.scoutJoiningYear),
            _buildDetailItem('Sana Marhalna Name', person.SanaMarhalaName),
            _buildDetailItem('Raqam Qawmy', person.raqamQawmy),
            _buildPhoneItem('Mobile Number', person.personPersonalMobileNumber, context),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
            ),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneItem(String label, String phoneNumber, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InkWell(
              onTap: () {
                _callNumber(phoneNumber);
              },
              child: Row(
                children: [
                  Icon(Icons.phone, color: Colors.blueAccent),
                  SizedBox(width: 8),
                  Text(
                    phoneNumber,
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: () {
                _copyToClipboard(context, phoneNumber);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end, // Align items to the end
                children: [
                  SizedBox(width: 8),
                  Icon(Icons.content_copy, color: Colors.blueAccent),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }



  void _callNumber(String phoneNumber) async {
    String url = 'tel:$phoneNumber';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied to clipboard: $text'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

class Person {
  final int personId;
  final String shamandoraCode;
  final String firstName;
  final String secondName;
  final String thirdName;
  final String fourthName;
  final String qetaaName;
  final String scoutJoiningYear;
  final String SanaMarhalaName;
  final String raqamQawmy;
  final String personPersonalMobileNumber;

  Person({
    required this.personId,
    required this.shamandoraCode,
    required this.firstName,
    required this.secondName,
    required this.thirdName,
    required this.fourthName,
    required this.qetaaName,
    required this.scoutJoiningYear,
    required this.SanaMarhalaName,
    required this.raqamQawmy,
    required this.personPersonalMobileNumber,
  });

  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(
        personId: json['PersonID'] ?? 0,
        shamandoraCode: json['ShamandoraCode'] ?? '',
        firstName: json['FirstName'] ?? '',
        secondName: json['SecondName'] ?? '',
        thirdName: json['ThirdName'] ?? '',
        fourthName: json['FourthName'] ?? '',
        qetaaName: json['QetaaName'] ?? '',
        scoutJoiningYear: json['ScoutJoiningYear'] ?? '',
        SanaMarhalaName: json['SanaMarhalaName'] ?? '',
        raqamQawmy: json['RaqamQawmy'] ?? '',
        personPersonalMobileNumber: json['PersonPersonalMobileNumber'] ??'',
    );
  }
}

