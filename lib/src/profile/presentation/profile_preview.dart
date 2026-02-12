import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:country_picker/country_picker.dart';
import 'package:diplomaapp/src/core/navigation/menu.dart';
import 'package:diplomaapp/src/core/setup_locator.dart';
import 'package:diplomaapp/src/services/language_service.dart';
import 'package:diplomaapp/src/obligation/domain/obligation.dart';
import 'package:diplomaapp/src/obligation/presentation/obligation_page.dart';
import 'package:diplomaapp/src/profile/application/profile_controller.dart';
import 'package:diplomaapp/src/profile/application/workpermit_enum.dart';
import 'package:diplomaapp/src/shared/domain/user.dart';
import 'package:diplomaapp/src/shared/widgets/appbar.dart';
import 'package:diplomaapp/src/shared/widgets/form_field.dart';
import 'package:diplomaapp/src/shared/widgets/menu_button.dart';
import 'package:diplomaapp/src/utils/date_helper.dart';
import 'package:diplomaapp/src/utils/other.dart';
import 'package:diplomaapp/src/utils/ui_helper.dart';
import 'package:diplomaapp/src/constants/theme.dart';
import 'package:logger/logger.dart';

class ProfilePreviewPage extends StatefulWidget {
  const ProfilePreviewPage({super.key});
  static const route = '/profile-preview';

  @override
  State<ProfilePreviewPage> createState() => _ProfilePreview();
}

class _ProfilePreview extends State<ProfilePreviewPage> {
  WorkPermit? workPermitVal;
  List<WorkPermit>? workPermitOptions;
  FilePickerResult? workPermitFile;

  final controller = ProfileController();

  late User user = controller.userService.currentUser!;

  late Country selCountry = CountryParser.parse(user.country);

  late final bool isEuEfta;

  Obligation? ddObligation;

  late final Map<String, TextEditingController> controllers = {
    "firstName": TextEditingController(text: user.firstName),
    "lastName": TextEditingController(text: user.lastName),
    "dofBirth": TextEditingController(text: formatDate(user.birthDate)),
    "email": TextEditingController(
        text: controller.userService.currentAccount!.email),
    "address": TextEditingController(text: user.address),
    "citizenship":
        TextEditingController(text: "${selCountry.flagEmoji} ${user.country}"),
  };

  ValueNotifier isLoadingNotifier = ValueNotifier(false);
  ValueNotifier fileIconNotifier = ValueNotifier(ColorTheme.white);

  @override
  void initState() {
    super.initState();
    loadWorkpermit();
    isEuEfta = isEUEFTA(user.country);
  }

  void loadWorkpermit() {
    workPermitOptions = [
      WorkPermit.none,
      WorkPermit.temporary,
      WorkPermit.permanent,
    ];
    workPermitVal = WorkPermit.none;
  }

  User updatedUser() {
    return user.copyWith(
        id: user.id,
        group: user.group,
        firstName: controllers["firstName"]!.text,
        lastName: controllers["lastName"]!.text,
        mobile: user.mobile,
        birthDate:
            DateFormat('dd.MM.yyyy').parse(controllers["dofBirth"]!.text),
        address: controllers["address"]!.text,
        workPermit: workPermitVal!.englishValue,
        country: selCountry.name);
  }

  @override
  Widget build(BuildContext context) {
    bool isEuEfta = isEUEFTA(user.country);
    if (isEuEfta) {
      workPermitVal = workPermitOptions![2];
    }

    return Scaffold(
      appBar: DiplomaAppbar(),
      body: Container(
        height: double.infinity,
        alignment: Alignment.center,
        child: SizedBox(
          width: width(context) * 0.85,
          child: SingleChildScrollView(
            child: ValueListenableBuilder<Map<String, String>>(
                valueListenable: getIt<LanguageService>().translations,
                builder: (context, translations, child) {
                  return Column(
                    children: [
                      gap(),
                      TapRegion(
                        onTapOutside: (_) {
                          FocusScope.of(context).unfocus();
                        },
                        child: Column(
                          children: [
                            for (var i = 0; i < 5; i++) ...[
                              DiplomaFormField(
                                  label: translations[
                                      controllers.keys.elementAt(i)]!,
                                  controller: controllers[
                                      controllers.keys.elementAt(i)]!),
                              gap()
                            ],
                            citizenshipDropdown(translations),
                            gap(),
                            if (!isEUEFTA(selCountry.name))
                              workpermitDropdown(translations),
                            gap(),
                          ],
                        ),
                      ),
                      gap(),
                      applyWidget(translations),
                      gap(),
                    ],
                  );
                }),
          ),
        ),
      ),
    );
  }

  Widget gap() => SizedBox(height: height(context) * 0.03);

  Widget citizenshipDropdown(Map<String, String> translations) {
    return DiplomaFormField(
      label: translations["citizenship"]!,
      controller: controllers["citizenship"]!,
      readOnly: true,
      onTap: () => {
        showCountryPicker(
          context: context,
          favorite: {
            selCountry.countryCode,
            "SI",
          }.toList(),
          showPhoneCode: true,
          onSelect: (Country country) {
            selCountry = country;
            controllers["citizenship"]!.text =
                "${country.flagEmoji} ${country.name}";
            setState(() {});
          },
          moveAlongWithKeyboard: false,
          countryListTheme: CountryListThemeData(
            backgroundColor: ColorTheme.bgLight.withValues(alpha: 0.8),
            inputDecoration: InputDecoration(
              labelText: translations["searchMessage"],
              hintText: translations["searchMessage"],
              hintStyle: Theme.of(context).textTheme.labelLarge,
              labelStyle: TextStyle(color: ColorTheme.white),
              prefixIcon: Icon(
                Icons.search,
                color: ColorTheme.white,
              ),
            ),
            searchTextStyle: Theme.of(context).textTheme.titleLarge,
          ),
        )
      },
    );
  }

