import 'dart:convert';
import 'dart:io';

// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info/device_info.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:sq_notification/api/api.dart';
import 'package:sq_notification/view/auth/SignIn.dart';
import 'package:unique_identifier/unique_identifier.dart';

import '../../Model/UserDataModel.dart';
import '../../SharedPrefrence/SharedPrefrence.dart';
import '../../api/configurl.dart';
import '../../notification/notification.dart';
import '../../provider/theme_provider.dart';
import '../../widget/CustomTextFormField.dart';
import '../home/bottom_nav_bar.dart';
import '../home/widget/search_dropdown.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  TextEditingController nameTextEditingController = TextEditingController();

  TextEditingController emailTextEditingController = TextEditingController();

  TextEditingController phoneTextEditingController = TextEditingController();

  TextEditingController passwordTextEditingController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool isPasswordVisible = true;

  String _identifier = '';

  bool isLoading = false;

  String city = "";

  Future<void> initUniqueIdentifierState() async {
    String? identifier;
    try {
      if (Platform.isAndroid) {
        identifier = await UniqueIdentifier.serial;
      } else if (Platform.isIOS) {
        final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
        var data = await deviceInfoPlugin.iosInfo;
        identifier = data.identifierForVendor;
      }
    } on PlatformException {
      identifier = '';
    }

    if (!mounted) return;
    setState(() {
      _identifier = identifier!;
      print("identifiers == $_identifier");
    });
  }

  void submitData(String firebaseUid) async {
    NotificationServices notification = NotificationServices();
    String fcmToken = await notification.getDeviceToken();
    print(" submitData fcmToken ==  $fcmToken");
    var headers = {'Content-Type': 'application/json'};

    var data = {
      //"username": nameTextEditingController.text,
      "username": firebaseUid, // Use username as place holder
      "email": emailTextEditingController.text,
      //"fcm_token": fcmToken
    };

    var dio = Dio();
    dio.options.connectTimeout = const Duration(seconds: 30);

    try {
      var response = await dio.post(
        'https://sq-notification-middleware.onrender.com/setRegistered',
        //'https://sqapp.smartqsys.com/sync/RegisterDevice',
        options: Options(headers: headers),
        data: json.encode(data),
      );

      //print("register $response.data");

      if (response.statusCode == 200) {
        print("set registered response data == ${response.data}");
        //SharedPref.setAuthToken("${response.data["token"]}");
        //SharedPref.setCustomerId("${response.data["customerid"]}");
        //SharedPref.setUserData(UserData.fromJson(response.data["user"]));
        //print("shared auth token ${SharedPref.getAuthToken()}");
        //print("shared user data  ${SharedPref.getUserData().toJson()}");
        //print("shared Customer ID  ${SharedPref.getCustomerId()}");
      } else {
        print(response.statusMessage);
      }
    } catch (e) {
      print('Error occurred: $e');
      // Handle errors accordingly, like showing an error message to the user
    }
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });
      NotificationServices notification = NotificationServices();
      String fcmToken = "";
      fcmToken = await notification.getDeviceToken();

      SharedPref.setFcmToken(fcmToken);

      var data = {
        "deviceId": _identifier,
        "username": nameTextEditingController.text,
        "password": passwordTextEditingController.text,
        "email": emailTextEditingController.text,
        "fcm_token": fcmToken,
        "phoneNo": phoneTextEditingController.text,
        "platForm": Platform.isAndroid ? "android" : "ios",
        "city": city
      };

      final result =
          await DioApi.post(path: "${ConfigUrl.signUpUrl}", data: data);

      if (result.response?.statusCode == 200) {
        print("submit /register response data == ${result.response?.data}");
        SharedPref.setAuthToken("${result.response?.data["token"]}");
        SharedPref.setUserData(
            UserData.fromJson(result.response?.data["user"]));
        print("shared auth token ${SharedPref.getAuthToken()}");
        print("shared user data  ${SharedPref.getUserData().toJson()}");
        print("register customer ID ${SharedPref.getUserData().customerId}");
        await Fluttertoast.showToast(msg: "successfully Registered");
        setState(() {
          isLoading = false;
        });
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (c) => BottomNavBar(),
          ),
          (route) => false,
        );

        // await firebaseAuth
        //     .createUserWithEmailAndPassword(
        //   email: emailTextEditingController.text.trim(),
        //   password: passwordTextEditingController.text.trim(),
        // ).then((auth) async {
        //   currentUser = auth.user;
        //
        //   if (currentUser != null) {
        //     print("Current User is == $currentUser");
        //     Map<String, dynamic> userMap = {
        //       "id": currentUser!.uid,
        //       "name": nameTextEditingController.text.trim(),
        //       "email": emailTextEditingController.text.trim(),
        //       "phone": phoneTextEditingController.text.trim(),
        //       "requestCode": result.response?.statusCode,
        //       "deviceId": _identifier,
        //       "platform": Platform.isAndroid ? "android" : "ios"
        //     };
        //
        //     CollectionReference userRef = firestore.collection("users");
        //     userRef.doc(currentUser!.uid).set(userMap);
        //     submitData(currentUser!.uid);
        //     setState(() {
        //       isLoading = false;
        //     });
        //   }
        //   else {
        //     setState(() {
        //       isLoading = false;
        //     });
        //     print("Current User is Null == $currentUser");
        //   }
        //
        //
        //
        // }).catchError((errorMessage) {
        //   setState(() {
        //     isLoading = false;
        //   });
        //   print("error msg in $errorMessage");
        //   Fluttertoast.showToast(msg: "Error Occured: \n $errorMessage");
        // });
      } //if status 200
      else {
        setState(() {
          isLoading = false;
        });
        result.handleError(context);
      }
    } //Validate data
    else {
      Fluttertoast.showToast(msg: "Not all fields are valid");
    }
  }

  bool showPass = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initUniqueIdentifierState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Provider.of<ThemeProvider>(context, listen: false).getRegionData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: true);
    return MaterialApp(
      home: GestureDetector(
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Scaffold(
          body: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              height: MediaQuery.of(context).size.height - 20,
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      const SizedBox(height: 60.0),
                      const Text(
                        "Sign up",
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Create your account",
                        style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            "Name",
                            style: TextStyle(
                                fontSize: 15, color: Colors.grey[700]),
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        CustomTextFormField(
                          textStyle: TextStyle(color: Colors.black),
                          controller: nameTextEditingController,
                          hintText: "Name",
                          prefix: const Icon(Icons.person),
                          validator: (val) {
                            if (val!.isEmpty) {
                              return "This field cannot be empty";
                            } else {
                              return null;
                            }
                          },
                        ),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            "Email",
                            style: TextStyle(
                                fontSize: 15, color: Colors.grey[700]),
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        CustomTextFormField(
                          textStyle: TextStyle(color: Colors.black),
                          controller: emailTextEditingController,
                          hintText: "Email",
                          prefix: const Icon(Icons.email),
                          validator: (val) {
                            if (isEmailValid(emailTextEditingController.text) ==
                                false) {
                              return "Enter a valid email address";
                            } else {
                              return null;
                            }
                          },
                        ),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            "Phone",
                            style: TextStyle(
                                fontSize: 15, color: Colors.grey[700]),
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        CustomTextFormField(
                          textStyle: TextStyle(color: Colors.black),
                          textInputType: TextInputType.phone,
                          controller: phoneTextEditingController,
                          hintText: "Phone",
                          prefix: const Icon(Icons.phone),
                          validator: (val) {
                            if (val!.isEmpty) {
                              return "This field cannot be empty";
                            } else {
                              return null;
                            }
                          },
                        ),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            "Password",
                            style: TextStyle(
                                fontSize: 15, color: Colors.grey[700]),
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        CustomTextFormField(
                          textStyle: TextStyle(color: Colors.black),
                          controller: passwordTextEditingController,
                          hintText: "Password",
                          suffix: GestureDetector(
                            onTap: () {
                              print(" showPass  $showPass");
                              setState(() {
                                showPass = !showPass;
                              });
                            },
                            child: Icon(
                              showPass
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              // color: !showPass
                              //     ? AppColor.borderColor
                              //     : AppColor.placeholderColor,
                            ),
                          ),
                          prefix: const Icon(Icons.password),
                          obscureText: showPass,
                          validator: (val) {
                            if (val!.isEmpty) {
                              return "This field cannot be empty";
                            } else {
                              return null;
                            }
                          },
                        ),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            "City",
                            style: TextStyle(
                                fontSize: 15, color: Colors.grey[700]),
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Stack(
                          children: [
                            CustomTextFormField(
                              textStyle: TextStyle(color: Colors.black),
                              prefix: const Icon(Icons.location_city),
                              readOnly: true,
                              hintText: city.isEmpty ? "City" : "",
                              onTap: () async {},
                              // title: TestPage(dropDownList: [], hintText: 'Country', changedValue: (val) {  },),
                            ),
                            Positioned(
                              left: 50,
                              top: 0,
                              right: 0,
                              bottom: 0,
                              child: TestPage(
                                dropDownList: themeProvider.cityDropDown,
                                hintText: "",
                                changedValue: (val) {
                                  setState(() {
                                    city = val.name;
                                  });
                                },
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : Container(
                          height: 45,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(
                              color: Colors.purple,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withOpacity(0.5),
                                spreadRadius: 1,
                                blurRadius: 1,
                                offset: const Offset(
                                    0, 1), // changes position of shadow
                              ),
                            ],
                          ),
                          child: TextButton(
                            onPressed: () {
                              _submit();
                              //submitData();
                            },
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Sign up",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.purple,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Text("Already have an account?"),
                      GestureDetector(
                          onTap: () {
                            Navigator.of(context).pushReplacement(
                                MaterialPageRoute(builder: (context) {
                              return const LoginPage();
                            }));
                          },
                          child: const Text(
                            " Login",
                            style: TextStyle(color: Colors.purple),
                          ))
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

bool isEmailValid(String? email) {
  return email == null
      ? false
      : RegExp(
              r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
          .hasMatch(email);
}

String extractDataFromXml(String xmlResponse, String tag) {
  int startIndex = xmlResponse.indexOf('<$tag>') + tag.length + 2;
  int endIndex = xmlResponse.indexOf('</$tag>', startIndex);
  return xmlResponse.substring(startIndex, endIndex);
}


/* void _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });
      NotificationServices notification = NotificationServices();
      String fcmToken = "";
      fcmToken = await notification.getDeviceToken();
      print(" submit fcmToken ==  $fcmToken");
      var dio = Dio();
      var response = await dio.request(
        //'https://sq-notification-middleware.onrender.com/register',
        'https://sqapp.smartqsys.com/sync/RegisterDevice?RequestCode=Register Device&DeviceID=$_identifier&FCMToken=$fcmToken&CustomerEmail=${emailTextEditingController.text}&PhoneNo=${phoneTextEditingController.text}&Platform=${Platform.isAndroid ? "android" : "ios"}',
        options: Options(
          method: 'GET',
        ),
      );

      print("submit response data  ==  ${response.data}");
      String xmlResponse = '''${response.data}''';
      String? resultCode = extractDataFromXml(xmlResponse, 'ResultCode');
      String? ResultMessage = extractDataFromXml(xmlResponse, 'ResultMessage');

      //const resultCode = "Success";

      if (resultCode == "Success") {

        print("resultCode === $resultCode");

        if (resultCode == "Success") {
          await firebaseAuth
              .createUserWithEmailAndPassword(
            email: emailTextEditingController.text.trim(),
            password: passwordTextEditingController.text.trim(),
          )
              .then((auth) async {
            currentUser = auth.user;

            if (currentUser != null) {
              print("Current User is == $currentUser");
                Map<String, dynamic> userMap = {
                "id": currentUser!.uid,
                "name": nameTextEditingController.text.trim(),
                "email": emailTextEditingController.text.trim(),
                "phone": phoneTextEditingController.text.trim(),
                "requestCode": "",
                "deviceId": _identifier,
                "platform": Platform.isAndroid ? "android" : "ios"
              };

              CollectionReference userRef = firestore.collection("users");
              userRef.doc(currentUser!.uid).set(userMap);
              setState(() {
                isLoading = false;
              });
            }
            else {
              print("Current USer is Null == $currentUser");
            }

            await Fluttertoast.showToast(msg: "successfully Registered");

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (c) => const HomePage(),
              ),
            );
          }).catchError((errorMessage) {
            setState(() {
              isLoading = false;
            });
            print("error msg in $errorMessage");
            Fluttertoast.showToast(msg: "Error Occured: \n $errorMessage");
          });
        }
      } else {
        setState(() {
          isLoading = false;
        });
        Dialogs.errorDialog(context, ResultMessage);
        //Dialogs.errorDialog(context, "No uplink");
      }

    } else {
      Fluttertoast.showToast(msg: "Not all fields are valid");
    }
  }

 */
