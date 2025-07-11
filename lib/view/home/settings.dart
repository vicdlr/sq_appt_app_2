// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sq_notification/SharedPrefrence/SharedPrefrence.dart';
import 'package:sq_notification/utils/utils.dart';
import 'package:sq_notification/view/auth/SignUp.dart';
import 'package:sq_notification/view/home/widget/search_dropdown.dart';
import 'package:package_info_plus/package_info_plus.dart';

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
      'https://node-app-server.onrender.com/users/${SharedPref.getUserData().id}',
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
      body: Column(
        children: [
          Expanded(
            child: Container(
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
                        contentPadding: EdgeInsets.symmetric(horizontal: 2),
                        onTap: () async {},
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        )),
                        tileColor: Theme.of(context).colorScheme.secondary,
                        title: CustomDropDown(
                          changedValue: (val) {
                            themeProvider
                                .setSelectedCity({"city": val}).then((value) {
                              setState(() {});
                            });
                          },
                          // controller: TextEditingController(),
                          selectedValue: "",
                          dropDownList: themeProvider.cityDropDown,
                          hintText: (SharedPref.getUserData().city != null &&
                                  SharedPref.getUserData().city.isNotEmpty)
                              ? SharedPref.getUserData().city
                              : 'City',
                        )
                        ),
                    const SizedBox(
                      height: 10,
                    ),
                    ListTile(
                      onTap: () {
                        Navigator.of(context)
                            .push(MaterialPageRoute(builder: (context) {
                          return WebView(
                            url:
                                'https://node-app-server.onrender.com/privacy.html',
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
                            url:
                                'https://node-app-server.onrender.com/about.html',
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
                            url:
                                'https://node-app-server.onrender.com/terms.html',
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
                      onTap: () async {
                        // firebaseAuth.signOut();

                        final bool isLogout =
                            await Utils.logoutDialog(context) ?? false;
                        if (isLogout) {
                          SharedPref.deleteData();
                          Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(builder: (context) {
                            return const SignupPage();
                          }), (route) => false);
                        }
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

                    // Delete Account Button
                    ElevatedButton(
                      onPressed: () {
                        // Show a confirmation dialog before deleting the account
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text("Delete Account"),
                                content: Text(
                                    "Are you sure you want to delete your account? This action is irreversible."),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context)
                                          .pop(); // Close dialog
                                    },
                                    child: Text("No"),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      Navigator.of(context)
                                          .pop(); // Close dialog
                                      deleteAccount(); // Call the deleteAccount method
                                      // Optionally, log out and navigate to signup page
                                      SharedPref.deleteData();
                                      Navigator.of(context).pushAndRemoveUntil(
                                          MaterialPageRoute(builder: (context) {
                                        return const SignupPage();
                                      }), (route) => false);
                                    },
                                    child: Text("Yes"),
                                  ),
                                ],
                              );
                            });
                      },
                      child: Text("Delete Account"),
                      style: ElevatedButton.styleFrom(
                        padding:
                            EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                        backgroundColor:
                            Colors.red, // Red color for delete action
                      ),
                    ),

                    SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              ),
            ),
          ),
          FutureBuilder<PackageInfo>(
            future: PackageInfo.fromPlatform(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done &&
                  snapshot.hasData) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Center(
                    child: Text(
                      'Version: ${snapshot.data!.version}',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ),
                );
              } else {
                return SizedBox.shrink();
              }
            },
          ),
        ],
      ),
    );
  }
}
