// ignore_for_file: deprecated_member_use

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:padaria_sustentavel_app/ui/pages/home_page.dart';
import 'package:padaria_sustentavel_app/ui/utils/assets_util.dart';
import 'package:padaria_sustentavel_app/ui/utils/colors_util.dart';

class MenuBar extends StatelessWidget {
  const MenuBar({super.key});

  @override
  Widget build(BuildContext context) {
    // List pages
    List<Widget> pages = [
      const HomeScreen(),
      const Scaffold(),
    ];
    final navC = Get.put(NavbarController());
    return Obx(
      () => Scaffold(
        body: pages.elementAt(navC.index.value),
        floatingActionButtonLocation: const FixedCenterDockedFabLocation(),
        floatingActionButton: FloatingActionButton(
          backgroundColor: AppColors.primary,
          onPressed: () {
            Get.toNamed("/image");
          },
          elevation: 4.0,
          child: Container(
            margin: const EdgeInsets.all(15.0),
            child: SvgPicture.asset(
              AssetIcons.camera,
              color: Colors.white,
            ),
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          clipBehavior: Clip.antiAliasWithSaveLayer,
          elevation: 0.5,
          shape: const CircularNotchedRectangle(),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              color: Colors.white,
              child: BottomNavigationBar(
                selectedItemColor: AppColors.primary,
                selectedFontSize: 12,
                currentIndex: navC.index.value,
                onTap: (index) {
                  navC.setIndex(index);
                },
                type: BottomNavigationBarType.fixed,
                items: [
                  BottomNavigationBarItem(
                    label: "Home",
                    icon: SvgPicture.asset(
                      AssetIcons.home,
                      color: navC.index.value == 0
                          ? AppColors.primary
                          : AppColors.secondaryText,
                    ),
                  ),
                  BottomNavigationBarItem(
                    label: "Produtos",
                    icon: SvgPicture.asset(
                      AssetIcons.edit,
                      color: navC.index.value == 1
                          ? AppColors.primary
                          : AppColors.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class FixedCenterDockedFabLocation extends StandardFabLocation
    with FabCenterOffsetX, FabDockedOffsetY {
  const FixedCenterDockedFabLocation();

  @override
  String toString() => 'FloatingActionButtonLocation.fixedCenterDocked';

  @override
  double getOffsetY(
      ScaffoldPrelayoutGeometry scaffoldGeometry, double adjustment) {
    final double contentBottom = scaffoldGeometry.contentBottom;
    final double bottomMinInset = scaffoldGeometry.minInsets.bottom;
    if (bottomMinInset > 0) {
      // Hide if there's a keyboard
      return contentBottom;
    }
    return super.getOffsetY(scaffoldGeometry, adjustment);
  }
}

class NavbarController extends GetxController {
  var index = 0.obs;
  void setIndex(int page) => index.value = page;
}
