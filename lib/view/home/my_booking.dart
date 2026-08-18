import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../Model/BookingModel.dart';
import '../../api/api.dart';
import '../../api/configurl.dart';
import '../../provider/home_provider.dart';
import 'get_ticket.dart';

class MyBooking extends StatefulWidget {
  const MyBooking({super.key});

  @override
  State<MyBooking> createState() => _MyBookingState();
}

enum _BookingStatusKind { pending, confirmed, declined, completed }

_BookingStatusKind _statusKind(String status) {
  final s = status.toLowerCase();
  if (s.contains("cancel") || s.contains("declin") || s.contains("reject")) {
    return _BookingStatusKind.declined;
  }
  if (s.contains("confirm") || s.contains("checked")) return _BookingStatusKind.confirmed;
  if (s.contains("complet") || s.contains("served")) return _BookingStatusKind.completed;
  return _BookingStatusKind.pending;
}

Color _statusColor(_BookingStatusKind kind, BuildContext context) {
  switch (kind) {
    case _BookingStatusKind.declined:
      return Colors.red;
    case _BookingStatusKind.confirmed:
      return Colors.green;
    case _BookingStatusKind.completed:
      return Colors.grey;
    case _BookingStatusKind.pending:
      return Colors.orange;
  }
}

class _MyBookingState extends State<MyBooking> {
  final Set<int> _mintingQueueAccessForBookingId = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Provider.of<HomeProvider>(context, listen: false).getAllBooking(context);
    });
  }

  Future<void> _viewQueue(BookingModel booking) async {
    setState(() {
      _mintingQueueAccessForBookingId.add(booking.id);
    });

    final result =
        await DioApi.post(path: ConfigUrl.queueAccessUrl(booking.id.toString()), data: {});

    setState(() {
      _mintingQueueAccessForBookingId.remove(booking.id);
    });

    final careConnectUrl = result.response?.data?["data"]?["careConnectUrl"];
    if (result.response != null && careConnectUrl != null) {
      if (mounted) {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return WebViewPage(url: careConnectUrl);
        }));
      }
    } else {
      Fluttertoast.showToast(msg: "Couldn't open the queue right now. Please try again.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final homeData = Provider.of<HomeProvider>(context);

    final bookings = List<BookingModel>.from(homeData.bookingList)
      ..sort((a, b) => b.id.compareTo(a.id));

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Appointments"),
      ),
      body: homeData.isLoadingBooking
          ? const Center(child: CircularProgressIndicator())
          : bookings.isEmpty
              ? Center(
                  child: Text(
                  "No booking available",
                  style: Theme.of(context).textTheme.titleMedium,
                ))
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: bookings.length,
                  itemBuilder: (context, index) {
                    final booking = bookings[index];
                    final kind = _statusKind(booking.status);
                    final color = _statusColor(kind, context);
                    final isMinting = _mintingQueueAccessForBookingId.contains(booking.id);

                    String? formattedDataTime;
                    if (booking.startTime != null && booking.endTime != null) {
                      try {
                        DateTime startTime = DateTime.parse(booking.startTime).toLocal();
                        DateTime endTime = DateTime.parse(booking.endTime).toLocal();
                        formattedDataTime =
                            "${DateFormat('d MMMM hh:mm a').format(startTime)} to ${DateFormat('hh:mm a').format(endTime)}";
                      } catch (e) {
                        // leave formattedDataTime null on parse failure
                      }
                    }

                    // apptTime is CareConnect's confirmed final appointment time -- once set,
                    // it supersedes the originally-requested startTime/endTime slot above.
                    String? formattedApptTime;
                    if (booking.apptTime != null) {
                      try {
                        final apptDt =
                            DateTime.parse(booking.apptTime.toString()).toLocal();
                        formattedApptTime =
                            DateFormat('d MMMM hh:mm a').format(apptDt);
                      } catch (e) {
                        // leave formattedApptTime null on parse failure
                      }
                    }

                    // remarks carries CareConnect's outcome message -- the rejection reason
                    // for declined/cancelled, or a confirmation/booking-ref summary otherwise.
                    final remarksText =
                        booking.remarks?.toString().trim().isNotEmpty == true
                            ? booking.remarks.toString().trim()
                            : null;

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: color, width: 1.5),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Text(
                                    booking.organisation.isNotEmpty
                                        ? booking.organisation
                                        : booking.unit,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: color.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    booking.status,
                                    style: TextStyle(
                                        color: color, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            if (formattedApptTime != null) ...[
                              const SizedBox(height: 6),
                              Text("Appointment: $formattedApptTime",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(fontWeight: FontWeight.w600)),
                            ] else if (formattedDataTime != null) ...[
                              const SizedBox(height: 6),
                              Text(formattedDataTime,
                                  style: Theme.of(context).textTheme.bodySmall),
                            ],
                            if (remarksText != null) ...[
                              const SizedBox(height: 6),
                              Text(remarksText,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: kind == _BookingStatusKind.declined
                                          ? Colors.red[700]
                                          : Colors.grey[700])),
                            ],
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    Provider.of<HomeProvider>(context, listen: false)
                                        .deleteBooking(context, booking.id.toString());
                                  },
                                  icon: const Icon(Icons.delete_outline),
                                ),
                                const Spacer(),
                                if (kind == _BookingStatusKind.confirmed &&
                                    booking.handledBy == "CARECONNECT")
                                  ElevatedButton(
                                    onPressed:
                                        isMinting ? null : () => _viewQueue(booking),
                                    child: isMinting
                                        ? const SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                                strokeWidth: 2),
                                          )
                                        : const Text("View Queue"),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
    );
  }
}
