import 'package:diplomaapp/src/shared/data/encrypted_token_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:diplomaapp/src/core/setup_locator.dart';
import 'package:diplomaapp/src/services/firebase_api.dart';
import 'package:diplomaapp/src/shared/data/hashed_token_repository.dart';
import 'package:diplomaapp/src/shared/data/user_repository.dart';
import 'package:diplomaapp/src/shared/domain/account.dart';
import 'package:diplomaapp/src/shared/domain/token.dart';
import 'package:diplomaapp/src/shared/domain/user.dart';

class UserService {
  final user = ValueNotifier<User?>(null);
  final infoUser = ValueNotifier<User?>(null);
  final account = ValueNotifier<Account?>(null);
  final storage = getIt<FlutterSecureStorage>();

  bool initialized = false;

  final hTokenRepo = getIt<HashedTokenRepository>();
  final eTokenRepo = getIt<EncryptedTokenRepository>();

  User? get currentUser => user.value;
  Account? get currentAccount => account.value;

  void setSession(User? u, Account? a) {
    user.value = u;
    account.value = a;
  }

  Future<void> clear() async {
    final tokenKeys = ["secure_token", "repeat_token"];
    final fcm = getIt<FirebaseAPI>().fcmToken;

    final accId = currentAccount?.id;

    if (accId != null) {
      if (fcm != null) {
        eTokenRepo.deleteToken(Token(accId: accId, token: fcm, type: "FCM"));
      }

      for (final key in tokenKeys) {
        final token = await storage.read(key: key);
        if (token != null) {
          hTokenRepo.deleteToken(Token(accId: accId, token: token, type: key));
        }
      }
    }

    await Future.wait([
      storage.delete(key: "acc_id"),
      storage.delete(key: "user_id"),
      ...tokenKeys.map((key) => storage.delete(key: key)),
    ]);

    setSession(null, null);
  }

  Future<void> initializeSession() async {
    String? accId = await storage.read(key: "acc_id");
    String? userId = await storage.read(key: "user_id");
    String? secureToken = await storage.read(key: "secure_token");
    String? repeatToken = await storage.read(key: "repeat_token");

    if ([userId, accId, secureToken, repeatToken].any((e) => e == null)) {
      initialized = true;
      return;
    }

    bool st = await hTokenRepo.matchingToken(Token(
      accId: int.parse(accId!),
      token: secureToken!,
      type: "secure_token",
    ));
    bool rt = await hTokenRepo.matchingToken(Token(
      accId: int.parse(accId),
      token: repeatToken!,
      type: "repeat_token",
    ));

    if (!st || !rt) {
      clear();
      initialized = true;
      return;
    }

    await initUser(accId: int.parse(accId), userId: int.parse(userId!));

    initialized = true;
  }

  Future initUser({User? user, Account? acc, int? accId, int? userId}) async {
    final userRepo = getIt<UserRepository>();
    final account = acc ?? await userRepo.accountById(accId!);
    final u = user ?? await userRepo.getUserById(userId!);

    setSession(u!, account!);

    infoUser.value = await userRepo.getUserById(1);
    getIt<FirebaseAPI>().syncNotificationToken(account: account);
  }
}
