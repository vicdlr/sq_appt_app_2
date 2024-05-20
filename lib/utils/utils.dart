import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Utils {

  static String getFormattedDateSimple(int time) {
    DateFormat newFormat = DateFormat("MMMM dd, yyyy");
    return newFormat.format(DateTime.fromMillisecondsSinceEpoch(time));
  }

  static Future<bool?> logoutDialog(BuildContext context) async {


    return showAdaptiveDialog<bool>(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Container(
            // margin: EdgeInsets.all(10),

            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25), color: Colors.white),
            child: Padding(
              padding: EdgeInsets.only(
                left: 20.0,
                right: 20.0,
                top: 30,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // const Text("Logout"),
                  // Icon(
                  //   CupertinoIcons.info,
                  //   size: 50.adaptSize,
                  // ),
                  // Icon for Account Deleted

                  SizedBox(height: 16.0),

                  // Text: Account Deleted
                  Text(
                    "Are you sure you want to log out?",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                      fontFamily: 'Nunito Sans',
                      fontWeight: FontWeight.w700,
                      height: 0,
                    ),
                  ),
                  SizedBox(height: 16.0),

                  // Done Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 120,
                        height: 50,
                        child: TextButton(
                          onPressed: () {
                            // Handle the action when the user clicks the Done button
                            Navigator.of(context)
                                .pop(false); // Close the dialog
                          },
                          child: const Text('No',
                            style: TextStyle(
                            color: Colors.black,
                          ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 120,
                        height: 50,
                        child: TextButton(
                          onPressed: () {

                            Navigator.of(context).pop(true); // Close the dialog
                          }, child: const Text('Yes',style: TextStyle(
                          color: Colors.black,
                        ),),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
        // return AlertDialog(
        //   title: const Text('Logout'),
        //   content: const Text('Do you want to logout?'),
        //   actions: [
        //     TextButton(
        //         onPressed: () => Navigator.of(context).pop(false),
        //         child: const Text(
        //           'Cancel',
        //           style: TextStyle(
        //               // color: AppColor.subTextColor
        //               ),
        //         )),
        //     TextButton(
        //       onPressed: () => Navigator.pop(context, true),
        //       // Navigator.of(context).pop(true),
        //       child: const Text(
        //         'Yes',
        //         style: TextStyle(
        //             // color: AppColor.primaryColor
        //             ),
        //       ),
        //     ),
        //   ],
        // );
      },
    );
  }

}