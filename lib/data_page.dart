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
        title: const Text('Database'),
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
            child: StreamBuilder<QuerySnapshot>(
              stream: _dataStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No data available'));
                }
                return GridView.builder(
                  padding: const EdgeInsets.all(8.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                            const SizedBox(height: 8.0),
                            Text(
                              document['name'] ?? 'No Name',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
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
          documentId: document.id,
          name: document['name'].toString(),
          image: 'img/5.jpg',
          currentGrade: document['Current grade'].toString(),
          fatherName: document['Father’s name'].toString(),
          fatherPhone: document['Father’s phone'].toString(),
          motherName: document['Mother’s name'].toString(),
          motherPhone: document['Mother’s phone'].toString(),
          nationalId: document['National id'].toString(),
          childPhone: document['child phone'].toString(),
          nextGrade: document['next grade'].toString(),
          school: document['school'].toString(),
          tale3A: document['tale3A'].toString(),
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

class DetailsPage extends StatefulWidget {
  final String documentId;
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
    required this.documentId,
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
  _DetailsPageState createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  late TextEditingController _nameController;
  late TextEditingController _currentGradeController;
  late TextEditingController _fatherNameController;
  late TextEditingController _fatherPhoneController;
  late TextEditingController _motherNameController;
  late TextEditingController _motherPhoneController;
  late TextEditingController _nationalIdController;
  late TextEditingController _childPhoneController;
  late TextEditingController _nextGradeController;
  late TextEditingController _schoolController;
  late TextEditingController _tale3AController;

  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
    _currentGradeController = TextEditingController(text: widget.currentGrade);
    _fatherNameController = TextEditingController(text: widget.fatherName);
    _fatherPhoneController = TextEditingController(text: widget.fatherPhone);
    _motherNameController = TextEditingController(text: widget.motherName);
    _motherPhoneController = TextEditingController(text: widget.motherPhone);
    _nationalIdController = TextEditingController(text: widget.nationalId);
    _childPhoneController = TextEditingController(text: widget.childPhone);
    _nextGradeController = TextEditingController(text: widget.nextGrade);
    _schoolController = TextEditingController(text: widget.school);
    _tale3AController = TextEditingController(text: widget.tale3A);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _currentGradeController.dispose();
    _fatherNameController.dispose();
    _fatherPhoneController.dispose();
    _motherNameController.dispose();
    _motherPhoneController.dispose();
    _nationalIdController.dispose();
    _childPhoneController.dispose();
    _nextGradeController.dispose();
    _schoolController.dispose();
    _tale3AController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(_isEditing ? 'Edit Details' : 'Details'),
          actions: [
            if (!_isEditing)
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  setState(() {
                    _isEditing = true;
                  });
                },
              ),
            if (_isEditing)
              IconButton(
                icon: const Icon(Icons.save),
                onPressed: () => _saveChanges(context),
              ),
          ],
        ),
        body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    AspectRatio(
    aspectRatio: 6 / 6,
    child: ClipRRect(
    borderRadius: BorderRadius.circular(10.0),
    child: Image.asset(
    widget.image,
    fit: BoxFit.cover,
    ),
    ),
    ),
    const SizedBox(height: 16.0),
    _isEditing ? _buildTextField(_nameController, 'Name') : DetailItem(label: 'Name', value: widget.name),
    _isEditing
    ? _buildTextField(_currentGradeController, 'Current Grade')
        : DetailItem(label: 'Current Grade', value: widget.currentGrade),
    _isEditing
    ? _buildTextField(_fatherNameController, 'Father\'s Name')
        : DetailItem(label: 'Father\'s Name', value: widget.fatherName),
    _isEditing
    ? _buildTextField(_fatherPhoneController, 'Father\'s Phone')
        : _buildPhoneCallItem(context, 'Father\'s Phone', widget.fatherPhone),
    _isEditing
    ? _buildTextField(_motherNameController, 'Mother\'s Name')
        : DetailItem(label: 'Mother\'s Name', value: widget                .motherName),
      _isEditing
          ? _buildTextField(_motherPhoneController, 'Mother\'s Phone')
          : _buildPhoneCallItem(context, 'Mother\'s Phone', widget.motherPhone),
      _isEditing
          ? _buildTextField(_nationalIdController, 'National ID')
          : DetailItem(label: 'National ID', value: widget.nationalId),
      _isEditing
          ? _buildTextField(_childPhoneController, 'Child Phone')
          : _buildPhoneCallItem(context, 'Child Phone', widget.childPhone),
      _isEditing
          ? _buildTextField(_nextGradeController, 'Next Grade')
          : DetailItem(label: 'Next Grade', value: widget.nextGrade),
      _isEditing
          ? _buildTextField(_schoolController, 'School')
          : DetailItem(label: 'School', value: widget.school),
      _isEditing
          ? _buildTextField(_tale3AController, 'Tale3A')
          : DetailItem(label: 'Tale3A', value: widget.tale3A),
    ],
    ),
        ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
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
          TextField(
            controller: controller,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
          ),
        ],
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

  void _saveChanges(BuildContext context) {
    try {
      FirebaseFirestore.instance.collection('Database').doc(widget.documentId).update({
        'name': _nameController.text,
        'Current grade': _currentGradeController.text,
        'Father’s name': _fatherNameController.text,
        'Father’s phone': _fatherPhoneController.text,
        'Mother’s name': _motherNameController.text,
        'Mother’s phone': _motherPhoneController.text,
        'National id': _nationalIdController.text,
        'child phone': _childPhoneController.text,
        'next grade': _nextGradeController.text,
        'school': _schoolController.text,
        'tale3A': _tale3AController.text,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Changes saved')),
      );

      setState(() {
        _isEditing = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save changes')),
      );
    }
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
            style: const TextStyle(fontSize: 14.0),
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
    home: const DataPage(),
  ));
}

