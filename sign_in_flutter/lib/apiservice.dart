import 'package:googleapis/classroom/v1.dart' as classroom;
import 'package:google_sign_in/google_sign_in.dart' as GoogleSignIn;
import 'package:http/http.dart' as http;

class ApiService {
  GoogleSignIn.GoogleSignInAccount account;
  classroom.ClassroomApi classroomApi;
  final GoogleSignIn.GoogleSignIn googleSignIn = GoogleSignIn.GoogleSignIn.standard(
      scopes: [classroom.ClassroomApi.ClassroomCoursesReadonlyScope, classroom.ClassroomApi.ClassroomCourseworkMeReadonlyScope]);

  autoSignIn() async {
    account = await googleSignIn.signInSilently();
    if (account == null) {
      return false;
    }
    print("User account $account");
    await connectClassroom();
    return true;
  }

  signIn() async {
    account = await googleSignIn.signIn();
    if (account == null) {
      return false;
    }
    print("User account $account");
    await connectClassroom();
    return true;
  }

  connectClassroom() async {
    final authHeaders = await account.authHeaders;
    final authenticateClient = GoogleAuthClient(authHeaders);
    classroomApi = classroom.ClassroomApi(authenticateClient);
    return true;
  }

  signOut() {
    googleSignIn.signOut();
    googleSignIn.disconnect();
  }

  Future<bool> loginState() {
    if (account != null) {
      return Future.value(true);
    }
    if (googleSignIn == null) {
      return Future.value(false);
    }
    return googleSignIn.isSignedIn();
  }

  Future<List<classroom.Course>> courses() async {
    final classroom.ListCoursesResponse result = await classroomApi.courses.list(courseStates: ["ACTIVE"]);
    return result.courses;
  }

  Future<List<classroom.CourseWork>> assignments(classroom.Course course) async {
    try {
      final classroom.ListCourseWorkResponse result = await classroomApi.courses.courseWork.list(course.id);
      return result.courseWork;
    } on classroom.DetailedApiRequestError catch (e) {
      print(e.jsonResponse);
    }
    return new List<classroom.CourseWork>();
  }

  Future<List<classroom.StudentSubmission>> submission(classroom.Course course) async {
    try {
      final classroom.ListStudentSubmissionsResponse result = await classroomApi.courses.courseWork.studentSubmissions.list(course.id, '-');
      return result.studentSubmissions;
    } on classroom.DetailedApiRequestError catch (e) {
      print(e.jsonResponse);
    }
    return new List<classroom.StudentSubmission>();
  }

  DateTime date(classroom.CourseWork assignment) {
    classroom.Date dd = assignment.dueDate;
    classroom.TimeOfDay dt = assignment.dueTime;
    if (dd == null) {
      return null;
    }

    if (dt.hours == null || dt.minutes == null) {
      return DateTime.utc(dd.year, dd.month, dd.day, 0, 0).toLocal();
    }
    return DateTime.utc(dd.year, dd.month, dd.day, dt.hours, dt.minutes).toLocal();
  }
}

class GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = new http.Client();
  GoogleAuthClient(this._headers);
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _client.send(request..headers.addAll(_headers));
  }
}
