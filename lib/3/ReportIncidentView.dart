import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latLng;
import 'package:image_picker/image_picker.dart';
import 'package:thethirdeye/reportController.dart';
import 'package:thethirdeye/success.dart';

class ReportIncidentViewf extends StatelessWidget {
  ReportIncidentViewf({super.key});

  final ReportIncidentController controller = Get.put(ReportIncidentController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() {
        return Container(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: controller.formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Report an Issue',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2D3748),
                                fontFamily: "Rubik",
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _buildAnonymityBanner(),
                        const SizedBox(height: 30),

                        // Issue Type
                        _buildSectionTitle('Type of Issue*'),
                        _buildIssueTypeDropdown(),
                        const SizedBox(height: 20),

                        // Title
                        _buildSectionTitle('Title*'),
                        TextFormField(
                          controller: controller.titleController,
                          decoration: InputDecoration(
                            hintText: 'e.g., Pothole on Main Street',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.teal.withOpacity(0.1),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                          validator: (value) => value!.trim().isEmpty ? 'Title cannot be empty' : null,
                          style: const TextStyle(fontSize: 14, fontFamily: "Rubik"),
                        ),
                        const SizedBox(height: 20),

                        // Location (Map)
                        _buildSectionTitle('Location*'),
                        _buildInteractiveMap(),
                        const SizedBox(height: 20),

                        // Description
                        _buildSectionTitle('Description'),
                        TextFormField(
                          controller: controller.descriptionController,
                          maxLines: 6,
                          minLines: 3,
                          decoration: InputDecoration(
                            hintText: 'Describe the issue in detail...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.teal.withOpacity(0.1),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                          style: const TextStyle(fontSize: 14, fontFamily: "Rubik"),
                        ),
                        const SizedBox(height: 20),

                        // Image Upload Section
                        _buildSectionTitle('Images (up to 10, Optional)'),
                        const SizedBox(height: 8),
                        _buildImageUploader(),
                        const SizedBox(height: 16),
                        _buildSelectedImagesList(),

                        const SizedBox(height: 30),

                        // Anonymous Toggle
                        Obx(() => Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Report Anonymously',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                fontFamily: "Rubik",
                                color: Color(0xFF374151),
                              ),
                            ),
                            Switch(
                              value: controller.isAnonymous.value,
                              onChanged: (value) => controller.isAnonymous.value = value,
                              activeColor: Colors.red, // Themed switch color
                            ),
                          ],
                        )),
                        const SizedBox(height: 20),

                        _buildSubmitButton(),
                        const SizedBox(height: 140),
                      ],
                    ),
                  ),
                ),
                if (controller.isLoading.value) _buildLoadingOverlay(),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontFamily: "Rubik",
          fontWeight: FontWeight.w500,
          color: Color(0xFF374151),
        ),
      ),
    );
  }

  Widget _buildAnonymityBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.teal.shade400, Colors.teal.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.16),
            blurRadius: 8,
            spreadRadius: 3,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.teal.shade200,
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Center(
              child: Icon(
                Icons.shield_outlined,
                color: Colors.teal.shade600,
                size: 30,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Empower your community.',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    fontFamily: "Rubik",
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Help improve your neighborhood by reporting issues like road damage and garbage.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                    height: 1.5,
                    fontFamily: "Rubik",
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIssueTypeDropdown() {
    return Obx(() {
      return DropdownButtonFormField<String>(
        value: controller.issueType.value,
        hint: const Text('Select issue type'),
        onChanged: (newValue) => controller.issueType.value = newValue,
        items: controller.issueTypes.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        validator: (value) => value == null ? 'Please select an issue type' : null,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.teal.withOpacity(0.1),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        style: const TextStyle(fontSize: 14, color: Colors.black, fontFamily: "Rubik"),
        dropdownColor: Colors.white,
        isExpanded: true,
      );
    });
  }

  Widget _buildInteractiveMap() {
    return Obx(() {
      final currentLatLng = controller.selectedLocation.value ??
          latLng.LatLng(20.5937, 78.9629); // Default: India
      return Column(
        children: [
          Container(
            height: 300,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: FlutterMap(
              mapController: controller.mapController,
              options: MapOptions(
                onTap: (_, point) {
                  controller.setSelectedLocation(point);
                },
                initialCenter: currentLatLng,
                initialZoom: 18.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                  userAgentPackageName: 'com.example.app',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      width: 40,
                      height: 40,
                      point: currentLatLng,
                      child: const Icon(Icons.location_on, size: 40, color: Colors.red),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            controller.selectedLocation.value != null
                ? 'Selected Location: Lat: ${controller.selectedLocation.value!.latitude.toStringAsFixed(4)}, Lng: ${controller.selectedLocation.value!.longitude.toStringAsFixed(4)}'
                : 'Tap on the map to select a location',
            style: TextStyle(
              fontSize: 14,
              color: controller.selectedLocation.value != null ? Colors.teal : Colors.red,
              fontFamily: "Rubik",
            ),
          ),
        ],
      );
    });
  }

  Widget _buildImageUploader() {
    return GestureDetector(
      onTap: controller.pickImages, // Updated to a new method
      child: DottedBorder(
        dashPattern: const [6, 4],
        color: Colors.teal.withOpacity(0.6),
        strokeWidth: 1.5,
        radius: const Radius.circular(12),
        borderType: BorderType.RRect,
        child: Container(
          width: double.infinity,
          height: 120,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.teal.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.camera_alt_outlined, size: 40, color: Colors.teal),
              const SizedBox(height: 8),
              Obx(() => Text(
                'Tap to upload up to 10 photos (${controller.selectedImages.length}/10)',
                style: const TextStyle(color: Colors.teal, fontSize: 14, fontFamily: "Rubik"),
              )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedImagesList() {
    return Obx(() {
      if (controller.selectedImages.isEmpty) return const SizedBox.shrink();
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: controller.selectedImages.length,
        itemBuilder: (context, index) {
          final file = controller.selectedImages[index];
          return Stack(
            fit: StackFit.expand,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(file.path),
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 5,
                right: 5,
                child: GestureDetector(
                  onTap: () => controller.removeImage(index),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, color: Colors.white, size: 16),
                  ),
                ),
              ),
            ],
          );
        },
      );
    });
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: controller.submitReport,
        icon: const Icon(Icons.send_outlined),
        label: const Text('SUBMIT ISSUE'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueGrey,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          shadowColor: Colors.teal.withOpacity(0.4),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, fontFamily: "Rubik"),
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.6),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text(
              'Submitting Report...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.2,
                fontWeight: FontWeight.bold,
                fontFamily: "Rubik",
              ),
            ),
          ],
        ),
      ),
    );
  }
}