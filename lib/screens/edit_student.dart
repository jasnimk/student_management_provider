import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:student_management_provider/model/student_model.dart';
import 'package:student_management_provider/provider/student_provider.dart';
import 'package:student_management_provider/widgets/appbar_widget.dart';
import 'package:student_management_provider/widgets/text_field.dart';

class EditStudentScreen extends StatefulWidget {
  final Student student; // Pass student for editing mode
  const EditStudentScreen({Key? key, required this.student}) : super(key: key);

  @override
  State<EditStudentScreen> createState() => _EditStudentScreenState();
}

class _EditStudentScreenState extends State<EditStudentScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _admissionController;
  late TextEditingController _courseController;
  late TextEditingController _contactController;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing data
    _nameController = TextEditingController(text: widget.student.name);
    _admissionController =
        TextEditingController(text: widget.student.admissionNumber);
    _courseController = TextEditingController(text: widget.student.course);
    _contactController = TextEditingController(text: widget.student.contact);

    // Set image in provider
    if (widget.student.imagePath != null) {
      Future.microtask(() {
        Provider.of<StudentProvider>(context, listen: false).imageFile =
            File(widget.student.imagePath!);
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _admissionController.dispose();
    _courseController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  Future<void> _submitForm(
      BuildContext context, StudentProvider provider) async {
    if (_formKey.currentState!.validate()) {
      provider.isLoading1 = true; // Start loading state
      provider.notifyListeners(); // Notify listeners

      try {
        final student = Student(
          id: widget.student.id,
          name: _nameController.text,
          admissionNumber: _admissionController.text,
          course: _courseController.text,
          contact: _contactController.text,
          imagePath: provider.imageFile?.path ?? widget.student.imagePath,
        );

        await provider.updateStudent(student);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Student updated successfully')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      } finally {
        provider.isLoading1 = false; // Reset loading state
        provider.notifyListeners(); // Notify listeners
      }
    }
  }

  void _showImagePickerDialog(BuildContext context) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appbarWidget('Edit Student'),
      body: Consumer<StudentProvider>(builder: (context, provider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GestureDetector(
                  onTap: () => _showImagePickerDialog(context),
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
                              File(widget.student.imagePath!),
                              fit: BoxFit.cover,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
                buildTextFormField(
                    controller: _nameController,
                    labelText: 'Name',
                    emptyValidationMessage: 'Enter name'),
                const SizedBox(height: 16),
                buildTextFormField(
                    controller: _admissionController,
                    labelText: 'Admission Numbeer',
                    emptyValidationMessage: 'Enter admission number'),
                const SizedBox(height: 16),
                buildTextFormField(
                    controller: _courseController,
                    labelText: 'Course',
                    emptyValidationMessage: 'Enter course'),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _contactController,
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
                  onPressed: provider.isLoading
                      ? null
                      : () => _submitForm(context, provider),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  child: provider.isLoading
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
      }),
    );
  }
}
