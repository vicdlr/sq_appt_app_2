import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:sq_notification/constant/app_colors.dart';
import 'package:sq_notification/provider/home_provider.dart';

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
      helpText: 'Your preferred Date',
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

  Widget _buildPickerRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
    required String placeholder,
    required VoidCallback onTap,
  }) {
    final hasValue = value != "00";
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: kSmartQGreenLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: kSmartQGreen, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style:
                          TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(icon, color: kSmartQGreen, size: 16),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            hasValue ? value : placeholder,
                            style: TextStyle(
                              color: hasValue
                                  ? Colors.black87
                                  : Colors.grey.shade500,
                            ),
                          ),
                        ),
                        Icon(Icons.keyboard_arrow_down,
                            color: Colors.grey.shade500),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final homeProvider = Provider.of<HomeProvider>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: kSmartQGreen),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text("Request new booking",
                style: TextStyle(
                    color: kSmartQGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 18)),
            Text("Choose your preferred date and time",
                style: TextStyle(color: Colors.black54, fontSize: 12)),
          ],
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.calendar_month, color: kSmartQGreen),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildPickerRow(
                    icon: Icons.calendar_today,
                    title: "Date",
                    subtitle: "Select the date for your appointment",
                    value: date,
                    placeholder: "Select date",
                    onTap: () => showDialogPicker(context),
                  ),
                  const Divider(height: 1),
                  _buildPickerRow(
                    icon: Icons.access_time,
                    title: "Available from",
                    subtitle: "I'm available from this time",
                    value: firstTime,
                    placeholder: "Select start time",
                    onTap: () => showDialogTimePicker(context),
                  ),
                  const Divider(height: 1),
                  _buildPickerRow(
                    icon: Icons.access_time,
                    title: "To",
                    subtitle: "to this time",
                    value: secondTime,
                    placeholder: "Select end time",
                    onTap: () => showSecondTimePicker(context),
                  ),
                ],
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: kSmartQGreen,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.info_outline,
                        color: Colors.white, size: 16),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Tip",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: kSmartQGreen)),
                        SizedBox(height: 2),
                        Text(
                          "Choose a time range when you are available.\n"
                          "We will show you the best slots.",
                          style: TextStyle(fontSize: 12, color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 52,
              child: homeProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kSmartQGreen,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(26)),
                      ),
                      onPressed: () async {
                        if (firstTime == "00" ||
                            date == "00" ||
                            secondTime == "00") {
                          await Fluttertoast.showToast(
                              msg: "Date & Time are required");
                        } else {
                          if (firstDate != null &&
                              lastDate != null &&
                              selectedDateTime != null) {
                            Provider.of<HomeProvider>(context, listen: false)
                                .createBooking(
                              context,
                              date: selectedDateTime?.toUtc().toString(),
                              startTime: firstDate?.toUtc().toString(),
                              endTime: lastDate?.toUtc().toString(),
                            );
                          }
                        }
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.event_available, size: 20),
                          SizedBox(width: 8),
                          Text("Add Booking",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock, size: 12, color: Colors.grey.shade600),
                const SizedBox(width: 6),
                Text("Your information is secure and private.",
                    style:
                        TextStyle(fontSize: 11, color: Colors.grey.shade600)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
