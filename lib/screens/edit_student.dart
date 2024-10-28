import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:student_management_provider/model/student_model.dart';
import 'package:student_management_provider/provider/student_provider.dart';
import 'package:student_management_provider/widgets/appbar_widget.dart';
import 'package:student_management_provider/widgets/text_field.dart';

class EditStudentScreen extends StatelessWidget {
  final Student student;
  const EditStudentScreen({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: student.name);
    final admissionController =
        TextEditingController(text: student.admissionNumber);
    final courseController = TextEditingController(text: student.course);
    final contactController = TextEditingController(text: student.contact);

    // Set image in provider
    if (student.imagePath != null) {
      Future.microtask(() {
        Provider.of<StudentProvider>(context, listen: false).imageFile =
            File(student.imagePath!);
      });
    }

    Future<void> submitForm(StudentProvider provider) async {
      if (formKey.currentState!.validate()) {
        provider.isLoading1 = true; // Start loading state

        try {
          final updatedStudent = Student(
            id: student.id,
            name: nameController.text,
            admissionNumber: admissionController.text,
            course: courseController.text,
            contact: contactController.text,
            imagePath: provider.imageFile?.path ?? student.imagePath,
          );

          await provider.updateStudent(updatedStudent);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Student updated successfully')),
          );
          Navigator.pop(context);
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        } finally {
          provider.isLoading1 = false; // Reset loading state
        }
      }
    }

    void showImagePickerDialog(BuildContext context) {
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
                    await Provider.of<StudentProvider>(context, listen: false)
                        .pickImage(ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('From Camera'),
                  onTap: () async {
                    Navigator.pop(context);
                    await Provider.of<StudentProvider>(context, listen: false)
                        .pickImage(ImageSource.camera);
                  },
                ),
              ],
            ),
          );
        },
      );
    }

    return Scaffold(
      appBar: appbarWidget('Edit Student'),
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
                    onTap: () => showImagePickerDialog(context),
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
                                fit: BoxFit.cover,
                              ),
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.file(
                                File(student.imagePath!),
                                fit: BoxFit.cover,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  buildTextFormField(
                      controller: nameController,
                      labelText: 'Name',
                      emptyValidationMessage: 'Enter name'),
                  const SizedBox(height: 16),
                  buildTextFormField(
                      controller: admissionController,
                      labelText: 'Admission Number',
                      emptyValidationMessage: 'Enter admission number'),
                  const SizedBox(height: 16),
                  buildTextFormField(
                      controller: courseController,
                      labelText: 'Course',
                      emptyValidationMessage: 'Enter course'),
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
                        provider.isLoading1 ? null : () => submitForm(provider),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    child: provider.isLoading1
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(),
                          )
                        : const Text('Update Student',
                            style: TextStyle(color: Colors.black)),
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
