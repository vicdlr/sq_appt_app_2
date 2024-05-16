import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sq_notification/provider/home_provider.dart';
import 'package:sq_notification/provider/theme_provider.dart';

import '../../Model/NotificationModel.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Provider.of<HomeProvider>(context, listen: false)
          .getNotificationList(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final notificationList = Provider.of<HomeProvider>(context);
    final themeData = Provider.of<ThemeProvider>(context);
    return Scaffold(
      backgroundColor: themeData.isDarkTheme ? Colors.black : Colors.white,
      appBar: AppBar(
        title: Text("Notification"),
      ),
      // appBar: _buildAppBar(context),
      body: notificationList.isLoading
          ? Center(
              child: SizedBox(
                  height: 40,
                  width: 40,
                  child: const CircularProgressIndicator()))
          : Container(
              width: double.maxFinite,
              padding: const EdgeInsets.symmetric(
                horizontal: 19,
                vertical: 15,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // SizedBox(height: 8.v),
                  notificationList.notificationList.isEmpty
                      ? Padding(
                          padding: EdgeInsets.symmetric(vertical: 300),
                          child: Center(
                            child: Text(
                              "Notification is Not Available",
                            ),
                          ),
                        )
                      : _buildToday(context,
                          notificationCoachList:
                              notificationList.notificationList),
                  SizedBox(height: 5),
                ],
              ),
            ),
    );
  }

  /// Section Widget
  Widget _buildToday(BuildContext context,
      {required List<NotificationModel> notificationCoachList}) {
    return Expanded(
      child: GroupedListView<NotificationModel, String>(
        shrinkWrap: true,
        stickyHeaderBackgroundColor: Colors.transparent,
        elements: notificationCoachList,
        groupBy: (element) {
          return DateFormat('d MMMM, yyyy').format(element.sentTime!);
        },
        sort: false,
        groupSeparatorBuilder: (String value) {
          return Padding(
            padding: EdgeInsets.only(
              top: 19,
              bottom: 8,
            ),
            child: Text(
              value,
            ),
          );
        },
        itemBuilder: (context, notificationData) {
          return NotificationItemWidget(notificationData: notificationData);
        },
        separator: SizedBox(
          height: 10,
        ),
      ),
    );
  }
}

class NotificationItemWidget extends StatelessWidget {
  final NotificationModel notificationData;

  const NotificationItemWidget({Key? key, required this.notificationData})
      : super(
          key: key,
        );

  @override
  Widget build(BuildContext context) {
    final mediaQueryData = MediaQuery.sizeOf(context);
    return Card(
      child: Container(
        padding: EdgeInsets.all(10),
        // decoration: BoxDecoration(
        //     border: Border.all(color: Colors.black),
        //     borderRadius: BorderRadius.circular(5),
        //     color: Theme.of(context).colorScheme.secondaryContainer),
        child: Row(
          children: [
            Padding(
              padding: EdgeInsets.only(
                left: 13,
                top: 2,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: mediaQueryData.width * 0.7,
                    child: Text(
                      notificationData.message,
                    ),
                  ),
                  SizedBox(height: 3),
                  SizedBox(
                    width: mediaQueryData.width * 0.7,
                    child: Text(
                      notificationData.title,
                    ),
                  ),
                  SizedBox(height: 3),
                  Row(
                    children: [
                      Text(
                        DateFormat('d MMM').format(notificationData.sentTime!),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 11),
                        child: Text(
                          DateFormat('h:mm a')
                              .format(notificationData.sentTime!.toLocal()),
                          // DateFormat('HH:mm').format(notificationData.updatedAt!),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
