import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:student_management_provider/model/student_model.dart';
import 'package:student_management_provider/provider/student_provider.dart';
import 'package:student_management_provider/widgets/appbar_widget.dart';
import 'package:student_management_provider/widgets/text_field.dart';

class AddStudentScreen extends StatefulWidget {
  const AddStudentScreen({Key? key}) : super(key: key);

  @override
  State<AddStudentScreen> createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends State<AddStudentScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _admissionController;
  late TextEditingController _courseController;
  late TextEditingController _contactController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _admissionController = TextEditingController();
    _courseController = TextEditingController();
    _contactController = TextEditingController();
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
      try {
        final student = Student(
          name: _nameController.text,
          admissionNumber: _admissionController.text,
          course: _courseController.text,
          contact: _contactController.text,
          imagePath: provider.imageFile?.path,
        );

        await provider.addStudent(student);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Student added successfully')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
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
      appBar: appbarWidget('Add a Student'),
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
      }),
    );
  }
}