  Widget applyWidget(Map<String, String> translations) {
    return ValueListenableBuilder(
        valueListenable: isLoadingNotifier,
        builder: (context, value, child) {
          return DiplomaBtn(
            title: translations["apply"]!,
            size: Size(width(context) * 0.65, 40),
            isLoading: value,
            fontSize: 15,
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              final navigator = Navigator.of(context);

              isLoadingNotifier.value = true;
              try {
                User userUpdated = updatedUser();
                if (!userUpdated.equal(user)) {
                  await controller.uRepo.updateUser(userUpdated);
                  user = userUpdated;
                }

                if (isEuEfta) {
                  await controller.assignEuEfta();
                } else if (workPermitVal != WorkPermit.none) {
                  if (workPermitVal == null) {
                    flickerMissingFile(translations, messenger);
                    return;
                  }
                  await controller.assignTujina(
                      workPermitFile!.files, ddObligation!);
                } else {
                  await controller.assignTujina(null, null);
                }

                navigator.pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const Menu(),
                  ),
                );
              } catch (e) {
                Logger().f(e);
              } finally {
                isLoadingNotifier.value = false;
              }
            },
          );
        });
  }

  void flickerMissingFile(
      Map<String, String> translations, ScaffoldMessengerState messenger) {
    messenger.showSnackBar(
      SnackBar(
          duration: Duration(milliseconds: 1500),
          content: Text(translations["attachDD"]!)),
    );

    isLoadingNotifier.value = true;
    fileIconNotifier.value = ColorTheme.red;

    Future.delayed(const Duration(seconds: 3),
        () => fileIconNotifier.value = ColorTheme.white);
  }

  Widget workpermitDropdown(Map<String, String> translations) {
    return SizedBox(
      width: width(context) * 0.85,
      child: DropdownButtonFormField<WorkPermit>(
        icon: SizedBox(
          width: width(context) * 0.15,
          child:
              workPermitVal == WorkPermit.none ? null : workpermitFileIcons(),
        ),
        padding: EdgeInsets.only(left: width(context) * 0.15),
        isExpanded: true,
        alignment: AlignmentGeometry.center,
        initialValue: workPermitVal,
        hint: Center(
          child: Text(
            translations["workPermit"]!,
            style: TextStyle(
              color: ColorTheme.white,
            ),
          ),
        ),
        dropdownColor: ColorTheme.bgLight.withValues(alpha: 0.7),
        style: TextStyle(color: ColorTheme.white, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          labelText: translations["workPermit"],
          floatingLabelStyle:
              TextStyle(fontWeight: FontWeight.bold, color: ColorTheme.white),
          floatingLabelAlignment: FloatingLabelAlignment.center,
          labelStyle: TextStyle(color: ColorTheme.white),
          hintText: translations["workPermit"],
        ),
        items: workPermitOptions!
            .map(
              (e) => DropdownMenuItem(
                value: e,
                child: Center(
                  child: Text(
                    translations[e.translationKey]!,
                    style: TextStyle(color: ColorTheme.white),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            )
            .toList(),
        onChanged: (WorkPermit? e) {
          setState(() {
            workPermitVal = e;
          });
          if (e != workPermitOptions![0]) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  backgroundColor: ColorTheme.red,
                  content: Text(translations["attachDD"]!)),
            );
          }
        },
      ),
    );
  }

  Widget workpermitFileIcons() {
    return Row(
      children: [
        Expanded(
          child: IconButton(
              onPressed: () async {
                var ctx = context;

                ddObligation = await controller.workpermitObligation();
                var ddDoc = await controller
                    .workpermitDocument(ddObligation!.exampleDocId!);

                if (ctx.mounted) {
                  showDialog(
                      context: ctx,
                      builder: (dialogContext) => ObligationPage(
                            obligation: ddObligation!,
                            document: ddDoc,
                          ));
                }
              },
              icon: Icon(Icons.question_mark_outlined)),
        ),
        Expanded(
          child: ValueListenableBuilder(
              valueListenable: fileIconNotifier,
              builder: (context, value, _) {
                return TweenAnimationBuilder<Color?>(
                  tween: ColorTween(begin: ColorTheme.white, end: value),
                  duration: const Duration(milliseconds: 600),
                  builder: (_, color, __) {
                    return IconButton(
                      onPressed: () async {
                        FilePickerResult? result = await FilePicker.platform
                            .pickFiles(type: FileType.any);
                        if (result == null) {
                          color = ColorTheme.green;
                          return;
                        }

                        workPermitFile = result;
                        fileIconNotifier.value = ColorTheme.green;
                      },
                      icon: Icon(Icons.file_open, color: color),
                    );
                  },
                );
              }),
        ),
      ],
    );
  }
}
