import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';

enum FilterCriteria { all, day1, day2, day3, day4, day5, day6, day7, day8, day9}

class AttendancePage extends StatefulWidget {
  const AttendancePage({Key? key}) : super(key: key);

  @override
  _AttendancePageState createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  final TextEditingController _searchController = TextEditingController();
  late Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>> _attendanceStream;
  Timer? _debounce;
  List<String> _selectedNames = [];
  List<String> _selectedDocIds = [];
  FilterCriteria _currentFilterCriteria = FilterCriteria.all;

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
    if (_currentFilterCriteria == FilterCriteria.all) {
      return FirebaseFirestore.instance.collection('Attendance').snapshots().map((snapshot) {
        return snapshot.docs;
      });
    } else {
      return FirebaseFirestore.instance
          .collection('Attendance')
          .where(_currentFilterCriteria.toString().split('.').last, isEqualTo: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs;
      });
    }
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _search(_searchController.text);
    });
  }

  void _search(String query) {
    if (_currentFilterCriteria == FilterCriteria.all) {
      setState(() {
        _attendanceStream = FirebaseFirestore.instance
            .collection('Attendance')
            .where('name', isGreaterThanOrEqualTo: query)
            .where('name', isLessThanOrEqualTo: '$query\uf8ff')
            .snapshots()
            .map((snapshot) {
          return snapshot.docs;
        });
      });
    } else {
      setState(() {
        _attendanceStream = FirebaseFirestore.instance
            .collection('Attendance')
            .where('name', isGreaterThanOrEqualTo: query)
            .where('name', isLessThanOrEqualTo: '$query\uf8ff')
            .where(_currentFilterCriteria.toString().split('.').last, isEqualTo: true)
            .snapshots()
            .map((snapshot) {
          return snapshot.docs;
        });
      });
    }
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
            content: Text('Attendance data downloaded successfully'),
            duration: Duration(seconds: 2),
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
      print('Error downloading data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
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
          duration: Duration(seconds: 2),
        ),
      );
      setState(() {
        _selectedNames.clear();
        _selectedDocIds.clear();
      });
    } catch (e) {
      print('Error updating attendance: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
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
              Text('Tale3A: ${record['tale3A'] ?? 'Not available'}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }


  void _showDaySelectionMenu(BuildContext context) {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(100, 100, 0, 0),
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
        title: Text('Attendance Tracker'),
        actions: [
          DropdownButton<FilterCriteria>(
            value: _currentFilterCriteria,
            icon: Icon(Icons.filter_list, color: Colors.white),
            underline: Container(),
            onChanged: (FilterCriteria? newValue) {
              if (newValue != null) {
                setState(() {
                  _currentFilterCriteria = newValue;
                  _attendanceStream = _fetchAttendance();
                });
              }
            },
            items: FilterCriteria.values.map((FilterCriteria criteria) {
              return DropdownMenuItem<FilterCriteria>(
                value: criteria,
                child: Text(
                  criteria == FilterCriteria.all ? 'All' : criteria.toString().split('.').last,
                  style: TextStyle(color: Colors.white),
                ),
              );
            }).toList(),
          ),
          IconButton(
            icon: Icon(Icons.file_download),
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
            child: StreamBuilder<List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
              stream: _attendanceStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No attendance records found'));
                }
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    var record = snapshot.data![index];
                    return Card(
                      margin: EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Text(record['name'] ?? 'Unknown'),
                        subtitle: Text('Tap to view details, long press to select for attendance'),
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
                            ? Icon(Icons.check_circle, color: Colors.green)
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
              padding: EdgeInsets.all(16.0),
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
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _clearSelection,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: Text(
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
  runApp(MaterialApp(
    home: AttendancePage(),
  ));
}