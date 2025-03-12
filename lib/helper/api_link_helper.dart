class ApiLinkHelper {
  static const String BASE_URL = "https://collegemanagment-springboot-production.up.railway.app/api/v1/";

  static String loginUserApiUri() {
    return "${BASE_URL}auth/user/login";
  }

  static String getUserProfileApiUri() {
    return "${BASE_URL}User/my_profile";
  }

  static String getMyClassesApiUri() {
    return "${BASE_URL}teacher/my_classes";
  }

  static String getStudentsOfClassApiUri(int classId) {
    return "${BASE_URL}teacher/$classId/students";
  }

  static String markAttendanceApiUri() {
    return "${BASE_URL}teacher/mark_attendance";
  }
}
