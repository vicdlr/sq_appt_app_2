import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:sq_notification/constant/app_colors.dart';

import '../../provider/home_provider.dart';

class FormPage extends StatefulWidget {
  FormPage({super.key});

  @override
  State<FormPage> createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  File? _image;
  TextEditingController companyNameController = TextEditingController();
  TextEditingController deliveryPersonController = TextEditingController();
  TextEditingController remarksController = TextEditingController();

  final formKey = GlobalKey<FormState>();

  String? note1Hint;
  String? note2Hint;
  String? note3Hint;
  bool isServiceOptionsLoading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      final homeProvider = Provider.of<HomeProvider>(context, listen: false);
      await homeProvider.getServiceOptions(context);
      for (var item in homeProvider.serviceOptions) {
        switch (item.key) {
          case 'note1':
            note1Hint = item.value.trim();
            break;
          case 'note2':
            note2Hint = item.value.trim();
            break;
          case 'note3':
            note3Hint = item.value.trim();
            break;
        }
      }
      setState(() {
        isServiceOptionsLoading = false;
      });
    });
  }

  Future _getImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    setState(() {
      _image = pickedFile != null ? File(pickedFile.path) : null;
    });
  }

  void _checkPermission(BuildContext context, ImageSource source) async {
    Map<Permission, PermissionStatus> statuses =
        await [Permission.camera, Permission.storage].request();

    if (statuses[Permission.camera] == PermissionStatus.granted) {
      _getImage(source);
    }
  }

  void profilePiccker() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library, color: kSmartQGreen),
                title: const Text('Choose from gallery'),
                onTap: () {
                  _checkPermission(context, ImageSource.gallery);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: kSmartQGreen),
                title: const Text('Take a picture'),
                onTap: () {
                  Navigator.pop(context);
                  _checkPermission(context, ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Reference mockup (Enhanced Data Capture page.png) shows semantically-typed icons (location
  // pin / clinic / doctor), but note1/note2/note3 are generic, clinic-configured free-text notes
  // -- their meaning varies per service, so a fixed pin/clinic/doctor icon set would mismatch
  // whatever a given clinic actually put in these fields. Using one consistent neutral icon
  // avoids that mismatch while keeping the same visual language.
  Widget _buildNoteField({
    required TextEditingController controller,
    required String label,
    required String errorText,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: kSmartQGreenLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.edit_note, color: kSmartQGreen, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: controller,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: "Type here",
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFE0E0E0)),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: kSmartQGreen, width: 1.5),
                    ),
                  ),
                  validator: (val) =>
                      (val == null || val.isEmpty) ? errorText : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final homeData = Provider.of<HomeProvider>(context);

    final instruction = homeData.serviceOptions
        .firstWhereOrNull((e) => e.key == 'instructions');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: kSmartQGreen),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text("Request new booking",
                style: TextStyle(
                    color: kSmartQGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 18)),
            Text("Provide a few details to complete your booking.",
                style: TextStyle(color: Colors.black54, fontSize: 12)),
          ],
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.verified_user_outlined, color: kSmartQGreen),
          ),
        ],
      ),
      body: isServiceOptionsLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (instruction != null &&
                        instruction.value.trim().isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          instruction.value.trim(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    GestureDetector(
                      onTap: profilePiccker,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 28),
                        decoration: BoxDecoration(
                          color: kSmartQGreenLight.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: kSmartQGreen.withOpacity(0.4),
                            style: BorderStyle.solid,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Stack(
                              children: [
                                Container(
                                  width: 72,
                                  height: 72,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: kSmartQGreenLight,
                                    shape: BoxShape.circle,
                                  ),
                                  child: _image != null
                                      ? ClipOval(
                                          child: Image.file(_image!,
                                              width: 72,
                                              height: 72,
                                              fit: BoxFit.cover))
                                      : const Icon(Icons.camera_alt_outlined,
                                          color: kSmartQGreen, size: 30),
                                ),
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: Container(
                                    width: 22,
                                    height: 22,
                                    alignment: Alignment.center,
                                    decoration: const BoxDecoration(
                                      color: kSmartQGreen,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.add,
                                        color: Colors.white, size: 16),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            const Text("Add your prescription",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 4),
                            Text(
                                "Press + and take a photo of your prescription",
                                style: TextStyle(
                                    color: Colors.grey.shade600, fontSize: 12)),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: kSmartQGreenLight,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(Icons.lock,
                                      color: kSmartQGreen, size: 14),
                                  SizedBox(width: 6),
                                  Text(
                                      "Your image is secure and only used for this booking",
                                      style: TextStyle(
                                          color: kSmartQGreen,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildNoteField(
                      controller: companyNameController,
                      label: note1Hint?.isNotEmpty == true
                          ? note1Hint!
                          : "Company name",
                      errorText: "This field is required",
                    ),
                    _buildNoteField(
                      controller: deliveryPersonController,
                      label: note2Hint?.isNotEmpty == true
                          ? note2Hint!
                          : "Delivery person name",
                      errorText: "This field is required",
                    ),
                    _buildNoteField(
                      controller: remarksController,
                      label: note3Hint?.isNotEmpty == true
                          ? note3Hint!
                          : "Remarks",
                      errorText: "This field is required",
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: kSmartQGreenLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 26,
                            height: 26,
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                              color: kSmartQGreen,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.info_outline,
                                color: Colors.white, size: 16),
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Note",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: kSmartQGreen)),
                                SizedBox(height: 2),
                                Text(
                                  "Your booking request will be sent to the clinic.\n"
                                  "You will receive a confirmation once it is approved.",
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.black87),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    homeData.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : SizedBox(
                            height: 52,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kSmartQGreen,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(26)),
                              ),
                              onPressed: () {
                                if (formKey.currentState!.validate()) {
                                  if (_image == null) {
                                    Fluttertoast.showToast(
                                        msg: "Please select an image");
                                  } else {
                                    Provider.of<HomeProvider>(context,
                                            listen: false)
                                        .createBooking(
                                      context,
                                      file: _image,
                                      companyName: companyNameController.text,
                                      deliveryPerson:
                                          deliveryPersonController.text,
                                      remarks: remarksController.text,
                                    );
                                  }
                                }
                              },
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.event_available, size: 20),
                                  SizedBox(width: 8),
                                  Text("Add Booking",
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.lock, size: 12, color: Colors.grey.shade600),
                        const SizedBox(width: 6),
                        Text("Your information is secure and private.",
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey.shade600)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

extension FirstWhereOrNullExtension<E> on Iterable<E> {
  E? firstWhereOrNull(bool Function(E) test) {
    for (E element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}
