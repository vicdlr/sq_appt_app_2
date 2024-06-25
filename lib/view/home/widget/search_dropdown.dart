import 'package:dropdown_button2/dropdown_button2.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../widget/CustomTextFormField.dart';


// Future<void> dialogBuilder(BuildContext context) async{
//   return showDialog<void>(
//     context: context,
//     builder: (BuildContext context) {
//       return AlertDialog(
//         title: const Text('Basic dialog title'),
//         content: CustomDropDown(dropDownList: const [
//           DropDownValueModel(name: 'name1', value: "value1"),
//           DropDownValueModel(
//               name: 'name2',
//               value: "value2",),
//           DropDownValueModel(name: 'name3', value: "value3"),
//           DropDownValueModel(
//               name: 'name4',
//               value: "value4",
//               toolTipMsg:
//               "DropDownButton is a widget that we can use to select one unique value from a set of values"),
//           DropDownValueModel(name: 'name5', value: "value5"),
//           DropDownValueModel(name: 'name6', value: "value6"),
//           DropDownValueModel(name: 'name7', value: "value7"),
//           DropDownValueModel(name: 'name8', value: "value8"),
//         ], hintText: 'Country', changedValue: (val) {  },),
//         actions: <Widget>[
//           TextButton(
//             style: TextButton.styleFrom(
//               textStyle: Theme.of(context).textTheme.labelLarge,
//             ),
//             child: const Text('Disable'),
//             onPressed: () {
//               Navigator.of(context).pop();
//             },
//           ),
//           TextButton(
//             style: TextButton.styleFrom(
//               textStyle: Theme.of(context).textTheme.labelLarge,
//             ),
//             child: const Text('Enable'),
//             onPressed: () {
//               Navigator.of(context).pop();
//             },
//           ),
//         ],
//       );
//     },
//   ).then((value) {
//
//   });
// }




class CustomDropDown extends StatefulWidget {

  List<String> dropDownList ;
  String hintText;
  String selectedValue;
  // TextEditingController controller;
   Function(dynamic val) changedValue;
   CustomDropDown({
     // required this.controller,
     required this.selectedValue,
     required this.dropDownList, required this.hintText, required this.changedValue, Key? key}) : super(key: key);

  @override
  State<CustomDropDown> createState() => _CustomDropDownState();
}

class _CustomDropDownState extends State<CustomDropDown> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  FocusNode searchFocusNode = FocusNode();
  FocusNode textFieldFocusNode = FocusNode();


  @override
  void initState() {

    super.initState();
  }

  @override
  void dispose() {


    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return  DropdownButtonHideUnderline(
      child: DropdownButton2<String>(

        hint: Text(
          '${widget.hintText}',
          style: Theme.of(context).textTheme.labelMedium,
        ),
        items: widget.dropDownList
            .map((item) => DropdownMenuItem(
          value: item,
          child: Text(
            item,
            style:  TextStyle(
              color: Colors.black
            ),
          ),
        ))
            .toList(),
        // value: widget.selectedValue,
        onChanged: widget.changedValue,
        buttonStyleData: const ButtonStyleData(

          padding: EdgeInsets.symmetric(horizontal: 16),
          height: 40,
          width: 200,
        ),
        dropdownStyleData: const  DropdownStyleData(
          decoration: BoxDecoration(
              color: Colors.white
          ),
          maxHeight: 200,
        ),
        menuItemStyleData: const MenuItemStyleData(

          height: 40,
        ),

      ),
    );
  }
  
}






