import 'dart:convert';
import 'package:attendence_admin_fultter/modules/user_profile.dart';
import 'package:http/http.dart' as http;
import '../helper/api_link_helper.dart';
import '../modules/UserLoginRequest.dart';
import '../modules/UserLoginResponse.dart';

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
}

