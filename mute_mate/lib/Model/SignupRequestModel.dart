class SignupRequestModel {
  String firstName;
  String lastName;
  String email;
  String governorate;
  String password;
  String mobileNumber;

  SignupRequestModel({
    this.firstName = '',
    this.lastName = '',
    this.email = '',
    this.governorate = '',
    this.password = '',
    this.mobileNumber = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'governorate': governorate,
      'password': password,
      'mobile_number': mobileNumber,
    };
  }
}
