import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  bool isLoading = true;
  int? modifiedIndex; // Track the currently modified index
  Map<int, bool> originalStatus = {}; // Store original attendance status

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
        isLoading = false;
      });
    }
  }

  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("auth_token"); // Replace with actual token retrieval logic
  }

  void _togglePresentStatus(int index) {
    if (modifiedIndex != null && modifiedIndex != index) return; // Only allow one change at a time

    setState(() {
      if (modifiedIndex == null) {
        originalStatus[index] = attendanceRecords![index].present; // Store the original state
      }
      attendanceRecords![index].present = !attendanceRecords![index].present;
      modifiedIndex = index;
    });
  }

  Future<void> _saveChanges(int index) async {
    String? token = await _getToken();
    if (token != null) {
      final record = attendanceRecords![index];
      bool success = await ApiService.updateAttendance(
        token,
        widget.studentId,
        widget.subjectId,
        record.attendanceDate,
        record.present,
      );

      if (success) {
        setState(() {
          modifiedIndex = null; // Reset edit state
          originalStatus.remove(index); // Remove original state after save
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
        attendanceRecords![modifiedIndex!].present = originalStatus[modifiedIndex]!; // Revert to original
        modifiedIndex = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Attendance")),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : attendanceRecords == null || attendanceRecords!.isEmpty
          ? Center(child: Text("No attendance records found"))
          : ListView.builder(
        itemCount: attendanceRecords!.length,
        itemBuilder: (context, index) {
          final record = attendanceRecords![index];
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
                      Text("Date: ${record.attendanceDate}", style: TextStyle(fontSize: 16)),
                      Text("Period: ${record.schedulePeriod}", style: TextStyle(fontSize: 14, color: Colors.grey)),
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

