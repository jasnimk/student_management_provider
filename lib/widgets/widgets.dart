import 'dart:io';

import 'package:flutter/material.dart';
import 'package:student_management_provider/model/student_model.dart';
import 'package:student_management_provider/provider/student_provider.dart';
import 'package:student_management_provider/screens/edit_student.dart';
import 'package:student_management_provider/screens/profile_screen.dart';

buildStudentCard(
    BuildContext context, Student student, StudentProvider provider) {
  return GestureDetector(
    onTap: () {
      Navigator.of(context).push(MaterialPageRoute(builder: (ctx) {
        if (student.id == null) {
          return const Center(child: Text('No student ID found.'));
        }

        return ProfileScreen(studentId: student.id!);
      }));
    },
    child: Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (student.imagePath != null)
            Expanded(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(8.0)),
                child: Image.file(
                  File(student.imagePath!),
                  width: double.infinity,
                  fit: BoxFit.fitHeight,
                ),
              ),
            )
          else
            Expanded(
              child: Container(
                color: Colors.grey[300],
                child: const Icon(Icons.person, size: 50),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(student.admissionNumber),
                Text(student.course),
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
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        showDeleteDialog(context, student, provider);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

buildStudentListTile(
    BuildContext context, Student student, StudentProvider provider) {
  return GestureDetector(
    onTap: () {
      Navigator.of(context).push(MaterialPageRoute(builder: (ctx) {
        if (student.id == null) {
          // Handle null case, maybe show a message or prevent navigation.
          return const Center(child: Text('No student ID found.'));
        }

        return ProfileScreen(studentId: student.id!);
      }));
    },
    child: ListTile(
      leading: student.imagePath != null
          ? ClipOval(
              child: Image.file(
                File(student.imagePath!),
                fit: BoxFit.fitHeight,
                width: 56.0,
                height: 56.0,
              ),
            )
          : const CircleAvatar(child: Icon(Icons.person)),
      title: Text(student.name),
      subtitle: Text('${student.admissionNumber} - ${student.course}'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditStudentScreen(student: student),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              showDeleteDialog(context, student, provider);
            },
          ),
        ],
      ),
    ),
  );
}

Future<bool> showDeleteDialog(
    BuildContext context, Student student, StudentProvider provider) {
  return showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Delete Student'),
        content: const Text('Are you sure you want to delete this student?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false); // Return false for cancel
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              provider.deleteStudent(student.id!); // Perform delete action
              Navigator.of(context).pop(true); // Return true for confirmation
            },
            child: const Text('Delete'),
          ),
        ],
      );
    },
  ).then((value) => value ?? false); // Ensure a default return value of false
}
