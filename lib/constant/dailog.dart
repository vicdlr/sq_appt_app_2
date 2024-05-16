import 'package:flutter/material.dart';


class Dialogs {
  static Future<void> errorDialog(BuildContext context, String err) async {
    return await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Icon(
            Icons.error_outline,
            size: 45,

          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                err,
                style: const TextStyle(
                    fontSize: 17, fontWeight: FontWeight.w400,

                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 20,
              ),
              InkWell(
                child: const Text(
                  'Back',
                  style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,

                  ),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),
              const SizedBox(
                height: 10,
              ),
            ],
          ),
        );
      },
    );
  }

  static Future<void> successDialog(BuildContext context, String message) async {
    return await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Icon(
            Icons.check_circle_outline,
            size: 45,

          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message,
                style: const TextStyle(
                    fontSize: 17, fontWeight: FontWeight.w400),
              ),
              const SizedBox(
                height: 20,
              ),
              InkWell(
                child: const Text(
                  'Back',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,),
                ),
                onTap: () {
                  Navigator.of(context).pop();

                },
              ),
              const SizedBox(
                height: 10,
              ),
            ],
          ),
        );
      },
    );
  }

  // static Future<void> successDialogAccept(BuildContext context, String message) async {
  //   return await showDialog<void>(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: const Icon(
  //           Icons.check_circle_outline,
  //           size: 45,
  //
  //         ),
  //         content: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             Text(
  //               message,
  //               textAlign: TextAlign.center,
  //               style: const TextStyle(
  //                   fontSize: 17, fontWeight: FontWeight.w400),
  //             ),
  //             const SizedBox(
  //               height: 20,
  //             ),
  //             InkWell(
  //               child: const Text(
  //                 'Ok',
  //                 style: TextStyle(
  //                   fontSize: 19,
  //                   fontWeight: FontWeight.bold,
  //                   color: AppColor.primaryColor,),
  //               ),
  //               onTap: () {
  //                 Navigator.of(context).pop();
  //                 Navigator.of(context).pop();
  //               },
  //             ),
  //             const SizedBox(
  //               height: 10,
  //             ),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }
  //
  // static Future<void> errorDialogReject(BuildContext context, String err) async {
  //   return await showDialog<void>(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: const Icon(
  //           Icons.error_outline,
  //           size: 45,
  //           color: AppColor.primaryColor,
  //         ),
  //         content: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             Text(
  //               err,
  //               style: const TextStyle(
  //                   fontSize: 17, fontWeight: FontWeight.w400),
  //             ),
  //             const SizedBox(
  //               height: 20,
  //             ),
  //             InkWell(
  //               child: const Text(
  //                 'Ok',
  //                 style: TextStyle(
  //                     fontSize: 19,
  //                     fontWeight: FontWeight.bold,
  //                     color: AppColor.primaryColor),
  //               ),
  //               onTap: () {
  //                 Navigator.of(context).pop();
  //                 Navigator.of(context).pop();
  //               },
  //             ),
  //             const SizedBox(
  //               height: 10,
  //             ),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }
  //
  // static Future<bool?> logoutDialog(BuildContext context) async {
  //   return showDialog<bool>(
  //     context: context,
  //     builder: (context){
  //       return AlertDialog(
  //         title: const Text('Logout'),
  //         content: const Text('Do you want to logout?'),
  //         actions: [
  //           TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text('Cancel', style: TextStyle(color: AppColor.subTextColor),)),
  //           TextButton(onPressed: () => Navigator.of(context).pop(true), child: Text('Yes', style: TextStyle(color: AppColor.primaryColor))),
  //         ],
  //       );
  //     },
  //   );
  // }
  //
  static Future<void> confirmDelete(BuildContext context, String message,Function() ontap ,String firstStr ,String secondStr) async {
    return await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).dialogBackgroundColor,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message,
                style: const TextStyle(
                    fontSize: 17, fontWeight: FontWeight.w400),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  InkWell(
                    onTap: ontap,
                    child: Container(

                      child:  Text(
                        firstStr,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    child:  Text(
                      secondStr,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),

              const SizedBox(
                height: 10,
              ),
            ],
          ),
        );
      },
    );
  }

}
