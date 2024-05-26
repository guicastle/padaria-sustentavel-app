import 'package:get/get.dart';
import 'package:padaria_sustentavel_app/ui/pages/home_page.dart';
import 'package:padaria_sustentavel_app/ui/pages/menu_bar_page.dart';
import 'package:padaria_sustentavel_app/ui/pages/image_text_page.dart';

class Routes {
  static final pages = [
    GetPage(
      name: '/',
      page: () => const MenuBar(),
    ),
    GetPage(
      name: '/home',
      page: () => const HomeScreen(),
    ),
    GetPage(
      name: '/image',
      page: () => ImageTextPage(),
    ),
  ];
}
