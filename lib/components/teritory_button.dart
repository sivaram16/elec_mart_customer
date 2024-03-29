import 'package:elec_mart_customer/constants/Colors.dart';
import 'package:flutter/material.dart';

class TeritoryButton extends StatelessWidget {
  final String text;
  final Function onpressed;

  TeritoryButton({this.text, this.onpressed});
  @override
  Widget build(BuildContext context) {
    return FlatButton(
      color: WHITE_COLOR,
      onPressed: onpressed,
      child: Text(
        "$text",
        style: TextStyle(
            fontSize: 16, fontWeight: FontWeight.bold, color: PRIMARY_COLOR),
      ),
    );
  }
}
