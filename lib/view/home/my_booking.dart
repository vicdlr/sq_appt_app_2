import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sq_notification/provider/home_provider.dart';

class MyBooking extends StatefulWidget {
  const MyBooking({super.key});

  @override
  State<MyBooking> createState() => _MyBookingState();
}

class _MyBookingState extends State<MyBooking> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Provider.of<HomeProvider>(context, listen: false).getAllBooking(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final homeData = Provider.of<HomeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Bookings"),
      ),
      body: homeData.isLoadingBooking
          ? Center(child: CircularProgressIndicator())
          : homeData.bookingList.isEmpty
              ? Center(
                  child: Text(
                  "No booking available",
                  style: Theme.of(context).textTheme.titleMedium,
                ))
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: homeData.bookingList.length,
                  itemBuilder: (context, index) {
                    final bookingData = homeData.bookingList[index];
                    String? formattedDataTime;
                    String? assignedTime;
                    if (bookingData.startTime != null &&
                        bookingData.endTime != null) {
                      try {
                        DateTime startTime =
                            DateTime.parse(bookingData.startTime).toLocal();
                        DateTime endTime =
                            DateTime.parse(bookingData.endTime).toLocal();
                        formattedDataTime =
                            DateFormat('d MMMM hh:mm a').format(startTime) +
                                " to " +
                                DateFormat('hh:mm a').format(endTime);
                      } catch (e) {
                        // Handle parsing errors here
                        print("Error parsing date: $e");
                        // You may want to assign default values or show an error message to the user
                      }
                    }

                    if (bookingData.apptTime != null) {
                      try {
                        DateTime startTimeAssigned =
                            DateTime.parse(bookingData.apptTime).toLocal();

                        assignedTime = DateFormat('d MMMM hh:mm a')
                            .format(startTimeAssigned);
                      } catch (e) {
                        // Handle parsing errors here
                        print("Error parsing date: $e");
                        // You may want to assign default values or show an error message to the user
                      }
                    }
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        child: Column(
                          children: [
                            Card(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Flexible(
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Container(
                                          margin: EdgeInsets.all(10),
                                          height: 50,
                                          width: 50,
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade300,
                                            shape: BoxShape.circle,
                                          ),
                                          child: bookingData.imageUrl.isNotEmpty
                                              ? ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(30),
                                                  child: Image.network(
                                                    bookingData.imageUrl,
                                                    fit: BoxFit.cover,
                                                  ),
                                                )
                                              : Icon(
                                                  Icons.person,
                                                  size: 41,
                                                ),
                                        ),
                                        Flexible(
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                right: 8.0),
                                            child: Text(
                                              bookingData.userName,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      homeData.deleteBooking(
                                          context, bookingData.id.toString());
                                    },
                                    icon: Icon(Icons.delete),
                                  ),
                                ],
                              ),
                            ),
                            Card(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 8),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    bottom: 8, left: 8, right: 8),
                                child: Column(
                                  children: [
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text("Status"),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.circle,
                                              color: bookingData.status
                                                          .toLowerCase() ==
                                                      "confirmed"
                                                  ? Colors.green
                                                  : Colors.red,
                                              size: 10,
                                            ),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            Text(
                                              bookingData.status,
                                              style: TextStyle(
                                                  color: bookingData.status
                                                              .toLowerCase() ==
                                                          "confirmed"
                                                      ? Colors.green
                                                      : Colors.red,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                    formattedDataTime != null
                                        ? const SizedBox(
                                            height: 10,
                                          )
                                        : SizedBox(),
                                    formattedDataTime != null
                                        ? Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text("Date & Time"),
                                              Flexible(
                                                  child: Text(
                                                      formattedDataTime ?? ""))
                                            ],
                                          )
                                        : SizedBox(),
                                    assignedTime != null
                                        ? const SizedBox(
                                            height: 10,
                                          )
                                        : SizedBox(),
                                    assignedTime != null
                                        ? buildRow("Appointment time",
                                            assignedTime ?? "")
                                        // Row(
                                        //         mainAxisAlignment:
                                        //             MainAxisAlignment.spaceBetween,
                                        //         children: [
                                        //           Text("Appointment time"),
                                        //           Flexible(child : Text(assignedTime ?? ""))
                                        //           // Text(assignedTime ?? "")
                                        //         ],
                                        //       )
                                        : SizedBox(),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    buildRow(
                                        "Industry", bookingData.industry ?? ""),
                                    // Row(
                                    //   mainAxisAlignment:
                                    //       MainAxisAlignment.spaceBetween,
                                    //   children: [
                                    //     Text("Industry"),
                                    //     Text(bookingData.industry)
                                    //   ],
                                    // ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    buildRow("Company",
                                        bookingData.organisation ?? ""),
                                    // Row(
                                    //   mainAxisAlignment:
                                    //       MainAxisAlignment.spaceBetween,
                                    //   children: [
                                    //     Text("Company"),
                                    //     Text(bookingData.organisation)
                                    //   ],
                                    // ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    buildRow("Department",
                                        bookingData.department ?? ""),
                                    // Row(
                                    //   mainAxisAlignment:
                                    //       MainAxisAlignment.spaceBetween,
                                    //   children: [
                                    //     const Text("Department"),
                                    //     Text(bookingData.department)
                                    //   ],
                                    // ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    buildRow("Group", bookingData.groups ?? ""),
                                    // Row(
                                    //   mainAxisAlignment:
                                    //       MainAxisAlignment.spaceBetween,
                                    //   children: [
                                    //     const Text("Group"),
                                    //     Text(bookingData.groups)
                                    //   ],
                                    // ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    buildRow("Unit", bookingData.unit ?? ""),
                                    // Row(
                                    //   mainAxisAlignment:
                                    //       MainAxisAlignment.spaceBetween,
                                    //   children: [
                                    //     const Text("Unit"),
                                    //     Text(bookingData.unit)
                                    //   ],
                                    // ),
                                    (bookingData.companyName != null &&
                                            bookingData.companyName
                                                .toString()
                                                .isNotEmpty)
                                        ? const SizedBox(
                                            height: 10,
                                          )
                                        : SizedBox(),
                                    (bookingData.companyName != null &&
                                            bookingData.companyName
                                                .toString()
                                                .isNotEmpty)
                                        ? buildRow("Company name",
                                            bookingData.companyName ?? "")
                                        // Row(
                                        //         mainAxisAlignment:
                                        //             MainAxisAlignment.spaceBetween,
                                        //         children: [
                                        //           Text("Company name"),
                                        //           Text(bookingData.companyName ?? "")
                                        //         ],
                                        //       )
                                        : SizedBox(),
                                    (bookingData.deliveryPersonName != null &&
                                            bookingData.deliveryPersonName
                                                .toString()
                                                .isNotEmpty)
                                        ? const SizedBox(
                                            height: 10,
                                          )
                                        : SizedBox(),
                                    (bookingData.deliveryPersonName != null &&
                                            bookingData.deliveryPersonName
                                                .toString()
                                                .isNotEmpty)
                                        ? buildRow(
                                            "Deliver person name",
                                            bookingData.deliveryPersonName ??
                                                "")

                                        // Row(
                                        //         mainAxisAlignment:
                                        //             MainAxisAlignment.spaceBetween,
                                        //         children: [
                                        //           Text("Deliver person name"),
                                        //           Text(bookingData.deliveryPersonName ??
                                        //               "")
                                        //         ],
                                        //       )
                                        : SizedBox(),
                                    (bookingData.remarks != null &&
                                            bookingData.remarks
                                                .toString()
                                                .isNotEmpty)
                                        ? const SizedBox(
                                            height: 10,
                                          )
                                        : SizedBox(),
                                    (bookingData.remarks != null &&
                                            bookingData.remarks
                                                .toString()
                                                .isNotEmpty)
                                        ? buildRow(
                                            "Remarks", bookingData.remarks)

                                        // Row(
                                        //         mainAxisAlignment:
                                        //             MainAxisAlignment.spaceBetween,
                                        //         children: [
                                        //           Text("Remarks"),
                                        //           Text(bookingData.remarks ?? "")
                                        //         ],
                                        //       )
                                        : SizedBox(),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    (bookingData.servicetype != null &&
                                            bookingData.servicetype
                                                .toString()
                                                .isNotEmpty)
                                        ? buildRow("Booking type",
                                            bookingData.servicetype)
                                        // Row(
                                        //         mainAxisAlignment:
                                        //             MainAxisAlignment.spaceBetween,
                                        //         children: [
                                        //           Text("Booking type"),
                                        //           Text(bookingData.servicetype ?? "")
                                        //         ],
                                        //       )
                                        : SizedBox(),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  }),
    );
  }

  Widget buildRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title),
        Flexible(child: Text(value))
        // Text(assignedTime ?? "")
      ],
    );
  }
}
