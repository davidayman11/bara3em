// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';

enum FilterCriteria { all, tale3A }

class AttendancePage extends StatefulWidget {
  const AttendancePage({Key? key}) : super(key: key);

  @override
  _AttendancePageState createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  final TextEditingController _searchController = TextEditingController();
  late Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>> _attendanceStream;
  Timer? _debounce;
  final List<String> _selectedNames = [];
  final List<String> _selectedDocIds = [];
  FilterCriteria _currentFilterCriteria = FilterCriteria.all;
  String _selectedTale3A = 'All';

  @override
  void initState() {
    super.initState();
    _attendanceStream = _fetchAttendance();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>> _fetchAttendance() {
    Query<Map<String, dynamic>> query = FirebaseFirestore.instance.collection('Attendance');
    if (_currentFilterCriteria == FilterCriteria.tale3A && _selectedTale3A != 'All') {
      query = query.where('tale3A', isEqualTo: _selectedTale3A);
    }
    return query.snapshots().map((snapshot) {
      return snapshot.docs;
    });
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _search(_searchController.text);
    });
  }

  void _search(String query) {
    setState(() {
      var firestoreQuery = FirebaseFirestore.instance
          .collection('Attendance')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: '$query\uf8ff');
      if (_currentFilterCriteria == FilterCriteria.tale3A && _selectedTale3A != 'All') {
        firestoreQuery = firestoreQuery.where('tale3A', isEqualTo: _selectedTale3A);
      }
      _attendanceStream = firestoreQuery.snapshots().map((snapshot) => snapshot.docs);
    });
  }

  Future<void> _downloadData() async {
    try {
      final data = await FirebaseFirestore.instance.collection('Attendance').get();
      final excel = Excel.createExcel();
      final sheet = excel['Sheet1'];

      sheet.appendRow([
        'Name',
        for (int i = 1; i <= 9; i++) 'Day $i'
      ]);

      for (var doc in data.docs) {
        final List<String?> days = List.generate(9, (index) => doc['day${index + 1}']?.toString());
        sheet.appendRow([doc['name'], ...days]);
      }

      Directory directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/attendance_data.xlsx';
      final file = File(filePath);

      final excelData = excel.encode();
      if (excelData != null) {
        await file.writeAsBytes(excelData);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Attendance data downloaded successfully'),
            duration: const Duration(seconds: 2),
            action: SnackBarAction(
              label: 'Open',
              onPressed: () {
                // Implement file opening here
              },
            ),
          ),
        );
      } else {
        throw Exception('Failed to encode Excel data');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to download attendance data. Please try again later.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _updateAttendance(String day) async {
    try {
      for (int i = 0; i < _selectedDocIds.length; i++) {
        await FirebaseFirestore.instance
            .collection('Attendance')
            .doc(_selectedDocIds[i])
            .update({day: true});
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Attendance recorded successfully for selected names on $day'),
          duration: const Duration(seconds: 2),
        ),
      );
      setState(() {
        _selectedNames.clear();
        _selectedDocIds.clear();
      });
    } catch (e) {
      print('Error updating attendance: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to record attendance. Please try again later.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _showDetailsDialog(BuildContext context, Map<String, dynamic> record) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Attendance Details for ${record['name']}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 1; i <= 9; i++)
                Text('Day $i: ${record['day$i'] ?? 'Not available'}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showDaySelectionMenu(BuildContext context) {
    showMenu(
      context: context,
      position: const RelativeRect.fromLTRB(100, 100, 0, 0),
      items: List.generate(9, (index) {
        return PopupMenuItem<String>(
          value: 'day${index + 1}',
          child: Text('Record Attendance for Day ${index + 1}'),
        );
      }),
    ).then((value) {
      if (value != null) {
        _updateAttendance(value);
      }
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedNames.clear();
      _selectedDocIds.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Tracker'),
        actions: [
          DropdownButton<String>(
            value: _selectedTale3A,
            icon: const Icon(Icons.filter_list, color: Colors.white),
            underline: Container(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  _selectedTale3A = newValue;
                  _currentFilterCriteria = FilterCriteria.tale3A;
                  _attendanceStream = _fetchAttendance();
                });
              }
            },
            items: [
              'All',
              'الجمبري',
              'سلاحف البحر',
              'القرش',
              'قنديل البحر',
              'الدولفين',
              'نجمة البحر',
              'الكابوريا',
              'الاخطبوط',
              'سمكة السيف',
              'حصان البحر'
            ].map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: _downloadData,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
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
            child: StreamBuilder<List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
              stream: _attendanceStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No attendance records found'));
                }
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    var record = snapshot.data![index];
                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(record['name'] ?? 'Unknown'),
                            if (record['tale3A'] != null)
                              Text(
                                'Tale3A: ${record['tale3A']}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                          ],
                        ),
                        onTap: () => _showDetailsDialog(context, record.data()),
                        onLongPress: () {
                          setState(() {
                            if (_selectedDocIds.contains(record.id)) {
                              _selectedDocIds.remove(record.id);
                              _selectedNames.remove(record['name']);
                            } else {
                              _selectedDocIds.add(record.id);
                              _selectedNames.add(record['name']);
                            }
                          });
                        },
                        trailing: _selectedDocIds.contains(record.id)
                            ? const Icon(Icons.check_circle, color: Colors.green)
                            : null,
                      ),
                    );
                  },
                );
              },
            ),
          ),
          if (_selectedDocIds.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              color: Theme.of(context).colorScheme.surface,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton(
                    onPressed: () => _showDaySelectionMenu(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                    ),
                    child: Text(
                      'Record Attendance for ${_selectedNames.length} Selected Names',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _clearSelection,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text(
                      'Clear Selection',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: AttendancePage(),
  ));
}
