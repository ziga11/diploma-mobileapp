import 'package:flutter/material.dart';
import 'package:diplomaapp/src/core/setup_locator.dart';
import 'package:diplomaapp/src/services/language_service.dart';
import 'package:diplomaapp/src/services/user_service.dart';
import 'package:diplomaapp/src/shared/widgets/appbar.dart';
import 'package:diplomaapp/src/shared/widgets/drawer.dart';
import 'package:diplomaapp/src/shared/widgets/form_field.dart';
import 'package:diplomaapp/src/utils/date_helper.dart';
import 'package:diplomaapp/src/constants/theme.dart';

class ProfilePage extends StatefulWidget {
  static const route = '/profile-page';
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController userEditingController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final userService = getIt<UserService>();

  late final Map<String, TextEditingController> controllers = {
    "firstName":
        TextEditingController(text: userService.currentUser?.firstName),
    "lastName": TextEditingController(text: userService.currentUser?.lastName),
    "dofBirth": TextEditingController(
        text: formatDate(userService.currentUser!.birthDate)),
    "email": TextEditingController(text: userService.account.value?.email),
    "address": TextEditingController(text: userService.currentUser?.address),
    "citizenship":
        TextEditingController(text: userService.currentUser?.country),
    "workPermit":
        TextEditingController(text: userService.currentUser?.workPermit)
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: DiplomaAppbar(
        leading: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            BackButton(
              color: ColorTheme.white,
            ),
            IconButton(
                onPressed: () {
                  _scaffoldKey.currentState!.openDrawer();
                },
                icon: const Icon(Icons.menu_rounded))
          ],
        ),
      ),
      drawer: const DiplomaDrawer(),
      body: Container(
        height: double.infinity,
        alignment: Alignment.center,
        child: FractionallySizedBox(
          widthFactor: 0.85,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (var key in controllers.keys)
                ValueListenableBuilder(
                    valueListenable: getIt<LanguageService>().translations,
                    builder: (context, translations, child) {
                      return DiplomaFormField(
                        label: translations[key]!,
                        controller: controllers[key]!,
                      );
                    })
            ],
          ),
        ),
      ),
    );
  }
}
