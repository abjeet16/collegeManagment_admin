import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../helper/api_link_helper.dart';
import '../modules/AddTeacherRequest.dart';
import '../modules/AddUserRequest.dart';
import '../modules/AttendanceUpdateRequest.dart';
import '../modules/StudentDetails.dart';
import '../modules/StudentsSubjectAttendance.dart';
import '../modules/SubjectDTO.dart';
import '../modules/TeacherDetailResponse.dart';
import '../modules/UserLoginRequest.dart';
import '../modules/UserLoginResponse.dart';
import '../modules/course.dart';
import '../modules/class_entity.dart';
import '../modules/student.dart';
import '../modules/user_profile.dart'; // Import ClassEntity model

class ApiService {
  static Future<UserLoginResponse?> loginUser(UserLoginRequest request) async {
    try {
      final response = await http.post(
        Uri.parse(ApiLinkHelper.loginUserApiUri()),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "uucms_id": request.uucmsId,
          "password": request.password,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 202) {
        final data = jsonDecode(response.body);
        return UserLoginResponse(
          token: data["token"],
          firstName: data["firstName"],
          lastName: data["lastName"],
          username: data["username"],
        );
      } else {
        print("Login failed: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }

  static Future<UserProfile?> getUserProfile(String token) async {
    try {
      final response = await http.get(
        Uri.parse(ApiLinkHelper.getUserProfileApiUri()),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      print("getUserProfile Response status: ${response.statusCode}");
      print("getUserProfile Response body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return UserProfile.fromJson(data);
      } else {
        print("getUserProfile failed: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error in getUserProfile: $e");
      return null;
    }
  }

  // Fetch all courses
  static Future<List<Course>?> getAllCourses(String token) async {
    try {
      final response = await http.get(
        Uri.parse(ApiLinkHelper.viewCoursesApiUri()),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      print("getAllCourses Response status: ${response.statusCode}");
      print("getAllCourses Response body: ${response.body}");

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Course.fromJson(json)).toList();
      } else {
        print("getAllCourses failed: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error in getAllCourses: $e");
      return null;
    }
  }

  // Fetch all classes for a given course
  static Future<List<ClassEntity>?> getAllClasses(String token, int courseId) async {
    try {
      final response = await http.get(
        Uri.parse(ApiLinkHelper.getClassesByCourseIdApiUri(courseId)), // Define in ApiLinkHelper
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      print("getAllClasses Response status: ${response.statusCode}");
      print("getAllClasses Response body: ${response.body}");

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => ClassEntity.fromJson(json)).toList();
      } else {
        print("getAllClasses failed: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error in getAllClasses: $e");
      return null;
    }
  }

  // Add a new course
  static Future<bool> addCourse(String token, String courseName) async {
    try {
      final response = await http.post(
        Uri.parse(ApiLinkHelper.addCourseApiUri()),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "courseName": courseName,
        }),
      );

      print("addCourse Response status: ${response.statusCode}");
      print("addCourse Response body: ${response.body}");

      return response.statusCode == 200;
    } catch (e) {
      print("Error in addCourse: $e");
      return false;
    }
  }

  // Delete a course
  static Future<bool> deleteCourse(String token, int courseId, String password) async {
    try {
      final uri = Uri.parse(ApiLinkHelper.deleteCourseApiUri(courseId, password));

      final response = await http.delete(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      print("deleteCourse Response status: ${response.statusCode}");
      print("deleteCourse Response body: ${response.body}");

      if (response.statusCode == 200) {
        showToast("✅ Course deleted successfully", position: ToastPosition.bottom);
        return true;
      }

      if (response.statusCode == 401 && response.body.contains("Invalid password")) {
        showToast("❌ Incorrect password. Try again!", position: ToastPosition.bottom, backgroundColor: Colors.red);
        return false;
      }

      showToast("❌ Failed to delete course: ${response.body}", position: ToastPosition.bottom, backgroundColor: Colors.red);
      return false;
    } catch (e) {
      print("Error in deleteCourse: $e");
      showToast("❌ Error: Something went wrong!", position: ToastPosition.bottom, backgroundColor: Colors.red);
      return false;
    }
  }

  // Fetch all subjects for a given course
  static Future<List<SubjectDTO>?> getAllSubjects(String token, int courseId,int classId) async {
    try {
      final response = await http.get(
        Uri.parse(ApiLinkHelper.getSubjectsByCourseIdApiUri(courseId,classId)), // Define in ApiLinkHelper
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => SubjectDTO.fromJson(json)).toList();
      } else {
        print("getAllSubjects failed: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error in getAllSubjects: $e");
      return null;
    }
  }

  static Future<List<Student>?> getStudentsByClassId(String token, int classId) async {
    try {
      final response = await http.get(
        Uri.parse(ApiLinkHelper.getStudentsByClassIdApiUri(classId)), // Define this URL in ApiLinkHelper
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      print("getStudentsByClassId Response status: ${response.statusCode}");
      print("getStudentsByClassId Response body: ${response.body}");

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Student.fromJson(json)).toList();
      } else {
        print("getStudentsByClassId failed: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error in getStudentsByClassId: $e");
      return null;
    }
  }

  // Get student details by studentId
  static Future<StudentDetails?> getStudentById(String token, String studentId) async {
    try {
      final response = await http.get(
        Uri.parse(ApiLinkHelper.getStudentByIdApiUri(studentId)),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      print("getStudentById Response status: ${response.statusCode}");
      print("getStudentById Response body: ${response.body}");

      if (response.statusCode == 200) {
        return StudentDetails.fromJson(jsonDecode(response.body));
      } else {
        print("getStudentById failed: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error in getStudentById: $e");
      return null;
    }
  }

  static Future<List<StudentsSubjectAttendance>?> getStudentAttendance(
      String token, String studentId, int subjectId) async {
    try {
      final response = await http.get(
        Uri.parse(ApiLinkHelper.getStudentSubjectAttendeceUri(studentId, subjectId)),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => StudentsSubjectAttendance.fromJson(json)).toList();
      } else {
        print("Failed to fetch attendance: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error fetching attendance: $e");
      return null;
    }
  }

  static Future<bool> updateAttendance(
      String token, String studentId, int subjectId, String date, bool status) async {
    try {
      final response = await http.put(
        Uri.parse(ApiLinkHelper.UpdateAttendanceUri()),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "studentId": studentId,
          "subjectId": subjectId,
          "date": date,
          "status": status
        }),
      );

      if (response.statusCode == 200) {
        print("Attendance updated successfully.");
        return true;
      } else {
        print("Failed to update attendance: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("Error updating attendance: $e");
      return false;
    }
  }

  static Future<bool> addClass(
      String token, String course, int batchYear, String section) async {
    try {
      final response = await http.post(
        Uri.parse(ApiLinkHelper.AddClassUri()), // Replace with actual API endpoint
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "course": course,
          "batchYear": batchYear,
          "section": section
        }),
      );

      if (response.statusCode == 200) {
        print("Class added successfully.");
        return true;
      } else {
        print("Failed to add class: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("Error adding class: $e");
      return false;
    }
  }

  static Future<bool> addSubject(
      String token, String subjectId, String subjectName, String courseName) async {
    try {
      final response = await http.post(
        Uri.parse(ApiLinkHelper.AddSubjectUri()), // API Endpoint
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "subjectId": subjectId,
          "subjectName": subjectName,
          "course": courseName // ✅ Sending courseId instead of course name
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print("Error adding subject: $e");
      return false;
    }
  }

  static Future<List<Map<String, dynamic>>?> getAllTeachers(String token) async {
    try {
      final response = await http.get(
        Uri.parse(ApiLinkHelper.GetAllTeachersUri()), // API Endpoint
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      } else {
        print("Failed to fetch teachers: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error fetching teachers: $e");
      return null;
    }
  }

  // Fetch teacher details by teacherId
  static Future<TeacherDetailResponse?> getTeacherDetails(String token, String teacherId) async {
    try {
      final response = await http.get(
        Uri.parse(ApiLinkHelper.getTeacherDetailsApiUri(teacherId)), // API Endpoint
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      print("getTeacherDetails Response status: ${response.statusCode}");
      print("getTeacherDetails Response body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return TeacherDetailResponse.fromJson(data);
      } else {
        print("getTeacherDetails failed: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error in getTeacherDetails: $e");
      return null;
    }
  }

  static Future<bool> assignTeacherToSubject(
      String token, String subjectCode, String teacherId, int classId) async {
    try {
      final response = await http.post(
        Uri.parse(ApiLinkHelper.assignTeacherApiUri()), // Define this in API Helper
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "subjectId": subjectCode.toString(), // Convert to String as expected by API
          "teacherId": teacherId,
          "classId" : classId
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print("Error in assignTeacherToSubject: $e");
      return false;
    }
  }

  static Future<bool> updateAssignedTeacher(
      String token, String subjectCode, String newTeacherId, int classId, String password) async {
    try {
      final Uri apiUrl = Uri.parse(
          "${ApiLinkHelper.assignTeacherApiUri()}?password=$password"); // Sending password as query parameter

      final response = await http.put(
        apiUrl,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "subjectId": subjectCode, // Ensure subjectCode is a string
          "teacherId": newTeacherId, // The new teacher's UUCMS ID
          "classId": classId
        }),
      );

      print("Response Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      return response.statusCode == 200; // Success condition
    } catch (e) {
      print("Error in updateAssignedTeacher: $e");
      return false;
    }
  }

  static Future<bool> addUser({
    required String token,
    required AddUserRequest request,
  }) async {
    try {
      final Uri apiUrl = Uri.parse(ApiLinkHelper.addUserApiUri());

      final response = await http.post(
        apiUrl,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: request.toJsonString(), // Convert request object to JSON
      );

      // Debugging response
      print("Response Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      // Return true if request is successful (status 201 - Created)
      return response.statusCode == 201;
    } catch (e) {
      print("Error in addUser: $e");
      return false;
    }
  }

  static Future<bool> addTeacher(AddTeacherRequest request) async {
    try {
      // Get token from SharedPreferences (if authentication is required)
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("auth_token");

      final Uri apiUrl = Uri.parse(ApiLinkHelper.addTeacherApiUri());

      final response = await http.post(
        apiUrl,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(request.toJson()), // Convert request object to JSON
      );

      print("Response Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      return response.statusCode == 201; // Return true if request was successful
    } catch (e) {
      print("Error in addTeacher: $e");
      return false;
    }
  }
}



