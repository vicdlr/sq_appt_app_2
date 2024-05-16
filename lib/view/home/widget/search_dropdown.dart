import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/material.dart';


Future<void> dialogBuilder(BuildContext context) async{
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Basic dialog title'),
        content: TestPage(dropDownList: const [
          DropDownValueModel(name: 'name1', value: "value1"),
          DropDownValueModel(
              name: 'name2',
              value: "value2",),
          DropDownValueModel(name: 'name3', value: "value3"),
          DropDownValueModel(
              name: 'name4',
              value: "value4",
              toolTipMsg:
              "DropDownButton is a widget that we can use to select one unique value from a set of values"),
          DropDownValueModel(name: 'name5', value: "value5"),
          DropDownValueModel(name: 'name6', value: "value6"),
          DropDownValueModel(name: 'name7', value: "value7"),
          DropDownValueModel(name: 'name8', value: "value8"),
        ], hintText: 'Country', changedValue: (val) {  },),
        actions: <Widget>[
          TextButton(
            style: TextButton.styleFrom(
              textStyle: Theme.of(context).textTheme.labelLarge,
            ),
            child: const Text('Disable'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            style: TextButton.styleFrom(
              textStyle: Theme.of(context).textTheme.labelLarge,
            ),
            child: const Text('Enable'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  ).then((value) {

  });
}




class TestPage extends StatefulWidget {

  List<DropDownValueModel> dropDownList ;
  String hintText;
   Function(dynamic val) changedValue;
   TestPage({ required this.dropDownList, required this.hintText, required this.changedValue, Key? key}) : super(key: key);

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  FocusNode searchFocusNode = FocusNode();
  FocusNode textFieldFocusNode = FocusNode();
  late SingleValueDropDownController _cnt;

  @override
  void initState() {
    _cnt = SingleValueDropDownController();
    super.initState();
  }

  @override
  void dispose() {
    _cnt.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return  DropDownTextField(
      clearOption: false,
      padding: EdgeInsets.zero,
      textFieldFocusNode: textFieldFocusNode,
      searchFocusNode: searchFocusNode,
      dropDownItemCount: 4,


      textFieldDecoration:  InputDecoration(
        contentPadding: EdgeInsets.all(0),
        floatingLabelAlignment: FloatingLabelAlignment.center,
        hintText: widget.hintText,
        hintStyle: Theme.of(context).textTheme.labelMedium,
        focusedBorder: OutlineInputBorder(
          gapPadding: 0,
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide.none,
        ),
        enabledBorder:  OutlineInputBorder(
          gapPadding: 0,
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide.none,
        ),
      ),
      enableSearch: true,
      searchKeyboardType: TextInputType.text,
      dropDownList: widget.dropDownList,
      onChanged: widget.changedValue,
    );
  }
  
}






