import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:student_management_provider/controller/database_helper.dart';
import 'package:student_management_provider/model/student_model.dart';

class StudentProvider extends ChangeNotifier {
  List<Student> _students = [];
  bool _isGridView = true;
  File? imageFile;
  bool isLoading1 = false;
  String _searchQuery = '';
  Student? _student1;
  bool _hasStudentData = false;

  bool get hasStudentData => _hasStudentData;

  List<Student> get students => _students;
  bool get isGridView => _isGridView;
  File? get imageFile1 => imageFile;
  bool get isLoading => isLoading1;
  Student get student1 {
    if (_student1 == null) {
      throw Exception('Student data not loaded');
    }
    return _student1!;
  }

  List<Student> get filteredStudents {
    return _students.where((student) {
      return student.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          student.admissionNumber
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());
    }).toList();
  }

  void toggleView() {
    _isGridView = !_isGridView;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> loadStudents() async {
    isLoading1 = true;
    notifyListeners();

    try {
      _students = await getAllStudents();
      isLoading1 = false;
      notifyListeners();
    } catch (e) {
      isLoading1 = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> addStudent(Student student) async {
    isLoading1 = true;
    notifyListeners();

    try {
      String? imagePath;
      if (imageFile != null) {
        final directory = await getApplicationDocumentsDirectory();
        final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
        final savedImage = await imageFile!.copy('${directory.path}/$fileName');
        imagePath = savedImage.path;
      }

      final newStudent = Student(
        name: student.name,
        admissionNumber: student.admissionNumber,
        course: student.course,
        contact: student.contact,
        imagePath: imagePath,
      );

      await insertStudent(newStudent);
      await loadStudents();
    } catch (e) {
      isLoading1 = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateStudent(Student student) async {
    isLoading1 = true;
    notifyListeners();

    try {
      String? imagePath = student.imagePath;
      if (imageFile != null) {
        final directory = await getApplicationDocumentsDirectory();
        final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
        final savedImage = await imageFile!.copy('${directory.path}/$fileName');
        imagePath = savedImage.path;
      }

      final updatedStudent = Student(
        id: student.id,
        name: student.name,
        admissionNumber: student.admissionNumber,
        course: student.course,
        contact: student.contact,
        imagePath: imagePath,
      );

      await updateStudent1(updatedStudent);
      await loadStudents();
    } catch (e) {
      // Handle error (log or show a message)
      print(e);
    } finally {
      isLoading1 = false; // Make sure to set loading to false here
      notifyListeners(); // Notify listeners
    }
  }

  Future<void> deleteStudent(int id) async {
    isLoading1 = true;
    notifyListeners();

    try {
      await deleteStudent1(id);
      await loadStudents();
    } catch (e) {
      isLoading1 = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? pickedFile = await picker.pickImage(source: source);
      if (pickedFile != null) {
        imageFile = File(pickedFile.path);
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }

  void clearImage() {
    imageFile = null;
    notifyListeners();
  }

  // Future<Student> getStudent(int id) async {
  //   isLoading1 = true;
  //   notifyListeners();

  //   try {
  //     _student1 = await getStudent(id);
  //     isLoading1 = false;
  //     return _student1!;
  //   } catch (e) {
  //     isLoading1 = false;
  //     notifyListeners();
  //     rethrow;
  //   }
  // }

  Future getStudent1(int id) async {
    isLoading1 = true;
    notifyListeners();

    try {
      _student1 = await getStudent(id);
      _hasStudentData = true;
      _student1 = student1;
    } catch (e) {
      print('Error loading student: $e');
      _student1 = null;
      _hasStudentData = false;
    }

    isLoading1 = false;
    notifyListeners();
  }
}
