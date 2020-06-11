import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_chat/constants.dart';
import 'package:flash_chat/screens/welcome_screen.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  static String id = "ChatScreen";
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  Firestore _firestore = Firestore.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseUser currentUser;
  String messageText;
  void getuserInfo() async {
    try {
      currentUser = await _auth.currentUser();
      if (currentUser != null) {
        print(currentUser.email);
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    getuserInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                _auth.signOut();
                Navigator.pushNamed(context, WelcomeScreen.id);
                //Implement logout functionality
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection("messsages").snapshots(),
              builder: (context, snapshat) {
                if (!snapshat.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                List<MassageBubble> messageBubbles = [];
                for (var document in snapshat.data.documents) {
                  String messageText = document.data["text"];
                  String messageSender = document.data["sender"];
                  messageBubbles.add(MassageBubble(
                    text: messageText,
                    email: messageSender,
                  ));
                }
                return Expanded(
                  child: ListView(
                    children: messageBubbles,
                  ),
                );
              },
            ),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      onChanged: (value) {
                        messageText = value;
                        //Do something with the user input.
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  FlatButton(
                    onPressed: () async {
                      await _firestore.collection("messsages").add(
                          {"text": messageText, "sender": currentUser.email});
                      //Implement send functionality.
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MassageBubble extends StatelessWidget {
  final String text;
  final String email;
  MassageBubble({this.text, this.email});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Text(
            email,
            style: TextStyle(
              color: Colors.black54,
              fontSize: 15.0,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 2.0, right: 10.0, bottom: 10.0),
          child: Material(
              borderRadius: BorderRadius.circular(20.0),
              elevation: 5.0,
              color: Colors.lightBlue,
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  text,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                  ),
                ),
              )),
        ),
      ],
    );
  }
}
