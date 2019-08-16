import 'package:elec_mart_customer/components/secondary_button.dart';
import 'package:elec_mart_customer/constants/Colors.dart';
import 'package:flutter/material.dart';

class VendorDetail extends StatelessWidget {
  final String name, address;

  VendorDetail({this.name, this.address});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 10),
      child: Row(
        children: <Widget>[
          Image.asset(
            "assets/images/Vendor.png",
          ),
          Container(
            padding: EdgeInsets.only(left: 10),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  vendorText(name, primary: true),
                  Container(margin: EdgeInsets.only(top: 5)),
                  vendorText(address),
                  SizedBox(
                    width: MediaQuery.of(context).size.width - 125,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        SecondaryButton(
                          buttonText: "call",
                          onPressed: () {},
                          buttonHeight: 30,
                          buttonWidth: 75,
                        )
                      ],
                    ),
                  )
                ]),
          ),
        ],
      ),
    );
  }

  Widget vendorText(String text, {bool primary = false}) {
    return Text(
      "$text",
      style: TextStyle(
        fontSize: primary ? 18 : 12,
        fontWeight: FontWeight.bold,
        color: !primary ? LIGHT_BLACK_COLOR : null,
      ),
      textAlign: TextAlign.left,
    );
  }
}
