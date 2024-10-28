import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_management_provider/provider/student_provider.dart';
import 'package:student_management_provider/screens/add_students.dart';
import 'package:student_management_provider/widgets/widgets.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<StudentProvider>(context, listen: false).loadStudents();
    });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[100],
        title: const Text('Student Management'),
        actions: [
          Consumer<StudentProvider>(builder: (context, provider, child) {
            return IconButton(
              icon: Icon(
                provider.isGridView ? Icons.list : Icons.grid_view,
              ),
              onPressed: provider.toggleView,
            );
          }),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) =>
                  Provider.of<StudentProvider>(context, listen: false)
                      .setSearchQuery(value),
              decoration: const InputDecoration(
                labelText: 'Search Students',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: Consumer<StudentProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final students = provider.filteredStudents;

                if (students.isEmpty) {
                  return const Center(
                    child: Text('No students found'),
                  );
                }

                return provider.isGridView
                    ? GridView.builder(
                        padding: const EdgeInsets.all(8),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemCount: students.length,
                        itemBuilder: (context, index) {
                          final student = students[index];
                          return buildStudentCard(context, student, provider);
                        },
                      )
                    : ListView.builder(
                        itemCount: students.length,
                        itemBuilder: (context, index) {
                          final student = students[index];
                          return buildStudentListTile(
                              context, student, provider);
                        },
                      );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Provider.of<StudentProvider>(context, listen: false).clearImage();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddStudentScreen()),
          ).then((_) {
            // Reload students when returning from AddStudentScreen
            Provider.of<StudentProvider>(context, listen: false).loadStudents();
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
