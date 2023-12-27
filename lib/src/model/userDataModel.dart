class UserModel {
  final String uid;
  final String displayName;
  final String email;
  final String profile;

  UserModel(
      {required this.uid,
      required this.displayName,
      required this.email,
      required this.profile});

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'displayName': displayName,
      'email': email,
      'profile': profile
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
        uid: map['uid'],
        displayName: map['displayName'],
        email: map['email'],
        profile: map['profile']);
  }
}
