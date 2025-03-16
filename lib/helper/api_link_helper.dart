class ApiLinkHelper {
  static const String BASE_URL = "http://192.168.29.30:8080/api/v1/";

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

  static String getClassesByCourseIdApiUri(int courseId) {
    return "${BASE_URL}Admin/course/$courseId/classes";
  }

  static String getSubjectsByCourseIdApiUri(int courseId) {
    return "${BASE_URL}Admin/course/$courseId/subjects";
  }

  static String getStudentsByClassIdApiUri(int classId) {
    return "${BASE_URL}Admin/class/$classId/students";
  }

  static String getStudentByIdApiUri(String studentId) {
    return "${BASE_URL}Admin/student/$studentId";
  }

  static String getStudentSubjectAttendeceUri(String studentId,int subjectId){
    return "${BASE_URL}Admin/attendence?studentId=$studentId&subjectId=$subjectId";
  }

  static String UpdateAttendanceUri() {
    return"${BASE_URL}Admin/updateAttendance";
  }
}
