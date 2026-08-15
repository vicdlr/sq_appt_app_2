import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sq_notification/api/api.dart';
import 'package:sq_notification/api/configurl.dart';
import 'package:sq_notification/view/auth/SignUp.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../Model/UserDataModel.dart';
import '../../SharedPrefrence/SharedPrefrence.dart';
import '../../constant/app_colors.dart';
import '../../widget/CustomTextFormField.dart';
import '../home/bottom_nav_bar.dart';

export '../../constant/app_colors.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isLoading = false;

  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool showPass = true;

  void submitData() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

    var data = {
      "email": emailTextEditingController.text.toLowerCase(),
      "password": passwordTextEditingController.text,
    };

    final result = await DioApi.post(path: ConfigUrl.loginUrl, data: data);

    final token = result.response?.data is Map ? result.response?.data["token"] : null;

    // A 200 response with no usable token would otherwise get stored as the literal string
    // "null" (Dart's string interpolation of a null value), silently poisoning every subsequent
    // authenticated request with an "Invalid Token" server error instead of failing here.
    if (result.response?.data != null && token is String && token.isNotEmpty) {
      SharedPref.setAuthToken(token);
      SharedPref.setUserData(UserData.fromJson(result.response?.data["user"]));
      setState(() {
        isLoading = false;
      });
      await Fluttertoast.showToast(msg: "Successfully Logged In");
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (c) => BottomNavBar(),
          ),
          (route) => false,
        );
      }
    } else {
      setState(() {
        isLoading = false;
      });
      if (result.dioError != null) {
        result.handleError(context);
      } else {
        await Fluttertoast.showToast(msg: "Login failed. Please try again.");
      }
    }
  }

  void _launchURL() async {
    final Uri url = Uri.parse('https://node-app-server.onrender.com/forgetPasswordPage');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  InputBorder _fieldBorder() => OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _header(context),
              const SizedBox(height: 24),
              Text(
                "Welcome Back!",
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(color: kSmartQGreen, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                "Sign in to continue to your queue dashboard.",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text("Email Address", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    CustomTextFormField(
                      textStyle: const TextStyle(color: Colors.black),
                      controller: emailTextEditingController,
                      hintText: "Enter your email",
                      prefix: Icon(Icons.email_outlined, color: kSmartQGreen),
                      borderDecoration: _fieldBorder(),
                      validator: (val) {
                        if (isEmailValid(emailTextEditingController.text) == false) {
                          return "Enter a valid email address";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text("Password", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    CustomTextFormField(
                      textStyle: const TextStyle(color: Colors.black),
                      controller: passwordTextEditingController,
                      hintText: "Enter your password",
                      prefix: Icon(Icons.lock_outline, color: kSmartQGreen),
                      borderDecoration: _fieldBorder(),
                      obscureText: showPass,
                      suffix: GestureDetector(
                        onTap: () {
                          setState(() {
                            showPass = !showPass;
                          });
                        },
                        child: Icon(showPass ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                      ),
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return "This field cannot be empty";
                        }
                        return null;
                      },
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _launchURL,
                        child: const Text("Forgot Password?", style: TextStyle(color: kSmartQGreen)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
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
                        onPressed: submitData,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Sign In", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward, size: 18),
                          ],
                        ),
                      ),
                    ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: kSmartQGreenLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.verified_user_outlined, color: kSmartQGreen),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text("Secure & Protected", style: TextStyle(fontWeight: FontWeight.bold, color: kSmartQGreen)),
                          Text("Your data is encrypted and always protected.", style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _signup(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Row(
      children: [
        Image.asset("assets/images/smartq_logo.png", width: 40, height: 40),
        const SizedBox(width: 8),
        const Text("SmartQ",
            style: TextStyle(color: kSmartQGreen, fontWeight: FontWeight.bold, fontSize: 22)),
      ],
    );
  }

  Widget _signup(BuildContext context) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        children: [
          const TextSpan(text: "Don't have an account? ", style: TextStyle(color: Colors.black)),
          TextSpan(
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) {
                    return SignupPage();
                  }),
                );
              },
            text: "Sign Up",
            style: const TextStyle(color: kSmartQGreen, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
