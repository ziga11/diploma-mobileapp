import 'package:get_it/get_it.dart';
import 'package:diplomaapp/src/auth/data/auth_repository.dart';
import 'package:diplomaapp/src/auth/domain/login_response.dart';
import 'package:diplomaapp/src/core/setup_locator.dart';
import 'package:diplomaapp/src/services/user_service.dart';
import 'package:diplomaapp/src/shared/data/user_repository.dart';
import 'package:diplomaapp/src/shared/domain/account.dart';
import 'package:diplomaapp/src/shared/domain/user.dart';
import 'package:diplomaapp/src/utils/other.dart';

class LoginController {
  final AuthRepository aRepo = getIt<AuthRepository>();
  final UserRepository uRepo = getIt<UserRepository>();
  final UserService uService = getIt<UserService>();

  bool validEmail(String email) {
    return RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email);
  }

  Future<void> successfulLogin(LoginResponse response) async {
    int aId = response.account!.id!;
    int uId = response.user!.id;

    await saveToSecureStorage(
      aId: aId,
      uId: uId,
      secureToken: response.secureToken!,
      repeatToken: response.repeatToken!,
    );

    await uService.initUser(user: response.user!, acc: response.account!);
  }

  Future<void> resetPassword({
    required String email,
    required String pw,
    required String confPw,
    required String token,
  }) async {
    throwIf(pw != confPw, "nonMatchingPW");
    throwIf(pw.length < 6, "pwMin6Chars");

    await aRepo.resetPW(email, pw, token);
  }

  Future<void> applySetPassword(
      {required String token,
      required String pw,
      required String confPw}) async {
    throwIf(pw != confPw, "nonMatchingPW");
    throwIf(pw.length < 6, "pwMin6Chars");

    try {
      final map = await aRepo.setPW(token: token, pw: pw);

      Account acc = Account.fromJson(map["account"]);
      User user = User.fromJson(map["user"]);

      await saveToSecureStorage(
          aId: acc.id!,
          uId: user.id,
          secureToken: map["secure_token"]!,
          repeatToken: map["repeat_token"]!);

      await getIt<UserService>().initUser(acc: acc, user: user);
    } catch (e) {
      throw Exception("errorOccurred");
    }
  }
}
