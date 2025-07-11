import 'dart:developer';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:sq_notification/provider/theme_provider.dart';

import '../../provider/home_provider.dart';
import '../../widget/CustomTextFormField.dart';

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
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.storage
    ].request();

    if (statuses[Permission.camera] == PermissionStatus.granted) {
      _getImage(source);
    }
  }

  Widget _buildProfilePicture() {
    return GestureDetector(
      onTap: () {
        profilePiccker();
      },
      child: Container(
        height: 101,
        width: 101,
        decoration: const BoxDecoration(
          color: Color(0XFFF0F0F0),
          shape: BoxShape.circle,
        ),
        child: _image != null
            ? CircleAvatar(backgroundImage: FileImage(_image!))
            : Icon(Icons.add, size: 41),
      ),
    );
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
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from gallery'),
                onTap: () {
                  _checkPermission(context, ImageSource.gallery);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera),
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

  @override
  Widget build(BuildContext context) {
    final homeData = Provider.of<HomeProvider>(context);
    final themeData = Provider.of<ThemeProvider>(context);
    final isDark = themeData.isDarkTheme;

    final instruction = homeData.serviceOptions
        .firstWhereOrNull((e) => e.key == 'instructions');

    final inputTextStyle = TextStyle(
      color: isDark ? Colors.white : Colors.black,
      fontSize: 16,
    );

    final inputHintStyle = TextStyle(
      color: isDark ? Colors.grey[400] : Colors.grey[600],
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("Request new booking"),
      ),
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: isServiceOptionsLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
        margin: const EdgeInsets.all(20),
        child: Form(
          key: formKey,
          child: ListView(
            children: [
              _buildProfilePicture(),
              const SizedBox(height: 10),
              if (instruction != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    instruction.value.trim(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              CustomTextFormField(
                controller: companyNameController,
                hintText: note1Hint ?? "Company name",
                textStyle: inputTextStyle,
                hintStyle: inputHintStyle,
                validator: (val) =>
                val!.isEmpty ? "Please enter company name" : null,
              ),
              const SizedBox(height: 10),
              CustomTextFormField(
                controller: deliveryPersonController,
                hintText: note2Hint ?? "Delivery person name",
                textStyle: inputTextStyle,
                hintStyle: inputHintStyle,
                validator: (val) => val!.isEmpty
                    ? "Please enter delivery person name"
                    : null,
              ),
              const SizedBox(height: 10),
              CustomTextFormField(
                controller: remarksController,
                hintText: note3Hint ?? "Remarks",
                textStyle: inputTextStyle,
                hintStyle: inputHintStyle,
                validator: (val) =>
                val!.isEmpty ? "Please enter remarks" : null,
              ),
              const SizedBox(height: 10),
              homeData.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
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
                child: const Text("Add Booking"),
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
