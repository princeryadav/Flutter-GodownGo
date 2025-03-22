class APIConfig {
  static const String baseUrl = "https://localhost:7231/api";
  
  // Auth Endpoints
  static const String sendOtp = "$baseUrl/user/send-otp";
  static const String verifyOtp = "$baseUrl/user/verify-otp";
  static const String registerUser = "$baseUrl/user/register";
  // static const String loginUser = "$baseUrl/User/login";
  
  // Location Endpoints
  static const String getNearByUsers = "$baseUrl/location/nearby-users";
  
  // User Endpoints
  static const String getUserProfile = "$baseUrl/user/profile";
  static const String updateUserProfile = "$baseUrl/user/update";
}