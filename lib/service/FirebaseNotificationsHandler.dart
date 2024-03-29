import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class FirebaseNotificationsHandler {
  final GraphQLClient graphQLClient;
  final String jwtToken;
  FirebaseMessaging firebaseMessaging;

  FirebaseNotificationsHandler({
    this.jwtToken,
    this.graphQLClient,
  }) {
    firebaseMessaging = FirebaseMessaging();

    firebaseMessaging.configure(onMessage: (message) async {
      print("RECEIVED NOTIFICATION: $message");
    });
    sendInitialTokenToServer();
  }
  sendTokenToServer(String token) {
    graphQLClient
        .mutate(MutationOptions(
      context: {
        'headers': <String, String>{
          'Authorization': 'Bearer $jwtToken',
        },
      },
      document: '''
      mutation {
        integrateFCMToken(fcmToken: "$token") {
          id 
          name
        }
      }
      ''',
    ))
        .then((onValue) {
      print('FCM MUTATION SUCCEEDED: Token sent to server: $token');
    }, onError: (error) {
      print(
          "FCM MUTATION SERVER RETURNED ERROR: $error while sending token $token");
    }).catchError((onError) {
      print(
          "FCM MUTATION FAILED: Got error $onError while sending token $token");
    });
  }

  sendInitialTokenToServer() async {
    sendTokenToServer(await firebaseMessaging.getToken());
    var onTokenRefresh = firebaseMessaging.onTokenRefresh;
    onTokenRefresh.listen((onData) {
      sendTokenToServer(onData);
    });
  }
}
