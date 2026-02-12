import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:diplomaapp/src/constants/theme.dart';
import 'package:diplomaapp/src/core/setup_locator.dart';
import 'package:diplomaapp/src/profile/presentation/profile.dart';
import 'package:diplomaapp/src/services/language_service.dart';
import 'package:diplomaapp/src/shared/domain/language.dart';

class DiplomaAppbar extends StatefulWidget implements PreferredSizeWidget {
  final Widget? leading;
  final Color? bgColor;
  final Gradient? gradient;
  final bool showUser;
  final bool showLogo;

  const DiplomaAppbar(
      {super.key,
      this.leading,
      this.bgColor,
      this.gradient,
      this.showLogo = true,
      this.showUser = true});

  @override
  State<DiplomaAppbar> createState() => DiplomaAppbarState();

  @override
  Size get preferredSize => AppBar().preferredSize;
}

class DiplomaAppbarState extends State<DiplomaAppbar> {
  List<DropdownMenuItem<Language>> langIconItems = Language.values
      .map((language) => DropdownMenuItem<Language>(
            value: language,
            child: Image.asset(
              language.iconUri,
              width: 30,
              height: 30,
            ),
          ))
      .toList();

  final langService = getIt<LanguageService>();

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leadingWidth:
          widget.leading is Row ? MediaQuery.of(context).size.width / 3 : null,
      iconTheme: const IconThemeData(color: Colors.white),
      backgroundColor: widget.bgColor ??
          (widget.gradient == null ? ColorTheme.bgHighlight : null),
      flexibleSpace: Container(
        decoration: widget.gradient == null
            ? null
            : BoxDecoration(gradient: widget.gradient),
        child: !widget.showLogo
            ? null
            : Center(
                child: SvgPicture.asset(
                  "assets/logo_gradient.svg",
                  width:
                      (Scaffold.of(context).appBarMaxHeight ?? kToolbarHeight) *
                          0.7,
                  height:
                      (Scaffold.of(context).appBarMaxHeight ?? kToolbarHeight) *
                          0.7,
                ),
              ),
      ),
      leading: widget.leading,
      actions: [
        Container(
          alignment: Alignment.centerRight,
          padding: EdgeInsets.only(right: widget.showUser ? 5 : 15),
          child: DropdownButton<Language>(
            focusColor: Colors.transparent,
            elevation: 0,
            isExpanded: false,
            underline: const SizedBox.shrink(),
            icon: SizedBox.shrink(),
            value: langService.current,
            items: langIconItems,
            onChanged: (Language? language) async {
              langService.setLanguage(language!);
              setState(() {});
            },
          ),
        ),
        if (widget.showUser)
          IconButton(
              onPressed: () {
                final currentRoute = ModalRoute.of(context)?.settings.name;

                if (currentRoute != ProfilePage.route) {
                  Navigator.of(context).pushNamed(ProfilePage.route);
                }
              },
              icon: const Icon(
                Icons.person_rounded,
                color: Colors.white,
              ))
      ],
    );
  }
}
