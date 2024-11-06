class Patient {
  String id;
  String name;
  String email;
  String phoneNumber;
  String imageUrl;
  String bio;

  Patient({
    required this.email,
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.imageUrl,
    required this.bio,
  });

  factory Patient.formJson(Map<String, dynamic> json) {
    return Patient(
      email: json['email'],
      id: json['id'],
      name: json['name'],
      phoneNumber: json['phoneNumber'],
      imageUrl: json['imageUrl'],
      bio: json['bio'],
    );
  }

  Map<String, dynamic> toFireStore() {
    return {
      "id": id,
      "name": name,
      "email": email,
      "phoneNumber": phoneNumber,
      "imageUrl": imageUrl,
      "bio": bio,
    };
  }
}