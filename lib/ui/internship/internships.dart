import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/AuthRepository.dart';
import '../../data/internships_repository.dart'; // Import the new InternshipsRepository
import '../../model/Internship.dart'; // Import the new Internship model
import 'view_models/internships_vm.dart'; // Import the new InternshipsViewModel

class InternshipsPage extends StatefulWidget {
  const InternshipsPage({super.key});

  @override
  State<InternshipsPage> createState() => _InternshipsPageState();
}

class _InternshipsPageState extends State<InternshipsPage> {
  late InternshipsViewModel internshipsViewModel; // Use InternshipsViewModel
  final AuthRepository authRepository = Get.find();

  @override
  void initState() {
    super.initState();
    internshipsViewModel = Get.find<InternshipsViewModel>(); // Get InternshipsViewModel
  }

  Future<void> _confirmLogout() async {
    Get.dialog(
      AlertDialog(
        title: const Text('Logout Confirmation'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () {
              Get.back(); // Close the dialog
            },
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () async {
              Get.back(); // Close the dialog
              await authRepository.logout(); // Perform logout from the database
              Get.offAllNamed('/login'); // Navigate to login screen
            },
            child: const Text('Yes', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Row(
          children: [
            Image.asset(
              'assets/logo.png', // Add your logo image in the assets folder
              height: 40,
            ),
            const SizedBox(width: 70),
            const Center( // Changed to const
              child: Text(
                'Internships', // Changed title
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black87),
            onPressed: _confirmLogout, // Call the confirmation function
          ),
          const SizedBox(width: 10),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Changed route to /add_internship (you'll need to define this route)
          var result = await Get.toNamed('/add_internship');
          if (result == true) {
            Get.snackbar("Success", "Internship added successfully");
          }
        },
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Obx(() {
        // Use internshipsViewModel
        if (internshipsViewModel.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        } else if (internshipsViewModel.internships.isEmpty) { // Access the internships list
          return const Center(
            child: Text('No internships available. Click the + button to add one.'),
          );
        } else {
          return ListView.separated(
            padding: const EdgeInsets.all(10),
            itemCount: internshipsViewModel.internships.length, // Access the internships list
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              Internship internship = internshipsViewModel.internships[index]; // Use Internship model

              return Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: InkWell(
                  onLongPress: () {
                    Get.dialog(
                      AlertDialog(
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextButton.icon(
                              onPressed: () {
                                Get.back();
                                // Changed route to /edit_internship and pass internship object
                                Get.toNamed('/edit_internship', arguments: internship);
                              },
                              icon: const Icon(Icons.edit),
                              label: const Text('Edit'),
                            ),
                            const Divider(),
                            TextButton.icon(
                              onPressed: () {
                                Get.back();
                                internshipsViewModel.deleteInternship(internship); // Use deleteInternship
                              },
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.redAccent,
                              ),
                              label: const Text(
                                'Delete',
                                style: TextStyle(color: Colors.redAccent),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image/Logo
                        internship.image == null // Use internship.image
                            ? const Icon(Icons.business, size: 80, color: Colors.grey) // Default icon if no image
                            : ClipOval(
                          child: Image.network(
                            internship.image!, // Use internship.image!
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.business, size: 80, color: Colors.grey), // Fallback for image loading error
                          ),
                        ),
                        const SizedBox(height: 10), // Added some space for clarity
                        // Internship Title
                        Text(
                          internship.title, // Use internship.title
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Company Name
                        Row(
                          children: [
                            const Icon(
                              Icons.business,
                              color: Colors.grey,
                              size: 16,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              internship.companyName, // Use internship.companyName
                              style: const TextStyle(color: Colors.black54),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Location
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              color: Colors.grey,
                              size: 16,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              internship.location, // Use internship.location
                              style: const TextStyle(color: Colors.black54),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Stipend
                        Row(
                          children: [
                            const Icon(
                              Icons.money, // Changed icon for stipend
                              color: Colors.green,
                              size: 16,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              internship.stipend, // Use internship.stipend
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Duration
                        Row(
                          children: [
                            const Icon(
                              Icons.access_time, // Icon for duration
                              color: Colors.blueGrey,
                              size: 16,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              internship.duration, // Use internship.duration
                              style: const TextStyle(
                                color: Colors.blueGrey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        }
      }),
    );
  }
}

// Ensure this binding is used when navigating to InternshipsPage
class InternshipsBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(AuthRepository());
    Get.put(InternshipsRepository()); // Put InternshipsRepository
    Get.put(InternshipsViewModel()); // Put InternshipsViewModel
  }
}