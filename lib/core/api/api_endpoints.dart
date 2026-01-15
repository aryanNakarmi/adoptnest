class ApiEndpoints {
  ApiEndpoints._();

  // Base URL - change this for production
  static const String baseUrl = 'http://10.0.2.2:3000/api/v1';
  //static const String baseUrl = 'http://localhost:3000/api/v1';
  // For Android Emulator use: 'http://10.0.2.2:3000/api/v1'
  // For iOS Simulator use: 'http://localhost:5000/api/v1'
  // For Physical Device use your computer's IP: 'http://192.168.x.x:5000/api/v1'

  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

 // ===================  Users EndPoints ===================
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String currentUser = '/auth/currentUser';
  static String userById(String id) => '/users/$id';
  static String updateUser(String id) => '/users/$id'; // PUT for profile update

  // =================== Pets / Animals ===================
  static const String pets = '/pets';
  static String petById(String id) => '/pets/$id'; // GET, PUT, DELETE

  // =================== Adoption Requests ===================
  static const String adoptions = '/adoptions';
  static String adoptionById(String id) => '/adoptions/$id'; // GET, PUT, DELETE

  // =================== Reports (Lost/Found Pets) ===================
  static const String reports = '/reports';
  static String reportById(String id) => '/reports/$id'; // GET, PUT, DELETE


}
