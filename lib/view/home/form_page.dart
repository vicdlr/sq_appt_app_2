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

  Future _getImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);

    setState(() {
      _image = pickedFile != null ? File(pickedFile.path) : null;
    });
  }

  Future<Map<Permission, PermissionStatus>> _requestPermissions() async {
    print("This is thhhe stuff we are tring to access");
    Map<Permission, PermissionStatus> statuses = {};
    statuses[Permission.camera] = await _requestCameraPermission();
    statuses[Permission.storage] = await _requestStoragePermission();
    return statuses;
  }

  void _checkPermission(BuildContext context,ImageSource source) async {
    // FocusScope.of(context).requestFocus(FocusNode());
    Map<Permission, PermissionStatus> statues = await [
      Permission.camera,
      Permission.storage
    ].request();

    PermissionStatus? statusCamera = statues[Permission.camera];

    log("status camera $statusCamera");

    bool isGranted = statusCamera == PermissionStatus.granted ;
    if (isGranted) {
      _getImage(source);
    }else{

    }

  }







  Widget _buildProfilePicture() {
     return GestureDetector(
       onTap: () {
         profilePiccker();
         // Show a bottom sheet to choose the image source
         // showModalBottomSheet(
         //   context: context,
         //   builder: (BuildContext context) {
         //     return SafeArea(
         //       child: Column(
         //         mainAxisSize: MainAxisSize.min,
         //         children: [
         //           ListTile(
         //             leading: const Icon(Icons.photo_library),
         //             title: const Text('Choose from gallery'),
         //             onTap: () {
         //               Navigator.pop(context);
         //               _getImage(ImageSource.gallery);
         //             },
         //           ),
         //           ListTile(
         //             leading: const Icon(Icons.camera),
         //             title: const Text('Take a picture'),
         //             onTap: () {
         //               Navigator.pop(context);
         //               _getImage(ImageSource.camera);
         //             },
         //           ),
         //         ],
         //       ),
         //     );
         //   },
         // );
       },
       child: Container(
         height: 101,
         width: 101,
         // padding: EdgeInsets.all(30.h),
         decoration: const BoxDecoration(
             color: Color(0XFFF0F0F0), shape: BoxShape.circle),
         child: _image != null
             ? CircleAvatar(
           backgroundImage: FileImage(
             _image!,
             // height: 41.adaptSize,
             // width: 41.adaptSize,
             // fit: BoxFit.contain,
           ),
         )
             : Icon(
           Icons.add,
           size: 41,
         ),
       ),
     );
   }

   void profilePiccker() {
     Map<Permission, PermissionStatus> statuses = {};
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
                 onTap: () async {
                  _checkPermission(context,ImageSource.gallery);
                   Navigator.pop(context);
                   //_checkPermission(context,ImageSource.gallery);//

                 },
               ),
               ListTile(
                 leading: const Icon(Icons.camera),
                 title: const Text('Take a picture'),
                 onTap: () {
                   Navigator.pop(context);
                   _checkPermission(context,ImageSource.camera);
                 },
               ),
             ],
           ),
         );
       },
     );
   }



  Future<PermissionStatus> _requestCameraPermission() async {
    try {
      return await Permission.camera.request();
    } on PlatformException catch (e) {
      print("Failed to request camera permission: ${e.toString()}");
      return PermissionStatus.denied;
    }
  }

  Future<PermissionStatus> _requestStoragePermission() async {
    try {
      return await Permission.storage.request();
    } on PlatformException catch (e) {
      print("Failed to request storage permission: ${e.toString()}");
      return PermissionStatus.denied;
    }
  }


  @override
  Widget build(BuildContext context) {
    final homeData = Provider.of<HomeProvider>(context);
    final themeData = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Request new booking"),
      ),
      backgroundColor:  themeData.isDarkTheme ? Colors.black : Colors.white,
      body: Container(
        margin: const EdgeInsets.all(20),
        child: Form(
        key: formKey,
          child: ListView(
            children: [
              _buildProfilePicture(),
              const SizedBox(height: 20,),
              CustomTextFormField(
                borderDecoration: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: themeData.isDarkTheme ? Colors.white : Colors.black45,
                    width: 1,
                  ),
                ),
                textStyle: Theme.of(context).textTheme.labelLarge,
                hintStyle: Theme.of(context).textTheme.labelSmall,
                controller: companyNameController,
                hintText: "Company name",

                validator: (val) {
                  if (companyNameController.text.isEmpty) {
                    return "Please enter company name";
                  } else {
                    return null;
                  }
                },
              ),
              SizedBox(
                height: 10,
              ),CustomTextFormField(
                borderDecoration: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: themeData.isDarkTheme ? Colors.white : Colors.black45,
                    width: 1,
                  ),
                ),
                textStyle: Theme.of(context).textTheme.labelLarge,
                hintStyle: Theme.of(context).textTheme.labelSmall,
                controller: deliveryPersonController,
                hintText: "Delivery person name",


                validator: (val) {
                  if (companyNameController.text.isEmpty) {
                    return "Please enter delivery person name";
                  } else {
                    return null;
                  }
                },
              ),
              SizedBox(
                height: 10,
              ),CustomTextFormField(
                borderDecoration: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: themeData.isDarkTheme ? Colors.white : Colors.black45,
                    width: 1,
                  ),
                ),
                textStyle: Theme.of(context).textTheme.labelLarge,
                hintStyle: Theme.of(context).textTheme.labelSmall,
                controller: remarksController,
                hintText: "Remarks",

                validator: (val) {
                  if (companyNameController.text.isEmpty) {
                    return "Please enter remarks";
                  } else {
                    return null;
                  }
                },
              ),
              SizedBox(
                height: 10,
              ),
              homeData.isLoading ? const Center(child: CircularProgressIndicator()) :Container(
                height: 45,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: themeData.isDarkTheme ? Colors.white : Colors.black45,
                  ),
                ),
                child:  TextButton(
                  onPressed: () {


                    if(formKey.currentState!.validate()){
                      if(_image == null){
                             Fluttertoast.showToast(msg: "Please select an image");
                            }else{
                        Provider.of<HomeProvider>(context, listen: false)
                            .createBooking(context,
                            file: _image,
                            companyName: companyNameController.text,
                            deliveryPerson:
                            deliveryPersonController.text,
                            remarks: remarksController.text);
                      }
                          }
                  },
                  child:   Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Add Booking",
                        style: TextStyle(
                          fontSize: 16,
                          color: themeData.isDarkTheme ? Colors.white : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
