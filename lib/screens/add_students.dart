import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:student_management_provider/model/student_model.dart';
import 'package:student_management_provider/provider/student_provider.dart';
import 'package:student_management_provider/widgets/appbar_widget.dart';
import 'package:student_management_provider/widgets/text_field.dart';

class AddStudentScreen extends StatelessWidget {
  const AddStudentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final TextEditingController nameController = TextEditingController();
    final TextEditingController admissionController = TextEditingController();
    final TextEditingController courseController = TextEditingController();
    final TextEditingController contactController = TextEditingController();

    Future<void> submitForm(StudentProvider provider) async {
      if (formKey.currentState!.validate()) {
        try {
          final student = Student(
            name: nameController.text,
            admissionNumber: admissionController.text,
            course: courseController.text,
            contact: contactController.text,
            imagePath: provider.imageFile?.path,
          );

          await provider.addStudent(student);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Student added successfully')),
            );
            Navigator.pop(context);
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: $e')),
            );
          }
        }
      }
    }

    void showImagePickerDialog(StudentProvider provider) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Select Image'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('From Gallery'),
                  onTap: () async {
                    Navigator.pop(context);
                    await provider.pickImage(ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('From Camera'),
                  onTap: () async {
                    Navigator.pop(context);
                    await provider.pickImage(ImageSource.camera);
                  },
                ),
              ],
            ),
          );
        },
      );
    }

    return Scaffold(
      appBar: appbarWidget('Add a Student'),
      body: Consumer<StudentProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  GestureDetector(
                    onTap: () => showImagePickerDialog(provider),
                    child: Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: provider.imageFile != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.file(
                                provider.imageFile!,
                                fit: BoxFit.fitHeight,
                              ),
                            )
                          : const Center(
                              child: Icon(
                                Icons.add_a_photo,
                                size: 50,
                                color: Colors.grey,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  buildTextFormField(
                    controller: nameController,
                    labelText: 'Name',
                    emptyValidationMessage: 'Enter name',
                  ),
                  const SizedBox(height: 16),
                  buildTextFormField(
                    controller: admissionController,
                    labelText: 'Admission Number',
                    emptyValidationMessage: 'Enter admission number',
                  ),
                  const SizedBox(height: 16),
                  buildTextFormField(
                    controller: courseController,
                    labelText: 'Course',
                    emptyValidationMessage: 'Enter course',
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: contactController,
                    decoration: const InputDecoration(
                      labelText: 'Contact',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter contact number';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed:
                        provider.isLoading ? null : () => submitForm(provider),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    child: provider.isLoading
                        ? const CircularProgressIndicator()
                        : const Text(
                            'Add Student',
                            style: TextStyle(color: Colors.black),
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
