import 'dart:io';

import 'package:final_lab/ui/internship/view_models/edit_internship_vm.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/AuthRepository.dart';
import '../../data/internships_repository.dart';
import '../../data/media_repository.dart';
import '../../model/Internship.dart';

class EditInternship extends StatefulWidget {
  const EditInternship({super.key});

  @override
  State<EditInternship> createState() => _EditInternshipState();
}

class _EditInternshipState extends State<EditInternship> {
  TextEditingController titleController = TextEditingController();
  TextEditingController companyNameController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController stipendController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController durationController = TextEditingController();

  late EditInternshipViewModel editInternshipVM;
  late Internship internship;

  @override
  void initState() {
    super.initState();
    editInternshipVM = Get.find<EditInternshipViewModel>();

    internship = Get.arguments;

    if (internship != null) {
      titleController = TextEditingController(text: internship.title);
      companyNameController = TextEditingController(text: internship.companyName);
      locationController = TextEditingController(text: internship.location);
      stipendController = TextEditingController(text: internship.stipend.toString());
      descriptionController = TextEditingController(text: internship.description);
      durationController = TextEditingController(text: internship.duration);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Get.offAllNamed('/internships');
          },
          icon: const Icon(Icons.arrow_back),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: const Text(
                    "Edit Internship",
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Image picker section
              Obx(
                    () => editInternshipVM.image.value == null
                    ? (internship.image != null && internship.image!.isNotEmpty
                    ? Image.network(
                  internship.image!,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.business_center, size: 80, color: Colors.grey),
                )
                    : const Icon(Icons.business_center, size: 80, color: Colors.grey))
                    : Image.file(
                  File(editInternshipVM.image.value!.path), // Display newly picked image
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  editInternshipVM.pickImage();
                },
                child: const Text('Pick New Image'),
              ),

              const SizedBox(height: 15),

              // Internship title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F8F9),
                    border: Border.all(color: const Color(0xFFE8ECF4)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: TextFormField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Enter internship title',
                        hintStyle: TextStyle(color: Color(0xFF8391A1)),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // Company name
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F8F9),
                    border: Border.all(color: const Color(0xFFE8ECF4)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: TextFormField(
                      controller: companyNameController,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Enter company name',
                        hintStyle: TextStyle(color: Color(0xFF8391A1)),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // Location
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F8F9),
                    border: Border.all(color: const Color(0xFFE8ECF4)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: TextFormField(
                      controller: locationController,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Enter location',
                        hintStyle: TextStyle(color: Color(0xFF8391A1)),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // Stipend
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F8F9),
                    border: Border.all(color: const Color(0xFFE8ECF4)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: TextFormField(
                      controller: stipendController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Enter stipend (e.g., 15000)',
                        hintStyle: TextStyle(color: Color(0xFF8391A1)),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // Duration
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F8F9),
                    border: Border.all(color: const Color(0xFFE8ECF4)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: TextFormField(
                      controller: durationController,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Enter duration (e.g., 3 Months, Flexible)',
                        hintStyle: TextStyle(color: Color(0xFF8391A1)),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // Description
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F8F9),
                    border: Border.all(color: const Color(0xFFE8ECF4)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: TextFormField(
                      controller: descriptionController,
                      maxLines: null,
                      expands: true,
                      keyboardType: TextInputType.multiline,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Enter description',
                        hintStyle: TextStyle(color: Color(0xFF8391A1)),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // Update button
              Obx(() {
                return editInternshipVM.isUpdating.value
                    ? const CircularProgressIndicator()
                    : Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: MaterialButton(
                          color: const Color(0xFF1E232C),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          onPressed: () {
                            editInternshipVM.updateInternship(
                              internship,
                              titleController.text,
                              companyNameController.text,
                              locationController.text,
                              stipendController.text,
                              descriptionController.text,
                              durationController.text,
                            );
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(15.0),
                            child: Text(
                              "Update Internship",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class UpdateInternshipBinding extends Bindings { // Renamed binding class
  @override
  void dependencies() {
    Get.put(AuthRepository());
    Get.put(InternshipsRepository());
    Get.put(MediaRepository());
    Get.put(EditInternshipViewModel());
  }
}