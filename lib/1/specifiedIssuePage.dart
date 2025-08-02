import 'package:flutter/material.dart';


import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class IssueDetailView extends StatelessWidget {
  final Map<String, dynamic> issue;

  const IssueDetailView({super.key, required this.issue});

  // Helper method to navigate to the full-screen image view
  void _openFullImageView(String imageUrl) {
    if (imageUrl.isNotEmpty) {
      Get.to(() => FullImageView(imageUrl: imageUrl));
    }
  }

  // A generic builder for the horizontal image list
  Widget _buildImageCarousel(List<String> images, String title) {
    if (images.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Rubik'),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 150,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: images.length,
            itemBuilder: (context, index) {
              final imageUrl = images[index];
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: GestureDetector(
                  onTap: () => _openFullImageView(imageUrl),
                  child: Hero(
                    tag: imageUrl, // Use Hero animation for a smooth transition
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        width: 150,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 150,
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.broken_image, color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // Method to launch the map
  // Corrected method to launch the map
  void _launchMap(double? lat, double? lng) async {
    if (lat == null || lng == null) {
      Get.snackbar('Error', 'Location data is unavailable for this issue.',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    final String url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
    final Uri uri = Uri.parse(url);

    if (!await launchUrl(uri)) {
      Get.snackbar('Error', 'Could not open Google Maps.', snackPosition: SnackPosition.BOTTOM);
    }
  }


  // New method to build the timeline widget
  Widget _buildTimeline(Map<String, dynamic> issue) {
    // Get timestamps from the issue data
    final reportedAt = issue['created_at'] != null ? DateTime.parse(issue['created_at']) : null;
    final inProgressAt = issue['in_progress_at'] != null ? DateTime.parse(issue['in_progress_at']) : null;
    final resolvedAt = issue['resolved_at'] != null ? DateTime.parse(issue['resolved_at']) : null;

    final isReported = issue['status'] == 'Reported';
    final isInProgress = issue['status'] == 'In Progress' || issue['status'] == 'Resolved';
    final isResolved = issue['status'] == 'Resolved';

    // Helper function to build a single timeline tile
    Widget _buildTimelineTile({
      required bool isActive,
      required IconData icon,
      required Color color,
      required String title,
      String? subtitle,
    }) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: isActive ? color : Colors.grey.shade300,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 18),
              ),
              if (title != 'Resolved')
                Container(
                  height: 40,
                  width: 2,
                  color: isActive && issue['status'] != 'Reported' ? color : Colors.grey.shade300,
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Rubik',
                    color: isActive ? Colors.black87 : Colors.grey.shade600,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'Rubik',
                      color: isActive ? Colors.black54 : Colors.grey.shade500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        _buildTimelineTile(
          isActive: true,
          icon: Icons.check_circle_outline,
          color: Colors.green,
          title: 'Reported',
          subtitle: reportedAt != null ? 'on ${DateFormat.yMMMd().add_jm().format(reportedAt)}' : null,
        ),
        _buildTimelineTile(
          isActive: isInProgress,
          icon: Icons.access_time,
          color: Colors.orange,
          title: 'In Progress',
          subtitle: inProgressAt != null ? 'on ${DateFormat.yMMMd().add_jm().format(inProgressAt)}' : null,
        ),
        _buildTimelineTile(
          isActive: isResolved,
          icon: Icons.done_all,
          color: Colors.green,
          title: 'Resolved',
          subtitle: resolvedAt != null ? 'on ${DateFormat.yMMMd().add_jm().format(resolvedAt)}' : null,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Color statusColor = Colors.grey;
    switch (issue['status']) {
      case 'Reported':
        statusColor = Colors.red.shade400;
        break;
      case 'In Progress':
        statusColor = Colors.orange.shade400;
        break;
      case 'Resolved':
        statusColor = Colors.green.shade400;
        break;
    }

    final List<String> initialImages =
    List<String>.from(issue['image_urls'] ?? []);
    final List<String> completedImages =
    List<String>.from(issue['completed_image_urls'] ?? []);

    // Calculate days since reported
    final DateTime reportedDate = DateTime.parse(issue['created_at']);
    final int daysAgo = DateTime.now().difference(reportedDate).inDays;
    final String dateText = daysAgo == 0 ? 'Reported Today' : '$daysAgo days ago';

    return Scaffold(
      appBar: AppBar(
        title: Text(issue['title'] ?? 'Issue Details',
            style: const TextStyle(fontFamily: 'Rubik')),
        backgroundColor: Colors.red.shade600,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Title and Status
            Text(
              issue['title'] ?? 'No Title',
              style: const TextStyle(
                  fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'Rubik'),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    issue['status'] ?? 'Unknown',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        fontFamily: 'Rubik'),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  dateText,
                  style: const TextStyle(fontSize: 14, color: Colors.grey, fontFamily: 'Rubik'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Timeline Section
            const Text(
              'Issue Timeline',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Rubik'),
            ),
            const SizedBox(height: 12),
            _buildTimeline(issue),
            const SizedBox(height: 16),

            // Description Section
            const Text(
              'Description',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Rubik'),
            ),
            const SizedBox(height: 8),
            Text(
              issue['description'] ?? 'No description provided.',
              style: const TextStyle(fontSize: 16, fontFamily: 'Rubik'),
            ),
            const SizedBox(height: 16),

            // Reported Images
            _buildImageCarousel(initialImages, 'Reported Images'),

            // Completed Work Images
            _buildImageCarousel(completedImages, 'Completed Work Images'),

            // Location Section
            const Text(
              'Location',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Rubik'),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded( // FIX: Wrap the Text in an Expanded widget
                  child: Text(
                    'Lat: ${issue['latitude']}, Lng: ${issue['longitude']}',
                    style: const TextStyle(fontSize: 16, fontFamily: 'Rubik'),
                  ),
                ),
                const SizedBox(width: 8), // Add a small space between text and button
                ElevatedButton.icon(
                  onPressed: () {
                    _launchMap(issue['latitude'] as double?, issue['longitude'] as double?);
                  },
                  icon: const Icon(Icons.map_outlined),
                  label: const Text('View on Map'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade600,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


class FullImageView extends StatelessWidget {
  final String imageUrl;

  const FullImageView({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Hero(
          tag: imageUrl,
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) =>
            const Center(child: Icon(Icons.broken_image, color: Colors.white, size: 50)),
          ),
        ),
      ),
    );
  }
}