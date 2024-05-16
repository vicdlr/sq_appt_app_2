import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:sq_notification/provider/home_provider.dart';
import 'package:sq_notification/view/home/add_booking.dart';
import 'package:sq_notification/view/home/form_page.dart';
import 'package:sq_notification/view/home/widget/search_dropdown.dart';

class RequestNewBooking extends StatefulWidget {
  const RequestNewBooking({super.key});

  @override
  State<RequestNewBooking> createState() => _RequestNewBookingState();
}

class _RequestNewBookingState extends State<RequestNewBooking> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final homeProvider = Provider.of<HomeProvider>(context, listen: false);
      homeProvider.getIndustriesList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final homeProvider = Provider.of<HomeProvider>(context, listen: true);
    return Scaffold(
      appBar: AppBar(
        title: Text("Request new booking"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: ListView(
          children: [
            Text("Select Industry"),
            SizedBox(
              height: 10,
            ),
            ListTile(
              onTap: () async {},
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                Radius.circular(10),
              )),
              tileColor: Theme.of(context).colorScheme.secondary,
              title: TestPage(
                dropDownList: homeProvider.industryList,
                hintText: homeProvider.selectedIndusty.isNotEmpty
                    ? homeProvider.selectedIndusty
                    : 'Industries',
                changedValue: (val) {
                  print("value of =  ${val.value}");
                  homeProvider.setSelectedList(val.name);
                },
              ),
              // title: TestPage(dropDownList: [], hintText: 'Country', changedValue: (val) {  },),
            ),
            SizedBox(
              height: 10,
            ),
            Text("Select Organisation"),
            SizedBox(
              height: 10,
            ),
            ListTile(
              onTap: () async {},
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                Radius.circular(10),
              )),
              tileColor: Theme.of(context).colorScheme.secondary,
              title: TestPage(
                dropDownList: homeProvider.companiesList,
                hintText: homeProvider.selectedCompanies.isNotEmpty
                    ? homeProvider.selectedCompanies
                    : 'Organisations',
                changedValue: (val) {
                  print("value of =  ${val.value}");
                  homeProvider.setCompaniesList(val.name);
                },
              ),
              // title: TestPage(dropDownList: [], hintText: 'Country', changedValue: (val) {  },),
            ),
            SizedBox(
              height: 10,
            ),
            Text("Select Department"),
            SizedBox(
              height: 10,
            ),
            ListTile(
              onTap: () async {},
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                Radius.circular(10),
              )),
              tileColor: Theme.of(context).colorScheme.secondary,
              title: TestPage(
                dropDownList: homeProvider.departmentList,
                hintText: homeProvider.selectedDepartment.isNotEmpty
                    ? homeProvider.selectedDepartment
                    : 'Departments',
                changedValue: (val) {
                  print("value of =  ${val.value}");
                  homeProvider.setDepartmentList(val.name);
                },
              ),
              // title: TestPage(dropDownList: [], hintText: 'Country', changedValue: (val) {  },),
            ),
            SizedBox(
              height: 10,
            ),
            Text("Select Group"),
            SizedBox(
              height: 10,
            ),
            ListTile(
              onTap: () async {},
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                Radius.circular(10),
              )),
              tileColor: Theme.of(context).colorScheme.secondary,
              title: TestPage(
                dropDownList: homeProvider.groupList,
                hintText: homeProvider.selectedGroup.isNotEmpty
                    ? homeProvider.selectedGroup
                    : 'Groups',
                changedValue: (val) {
                  print("value of =  ${val.value}");
                  homeProvider.setGroupList(val.name);
                },
              ),
              // title: TestPage(dropDownList: [], hintText: 'Country', changedValue: (val) {  },),
            ),
            SizedBox(
              height: 10,
            ),
            Text("Select Unit"),
            SizedBox(
              height: 10,
            ),
            ListTile(
              onTap: () async {},
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                Radius.circular(10),
              )),
              tileColor: Theme.of(context).colorScheme.secondary,
              title: TestPage(
                dropDownList: homeProvider.unitList,
                hintText: homeProvider.selectedUnit.isNotEmpty
                    ? homeProvider.selectedUnit
                    : 'Units',
                changedValue: (val) {
                  print("value of =  ${val.value}");
                  homeProvider.setUnitList(val.name);
                },
              ),
              // title: TestPage(dropDownList: [], hintText: 'Country', changedValue: (val) {  },),
            ),
            // SizedBox(
            //   height: 10,
            // ),
            // Text("Service type"),
            // SizedBox(
            //   height: 10,
            // ),
            // ListTile(
            //   onTap: () {
            //
            //   },
            //   shape: const RoundedRectangleBorder(
            //       borderRadius: BorderRadius.all(
            //         Radius.circular(10),
            //       )),
            //   tileColor: Theme.of(context).colorScheme.secondary,
            //   title: Text(
            //     "${homeProvider.serviceType}",
            //     style: Theme.of(context).textTheme.labelMedium,
            //   ),
            // ),
            SizedBox(
              height: 30,
            ),
            Container(
              margin: const EdgeInsets.all(8.0),
              child: ListTile(
                onTap: () async {
                  final provider = homeProvider;

                  if (provider.selectedIndusty.isEmpty ||
                      provider.selectedGroup.isEmpty ||
                      provider.selectedDepartment.isEmpty ||
                      provider.selectedCompanies.isEmpty) {
                    await Fluttertoast.showToast(
                        msg: "All fields are required");
                  } else {
                    if (provider.serviceType.toLowerCase() ==
                        "Appointment".toLowerCase()) {
                      Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => AddBooking()));
                    } else if (provider.serviceType.toLowerCase() ==
                        "Data Capture".toLowerCase()) {
                      Navigator.of(context)
                          .push(MaterialPageRoute(builder: (_) => FormPage()));
                    }
                  }
                },
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                  Radius.circular(10),
                )),
                tileColor: Theme.of(context).colorScheme.secondary,
                title: const SizedBox(
                  height: 30,
                  child: Center(
                    child: Text("Continue"),
                  ),
                ),

                // title: TestPage(dropDownList: [], hintText: 'Country', changedValue: (val) {  },),
              ),
            )
          ],
        ),
      ),

      // bottomSheet: ,
    );
  }
}
