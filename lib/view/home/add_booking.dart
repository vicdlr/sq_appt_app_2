import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';
import 'package:provider/provider.dart';
import 'package:sq_notification/provider/home_provider.dart';

import '../../constant/CustomImage.dart';
import '../../provider/theme_provider.dart';
import '../../utils/utils.dart';

class AddBooking extends StatefulWidget {
  const AddBooking({super.key});

  @override
  State<AddBooking> createState() => _AddBookingState();
}

class _AddBookingState extends State<AddBooking> {
  File? _image;




  late Future<DateTime?> selectedDate;
  DateTime? selectedDateTime;

  String date = "00";

  late Future<TimeOfDay?> startTime;

  late Future<TimeOfDay?> endTime;

  String firstTime = "00";
  String secondTime = "00";

  DateTime? firstDate;
  DateTime? lastDate;

  DateTime? utcDateTime;

  void showDialogPicker(BuildContext context) {
    selectedDate = showDatePicker(
      context: context,
      helpText: 'Your Date of Birth',
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(Duration(days: 0)),
      lastDate: DateTime(2050),
      builder: (BuildContext context, Widget? child) {
        return child!;
      },
    );
    selectedDate.then((value) {
      selectedDateTime = value;
      // showDialogTimePicker(context);

      print("object ++  ${value}");
      setState(() {
        if (value == null) return;
        utcDateTime = value;
        date = Utils.getFormattedDateSimple(value.millisecondsSinceEpoch);
      });
    }, onError: (error) {
      if (kDebugMode) {
        print(error);
      }
    });
  }

  void showDialogTimePicker(BuildContext context) {
    TimeOfDay initialTime = TimeOfDay.now();

    if (DateTime.now().hour > initialTime.hour ||
        (DateTime.now().hour == initialTime.hour &&
            DateTime.now().minute >= initialTime.minute)) {
      initialTime = TimeOfDay(hour: initialTime.hour + 1, minute: 0);
    }

    startTime = showTimePicker(
      helpText: "From this time",
      context: context,
      initialTime: initialTime,
      builder: (BuildContext context, Widget? child) {
        return child!;
      },
    );
    startTime.then((value) {
      setState(() {
        if (value == null) return;
        if (utcDateTime == null) {
          Fluttertoast.showToast(msg: "Please select a date, then a time");
          return;
        }

        DateTime todayDate = DateTime.now();
        DateTime isFuture = DateTime(utcDateTime!.year, utcDateTime!.month,
            utcDateTime!.day, value.hour, value.minute);


        if (!isFuture.isAfter(todayDate)) {
          Fluttertoast.showToast(msg: "Please select future time");
          return;
        }

        log("value ==  $value");

        int hour = value.hourOfPeriod;
        log("hour ==  $hour");
        String minute = value.minute.toString().padLeft(2, '0');
        String period = value.period == DayPeriod.am ? 'AM' : 'PM';
        firstTime = "$hour : $minute $period";
        firstDate = DateTime(utcDateTime!.year, utcDateTime!.month,
            utcDateTime!.day, value.hour, value.minute);
      });
    }, onError: (error) {
      if (kDebugMode) {
        print(error);
      }
    });
  }

