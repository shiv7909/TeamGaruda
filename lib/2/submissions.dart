import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../issues/specifiedIssuePage.dart';

// -----------------------------------------------------------------------------
// MySubmissionsController: Manages state and data fetching for the My Submissions page.
// -----------------------------------------------------------------------------
class MySubmissionsController extends GetxController {
  final supabase = Supabase.instance.client;
  final RxList<Map<String, dynamic>> submissions = RxList<Map<String, dynamic>>([]);
  final isLoading = false.obs;
  final currentUserId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Fetch submissions once the user is authenticated.
    _setupAuthListener();
  }

  // Listens for authentication state changes to get the user ID.
  void _setupAuthListener() {
    // Set up the listener for auth state changes.
    supabase.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      if (event == AuthChangeEvent.signedIn) {
        currentUserId.value = supabase.auth.currentUser?.id ?? '';
        print('User signed in via listener. ID: ${currentUserId.value}');
        fetchMySubmissions();
      }
      if (event == AuthChangeEvent.signedOut) {
        currentUserId.value = '';
        submissions.clear();
        print('User signed out. Submissions cleared.');
      }
    });

    // Also, check the current auth state immediately on init.
    final currentUser = supabase.auth.currentUser;
    if (currentUser != null) {
      currentUserId.value = currentUser.id;
      print('User already signed in on init. ID: ${currentUserId.value}');
      fetchMySubmissions();
    } else {
      print('No user signed in on init.');
    }
  }

  // Fetches issues submitted by the current user from Supabase.
  Future<void> fetchMySubmissions() async {
    if (currentUserId.value.isEmpty) {
      return;
    }

    try {
      isLoading.value = true;
      // The query is updated to select the 'issue_type' text field directly.
      // It also selects the new 'image_urls' and 'completed_image_urls' arrays.
      final List<Map<String, dynamic>> data = await supabase
          .from('issues')
          .select('id, title, description, issue_type, status, latitude, longitude, image_urls, completed_image_urls, created_at')
          .eq('user_id', currentUserId.value)
          .order('created_at', ascending: false);

      submissions.value = data;
    } on PostgrestException catch (e) {
      Get.snackbar('Error', 'Failed to fetch submissions: ${e.message}');
    } finally {
      isLoading.value = false;
    }
  }
}

// -----------------------------------------------------------------------------
// MySubmissionsPage: The UI widget for displaying the list of user submissions.
// -----------------------------------------------------------------------------
class MySubmissionsPage extends StatelessWidget {
  MySubmissionsPage({Key? key}) : super(key: key);

  final MySubmissionsController controller = Get.put(MySubmissionsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Submissions',style: TextStyle(
          fontFamily: 'Rubik',
          color: Colors.white
        ),),
        backgroundColor: Colors.blueGrey,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.submissions.isEmpty) {
          return const Center(child: Text('You have not submitted any issues yet.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: controller.submissions.length,
          itemBuilder: (context, index) {
            final issue = controller.submissions[index];
            final issueType = issue['issue_type'] as String;
            final status = issue['status'] as String;
            final image_urls = (issue['image_urls'] as List<dynamic>?)?.cast<String>() ?? [];
            final completed_image_urls = (issue['completed_image_urls'] as List<dynamic>?)?.cast<String>() ?? [];

            return GestureDetector(
              onTap: () {
                // Navigate to the IssueDetailView page, passing the selected issue data.
                Get.to(() => IssueDetailView(issue: issue));
              },
              child: Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                elevation: 4.0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        issue['title'] as String,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Issue Type: $issueType',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      const SizedBox(height: 16),
                      _buildTimeline(status),
                      const SizedBox(height: 16),
                      if (image_urls.isNotEmpty)
                        _buildImageSection(
                            'Submitted Images', image_urls, Colors.blue),
                      if (completed_image_urls.isNotEmpty)
                        _buildImageSection(
                            'Completed Images', completed_image_urls, Colors.green),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }

  // Builds the timeline widget based on the current status.
  Widget _buildTimeline(String currentStatus) {
    final statuses = ['Reported', 'In Progress', 'Resolved'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: statuses.map((status) {
        final isActive = statuses.indexOf(status) <= statuses.indexOf(currentStatus);
        return Expanded(
          child: Column(
            children: [
              Icon(
                isActive ? Icons.check_circle : Icons.radio_button_unchecked,
                color: isActive ? Colors.green : Colors.grey,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                status,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isActive ? Colors.black : Colors.grey,
                ),
              ),
              if (status != statuses.last)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Container(
                    height: 2,
                    color: isActive ? Colors.green : Colors.grey,
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // A new helper method to build the image gallery section.
  Widget _buildImageSection(String title, List<String> imageUrls, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: imageUrls.map((url) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(
                url,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 100,
                    height: 100,
                    color: Colors.grey[200],
                    child: const Icon(Icons.broken_image, color: Colors.grey),
                  );
                },
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
