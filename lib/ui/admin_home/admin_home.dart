import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../internship/internships.dart';
import '../job/jobs.dart';
import 'applications/applications.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  int currentPage = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.work_outline),
            label: 'Jobs',
            activeIcon: Icon(Icons.work),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school_outlined),
            label: 'Internships',
            activeIcon: Icon(Icons.school),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            label: 'Applications',
            activeIcon: Icon(Icons.assignment),
          ),
        ],
        onTap: (value) {
          setState(() {
            currentPage = value;
          });
        },
        currentIndex: currentPage,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
      ),
      body: getPage(currentPage),
    );
  }

  Widget getPage(int currentPage) {
    if (currentPage == 0) {
      JobsBinding().dependencies();
      return JobsPage();
    } else if(currentPage == 1) {
      InternshipsBinding().dependencies();
      return InternshipsPage();
    }
    else
      ApplicationsPageBinding().dependencies();
      return ApplicationsPage();
  }
}
