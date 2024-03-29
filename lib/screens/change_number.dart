import 'package:elec_mart_customer/components/app_title.dart';
import 'package:elec_mart_customer/components/dialog_style.dart';
import 'package:elec_mart_customer/components/primary_button.dart';
import 'package:elec_mart_customer/components/text_field.dart';
import 'package:elec_mart_customer/constants/Colors.dart';
import 'package:elec_mart_customer/models/UserModel.dart';
import 'package:elec_mart_customer/screens/nav_screens.dart';
import 'package:elec_mart_customer/state/app_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'graphql/customerValidate.dart';
import 'graphql/updateCustomerAddress.dart';
import 'otp.dart';

class ChangeNumber extends StatefulWidget {
  @override
  _ChangeNumber createState() => _ChangeNumber();
}

class _ChangeNumber extends State<ChangeNumber> {
  String newPhoneNumber = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: layout(),
    );
  }

  Widget layout() {
    return ListView(
      children: <Widget>[
        AppTitleWidget(),
        texts(),
        textFields(),
        mutationComponent(),
      ],
    );
  }

  Widget texts() {
    return Container(
      padding: EdgeInsets.all(24),
      child: Column(
        children: <Widget>[
          text("Change your Number", 30, PRIMARY_COLOR, false),
          text(
              "Enter your new phone number to use for login purposes. This will not be used for delivery.",
              14,
              BLACK_COLOR,
              false),
        ],
      ),
    );
  }

  Widget textFields() {
    return Container(
      padding: EdgeInsets.all(24),
      child: CustomTextField(
        isNumeric: true,
        maxLength: 10,
        labelText: "New Phone Number",
        onChanged: (val) {
          setState(() {
            newPhoneNumber = val;
          });
        },
      ),
    );
  }

  Widget text(String title, double size, Color color, bool isBold) {
    return Text(
      "$title",
      style: TextStyle(
          color: color,
          fontSize: size,
          fontWeight: isBold ? FontWeight.bold : null),
      textAlign: TextAlign.center,
    );
  }

  Widget validateMutation(RunMutation runmutation) {
    return Mutation(
      options: MutationOptions(
        document: customerValidate,
      ),
      builder: (
        RunMutation runMutation,
        QueryResult result,
      ) {
        if (result.loading) return Center(child: CupertinoActivityIndicator());
        return result.loading
            ? Center(child: CupertinoActivityIndicator())
            : Container(
                padding: EdgeInsets.all(24),
                child: PrimaryButtonWidget(
                    buttonText: "Continue",
                    onPressed: newPhoneNumber.length != 10
                        ? null
                        : () {
                            runMutation({"phoneNumber": newPhoneNumber});
                          }));
      },
      update: (Cache cache, QueryResult result) {
        return cache;
      },
      onCompleted: (dynamic resultData) async {
        if (resultData["validateCustomerArguments"]["phoneNumber"] == false) {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => OTPScreen(
                      phoneNumber: newPhoneNumber,
                      onOTPIncorrect: () {
                        print("SOMETHING WRONG HAPPENED!!!");
                      },
                      onOTPSuccess: () {
                        print('ON OTP SUCCESS HAS BEEN CALLED!!!');
                        runmutation({"phoneNumber": newPhoneNumber});
                      },
                    )),
          );
        } else {
          showDialog(
              context: context,
              builder: (context) =>
                  DialogStyle(content: "Phone Number already Existing"));
        }
      },
    );
  }

  Widget mutationComponent() {
    final appState = Provider.of<AppState>(context);
    return Mutation(
      options: MutationOptions(
        document: updateCustomerAddress,
        context: {
          'headers': <String, String>{
            'Authorization': 'Bearer ${appState.jwtToken}',
          },
        },
      ),
      builder: (
        RunMutation runMutation,
        QueryResult result,
      ) {
        return result.loading
            ? Center(child: CupertinoActivityIndicator())
            : validateMutation(runMutation);
      },
      update: (Cache cache, QueryResult result) {
        return cache;
      },
      onCompleted: (dynamic resultData) async {
        final prefs = await SharedPreferences.getInstance();
        final appState = Provider.of<AppState>(context);

        if (resultData != null &&
            resultData['updateCustomerAccount']['error'] == null) {
          final user =
              UserModel.fromJson(resultData['updateCustomerAccount']['user']);
          if (user != null) {
            await prefs.setString('phone number', user.phoneNumber);
            appState.setPhoneNumber(user.phoneNumber);
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => NavigateScreens(selectedIndex: 3)));
          }
        }
      },
    );
  }
}
