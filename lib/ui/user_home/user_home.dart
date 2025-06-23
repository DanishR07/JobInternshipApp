import 'package:final_lab/ui/user_home/user_main_scaffold.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../applied_positions/applied_positions_page.dart';
import '../profile/profile.dart';
import 'home.dart';
import 'internships/user_internships.dart';
import 'jobs/user_jobs.dart';

class UserHomePage extends StatefulWidget {
  const UserHomePage({super.key});

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  int currentPage = 0;

  @override
  void initState() {
    super.initState();
    final int? initialPage = Get.arguments as int?;
    if (initialPage != null) {
      currentPage = initialPage;
    }
    _initBinding(currentPage);
  }

  void _initBinding(int index) {
    switch (index) {
      case 0:
        HomeBinding().dependencies();
        break;
      case 1:
        UserJobsBinding().dependencies();
        break;
      case 2:
        UserInternshipsBinding().dependencies();
        break;
      case 3:
        AppliedPositionsBinding().dependencies();
        break;
      case 4:
        ShowProfileBinding().dependencies();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Navigate to default route instead of popping
        Get.offAllNamed('/user_home'); // use Get.offNamed() if you want to keep history
        return false; // prevent the default back action
      },
      child: UserMainScaffold(
        currentIndex: currentPage,
        onTabSelected: (index) {
          setState(() {
            currentPage = index;
            _initBinding(index);
          });
        },
        body: getPage(currentPage),
      ),
    );
  }

  Widget getPage(int index) {
    switch (index) {
      case 0:
        return HomePage();
      case 1:
        return UserJobsPage();
      case 2:
        return UserInternshipsPage();
      case 3:
        return AppliedPositionsPage();
      case 4:
        return ShowProfilePage();
      default:
        return HomePage();
    }
  }
}
