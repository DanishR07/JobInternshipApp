import 'package:final_lab/services/notification_service.dart';
import 'package:final_lab/ui/admin_home/admin_home.dart';
import 'package:final_lab/ui/admin_home/applications/applications.dart';
import 'package:final_lab/ui/admin_home/applications/applications_detail.dart';
import 'package:final_lab/ui/applied_positions/applied_positions_page.dart';
import 'package:final_lab/ui/auth/forgot_password.dart';
import 'package:final_lab/ui/auth/link_send.dart';
import 'package:final_lab/ui/auth/login.dart';
import 'package:final_lab/ui/auth/signup.dart';
import 'package:final_lab/ui/auth/view_models/auth_decider_screen.dart';
import 'package:final_lab/ui/auth/welcome_screen.dart';
import 'package:final_lab/ui/internship/add_internship.dart';
import 'package:final_lab/ui/internship/edit_internship.dart';
import 'package:final_lab/ui/internship/internships.dart';
import 'package:final_lab/ui/job/add_job.dart';
import 'package:final_lab/ui/job/edit_job.dart';
import 'package:final_lab/ui/job/jobs.dart';
import 'package:final_lab/ui/notifications/notifications_page.dart';
import 'package:final_lab/ui/profile/create_update_profile.dart';
import 'package:final_lab/ui/profile/profile.dart';
import 'package:final_lab/ui/splash_screen/splash_screen.dart';
import 'package:final_lab/ui/user_home/custom_drawer.dart';
import 'package:final_lab/ui/user_home/home.dart';
import 'package:final_lab/ui/user_home/internships/internship_details_page.dart';
import 'package:final_lab/ui/user_home/internships/user_internships.dart';
import 'package:final_lab/ui/user_home/jobs/job_details_page.dart';
import 'package:final_lab/ui/user_home/user_home.dart';
import 'package:final_lab/ui/user_home/jobs/user_jobs.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'data/AuthRepository.dart';
import 'data/notification_repository.dart';
import 'firebase_options.dart';
import 'package:get/get.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  Get.put(AuthRepository());
  Get.put(NotificationRepository());
  Get.put(NotificationService());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      getPages: [
        GetPage(name: '/splash', page: () => SplashScreen()),
        GetPage(name: '/welcome', page: () => WelcomeScreen(), bindings: [LoginBinding(), SignUpBinding()]),
        GetPage(name: '/login', page: () => LoginScreen(), bindings: [LoginBinding(), SignUpBinding()]),
        GetPage(name: '/signup', page: () => RegisterScreen(), bindings: [SignUpBinding(), LoginBinding()]),
        GetPage(name: '/forget_password', page: () => ForgotPasswordScreen(), binding: ResetPasswordBinding()),
        GetPage(name: '/link_send', page: () => LinkSendScreen()),
        GetPage(name: '/user_home', page: () => UserHomePage(), binding: UserJobsBinding()),
        GetPage(name: '/admin', page: () => AdminHomePage()),
        GetPage(name: '/jobs', page: () => JobsPage(), binding: JobsBinding()),
        GetPage(name: '/internships', page: () => InternshipsPage(), binding: InternshipsBinding()),
        GetPage(name: '/add_job', page: () => AddJob(), binding: AddJobBinding()),
        GetPage(name: '/add_internship', page: () => AddInternship(), binding: AddInternshipBinding()),
        GetPage(name: '/edit_job', page: () => EditJob(), binding: UpdateJobBinding()),
        GetPage(name: '/edit_internship', page: () => EditInternship(), binding: UpdateInternshipBinding()),
        GetPage(name: '/job_details', page: () => JobDetailsPage(), binding: JobDetailsBinding()),
        GetPage(name: '/internship_details', page: () => InternshipDetailsPage(), binding: InternshipDetailsBinding()),
        GetPage(name: '/applied_positions', page: () => AppliedPositionsPage(), binding: AppliedPositionsBinding()),
        GetPage(name: '/profile', page: () => ShowProfilePage(), binding: ShowProfileBinding()),
        GetPage(name: '/create_edit_profile', page: () => SaveProfilePage(), binding: SaveProfileBinding()),
        GetPage(name: '/user_jobs', page: () => UserJobsPage(), binding: UserJobsBinding()),
        GetPage(name: '/user_internships', page: () => UserInternshipsPage(), binding: UserInternshipsBinding()),
        GetPage(name: '/applications', page: () => ApplicationsPage(), binding: ApplicationsPageBinding()),
        GetPage(name: '/application_details', page: () => ApplicationDetailPage(), binding: ApplicationDetailBinding()),
        GetPage(name: '/home', page: () => HomePage(), binding: HomeBinding()),
        GetPage(name: '/auth_decider', page: () => AuthDeciderScreen()),
        GetPage(name: '/custom_drawer', page: () => CustomDrawer()),
        GetPage(name: '/notifications', page: () => NotificationsPage(), binding: NotificationsBinding()),
      ],
      initialRoute: '/splash',
    );
  }
}