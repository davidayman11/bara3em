import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class DataPage extends StatefulWidget {
  const DataPage({Key? key}) : super(key: key);

  @override
  _DataPageState createState() => _DataPageState();
}

class _DataPageState extends State<DataPage> {
  late Stream<QuerySnapshot> _dataStream;
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _dataStream = FirebaseFirestore.instance.collection('Database').snapshots();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Database'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: _search,
              decoration: InputDecoration(
                labelText: 'Search',
                prefixIcon: Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _search('');
                  },
                )
                    : null,
                filled: true,
                fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

      Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _dataStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No data available'));
                }
                return GridView.builder(
                  padding: EdgeInsets.all(8.0),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                  ),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var document = snapshot.data!.docs[index];
                    return InkWell(
                      onTap: () => _navigateToDetailsPage(context, document),
                      borderRadius: BorderRadius.circular(10),
                      child: Card(
                        elevation: 2.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10.0),
                              child: Image.asset(
                                'img/5.jpg',
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                            SizedBox(height: 8.0),
                            Text(
                              document['name'] ?? 'No Name',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16.0,
                              ),
                            ),
                          ],
                        ),
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

  void _navigateToDetailsPage(BuildContext context, DocumentSnapshot document) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailsPage(
          name: document['name'].toString() ?? 'No Name',
          image: 'img/5.jpg',
          currentGrade: document['Current grade'].toString() ?? 'Unknown',
          fatherName: document['Father’s name'].toString() ?? 'Unknown',
          fatherPhone: document['Father’s phone'].toString() ?? 'Unknown',
          motherName: document['Mother’s name'].toString() ?? 'Unknown',
          motherPhone: document['Mother’s phone'].toString() ?? 'Unknown',
          nationalId: document['National id'].toString() ?? 'Unknown',
          childPhone: document['child phone'].toString() ?? 'Unknown',
          nextGrade: document['next grade'].toString() ?? 'Unknown',
          school: document['school'].toString() ?? 'Unknown',
          tale3A: document['tale3A'].toString() ?? 'Unknown',
        ),
      ),
    );
  }

  void _search(String query) {
    setState(() {
      if (query.isEmpty) {
        _dataStream = FirebaseFirestore.instance.collection('Database').snapshots();
      } else {
        _dataStream = FirebaseFirestore.instance
            .collection('Database')
            .where('name', isGreaterThanOrEqualTo: query, isLessThanOrEqualTo: query + '\uf8ff')
            .snapshots();
      }
    });
  }
}

class DetailsPage extends StatelessWidget {
  final String name;
  final String image;
  final String currentGrade;
  final String fatherName;
  final String fatherPhone;
  final String motherName;
  final String motherPhone;
  final String nationalId;
  final String childPhone;
  final String nextGrade;
  final String school;
  final String tale3A;

  const DetailsPage({
    required this.name,
    required this.image,
    required this.currentGrade,
    required this.fatherName,
    required this.fatherPhone,
    required this.motherName,
    required this.motherPhone,
    required this.nationalId,
    required this.childPhone,
    required this.nextGrade,
    required this.school,
    required this.tale3A,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Details'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 6 / 6,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Image.asset(
                  image,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 16.0),
            DetailItem(label: 'Name', value: name),
            DetailItem(label: 'Current Grade', value: currentGrade),
            DetailItem(label: 'Father\'s Name', value: fatherName),
            _buildPhoneCallItem(context, 'Father\'s Phone', fatherPhone),
            DetailItem(label: 'Mother\'s Name', value: motherName),
            _buildPhoneCallItem(context, 'Mother\'s Phone', motherPhone),
            DetailItem(label: 'National ID', value: nationalId),
            _buildPhoneCallItem(context, 'Child Phone', childPhone),
            DetailItem(label: 'Next Grade', value: nextGrade),
            DetailItem(label: 'School', value: school),
            DetailItem(label: 'Tale3A', value: tale3A),
          ],
        ),
      ),
    );
  }

  Widget _buildPhoneCallItem(BuildContext context, String label, String phoneNumber) {
    return InkWell(
      onTap: () {
        Clipboard.setData(ClipboardData(text: phoneNumber));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Copied $phoneNumber')),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
                color: Theme.of(context).textTheme.bodyText1!.color,
              ),
            ),
            Text(
              phoneNumber,
              style: TextStyle(
                fontSize: 14.0,
                color: Theme.of(context).textTheme.bodyText1!.color,
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DetailItem extends StatelessWidget {
  final String label;
  final String value;

  const DetailItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
              color: Theme.of(context).textTheme.bodyText1!.color,
            ),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 14.0),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    title: 'Your App',
    theme: ThemeData(
      primarySwatch: Colors.blueGrey,
    ),
    home: DataPage(),
  ));
}
