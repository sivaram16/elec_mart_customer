import 'package:elec_mart_customer/components/primary_button.dart';
import 'package:elec_mart_customer/constants/Colors.dart';
import 'package:flutter/material.dart';

class DialogStyle extends StatelessWidget {
  final String content;
  final String title;

  DialogStyle({this.title='Error Occured', this.content});
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Center(
        child: Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: PRIMARY_COLOR,
          ),
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            content == null ? "" : content.split("_").join(" ").toLowerCase(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: BLACK_COLOR,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 32.0),
            child: PrimaryButtonWidget(
              buttonText: 'Got it',
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          )
        ],
      ),
    );
  }
}
