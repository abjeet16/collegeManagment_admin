class ApiLinkHelper {
  static const String BASE_URL = "http://192.168.182.68:8080/api/v1/";

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

  static String getSubjectsByCourseIdApiUri(int courseId, int classId) {
    return "${BASE_URL}Admin/course/$courseId/class/$classId/subjects";
  }

  static String getStudentsByClassIdApiUri(int classId) {
    return "${BASE_URL}Admin/class/$classId/students";
  }

  static String getStudentByIdApiUri(String studentId) {
    return "${BASE_URL}Admin/student/$studentId";
  }

  static String getStudentSubjectAttendanceUri(String studentId,int subjectId){
    return "${BASE_URL}Admin/attendance/student/$studentId/subject/$subjectId";
  }

  static String UpdateAttendanceUri() {
    return"${BASE_URL}Admin/updateAttendance";
  }

  static String AddClassUri(){
    return "${BASE_URL}Admin/add_class";
  }

  static String AddSubjectUri(){
    return "${BASE_URL}Admin/add_subject";
  }

  static String GetAllTeachersUri(){
    return "${BASE_URL}Admin/Teachers";
  }

  static String getTeacherDetailsApiUri(String teacherId){
    return "${BASE_URL}Admin/Teacher/$teacherId/details";
  }

  static String assignTeacherApiUri(){
    return "${BASE_URL}Admin/assignTeacher";
  }

  static String addUserApiUri(){
    return "${BASE_URL}Admin/addUser";
  }

  static String addTeacherApiUri(){
    return "${BASE_URL}Admin/addTeacher";
  }

  static String registerStudentsBulkApiUri() {
    return "${BASE_URL}Admin/student/register-bulk";
  }

  static String changeUserDetailsApiUri(){
    return "${BASE_URL}Admin/user/changeDetails";
  }

  static String admins(){
    return "${BASE_URL}Admin";
  }

  static String deleteCLass(int classId){
    return "${BASE_URL}Admin/deleteStudents/$classId";
  }
}
