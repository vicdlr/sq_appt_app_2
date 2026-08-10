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
  // When true, only shows bookings with an active CareConnect-managed queue (the "My Queues"
  // bottom-nav tab) instead of the full appointment history.
  final bool filterActiveQueuesOnly;

  const MyBooking({super.key, this.filterActiveQueuesOnly = false});

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

    final bookings = widget.filterActiveQueuesOnly
        ? homeData.bookingList
            .where((b) =>
                b.handledBy == "CARECONNECT" && _statusKind(b.status) == _BookingStatusKind.confirmed)
            .toList()
        : (List<BookingModel>.from(homeData.bookingList)
          ..sort((a, b) => b.id.compareTo(a.id)));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.filterActiveQueuesOnly ? "My Queues" : "My Appointments"),
      ),
      body: homeData.isLoadingBooking
          ? const Center(child: CircularProgressIndicator())
          : bookings.isEmpty
              ? Center(
                  child: Text(
                  widget.filterActiveQueuesOnly
                      ? "No active queues right now"
                      : "No booking available",
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
                            if (formattedDataTime != null) ...[
                              const SizedBox(height: 6),
                              Text(formattedDataTime,
                                  style: Theme.of(context).textTheme.bodySmall),
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
