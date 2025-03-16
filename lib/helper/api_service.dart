import 'dart:convert';
import 'package:attendence_admin_fultter/modules/user_profile.dart';
import 'package:http/http.dart' as http;
import '../helper/api_link_helper.dart';
import '../modules/UserLoginRequest.dart';
import '../modules/UserLoginResponse.dart';
import '../modules/course.dart'; // Import Course model

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
        Uri.parse(ApiLinkHelper.viewCoursesApiUri()), // Define this URL in ApiLinkHelper
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

  // Add a new course
  static Future<bool> addCourse(String token, String courseName) async {
    try {
      final response = await http.post(
        Uri.parse(ApiLinkHelper.addCourseApiUri()), // Define this URL in ApiLinkHelper
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

      if (response.statusCode == 200) {
        return true; // Course added successfully
      } else {
        print("addCourse failed: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("Error in addCourse: $e");
      return false;
    }
  }

  static Future<bool> deleteCourse(String token, int courseId, String password) async {
    try {
      final uri = Uri.parse(ApiLinkHelper.deleteCourseApiUri(courseId,password));

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
        return true; // Course deleted successfully
      } else {
        print("deleteCourse failed: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("Error in deleteCourse: $e");
      return false;
    }
  }
}


