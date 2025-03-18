import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../helper/api_service.dart';
import '../modules/StudentsSubjectAttendance.dart';
import '../modules/class_entity.dart';

class AttendanceScreen extends StatefulWidget {
  final String studentId;
  final ClassEntity classEntity;
  final int subjectId;

  AttendanceScreen({
    required this.studentId,
    required this.classEntity,
    required this.subjectId,
  });

  @override
  _AttendanceScreenState createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  List<StudentsSubjectAttendance>? attendanceRecords;
  List<StudentsSubjectAttendance>? filteredRecords;
  bool isLoading = true;
  int? modifiedIndex;
  Map<int, bool> originalStatus = {};
  DateTime? selectedDate; // Stores the selected date for filtering

  @override
  void initState() {
    super.initState();
    _fetchAttendance();
  }

  Future<void> _fetchAttendance() async {
    String? token = await _getToken();
    if (token != null) {
      List<StudentsSubjectAttendance>? fetchedData =
      await ApiService.getStudentAttendance(token, widget.studentId, widget.subjectId);
      setState(() {
        attendanceRecords = fetchedData;
        filteredRecords = fetchedData; // Initialize filtered records with all data
        isLoading = false;
      });
    }
  }

  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("auth_token");
  }

  void _togglePresentStatus(int index) {
    if (modifiedIndex != null && modifiedIndex != index) return;

    setState(() {
      if (modifiedIndex == null) {
        originalStatus[index] = filteredRecords![index].present;
      }
      filteredRecords![index].present = !filteredRecords![index].present;
      modifiedIndex = index;
    });
  }

  Future<void> _saveChanges(int index) async {
    String? token = await _getToken();
    if (token != null) {
      final record = filteredRecords![index];
      bool success = await ApiService.updateAttendance(
        token,
        widget.studentId,
        widget.subjectId,
        record.attendanceDate,
        record.present,
      );

      if (success) {
        setState(() {
          modifiedIndex = null;
          originalStatus.remove(index);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Attendance updated successfully!")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to update attendance")),
        );
      }
    }
  }

  void _cancelEdit() {
    if (modifiedIndex != null && originalStatus.containsKey(modifiedIndex)) {
      setState(() {
        filteredRecords![modifiedIndex!].present = originalStatus[modifiedIndex!]!;
        modifiedIndex = null;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
        _filterRecordsByDate();
      });
    }
  }

  void _filterRecordsByDate() {
    if (selectedDate == null) return;

    String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate!);
    setState(() {
      filteredRecords = attendanceRecords!
          .where((record) => record.attendanceDate == formattedDate)
          .toList();
    });
  }

  void _clearFilter() {
    setState(() {
      selectedDate = null;
      filteredRecords = List.from(attendanceRecords!); // Reset to original data
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Attendance"),
        actions: [
          IconButton(
            icon: Icon(Icons.date_range),
            onPressed: () => _selectDate(context),
          ),
          if (selectedDate != null)
            IconButton(
              icon: Icon(Icons.clear),
              onPressed: _clearFilter,
            ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : filteredRecords == null || filteredRecords!.isEmpty
          ? Center(child: Text("No attendance records found"))
          : ListView.builder(
        itemCount: filteredRecords!.length,
        itemBuilder: (context, index) {
          final record = filteredRecords![index];
          bool isCurrentEditing = index == modifiedIndex;

          return Card(
            margin: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 🎯 **Formatted Date Display**
                      Text(
                        "Date: ${DateFormat('dd / MM / yyyy').format(DateTime.parse(record.attendanceDate))}",
                        style: TextStyle(fontSize: 16),
                      ),
                      Text("Period: ${record.schedulePeriod}",
                          style: TextStyle(fontSize: 14, color: Colors.grey)),
                    ],
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => _togglePresentStatus(index),
                        child: CircleAvatar(
                          backgroundColor: record.present ? Colors.green : Colors.red,
                          child: Icon(
                            record.present ? Icons.check : Icons.close,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      if (isCurrentEditing) ...[
                        SizedBox(width: 10),
                        IconButton(
                          icon: Icon(Icons.save, color: Colors.blue),
                          onPressed: () => _saveChanges(index),
                        ),
                        IconButton(
                          icon: Icon(Icons.cancel, color: Colors.red),
                          onPressed: _cancelEdit,
                        ),
                      ]
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}



