import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';
import 'package:whatsup/tile.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  get uid {
    return FirebaseAuth.instance.currentUser!.uid;
  }

  @override
  void initState() {
    FirebaseMessaging.instance.requestPermission();
    FirebaseMessaging.instance.getInitialMessage().then((msg) {
      print("onlaunch ..$msg");
    });
    FirebaseMessaging.onMessage.listen((msg) {
      print("onmessage ..$msg");
    });
    FirebaseMessaging.onMessageOpenedApp.listen((msg) {
      print("onmessageOpened ..$msg");
    });

    super.initState();
    initData();
  }

  void initData() async {
    WidgetsFlutterBinding.ensureInitialized();
    final keyApplicationId = 'xrf2IMv6Rusf2diR9ju4tl3aXfdfkuqYwhxR868i';
    final keyClientKey = 'xPlBhU7rzfnZwdWaSY27Ol2u7byIqLV4OY9gxXCc';
    final keyParseServerUrl = 'https://parseapi.back4app.com';

    await Parse().initialize(keyApplicationId, keyParseServerUrl,
        clientKey: keyClientKey, autoSendSessionId: true);
    var firstObject = ParseObject('FirstClass')
      ..set('message',
          'Hey ! First message from Flutter. Parse is now connected');
    await firstObject.save();

    print('done');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("What`s Up"),
        actions: [
          DropdownButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            items: [
              DropdownMenuItem(
                child: Row(
                  children: const [
                    Icon(
                      Icons.exit_to_app,
                      color: Colors.black,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text("Logout")
                  ],
                ),
                value: "logout",
              ),
            ],
            onChanged: (itemIdentifier) {
              if (itemIdentifier == "logout") {
                FirebaseAuth.instance.signOut();
              }
            },
          )
        ],
      ),
      body: StreamBuilder(
          stream: FirebaseFirestore.instance.collection("users").snapshots(),
          builder: (context, AsyncSnapshot<dynamic> streamSnapshot) {
            if (streamSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            final documents = streamSnapshot.data.docs;
            return ListView.builder(
              itemBuilder: (context, index) {
                print(documents[index].id);
                if (documents[index].id != uid) {
                  return Tile(
                    username: documents[index]["username"],
                    receiverId: documents[index].id,
                    imageUrl: documents[index]["imageUrl"],
                  );
                }
                return const SizedBox(
                  height: 0,
                );
              },
              itemCount: documents.length,
            );
          }),
    );
  }
}
