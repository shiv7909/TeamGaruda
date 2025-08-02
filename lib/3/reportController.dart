import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latLng;
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:thethirdeye/success.dart';

import '../home.dart';

class ReportIncidentController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final supabase = Supabase.instance.client;
  final mapController = MapController();
  final picker = ImagePicker();

  final issueType = Rx<String?>(null);
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final selectedImages = RxList<XFile>([]); // Updated to a list
  final isLoading = false.obs;

  final isAnonymous = false.obs;

  final Rx<Position?> currentPosition = Rx<Position?>(null);
  final Rx<latLng.LatLng?> selectedLocation = Rx<latLng.LatLng?>(null);

  final List<String> issueTypes = [
    'Road Damage',
    'Lighting',
    'Water Supply and leaks',
    'Power Outage',
    'Public Safety',
    'Obstructions',
    'Waste Management',
    'Other',
  ];

  @override
  void onInit() {
    super.onInit();
    _getCurrentLocation();
  }

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    super.onClose();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Get.snackbar('Location Disabled', 'Please enable location services.',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Get.snackbar('Permission Denied', 'Location permissions are required.',
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      Get.snackbar('Permission Denied', 'Location permissions are permanently denied, please enable from settings.',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
      return;
    }

    currentPosition.value = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    setSelectedLocation(
        latLng.LatLng(currentPosition.value!.latitude, currentPosition.value!.longitude));
  }

  void setSelectedLocation(latLng.LatLng latLng) {
    selectedLocation.value = latLng;
    mapController.move(latLng, mapController.camera.zoom);
  }

  // Updated to pick multiple images
  Future<void> pickImages() async {
    final List<XFile>? images = await picker.pickMultiImage();
    if (images != null) {
      // Add new images, but don't exceed the limit
      final currentCount = selectedImages.length;
      final remainingSlots = 10 - currentCount;
      if (remainingSlots > 0) {
        selectedImages.addAll(images.take(remainingSlots));
      } else {
        Get.showSnackbar(const GetSnackBar(
          title: "Upload Limit",
          message: "You can only upload up to 10 images.",
          duration: Duration(seconds: 3),
          backgroundColor: Colors.orange,
        ));
      }
    }
  }

  void removeImage(int index) {
    selectedImages.removeAt(index);
  }

  // Updated to upload multiple images
  Future<List<String>?> _uploadImages() async {
    if (selectedImages.isEmpty) return null;

    try {
      final List<String> imageUrls = [];
      for (var image in selectedImages) {
        final file = File(image.path);
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_${image.name}';
        final filePath = fileName;

        await supabase.storage.from('issues').upload(
          filePath,
          file,
          fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
        );

        final url = supabase.storage.from('issues').getPublicUrl(filePath);
        imageUrls.add(url);
      }
      return imageUrls;
    } catch (e) {
      Get.showSnackbar(GetSnackBar(
        title: "Image Upload Failed",
        message: e.toString(),
        duration: const Duration(seconds: 5),
        backgroundColor: Colors.red,
      ));
      return null;
    }
  }

  Future<void> submitReport() async {
    if (!formKey.currentState!.validate()) {
      Get.showSnackbar(const GetSnackBar(
        title: "Missing Information",
        message: "Please fill all required fields.",
        duration: Duration(seconds: 3),
        backgroundColor: Colors.orange,
      ));
      return;
    }

    if (selectedLocation.value == null) {
      Get.showSnackbar(const GetSnackBar(
        title: "Missing Location",
        message: "Please select a location on the map.",
        duration: Duration(seconds: 3),
        backgroundColor: Colors.orange,
      ));
      return;
    }

    isLoading.value = true;

    try {
      final userId = isAnonymous.value ? null : supabase.auth.currentUser?.id;

      if (!isAnonymous.value && userId == null) {
        isLoading.value = false;
        Get.defaultDialog(
          title: "Login Required",
          content: const Text("You must be logged in to submit a non-anonymous report."),
          confirm: ElevatedButton(onPressed: () => Get.back(), child: const Text("OK")),
        );
        return;
      }

      final imageUrls = await _uploadImages();

      // Insert data into the 'issues' table
      await supabase.from('issues').insert({
        'user_id': userId, // This will be null if isAnonymous is true
        'title': titleController.text.trim(),
        'description': descriptionController.text.trim(),
        'issue_type': issueType.value!,
        'status': 'Reported', // Default status for new issues
        'latitude': selectedLocation.value!.latitude,
        'longitude': selectedLocation.value!.longitude,
        'image_urls': imageUrls, // Updated to handle a list of URLs
      });

      _clearForm();
      Get.off(() => const SuccessView());
    } catch (e) {
      Get.showSnackbar(GetSnackBar(
        title: "Submission Failed",
        message: e.toString(),
        duration: const Duration(seconds: 5),
        backgroundColor: Colors.red,
      ));
    } finally {
      isLoading.value = false;
    }
  }

  void _clearForm() {
    formKey.currentState?.reset();
    issueType.value = null;
    titleController.clear();
    descriptionController.clear();
    selectedImages.clear();
    // Keep location on map to prevent null issues, but user can re-select
  }
}