// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sq_notification/SharedPrefrence/SharedPrefrence.dart';
import 'package:sq_notification/view/auth/SignUp.dart';
import 'package:sq_notification/view/home/widget/search_dropdown.dart';

import '../../provider/theme_provider.dart';
import 'WebView.dart';

//'https://sq-notification.onrender.com/privacy-policy'

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  void deleteAccount() async {
    var headers = {'x-access-token': SharedPref.getAuthToken()};
    var dio = Dio();
    var response = await dio.request(
      'https://node-app-server.onrender.com/device/${SharedPref.getUserData().id}',
      options: Options(
        method: 'DELETE',
        headers: headers,
      ),
    );

    if (response.statusCode == 200) {
      print("user delete successfully === ${response.data}");
    } else {
      print(response.statusMessage);
    }
  }

  // Future<void> deleteUser() async {
  //   // Obtain explicit user consent for deletion (not shown here)
  //
  //   try {
  //     // Re-authenticate if necessary (not shown here)
  //
  //     // Delete document in Cloud Firestore (if applicable)
  //     final colRef = firestore.doc("users/${firebaseAuth.currentUser?.uid}");
  //     await colRef.delete();
  //
  //     // Delete user authentication data
  //
  //     await firebaseAuth.currentUser?.delete();
  //
  //     // Deletion successful, handle next steps (e.g., redirect, logout)
  //     print("User deleted successfully.");
  //   } on FirebaseAuthException catch (error) {
  //     // Handle Firebase Authentication errors
  //     print("Error deleting user:${error.code}${error.message}");
  //     // Provide informative error message to the user
  //   } catch (error) {
  //     // Handle other unforeseen errors
  //     print("Unexpected error:$error");
  //     // Provide general error message to the user
  //   }
  // }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Provider.of<ThemeProvider>(context, listen: false).getRegionData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: true);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: SingleChildScrollView(
          child: Column(
            children: [
              ListTile(
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                  Radius.circular(10),
                )),
                tileColor: Theme.of(context).colorScheme.secondary,
                title: Text(
                  "Dark Mode",
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                trailing: Switch(
                  value: themeProvider.isDarkTheme,
                  onChanged: (bool value) {
                    themeProvider.toggleTheme();
                  },
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              ListTile(
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10),
                  ),
                ),
                tileColor: Theme.of(context).colorScheme.secondary,
                title: Text(
                  "Font Size",
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                trailing: SizedBox(
                  width: 120,
                  child: Slider(
                    divisions: 35,
                    inactiveColor:
                        Theme.of(context).sliderTheme.inactiveTrackColor,
                    min: 14,
                    max: 35,
                    value: themeProvider.fSize,
                    onChanged: (double value) {
                      themeProvider.setFontSize(value);
                    },
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              ListTile(
                onTap: () async {
                  await dialogBuilder(context);
                },
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                  Radius.circular(10),
                )),
                tileColor: Theme.of(context).colorScheme.secondary,
                title: TestPage(
                  dropDownList: themeProvider.cityDropDown,
                  hintText: (SharedPref.getUserData().city != null &&
                          SharedPref.getUserData().city.isNotEmpty)
                      ? SharedPref.getUserData().city
                      : 'City',
                  changedValue: (val) {
                    themeProvider.setSelectedCity({"city": val.name});
                  },
                ),
                // title: TestPage(dropDownList: [], hintText: 'Country', changedValue: (val) {  },),
              ),
              const SizedBox(
                height: 10,
              ),
              ListTile(
                onTap: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) {
                    return WebView(
                      url: 'https://node-app-server.onrender.com/privacy.html',
                      title: 'Privacy Policy',
                    );
                  }));
                },
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                  Radius.circular(10),
                )),
                tileColor: Theme.of(context).colorScheme.secondary,
                title: Text(
                  "Privacy Policy",
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              ListTile(
                onTap: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) {
                    return WebView(
                      url: 'https://node-app-server.onrender.com/about.html',
                      title: 'About Us',
                    );
                  }));
                },
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                  Radius.circular(10),
                )),
                tileColor: Theme.of(context).colorScheme.secondary,
                title: Text(
                  "About Us",
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              ListTile(
                onTap: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) {
                    return WebView(
                      url: 'https://node-app-server.onrender.com/terms.html',
                      title: 'Terms & Conditions',
                    );
                  }));
                },
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                  Radius.circular(10),
                )),
                tileColor: Theme.of(context).colorScheme.secondary,
                title: Text(
                  "Terms of Use",
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              /*ListTile(
                onTap: () {
                  Dialogs.confirmDelete(context, "Do you really want to delete your account ?", () async{
                    try{


                      deleteUser();
                    }catch(e){
                      print("something went wrong e ++${e}") ;
                    }
                    deleteAccount();
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) {
                        return SignupPage();
                      }), (route) => false);}, "Yes", "NO");

                },
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),),
                tileColor: Theme.of(context).colorScheme.secondary,
                title: Text("Delete Account",style: Theme.of(context).textTheme.labelMedium,),
              ),
              SizedBox(
                height: 10,
              ),*/
              ListTile(
                onTap: () {
                  // firebaseAuth.signOut();
                  SharedPref.deleteData();
                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) {
                    return const SignupPage();
                  }), (route) => false);
                },
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                  Radius.circular(10),
                )),
                tileColor: Theme.of(context).colorScheme.secondary,
                title: Text(
                  "Logout",
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ),
              SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
