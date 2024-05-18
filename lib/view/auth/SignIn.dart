import 'dart:convert';


import 'package:dio/dio.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:sq_notification/SharedPrefrence/SharedPrefrence.dart';
import 'package:sq_notification/api/api.dart';
import 'package:sq_notification/api/configurl.dart';
import 'package:sq_notification/view/auth/SignUp.dart';

import '../../Model/UserDataModel.dart';
import '../../constant/firebase_constant.dart';
import '../../provider/theme_provider.dart';
import '../../widget/CustomTextFormField.dart';
import '../home/bottom_nav_bar.dart';
import '../home/home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  bool isLoading = false ;
  TextEditingController nameTextEditingController = TextEditingController();

  TextEditingController emailTextEditingController = TextEditingController();

  TextEditingController phoneTextEditingController = TextEditingController();

  TextEditingController passwordTextEditingController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool isPasswordVisible = true;

  final String _identifier = '';


  void submitData() async {

    setState(() {
      isLoading = true;
    });

    var headers = {
      'Content-Type': 'application/json'
    };
    var data = {
      "email": emailTextEditingController.text,
      "password": passwordTextEditingController.text,
    };

    final result =await DioApi.post(path: ConfigUrl.loginUrl, data: data);

    if (result.response?.data != null) {

      print("login response data == ${result.response?.data}");
      SharedPref.setAuthToken("${result.response?.data["token"]}");
      SharedPref.setUserData(UserData.fromJson(result.response?.data["device"]));
      print("shared auth token ${SharedPref.getAuthToken()}");
      print("shared user data  ${SharedPref.getUserData().toJson()}");
      setState(() {
        isLoading = false;
      });
      await Fluttertoast.showToast(msg: "Successfully Logged In");
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (c) =>  BottomNavBar(),
        ),
            (route) => false,
      );
      // _submit();
    }
    else {
      setState(() {
        isLoading = false;
      });
      result.handleError(context);
    }
  }

  // void _submit() async {
  //   if (_formKey.currentState!.validate()) {
  //     try {
  //       setState(() {
  //         isLoading = true;
  //       });
  //       final authResult = await firebaseAuth.signInWithEmailAndPassword(
  //         email: emailTextEditingController.text.trim(),
  //         password: passwordTextEditingController.text.trim(),
  //       );
  //
  //       currentUser = authResult.user;
  //
  //       if (currentUser != null) {
  //         setState(() {
  //           isLoading = false;
  //         });
  //         await Fluttertoast.showToast(msg: "Successfully Logged In");
  //         Navigator.pushAndRemoveUntil(
  //           context,
  //           MaterialPageRoute(
  //             builder: (c) =>  BottomNavBar(),
  //           ),
  //           (route) => false,
  //         );
  //         setState(() {
  //           isLoading = false;
  //         });
  //       }
  //     } catch (error) {
  //       setState(() {
  //         isLoading = false;
  //       });
  //       print("Error message: $error");
  //       Fluttertoast.showToast(msg: "Error Occurred: \n$error");
  //     }
  //   } else {
  //     Fluttertoast.showToast(msg: "Not all fields are valid");
  //   }
  // }

  bool showPass = true;

  @override
  Widget build(BuildContext context) {
    final themeData = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            height: MediaQuery.of(context).size.height - 50,
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _header(context),
                const SizedBox(height: 20),
                Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      Align(
                        alignment : Alignment.topLeft,
                        child: Text(
                          "Email",
                          style: TextStyle(fontSize: 15, color: Colors.grey[700]),
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
                        alignment : Alignment.topLeft,
                        child: Text(
                          "Password",
                          style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      CustomTextFormField(
                        textStyle: TextStyle(color: Colors.black),
                        controller: passwordTextEditingController,
                        hintText: "Password",
                        prefix: const Icon(Icons.password),
                        obscureText: showPass,
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
                        validator: (val) {
                          if (val!.isEmpty) {
                            return "This field cannot be empty";
                          } else {
                            return null;
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                isLoading ? const Center(child: CircularProgressIndicator()) :Container(
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
                        offset:
                        const Offset(0, 1), // changes position of shadow
                      ),
                    ],
                  ),
                  child:  TextButton(
                    onPressed: () {
                      submitData();
                    },
                    child:  const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Sign In",
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
                  height: 10,
                ),
                _signup(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _header(context) {
    return const Column(
      children: [
        Text(
          "Welcome Back",
          style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
        ),
        Text("Enter your credential to login"),
      ],
    );
  }

  _inputField(context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          decoration: InputDecoration(
              hintText: "Username",
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none),
              fillColor: Colors.purple.withOpacity(0.1),
              filled: true,
              prefixIcon: const Icon(Icons.person)),
        ),
        const SizedBox(height: 10),
        TextField(
          decoration: InputDecoration(
            hintText: "Password",
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none),
            fillColor: Colors.purple.withOpacity(0.1),
            filled: true,
            prefixIcon: const Icon(Icons.password),
          ),
          obscureText: true,
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            shape: const StadiumBorder(),
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: Colors.purple,
          ),
          child: const Text(
            "Login",
            style: TextStyle(fontSize: 20),
          ),
        )
      ],
    );
  }

  _forgotPassword(context) {
    return TextButton(
      onPressed: () {},
      child: const Text(
        "Forgot password?",
        style: TextStyle(color: Colors.purple),
      ),
    );
  }

  _signup(context) {
    return  RichText(
      textAlign : TextAlign.center,
      text: TextSpan(
        children: [
          TextSpan(
              text: "Don't Have an Account?",
              style: TextStyle(
                  color: Colors.black
              )
          ),
          const TextSpan(
            text: " ",
          ),
          TextSpan(
            recognizer: TapGestureRecognizer()
              ..onTap = () {

                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context){
                      return SignupPage();
                    })
                );
              },
            text: "Sign Up",
            style: TextStyle(color: Colors.purple),
          ),
        ],
      ),

    );

    Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Don't Have an Account?"),
        GestureDetector(
          onTap: () {
            Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context) => const SignupPage(),
            ));
          },
          child: const Text(
            " Sign Up",
            style: TextStyle(color: Colors.purple),
          ),
        )
      ],
    );
  }
}

