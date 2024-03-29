import 'package:elec_mart_customer/components/dialog_style.dart';
import 'package:elec_mart_customer/components/primary_button.dart';
import 'package:elec_mart_customer/components/secondary_button.dart';
import 'package:elec_mart_customer/components/text_field.dart';
import 'package:elec_mart_customer/constants/Colors.dart';
import 'package:elec_mart_customer/models/UserModel.dart';
import 'package:elec_mart_customer/screens/create_account.dart';
import 'package:elec_mart_customer/screens/nav_screens.dart';
import 'package:elec_mart_customer/screens/verify_phonenumber.dart';
import 'package:elec_mart_customer/service/FirebaseNotificationsHandler.dart';
import 'package:elec_mart_customer/state/app_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'graphql/customerLogin.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  Map input = {"phoneNumber": "", "password": ""};

  String errors = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/image.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: layout(),
      ),
    );
  }

  Widget layout() {
    return ListView(
      children: <Widget>[
        Container(
            padding: EdgeInsets.only(left: 24, right: 24, top: 50),
            child: Image.asset("assets/images/logo.png")),
        login(),
        SizedBox(height: 60),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 100),
          child: SecondaryButton(
            borderColor: WHITE_COLOR,
            textColor: WHITE_COLOR,
            buttonText: "Create Account",
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => CreateAccount()));
            },
          ),
        ),
        SizedBox(height: 10),
        InkWell(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => VerifyPhonenumber()));
            },
            child: Center(
                child: Text("Forgot Password ?",
                    style: TextStyle(color: WHITE_COLOR)))),
        SizedBox(height: 20),
      ],
    );
  }

  Widget login() {
    return Container(
      padding: EdgeInsets.only(left: 24, right: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 100),
          CustomTextField(
            color: WHITE_COLOR,
            maxLength: 10,
            isNumeric: true,
            labelText: "Phone Number",
            onChanged: (val) {
              setState(() {
                input["phoneNumber"] = val;
              });
            },
          ),
          SizedBox(height: 30),
          CustomTextField(
            color: WHITE_COLOR,
            labelText: "Password",
            onChanged: (val) {
              setState(() {
                input["password"] = val;
              });
            },
            isSecure: true,
          ),
          SizedBox(height: 20),
          if (input['phoneNumber'] != "" && input['password'] != "")
            mutationComponent()
          else
            Container(height: 50),
        ],
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
    );
  }

  Widget mutationComponent() {
    return Mutation(
      options: MutationOptions(
        document: customerLogin,
      ),
      builder: (
        RunMutation runMutation,
        QueryResult result,
      ) {
        return result.loading
            ? Align(
                alignment: Alignment.bottomCenter,
                child: CupertinoActivityIndicator())
            : Align(
                alignment: Alignment.bottomRight,
                child: PrimaryButtonWidget(
                  borderColor: WHITE_COLOR,
                  color: Colors.transparent,
                  buttonText: "Login",
                  onPressed: () {
                    runMutation({
                      "phoneNumber": input['phoneNumber'],
                      "password": input['password'],
                    });
                  },
                ));
      },
      update: (Cache cache, QueryResult result) {
        return cache;
      },
      onCompleted: (dynamic resultData) async {
        final prefs = await SharedPreferences.getInstance();
        final appState = Provider.of<AppState>(context);
        if (resultData['customerLogin']['error'] != null) {
          setState(() {
            errors = resultData['customerLogin']['error']['message'];
          });
          return showDialog(
              context: context,
              builder: (context) => DialogStyle(content: errors));
        }

        if (resultData != null &&
            resultData['customerLogin']['error'] == null) {
          final user = UserModel.fromJson(resultData['customerLogin']['user']);
          if (user != null) {
            final String token = resultData['customerLogin']['jwtToken'];

            await prefs.setString('token', token);
            await prefs.setString('name', user.name);
            await prefs.setString('phone number', user.phoneNumber);
            await prefs.setBool('address', true);
            appState.setToken(token);
            appState.setName(user.name);
            appState.setPhoneNumber(user.phoneNumber);
            handleNotify();

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => NavigateScreens()),
            );
          }
        }
      },
    );
  }

  handleNotify() {
    final appState = Provider.of<AppState>(context);

    final HttpLink httpLink = HttpLink(
      uri: 'http://cezhop.herokuapp.com/graphql',
    );
    var graphQlClient = GraphQLClient(
      cache: InMemoryCache(),
      link: httpLink as Link,
    );
    FirebaseNotificationsHandler(
        graphQLClient: graphQlClient, jwtToken: appState.jwtToken);
  }
}
