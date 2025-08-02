import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math';

class IssueController extends GetxController {
  final supabase = Supabase.instance.client;
  final issues = <Map<String, dynamic>>[].obs;
  final isLoading = true.obs;
  final Rx<User?> currentUser = Rx<User?>(null);

  final displayedIssues = <Map<String, dynamic>>[].obs;

  final selectedCategory = Rx<String>('All');
  final selectedStatus = Rx<String>('All');
  final RxDouble selectedDistance = 5.0.obs;
  final distanceController = TextEditingController(text: '5.0');

  final List<String> categories = [
    'All',
    'Road Damage',
    'Garbage',
    'Water Leaks',
    'Power Outage',
    'Public Property',
    'Other'
  ];
  final List<String> statuses = ['All', 'Reported', 'In Progress', 'Resolved'];

  final Rx<Position?> userLocation = Rx<Position?>(null);

  @override
  void onInit() {
    super.onInit();
    currentUser.value = supabase.auth.currentUser;
    _initializeLocationAndFetchIssues();

    supabase.auth.onAuthStateChange.listen((data) {
      currentUser.value = data.session?.user;
    });

    distanceController.addListener(() {
      final value = double.tryParse(distanceController.text) ?? 0.0;
      if (selectedDistance.value != value) {
        selectedDistance.value = value;
      }
    });

    everAll([selectedCategory, selectedStatus, selectedDistance, issues], (_) {
      _updateDisplayedIssues();
    });
  }

  Future<void> _initializeLocationAndFetchIssues() async {
    await _getUserLocation();
    await fetchAllIssues(); // Call the now public method
  }

  Future<void> _getUserLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Get.snackbar('Location Error', 'Location services are disabled.',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Get.snackbar('Location Error', 'Location permissions are denied.',
            snackPosition: SnackPosition.BOTTOM);
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      Get.snackbar('Location Error', 'Location permissions are permanently denied.',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    try {
      userLocation.value = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to get user location: $e',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2) / 1000;
  }

  bool _isWithinDistance(Map<String, dynamic> issue) {
    if (userLocation.value == null || selectedDistance.value == 0) return true;

    final issueLat = issue['latitude'] as double?;
    final issueLon = issue['longitude'] as double?;

    if (issueLat == null || issueLon == null) return true;

    final distance = _calculateDistance(
      userLocation.value!.latitude,
      userLocation.value!.longitude,
      issueLat,
      issueLon,
    );

    return distance <= selectedDistance.value;
  }

  void _updateDisplayedIssues() {
    final filteredList = issues.where((issue) {
      final categoryMatch = selectedCategory.value == 'All' || issue['issue_type'] == selectedCategory.value;
      final statusMatch = selectedStatus.value == 'All' || issue['status'] == selectedStatus.value;
      final distanceMatch = _isWithinDistance(issue);
      return categoryMatch && statusMatch && distanceMatch;
    }).toList();

    displayedIssues.assignAll(filteredList);
  }

  // Changed to a public method
  Future<void> fetchAllIssues() async {
    try {
      isLoading.value = true;
      final response = await supabase.from('issues').select().order('created_at', ascending: false);
      issues.assignAll(List<Map<String, dynamic>>.from(response as List));
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch issues: $e',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void dispose() {
    distanceController.dispose();
    super.dispose();
  }
}