import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const MaterialApp(
    home: AttendancePage(),
  ));
}

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
    return FirebaseFirestore.instance
        .collection('Attendance')
        .snapshots()
        .map((snapshot) {
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
      _attendanceStream =
          firestoreQuery.snapshots().map((snapshot) => snapshot.docs);
    });
  }

  Future<void> _downloadData() async {
    try {
      final data = await FirebaseFirestore.instance.collection('Attendance').get();
      final excel = Excel.createExcel();
      final sheet = excel['Sheet1'];

      // List of days
      List<String> days = [
        'sun14-7',
        'sun16-6',
        'sun23-6',
        'sun30-6',
        'sun7-7',
        'sun28-7', // Removed space
        'sun4-8',  // Removed space
        'sun11-8',
        'sun18-8'
      ];

      // Create the header row with days
      List<String> columnHeaders = ['Name'];
      columnHeaders.addAll(days);
      sheet.appendRow(columnHeaders);

      // Create rows for each name
      for (var doc in data.docs) {
        List<dynamic> row = [doc['name']];
        for (var day in days) {
          row.add(doc[day] ?? 'No attendance recorded');
        }
        sheet.appendRow(row);
      }

      Directory directory;
      if (Platform.isAndroid) {
        directory = (await getExternalStorageDirectory())!;
      } else {
        directory = await getApplicationDocumentsDirectory();
      }
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
        print('File saved at $filePath'); // Debugging info
      } else {
        throw Exception('Failed to encode Excel data');
      }
    } catch (e) {
      print('Error: $e'); // Debugging info
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to download attendance data. Please try again later.'),
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
              _buildAttendanceRow('sun16-6', record),
              _buildAttendanceRow('sun23-6', record),
              _buildAttendanceRow('sun30-6', record),
              _buildAttendanceRow('sun7-7', record),
              _buildAttendanceRow('sun14-7', record),
              _buildAttendanceRow('sun28-7', record),
              _buildAttendanceRow('sun4-8', record),
              _buildAttendanceRow('sun11-8', record),
              _buildAttendanceRow('sun18-8', record),
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

  Widget _buildAttendanceRow(String day, Map<String, dynamic> record) {
    if (record.containsKey(day)) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(day),
          Text(record[day] ?? 'No attendance recorded'),
          SizedBox(height: 8),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(day),
          Text('No attendance recorded'),
          SizedBox(height: 8),
        ],
      );
    }
  }

  void _showDaySelectionMenu(BuildContext context) {
    showMenu(
      context: context,
      position: const RelativeRect.fromLTRB(100, 100, 0, 0),
      items: [
        'sun16-6',
        'sun23-6',
        'sun30-6',
        'sun7-7',
        'sun14-7',
        'sun28-7', // Removed space
        'sun4-8',  // Removed space
        'sun11-8',
        'sun18-8'
      ].map((day) {
        return PopupMenuItem<String>(
          value: day,
          child: Text('Record Attendance for $day'),
        );
      }).toList(),
    ).then((value) {
      if (value != null) {
        _showAttendanceStatusSelectionMenu(context, value);
      }
    });
  }

  void _showAttendanceStatusSelectionMenu(BuildContext context, String selectedDay) {
    showMenu(
      context: context,
      position: const RelativeRect.fromLTRB(200, 0, 0, 200),
      items: [
        'Present',
        'Will not come',
      ].map((status) {
        return PopupMenuItem<String>(
          value: status,
          child: Text('Record as $status'),
        );
      }).toList(),
    ).then((value) {
      if (value != null) {
        _updateAttendance(selectedDay, value);
      }
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedNames.clear();
      _selectedDocIds.clear();
    });
  }

  Future<void> _updateAttendance(String day, String status) async {
    try {
      for (int i = 0; i < _selectedDocIds.length; i++) {
        await FirebaseFirestore.instance
            .collection('Attendance')
            .doc(_selectedDocIds[i])
            .update({
          day: status, // Adjust the value as needed ('Present' or 'Will not come')
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Attendance recorded successfully for selected names as $status on $day'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Tracker'),
        actions: [
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
                contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
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
                if (snapshot.hasError) {
                  return const Center(child: Text('Error loading data.'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No records found.'));
                }
                final documents = snapshot.data!;
                return ListView.builder(
                  itemCount: documents.length,
                  itemBuilder: (context, index) {
                    final record = documents[index].data();
                    return ListTile(
                      title: Text(record['name']),
                      trailing: Checkbox(
                        value: _selectedDocIds.contains(documents[index].id),
                        onChanged: (bool? value) {
                          setState(() {
                            if (value == true) {
                              _selectedNames.add(record['name']);
                              _selectedDocIds.add(documents[index].id);
                            } else {
                              _selectedNames.remove(record['name']);
                              _selectedDocIds.remove(documents[index].id);
                            }
                          });
                        },
                      ),
                      onTap: () {
                        _showDetailsDialog(context, record);
                      },
                    );
                  },
                );
              },
            ),
          ),
          if (_selectedNames.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Selected Names',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyText1?.color,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_selectedNames.length} selected',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).textTheme.bodyText1?.color,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.clear,color: Colors.red,),
                        onPressed: _clearSelection,
                        tooltip: 'Clear Selection',
                      ),
                      ElevatedButton(
                        onPressed: () => _showDaySelectionMenu(context),
                        child: const Text('Record Attendance'),
                      ),
                    ],
                  ),
                ],
              ),
            )

        ],
      ),
    );
  }
}
