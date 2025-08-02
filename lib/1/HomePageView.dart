import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:thethirdeye/issues/specifiedIssuePage.dart';
import 'package:thethirdeye/new.dart';
import 'issueController.dart';
import 'package:geolocator/geolocator.dart';

class IssuesPage extends StatelessWidget {
  IssuesPage({super.key});

  final IssueController controller = Get.put(IssueController());

  Widget _buildIssueCard(Map<String, dynamic> issue) {
    String imageUrl = (issue['image_urls'] as List?)?.isNotEmpty == true
        ? issue['image_urls'][0]
        : '';

    Color statusColor = Colors.grey;
    IconData statusIcon = Icons.help_outline;
    switch (issue['status']) {
      case 'Reported':
        statusColor = Colors.red.shade400;
        statusIcon = Icons.announcement;
        break;
      case 'In Progress':
        statusColor = Colors.orange.shade400;
        statusIcon = Icons.hourglass_top;
        break;
      case 'Resolved':
        statusColor = Colors.green.shade400;
        statusIcon = Icons.check_circle_outline;
        break;
    }

    String distanceText = '';
    if (controller.userLocation.value != null && issue['latitude'] != null && issue['longitude'] != null) {
      final userLat = controller.userLocation.value!.latitude;
      final userLon = controller.userLocation.value!.longitude;
      final issueLat = issue['latitude'] as double;
      final issueLon = issue['longitude'] as double;

      final distanceInMeters = Geolocator.distanceBetween(userLat, userLon, issueLat, issueLon);
      final distanceInKm = distanceInMeters / 1000;
      distanceText = '${distanceInKm.toStringAsFixed(1)} km away';
    }

    return GestureDetector(
      onTap: () {
        Get.to(() => IssueDetailView(issue: issue));
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
        elevation: 6.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: imageUrl.isEmpty
                      ? Image.asset(
                    'assets/images/ticket-issue.png',
                    height: 150,
                    fit: BoxFit.fitHeight,
                  )
                      : Image.network(
                    imageUrl,
                    height: 150,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 150,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.broken_image, color: Colors.grey),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          issue['title'] ?? 'No Title',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Rubik',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(statusIcon, size: 16, color: statusColor),
                            const SizedBox(width: 4),
                            Text(
                              issue['status'] ?? 'Unknown',
                              style: TextStyle(
                                fontSize: 12,
                                color: statusColor,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Rubik',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: Text(
                            issue['description'] ?? 'No description available.',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                              fontFamily: 'Rubik',
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (distanceText.isNotEmpty)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    distanceText,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Rubik',
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(height: 18,),
          Row(
            children: [
              Expanded(
                child: Obx(() {
                  return DropdownButtonFormField<String>(
                    value: controller.selectedCategory.value == 'All' ? null : controller.selectedCategory.value,
                    decoration: InputDecoration(
                      hintText: 'Category',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: controller.categories.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      controller.selectedCategory.value = newValue ?? 'All';
                    },
                  );
                }),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Obx(() {
                  return DropdownButtonFormField<String>(
                    value: controller.selectedStatus.value == 'All' ? null : controller.selectedStatus.value,
                    decoration: InputDecoration(
                      hintText: 'Status',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: controller.statuses.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        controller.selectedStatus.value = newValue;
                      }
                    },
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Obx(() {
                  return Slider(
                    value: controller.selectedDistance.value,
                    min: 1,
                    max: 5,
                    divisions: 4,
                    label: '${controller.selectedDistance.value.toStringAsFixed(0)} km',
                    onChanged: (double value) {
                      controller.selectedDistance.value = value;
                    },
                    activeColor: Colors.red.shade600,
                    inactiveColor: Colors.grey.shade300,
                  );
                }),
              ),
              Obx(() {
                return Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    '${controller.selectedDistance.value.toStringAsFixed(0)} km',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                      fontFamily: 'Rubik',
                    ),
                  ),
                );
              }),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(Icons.refresh, color: Colors.red.shade600),
                onPressed: () {
                  controller.isLoading.value = true;
                  controller.fetchAllIssues(); // Now this call is valid
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
         backgroundColor: Colors.blueGrey,
        title: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Padding(
                padding: const EdgeInsets.all(6.0),
                child: Image.asset(
                  'assets/images/logo.png', // Your logo asset path
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(width: 20),
            const Text(
              'Third Eye',
              style: TextStyle(
                fontFamily: 'Rubik',
                 fontWeight: FontWeight.w500,
                color: Colors.white,
                fontSize: 17,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildFilterSection(),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.displayedIssues.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('No issues match your filters.', style: TextStyle(fontFamily: 'Rubik')),
                  ),
                );
              }
              return GridView.builder(
                padding: const EdgeInsets.all(8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 0.75,
                ),
                itemCount: controller.displayedIssues.length,
                itemBuilder: (context, index) {
                  return _buildIssueCard(controller.displayedIssues[index]);
                },
              );
            }),
          ),

          SizedBox(height: 100,)
        ],
      ),
    );
  }
}