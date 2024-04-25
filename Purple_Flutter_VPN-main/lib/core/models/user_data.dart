class UserData {
  String? contactNumber;
  String? email;
  String? firstName;
  String? lastName;
  String? profileImage;
  String? socialImage;
  String? loginType;
  int? id;
  String? uid;
  String? username;

  UserData({
    this.contactNumber,
    this.socialImage,
    this.email,
    this.firstName,
    this.id,
    this.lastName,
    this.username,
    this.profileImage,
    this.uid,
    this.loginType,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      contactNumber: json['contact_number'],
      email: json['email'],
      firstName: json['first_name'],
      id: json['id'],
      lastName: json['last_name'],
      socialImage: json['social_image'],
      username: json['username'],
      profileImage: json['profile_image'],
      uid: json['uid'],
      loginType: json['login_type'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (contactNumber != null) data['contact_number'] = contactNumber;
    if (email != null) data['email'] = email;
    if (firstName != null) data['first_name'] = firstName;
    if (id != null) data['id'] = id;
    if (socialImage != null) data['social_image'] = socialImage;
    if (lastName != null) data['last_name'] = lastName;
    if (username != null) data['username'] = username;
    if (profileImage != null) data['profile_image'] = profileImage;
    if (uid != null) data['uid'] = uid;
    if (loginType != null) data['login_type'] = loginType;
    return data;
  }

  Map<String, dynamic> toFirebaseJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (id != null) data['id'] = id;
    if (uid != null) data['uid'] = uid;
    if (firstName != null) data['first_name'] = firstName;
    if (lastName != null) data['last_name'] = lastName;
    if (email != null) data['email'] = email;
    if (socialImage != null) data['social_image'] = socialImage;
    if (profileImage != null) data['profile_image'] = profileImage;
    return data;
  }
}
