import 'package:diplomaapp/src/shared/domain/user.dart';
import 'package:diplomaapp/src/shared/domain/account.dart';

class LoginResponse {
  final User? user;
  final Account? account;
  final bool successful;
  final String? reasoning;
  final String? secureToken;
  final String? repeatToken;

  const LoginResponse(
      {this.user,
      this.account,
      required this.successful,
      this.reasoning,
      this.secureToken,
      this.repeatToken});
}
