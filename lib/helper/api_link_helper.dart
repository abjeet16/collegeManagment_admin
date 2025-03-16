class ApiLinkHelper {
  static const String BASE_URL = "https://abjeet.up.railway.app/api/v1/";

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

  static String viewCoursesApiUri(){
    return "${BASE_URL}Admin/courses";
  }

  static String addCourseApiUri() {
    return "${BASE_URL}Admin/add_course";
  }

  static deleteCourseApiUri(int courseId, String password) {
    return "${BASE_URL}Admin/deleteCourse/$courseId?password=$password";
  }
}
