// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:student_management_provider/model/student_model.dart';
// import 'package:student_management_provider/provider/student_provider.dart';

// class AddStudentScreen extends StatefulWidget {
//   final Student? student; // Pass student for editing mode
//   const AddStudentScreen({Key? key, this.student}) : super(key: key);

//   @override
//   State<AddStudentScreen> createState() => _AddStudentScreenState();
// }

// class _AddStudentScreenState extends State<AddStudentScreen> {
//   final _formKey = GlobalKey<FormState>();
//   late TextEditingController _nameController;
//   late TextEditingController _admissionController;
//   late TextEditingController _courseController;
//   late TextEditingController _contactController;

//   @override
//   void initState() {
//     super.initState();
//     // Initialize controllers with existing data if editing
//     _nameController = TextEditingController(text: widget.student?.name ?? '');
//     _admissionController =
//         TextEditingController(text: widget.student?.admissionNumber ?? '');
//     _courseController =
//         TextEditingController(text: widget.student?.course ?? '');
//     _contactController =
//         TextEditingController(text: widget.student?.contact ?? '');

//     // If editing, set the image in provider
//     if (widget.student?.imagePath != null) {
//       Future.microtask(() {
//         Provider.of<StudentProvider>(context, listen: false).imageFile =
//             File(widget.student!.imagePath!);
//       });
//     }
//   }

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _admissionController.dispose();
//     _courseController.dispose();
//     _contactController.dispose();
//     super.dispose();
//   }

//   Future<void> _submitForm(
//       BuildContext context, StudentProvider provider) async {
//     if (_formKey.currentState!.validate()) {
//       try {
//         final student = Student(
//           id: widget.student?.id,
//           name: _nameController.text,
//           admissionNumber: _admissionController.text,
//           course: _courseController.text,
//           contact: _contactController.text,
//           imagePath: provider.imageFile?.path ?? widget.student?.imagePath,
//         );

//         if (widget.student == null) {
//           await provider.addStudent(student);
//         } else {
//           await provider.updateStudent(student);
//         }

//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text(
//                 widget.student == null
//                     ? 'Student added successfully'
//                     : 'Student updated successfully',
//               ),
//             ),
//           );
//           Navigator.pop(context);
//         }
//       } catch (e) {
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Error: $e')),
//           );
//         }
//       }
//     }
//   }

//   void _showImagePickerDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Select Image'),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               ListTile(
//                 leading: const Icon(Icons.photo_library),
//                 title: const Text('From Gallery'),
//                 onTap: () async {
//                   Navigator.pop(context);
//                   await Provider.of<StudentProvider>(context, listen: false)
//                       .pickImage(ImageSource.gallery);
//                 },
//               ),
//               ListTile(
//                 leading: const Icon(Icons.camera_alt),
//                 title: const Text('From Camera'),
//                 onTap: () async {
//                   Navigator.pop(context);
//                   await Provider.of<StudentProvider>(context, listen: false)
//                       .pickImage(ImageSource.camera);
//                 },
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.student == null ? 'Add Student' : 'Edit Student'),
//       ),
//       body: Consumer<StudentProvider>(
//         builder: (context, provider, child) {
//           return SingleChildScrollView(
//             padding: const EdgeInsets.all(16.0),
//             child: Form(
//               key: _formKey,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: [
//                   GestureDetector(
//                     onTap: () => _showImagePickerDialog(context),
//                     child: Container(
//                       height: 200,
//                       decoration: BoxDecoration(
//                         color: Colors.grey[200],
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       child: provider.imageFile != null
//                           ? ClipRRect(
//                               borderRadius: BorderRadius.circular(10),
//                               child: Image.file(
//                                 provider.imageFile!,
//                                 fit: BoxFit.cover,
//                               ),
//                             )
//                           : widget.student?.imagePath != null
//                               ? ClipRRect(
//                                   borderRadius: BorderRadius.circular(10),
//                                   child: Image.file(
//                                     File(widget.student!.imagePath!),
//                                     fit: BoxFit.cover,
//                                   ),
//                                 )
//                               : const Center(
//                                   child: Icon(
//                                     Icons.add_a_photo,
//                                     size: 50,
//                                     color: Colors.grey,
//                                   ),
//                                 ),
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                   TextFormField(
//                     controller: _nameController,
//                     decoration: const InputDecoration(
//                       labelText: 'Name',
//                       border: OutlineInputBorder(),
//                     ),
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Please enter student name';
//                       }
//                       return null;
//                     },
//                   ),
//                   const SizedBox(height: 16),
//                   TextFormField(
//                     controller: _admissionController,
//                     decoration: const InputDecoration(
//                       labelText: 'Admission Number',
//                       border: OutlineInputBorder(),
//                     ),
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Please enter admission number';
//                       }
//                       return null;
//                     },
//                   ),
//                   const SizedBox(height: 16),
//                   TextFormField(
//                     controller: _courseController,
//                     decoration: const InputDecoration(
//                       labelText: 'Course',
//                       border: OutlineInputBorder(),
//                     ),
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Please enter course';
//                       }
//                       return null;
//                     },
//                   ),
//                   const SizedBox(height: 16),
//                   TextFormField(
//                     controller: _contactController,
//                     decoration: const InputDecoration(
//                       labelText: 'Contact',
//                       border: OutlineInputBorder(),
//                     ),
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Please enter contact number';
//                       }
//                       return null;
//                     },
//                     keyboardType: TextInputType.phone,
//                   ),
//                   const SizedBox(height: 24),
//                   ElevatedButton(
//                     onPressed: provider.isLoading
//                         ? null
//                         : () => _submitForm(context, provider),
//                     style: ElevatedButton.styleFrom(
//                       padding: const EdgeInsets.symmetric(vertical: 15),
//                     ),
//                     child: provider.isLoading
//                         ? const CircularProgressIndicator()
//                         : Text(
//                             widget.student == null
//                                 ? 'Add Student'
//                                 : 'Update Student',
//                           ),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }