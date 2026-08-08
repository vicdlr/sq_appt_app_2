import 'dart:io';

// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:sq_notification/api/api.dart';
import 'package:sq_notification/view/auth/SignIn.dart';
import 'package:unique_identifier/unique_identifier.dart';

import '../../SharedPrefrence/SharedPrefrence.dart';
import '../../api/configurl.dart';
import '../../notification/notification.dart';
import '../../provider/theme_provider.dart';
import '../../widget/CustomTextFormField.dart';
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
  TextEditingController confirmPasswordTextEditingController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

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
    });
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
        "email": emailTextEditingController.text.toLowerCase(),
        "fcm_token": fcmToken,
        "phoneNo": phoneTextEditingController.text,
        "platForm": Platform.isAndroid ? "android" : "ios",
        "city": city
      };

      final result = await DioApi.post(path: ConfigUrl.signUpUrl, data: data);

      if (result.response?.statusCode == 200) {
        SharedPref.setAuthToken("${result.response?.data["token"]}");
        await Fluttertoast.showToast(msg: "successfully Registered");
        setState(() {
          isLoading = false;
        });

        if (!mounted) return;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Registration Successful"),
              content: const Text("Please check your email for the activation link."),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    nameTextEditingController.clear();
                    emailTextEditingController.clear();
                    phoneTextEditingController.clear();
                    passwordTextEditingController.clear();
                    confirmPasswordTextEditingController.clear();
                  },
                  child: const Text("OK"),
                ),
              ],
            );
          },
        );
      } else {
        setState(() {
          isLoading = false;
        });
        result.handleError(context);
      }
    } else {
      Fluttertoast.showToast(msg: "Not all fields are valid");
    }
  }

  bool showPass = true;
  bool showConfirmPass = true;

  @override
  void initState() {
    super.initState();
    initUniqueIdentifierState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Provider.of<ThemeProvider>(context, listen: false).getRegionData();
    });
  }

  InputBorder _fieldBorder() => OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      );

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: true);

    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: kSmartQGreen),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const Spacer(),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(color: kSmartQGreen, shape: BoxShape.circle),
                      alignment: Alignment.center,
                      child: const Text("S",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 6),
                    const Text("SmartQ",
                        style: TextStyle(color: kSmartQGreen, fontWeight: FontWeight.bold, fontSize: 18)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  "Create your account",
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(color: kSmartQGreen, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  "Join SmartQ and enjoy a faster, smarter way to manage your queue.",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 20),
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text("Full Name", style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      CustomTextFormField(
                        textStyle: const TextStyle(color: Colors.black),
                        controller: nameTextEditingController,
                        hintText: "Enter your full name",
                        prefix: const Icon(Icons.person_outline, color: kSmartQGreen),
                        borderDecoration: _fieldBorder(),
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return "This field cannot be empty";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      const Text("Email Address", style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      CustomTextFormField(
                        textStyle: const TextStyle(color: Colors.black),
                        controller: emailTextEditingController,
                        hintText: "Enter your email address",
                        prefix: const Icon(Icons.email_outlined, color: kSmartQGreen),
                        borderDecoration: _fieldBorder(),
                        validator: (val) {
                          if (isEmailValid(emailTextEditingController.text) == false) {
                            return "Enter a valid email address";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      const Text("Phone Number", style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      CustomTextFormField(
                        textStyle: const TextStyle(color: Colors.black),
                        textInputType: TextInputType.phone,
                        controller: phoneTextEditingController,
                        hintText: "Enter your phone number",
                        prefix: const Icon(Icons.phone_outlined, color: kSmartQGreen),
                        borderDecoration: _fieldBorder(),
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return "This field cannot be empty";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 4),
                      Text("We'll send a verification code to this number.",
                          style: Theme.of(context).textTheme.bodySmall),
                      const SizedBox(height: 16),
                      const Text("Password", style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      CustomTextFormField(
                        textStyle: const TextStyle(color: Colors.black),
                        controller: passwordTextEditingController,
                        hintText: "Create a password",
                        prefix: const Icon(Icons.lock_outline, color: kSmartQGreen),
                        borderDecoration: _fieldBorder(),
                        suffix: GestureDetector(
                          onTap: () {
                            setState(() {
                              showPass = !showPass;
                            });
                          },
                          child: Icon(showPass ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                        ),
                        obscureText: showPass,
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return "This field cannot be empty";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 4),
                      Text("At least 8 characters with a mix of letters, numbers & symbols",
                          style: Theme.of(context).textTheme.bodySmall),
                      const SizedBox(height: 16),
                      const Text("Confirm Password", style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      CustomTextFormField(
                        textStyle: const TextStyle(color: Colors.black),
                        controller: confirmPasswordTextEditingController,
                        hintText: "Confirm your password",
                        prefix: const Icon(Icons.lock_outline, color: kSmartQGreen),
                        borderDecoration: _fieldBorder(),
                        suffix: GestureDetector(
                          onTap: () {
                            setState(() {
                              showConfirmPass = !showConfirmPass;
                            });
                          },
                          child: Icon(
                              showConfirmPass ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                        ),
                        obscureText: showConfirmPass,
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return "This field cannot be empty";
                          }
                          if (val != passwordTextEditingController.text) {
                            return "Passwords do not match";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      const Text("City", style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Stack(
                        children: [
                          CustomTextFormField(
                            textStyle: const TextStyle(color: Colors.black),
                            prefix: const Icon(Icons.location_city_outlined, color: kSmartQGreen),
                            borderDecoration: _fieldBorder(),
                            readOnly: true,
                            hintText: city.isEmpty ? "Select your city" : "",
                            onTap: () async {},
                          ),
                          Positioned(
                            left: 30,
                            top: 0,
                            right: 0,
                            bottom: 0,
                            child: CustomDropDown(
                              changedValue: (val) {
                                setState(() {
                                  city = val;
                                });
                              },
                              selectedValue: "",
                              dropDownList: themeProvider.cityDropDown,
                              hintText: city,
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kSmartQGreen,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                          ),
                          onPressed: _submit,
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Sign Up", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward, size: 18),
                            ],
                          ),
                        ),
                      ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text("or sign up with", style: Theme.of(context).textTheme.bodySmall),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () =>
                            Fluttertoast.showToast(msg: "Google sign-up is coming soon"),
                        icon: const Icon(Icons.g_mobiledata, size: 24),
                        label: const Text("Google"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () =>
                            Fluttertoast.showToast(msg: "Apple sign-up is coming soon"),
                        icon: const Icon(Icons.apple, size: 20),
                        label: const Text("Apple"),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    children: [
                      const TextSpan(text: "Already have an account? ", style: TextStyle(color: Colors.black)),
                      TextSpan(
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(builder: (context) {
                                return const LoginPage();
                              }),
                            );
                          },
                        text: "Log in",
                        style: const TextStyle(color: kSmartQGreen, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
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
      : RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
          .hasMatch(email);
}
