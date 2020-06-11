import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_chat/constants.dart';
import 'package:flash_chat/screens/welcome_screen.dart';
import 'package:flutter/material.dart';

FirebaseUser currentUser;
Firestore _firestore = Firestore.instance;
FirebaseAuth _auth = FirebaseAuth.instance;

class ChatScreen extends StatefulWidget {
  static String id = "ChatScreen";
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String messageText;
  TextEditingController textEditingController = TextEditingController();
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
            MassagesListBuilder(),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: textEditingController,
                      onChanged: (value) {
                        messageText = value;
                        //Do something with the user input.
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  FlatButton(
                    onPressed: () async {
                      textEditingController.clear();
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

class MassagesListBuilder extends StatefulWidget {
  @override
  _State createState() => _State();
}

class _State extends State<MassagesListBuilder> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection("messsages").snapshots(),
      builder: (context, snapshat) {
        if (!snapshat.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        List<MassageBubble> messageBubbles = [];
        for (var document in snapshat.data.documents.reversed) {
          String messageText = document.data["text"];
          String messageSender = document.data["sender"];
          messageBubbles.add(MassageBubble(
            text: messageText,
            email: messageSender,
            isMe: messageSender == currentUser.email,
          ));
        }
        return Expanded(
          child: ListView(
            reverse: true,
            children: messageBubbles,
          ),
        );
      },
    );
  }
}

class MassageBubble extends StatelessWidget {
  final String text;
  final String email;
  final bool isMe;
  MassageBubble({this.text, this.email, this.isMe});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          isMe ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 10.0, left: 10.0),
          child: Text(
            email,
            style: TextStyle(
              color: Colors.black54,
              fontSize: 10.0,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 2.0, right: 10.0, bottom: 10.0),
          child: Material(
              borderRadius: isMe
                  ? BorderRadius.only(
                      topRight: Radius.circular(15),
                      bottomLeft: Radius.circular(15),
                      bottomRight: Radius.circular(15))
                  : BorderRadius.only(
                      topLeft: Radius.circular(15),
                      bottomLeft: Radius.circular(15),
                      bottomRight: Radius.circular(15)),
              elevation: 5.0,
              color: isMe ? Colors.white : Colors.lightBlue,
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  text,
                  style: TextStyle(
                    color: isMe ? Colors.black54 : Colors.white,
                    fontSize: 16.0,
                  ),
                ),
              )),
        ),
      ],
    );
  }
}
