import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  const UserProfile({
    this.name = '',
    this.dateOfBirth,
    this.gender = '',
    this.profileImagePath,
  });

  final String name;
  final DateTime? dateOfBirth;
  final String gender;
  final String? profileImagePath;

  bool get isComplete =>
      name.trim().isNotEmpty &&
      dateOfBirth != null &&
      gender.isNotEmpty;

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  UserProfile copyWith({
    String? name,
    DateTime? dateOfBirth,
    bool clearDateOfBirth = false,
    String? gender,
    String? profileImagePath,
    bool clearProfileImage = false,
  }) {
    return UserProfile(
      name: name ?? this.name,
      dateOfBirth: clearDateOfBirth ? null : (dateOfBirth ?? this.dateOfBirth),
      gender: gender ?? this.gender,
      profileImagePath: clearProfileImage
          ? null
          : (profileImagePath ?? this.profileImagePath),
    );
  }

  @override
  List<Object?> get props => [name, dateOfBirth, gender, profileImagePath];
}
