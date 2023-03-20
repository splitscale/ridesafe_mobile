import 'package:hooks_riverpod/hooks_riverpod.dart';

enum UserType { driver, family }

class UserDetails {
  final String username;
  final UserType userType;

  UserDetails({
    required this.username,
    required this.userType,
  });
}

final _userDetails = UserDetails(
  username: '',
  userType: UserType.driver,
);

final userDetailsProvider = StateProvider((ref) => _userDetails);
