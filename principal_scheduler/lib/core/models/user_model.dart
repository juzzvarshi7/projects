import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { staff, principal }

class UserModel {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String? phoneNumber;
  final UserRole role;
  final String? department;
  final String? profileImageUrl;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final Map<String, dynamic>? preferences;

  UserModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.phoneNumber,
    required this.role,
    this.department,
    this.profileImageUrl,
    this.isActive = true,
    required this.createdAt,
    this.lastLoginAt,
    this.preferences,
  });

  String get fullName => '$firstName $lastName';
  
  bool get isStaff => role == UserRole.staff;
  bool get isPrincipal => role == UserRole.principal;

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return UserModel(
      id: doc.id,
      email: data['email'] ?? '',
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      phoneNumber: data['phoneNumber'],
      role: UserRole.values.firstWhere(
        (role) => role.name == data['role'],
        orElse: () => UserRole.staff,
      ),
      department: data['department'],
      profileImageUrl: data['profileImageUrl'],
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastLoginAt: data['lastLoginAt'] != null
          ? (data['lastLoginAt'] as Timestamp).toDate()
          : null,
      preferences: data['preferences'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'role': role.name,
      'department': department,
      'profileImageUrl': profileImageUrl,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLoginAt': lastLoginAt != null 
          ? Timestamp.fromDate(lastLoginAt!) 
          : null,
      'preferences': preferences,
    };
  }

  UserModel copyWith({
    String? email,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    UserRole? role,
    String? department,
    String? profileImageUrl,
    bool? isActive,
    DateTime? lastLoginAt,
    Map<String, dynamic>? preferences,
  }) {
    return UserModel(
      id: id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      department: department ?? this.department,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      preferences: preferences ?? this.preferences,
    );
  }
}