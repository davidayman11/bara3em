import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DataPage extends StatefulWidget {
  @override
  _DataPageState createState() => _DataPageState();
}

class _DataPageState extends State<DataPage> {
  late Future<List<Person>> _futurePersons;
  late List<Person> _allPersons; // Store all persons for search

  @override
  void initState() {
    super.initState();
    _futurePersons = fetchPersons();
  }

  Future<List<Person>> fetchPersons() async {
    final response = await http.get(Uri.parse('https://shamandorascout.com/api/get-persons-qetaa-baraem'));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body)['data'];
      _allPersons = data.map((json) => Person.fromJson(json)).toList();
      return _allPersons;
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<List<Person>> searchPersons(String query) async {
    List<Person> filteredPersons = _allPersons.where((person) {
      return person.firstName.toLowerCase().contains(query.toLowerCase());
    }).toList();
    return filteredPersons;
  }

  void _navigateToPersonDetail(BuildContext context, Person person) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PersonDetailPage(person: person),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Page'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () async {
              String? result = await showSearch<String>(
                context: context,
                delegate: PersonSearchDelegate(_allPersons),
              );
              if (result != null) {
                // Handle search result (if needed)
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Person>>(
        future: _futurePersons,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No data available'));
          }

          List<Person> persons = snapshot.data!;
          return ListView.builder(
            itemCount: persons.length,
            itemBuilder: (context, index) {
              Person person = persons[index];
              return ListTile(
                title: Text(person.firstName),
                subtitle: Text(person.shamandoraCode),
                onTap: () {
                  _navigateToPersonDetail(context, person);
                },
              );
            },
          );
        },
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
  final String sanaMahalnaName;
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
    required this.sanaMahalnaName,
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
      sanaMahalnaName: json['SanaMahalnaName'] ?? '',
      raqamQawmy: json['RaqamQawmy'] ?? '',
      personPersonalMobileNumber: json['PersonPersonalMobileNumber'] ?? '',
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
            Text('Name: ${person.firstName}'),
            Text('Shamandora Code: ${person.shamandoraCode}'),
            Text('Second Name: ${person.secondName}'),
            Text('Third Name: ${person.thirdName}'),
            Text('Fourth Name: ${person.fourthName}'),
            Text('Qetaa Name: ${person.qetaaName}'),
            Text('Scout Joining Year: ${person.scoutJoiningYear}'),
            Text('Sana Mahalna Name: ${person.sanaMahalnaName}'),
            Text('Raqam Qawmy: ${person.raqamQawmy}'),
            Text('Mobile Number: ${person.personPersonalMobileNumber}'),
          ],
        ),
      ),
    );
  }
}

class PersonSearchDelegate extends SearchDelegate<String> {
  final List<Person> persons;

  PersonSearchDelegate(this.persons);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults(context);
  }

  Widget _buildSearchResults(BuildContext context) {
    final List<Person> filteredPersons = query.isEmpty
        ? persons
        : persons.where((person) => person.firstName.toLowerCase().contains(query.toLowerCase())).toList();

    return ListView.builder(
      itemCount: filteredPersons.length,
      itemBuilder: (context, index) {
        Person person = filteredPersons[index];
        return ListTile(
          title: Text(person.firstName),
          subtitle: Text(person.shamandoraCode),
          onTap: () {
            close(context, person.firstName); // Pass back the selected name
          },
        );
      },
    );
  }
}