  void showSecondTimePicker(BuildContext context) {
    TimeOfDay initialTime = TimeOfDay.now();

    if (DateTime.now().hour > initialTime.hour ||
        (DateTime.now().hour == initialTime.hour &&
            DateTime.now().minute >= initialTime.minute)) {
      initialTime = TimeOfDay(hour: initialTime.hour + 1, minute: 0);
    }

    endTime = showTimePicker(
        helpText: "to this time",
        context: context,
        initialTime: initialTime,
        builder: (BuildContext context, Widget? child) {
          return child!;
        },
        onEntryModeChanged: (value) {});
    endTime.then((value) {
      setState(() {
        if (value == null) return;
        if (utcDateTime == null) {
          Fluttertoast.showToast(msg: "Please select a date, then a time");
          return;
        }

        DateTime todayDate = DateTime.now();
        DateTime isFuture = DateTime(utcDateTime!.year, utcDateTime!.month,
            utcDateTime!.day, value.hour, value.minute);


        if (!isFuture.isAfter(todayDate)) {
          Fluttertoast.showToast(msg: "Please select future time");
          return;
        }

        if (utcDateTime == null) {
          Fluttertoast.showToast(msg: "Please select a date, then a time");
          return;
        }

        log("value ==  $value");

        int hour = value.hourOfPeriod;
        log("hour ==  $hour");
        String minute = value.minute.toString().padLeft(2, '0');
        String period = value.period == DayPeriod.am ? 'AM' : 'PM';
        secondTime = "$hour : $minute $period";
        lastDate = DateTime(utcDateTime!.year, utcDateTime!.month,
            utcDateTime!.day, value.hour, value.minute);
      });
    }, onError: (error) {
      if (kDebugMode) {
        print(error);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final homeProvider = Provider.of<HomeProvider>(context);
    final themeData = Provider.of<ThemeProvider>(context);
    return Scaffold(
      backgroundColor: themeData.isDarkTheme ? Colors.black : Colors.white,
      appBar: AppBar(
        title: Text("Request new booking"),
      ),
      body: Column(
        children: [
          Expanded(
            child: Column(
              children: [
                SizedBox(height: 50),

                _buildTimePick(context, "Date", date, () {
                  showDialogPicker(context);
                }),
                SizedBox(
                  height: 10,
                ),
                _buildTimePick(context, "I'm available from this time", firstTime, () {
                  showDialogTimePicker(context);
                }),
                SizedBox(
                  height: 10,
                ),
                _buildTimePick(context, "to this time", secondTime, () {
                  showSecondTimePicker(context);
                }),
                SizedBox(
                  height: 10,
                ),
                // Align(
                //   alignment: Alignment.center,
                //   child: ElevatedButton(
                //
                //     child: Text(
                //       "PICK DATE & TIME",
                //       style: Theme.of(context).textTheme.labelMedium,
                //     ),
                //     onPressed: () {
                //       showDialogPicker(context);
                //     },
                //   ),
                // ),
              ],
            ),
          ),
         Container(
           margin: EdgeInsets.all(20),
            height: 45,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: themeData.isDarkTheme ? Colors.white : Colors.black45,
              ),
            ),
            child:
              homeProvider.isLoading

                      ? SizedBox(
                          height: 30,
                          child: Center(child: const CircularProgressIndicator()))
                      :

            TextButton(
              onPressed: () async {
                if (firstTime == "00" || date == "00" || secondTime == "00") {
                  await Fluttertoast.showToast(msg: "Date & Time are required");
                } else {
                  if(firstDate != null && lastDate != null && selectedDateTime != null){
                    Provider.of<HomeProvider>(context, listen: false).createBooking(
                      context,
                      date: selectedDateTime?.toUtc().toString(),
                      startTime: firstDate?.toUtc().toString(),
                      endTime: lastDate?.toUtc().toString(),
                    );
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
          // Padding(
          //
          //   padding: EdgeInsets.symmetric(vertical: 10),
          //   child: ListTile(
          //     onTap: () async {
          //       if (firstTime == "00" || date == "00" || secondTime == "00") {
          //         await Fluttertoast.showToast(msg: "Date & Time are required");
          //       } else {
          //         if(firstDate != null && lastDate != null && selectedDateTime != null){
          //           Provider.of<HomeProvider>(context, listen: false).createBooking(
          //             context,
          //             date: selectedDateTime?.toUtc().toString(),
          //             startTime: firstDate?.toUtc().toString(),
          //             endTime: lastDate?.toUtc().toString(),
          //           );
          //         }
          //       }
          //     },
          //     shape: const RoundedRectangleBorder(
          //         borderRadius: BorderRadius.all(
          //           Radius.circular(10),
          //         )),
          //     tileColor: Theme.of(context).colorScheme.secondary,
          //     title: const SizedBox(
          //       height: 30,
          //       child: Center(
          //         child: Text("Continue"),
          //       ),
          //     ),
          //
          //     // title: TestPage(dropDownList: [], hintText: 'Country', changedValue: (val) {  },),
          //   ),
          // )
        ],
      ),
      // bottomSheet: Container(
      //   margin: const EdgeInsets.all(8.0),
      //   child: ListTile(
      //     onTap: () async {
      //       if (firstTime == "00" || date == "00" || secondTime == "00") {
      //         await Fluttertoast.showToast(msg: "Date & Time are required");
      //       } else {
      //         if(firstDate != null && lastDate != null && selectedDateTime != null){
      //           Provider.of<HomeProvider>(context, listen: false).createBooking(
      //             context,
      //             date: selectedDateTime?.toUtc().toString(),
      //             startTime: firstDate?.toUtc().toString(),
      //             endTime: lastDate?.toUtc().toString(),
      //           );
      //         }
      //       }
      //     },
      //     shape: const RoundedRectangleBorder(
      //         borderRadius: BorderRadius.all(
      //       Radius.circular(10),
      //     )),
      //     tileColor: Theme.of(context).colorScheme.secondary,
      //     title: homeProvider.isLoading
      //         ? SizedBox(
      //             height: 30,
      //             child: Center(child: const CircularProgressIndicator()))
      //         : SizedBox(height: 30, child: Center(child: Text("Submit"),),),
      //
      //     // title: TestPage(dropDownList: [], hintText: 'Country', changedValue: (val) {  },),
      //   ),
      // ),
    );
  }
}

Widget _buildTimePick(
    BuildContext context, String title, String time, Function() onTimePicked) {
  return Column(
    children: [
      Text(
        title,
        style: TextStyle(fontSize: 20),
      ),
      GestureDetector(
        onTap: onTimePicked,
        child: Container(
            width: 180,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(5),
                color: Theme.of(context).colorScheme.secondaryContainer),
            child: Center(
              child: Text(
                time,
                style: TextStyle(fontSize: 20),
              ),
            )),
      ),
    ],
  );
}
