import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'NoteEdit-screen.dart';
import 'controller.dart';
import 'datetimeSearch.dart';
import 'note-search.dart';

class NoteListScreen extends StatelessWidget {
  final NoteController controller = Get.put(NoteController());
  final searchController = TextEditingController();
  final RxString searchQuery = ''.obs;

  NoteListScreen({super.key});

  String _formatDate(DateTime date) {
    return DateFormat('MMM d, yyyy • h:mm a').format(date);
  }

  @override
  Widget build(BuildContext context) {
    // Responsive breakpoints
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;
    final isMediumScreen = size.width >= 600 && size.width < 1200;
    final isLargeScreen = size.width >= 1200;

    int gridColumns = isSmallScreen ? 1: (isMediumScreen ? 2 : 3);

    return Scaffold(
      backgroundColor: Colors.pink.shade800,
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar Area
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 12 : 24,
                vertical: isSmallScreen ? 8 : 16,
              ),
              decoration: BoxDecoration(
                color: Colors.pink.shade800,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Search bar with date/time pickers
                  DateTimeSearchBar(
                    searchController: searchController,
                    searchQuery: searchQuery,
                    isSmallScreen: isSmallScreen,
                    onClearSearch: () {},
                  ),
                ],
              ),
            ),

            // Notes Grid
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: const Color(0xffedf3ff),
                      strokeWidth: isSmallScreen ? 3 : 4,
                    ),
                  );
                }

                final filteredNotes = NoteSearchService.filterNotes(
                  controller.notes,
                  searchQuery.value,
                );

                if (filteredNotes.isEmpty) {
                  return EmptyNotesView(
                    isSmallScreen: isSmallScreen,
                    searchQuery: searchQuery.value,
                  );
                }

                return Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 8 : 16,
                    vertical: isSmallScreen ? 8 : 16,
                  ),
                  child: MasonryGridView.count(
                    crossAxisCount: gridColumns,
                    mainAxisSpacing: isSmallScreen ? 8 : 16,
                    crossAxisSpacing: isSmallScreen ? 8 : 16,
                    itemCount: filteredNotes.length,
                    itemBuilder: (context, index) {
                      return NoteCard(
                        note: filteredNotes[index],
                        isSmallScreen: isSmallScreen,
                        screenHeight: size.height,
                      ).animate()
                          .fadeIn(duration: Duration(milliseconds: 300))
                          .slideY(begin: 0.1, end: 0);
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
      floatingActionButton: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
        child: FloatingActionButton(
          shape: const CircleBorder(),
          heroTag: 'fab1',
          backgroundColor: const Color(0xffedf3ff),
          onPressed: () => Get.to(() => NoteEditScreen()),
          child: Icon(
            Icons.add,
            color: Colors.pink.shade800,
            size: isSmallScreen ? 28 : 32,
            weight: 900,
          ),
        ),
      ),
    );
  }
}

// Separate widget for empty state
class EmptyNotesView extends StatelessWidget {
  final bool isSmallScreen;
  final String searchQuery;

  const EmptyNotesView({
    super.key,
    required this.isSmallScreen,
    required this.searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 24 : 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: isSmallScreen ? 48 : 64,
              color: const Color(0xffedf3ff).withOpacity(0.7),
            ),
            SizedBox(height: isSmallScreen ? 16 : 24),
            Text(
              'No notes found',
              style: TextStyle(
                color: const Color(0xffedf3ff),
                fontSize: isSmallScreen ? 20 : 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (searchQuery.isNotEmpty) ...[
              SizedBox(height: isSmallScreen ? 8 : 12),
              Text(
                'Try using different search terms\nor date formats like:',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0xffedf3ff).withOpacity(0.7),
                  fontSize: isSmallScreen ? 14 : 16,
                ),
              ),
              SizedBox(height: isSmallScreen ? 8 : 12),
              Text(
                '"today", "last week",\n"Mar 15", "2024-03-15"',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0xffedf3ff).withOpacity(0.5),
                  fontSize: isSmallScreen ? 12 : 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Separate widget for note cards
class NoteCard extends StatelessWidget {
  final dynamic note;
  final bool isSmallScreen;
  final double screenHeight;

  const NoteCard({
    super.key,
    required this.note,
    required this.isSmallScreen,
    required this.screenHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.pink.shade900,
      shadowColor: Colors.black.withOpacity(0.2),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => Get.to(() => NoteEditScreen(note: note)),
        child: Padding(
          padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (note.imagePath != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.file(
                      File(note.imagePath!),
                      fit: BoxFit.cover,
                    ).animate().fadeIn().scale(),
                  ),
                ),
              if (note.drawingPath != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Image.file(
                        File(note.drawingPath!),
                        fit: BoxFit.cover,
                      ).animate().fadeIn().scale(),
                    ),
                  ),
                ),
              SizedBox(height: isSmallScreen ? 12 : 16),
              Text(
                note.title,
                style: TextStyle(
                  fontSize: isSmallScreen ? 18 : 22,
                  color: const Color(0xffedf3ff),
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: isSmallScreen ? 4 : 8),
              Text(
                note.description,
                style: TextStyle(
                  color: const Color(0xffedf3ff).withOpacity(0.7),
                  fontSize: isSmallScreen ? 14 : 16,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: isSmallScreen ? 8 : 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('MMM d, yyyy').format(note.createdAt),
                    style: TextStyle(
                      color: const Color(0xffedf3ff).withOpacity(0.5),
                      fontSize: isSmallScreen ? 12 : 14,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.edit,
                          color: const Color(0xffedf3ff),
                          size: isSmallScreen ? 20 : 24,
                        ),
                        onPressed: () => Get.to(() => NoteEditScreen(note: note)),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.delete,
                          color: const Color(0xffedf3ff),
                          size: isSmallScreen ? 20 : 24,
                        ),
                        onPressed: () => Get.find<NoteController>().deleteNote(note.id!),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}