// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:student_management_provider/provider/student_provider.dart';
// import 'package:student_management_provider/screens/edit_student.dart';
// import 'package:student_management_provider/widgets/appbar_widget.dart';
// import 'package:student_management_provider/widgets/widgets.dart';

// class ProfileScreen extends StatelessWidget {
//   final int studentId;

//   const ProfileScreen({super.key, required this.studentId});

//   @override
//   Widget build(BuildContext context) {
//     // Fetch student data when the widget is built
//     final provider = Provider.of<StudentProvider>(context);

//     // Fetch student data if it hasn't been fetched already
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (!provider.hasStudentData && !provider.isLoading) {
//         provider.getStudent1(studentId);
//       }
//     });

//     return Scaffold(
//       appBar: appbarWidget('Student Profile'),
//       body: Consumer<StudentProvider>(builder: (context, provider, child) {
//         if (provider.isLoading) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         if (!provider.hasStudentData) {
//           return const Center(
//             child: Text('Student not found'),
//           );
//         }

//         final student = provider.student1;

//         return SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 if (student.imagePath != null &&
//                     File(student.imagePath!).existsSync())
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.end,
//                     children: [
//                       IconButton(
//                         icon: const Icon(Icons.edit),
//                         onPressed: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) =>
//                                   EditStudentScreen(student: student),
//                             ),
//                           );
//                         },
//                       ),
//                       IconButton(
//                           icon: const Icon(Icons.delete),
//                           onPressed: () {
//                             // Show the delete confirmation dialog
//                             showDeleteDialog(context, student, provider)
//                                 .then((confirmed) {
//                               if (confirmed) {
//                                 // If confirmed, pop the screen to go back
//                                 Navigator.of(context).pop();
//                               }
//                             });
//                           })
//                     ],
//                   ),
//                 Center(
//                   child: Row(
//                     children: [
//                       Container(
//                         height: 200,
//                         width: 200,
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(8),
//                           image: DecorationImage(
//                             image: FileImage(File(student.imagePath!)),
//                             fit: BoxFit.fitHeight,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 24),
//                 Card(
//                   child: Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         _buildInfoRow('Name', student.name),
//                         const SizedBox(height: 12),
//                         _buildInfoRow(
//                             'Admission Number', student.admissionNumber),
//                         const SizedBox(height: 12),
//                         _buildInfoRow('Course', student.course),
//                         const SizedBox(height: 12),
//                         _buildInfoRow('Contact', student.contact),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       }),
//     );
//   }

//   _buildInfoRow(String label, String value) {
//     return SizedBox(
//       width: double.infinity,
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             label,
//             style: const TextStyle(
//               fontSize: 14,
//               color: Colors.grey,
//             ),
//           ),
//           const SizedBox(height: 4),
//           Text(
//             value,
//             style: const TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_management_provider/provider/student_provider.dart';
import 'package:student_management_provider/screens/edit_student.dart';
import 'package:student_management_provider/widgets/appbar_widget.dart';
import 'package:student_management_provider/widgets/widgets.dart';

class ProfileScreen extends StatefulWidget {
  final int studentId;

  const ProfileScreen({super.key, required this.studentId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Reset the student data when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<StudentProvider>(context, listen: false);
      provider.clearStudentData(); // Clear previous student data
      provider.getStudent1(widget.studentId); // Fetch new student data
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appbarWidget('Student Profile'),
      body: Consumer<StudentProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final student = provider.student1;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (student.imagePath != null &&
                      File(student.imagePath!).existsSync())
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        EditStudentScreen(student: student),
                                  ),
                                ).then((_) {
                                  // Refresh data after editing
                                  provider.getStudent1(widget.studentId);
                                });
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                showDeleteDialog(context, student, provider)
                                    .then((confirmed) {
                                  if (confirmed == true) {
                                    Navigator.of(context).pop();
                                  }
                                });
                              },
                            ),
                          ],
                        ),
                        Center(
                          child: Container(
                            height: 200,
                            width: 200,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              image: DecorationImage(
                                image: FileImage(File(student.imagePath!)),
                                fit: BoxFit.fitHeight,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 24),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoRow('Name', student.name),
                          const SizedBox(height: 12),
                          _buildInfoRow(
                              'Admission Number', student.admissionNumber),
                          const SizedBox(height: 12),
                          _buildInfoRow('Course', student.course),
                          const SizedBox(height: 12),
                          _buildInfoRow('Contact', student.contact),
                        ],
                      ),
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

  Widget _buildInfoRow(String label, String value) {
    return SizedBox(
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
