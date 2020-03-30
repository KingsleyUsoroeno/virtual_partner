import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dialogflow/v2/dialogflow_v2.dart';
import 'package:loading/indicator/ball_pulse_indicator.dart';
import 'package:loading/loading.dart';
import 'package:tikbot/bot.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ChatApp(),
    );
  }
}

class ChatApp extends StatefulWidget {
  @override
  _ChatAppState createState() => _ChatAppState();
}

class _ChatAppState extends State<ChatApp> {
  StreamController<Map> streamController;
  TextEditingController _msgController = TextEditingController();
  ScrollController _scrollController = ScrollController();
  _scrollToBottom() {
    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
  }

  var chatList = [];
  @override
  void initState() {
    super.initState();
    streamController = StreamController.broadcast();
    streamController.stream.listen((data) {
      // if (data["type"] == 'sender') print('sender');
      return setState(() {
        if (data["type"] == 'response') chatList.removeLast();
        return chatList.add(data);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    return Scaffold(
        backgroundColor: Color(0XFF252231),
        appBar: AppBar(
          backgroundColor: Color(0XFF252231),
          leading: Icon(Icons.arrow_back, color: Color(0XFF317DFE)),
          title: Text("Damola Adekoya"),
        ),
        body: SingleChildScrollView(
          child: Container(
            height: height,
            child: Column(
              children: <Widget>[
                Container(
                    height: height * 0.8,
                    width: width,
                    child: ListView.builder(
                        controller: _scrollController,
                        itemBuilder: (context, index) {
                          return _buildList(index);
                        })
                    // color: Colors.pinkAccent,
                    ),
                Container(
                  height: 50,
                  child: Row(children: <Widget>[
                    Container(
                        height: 80.0,
                        decoration: BoxDecoration(
                            color: Color(0XFF1E1B25),
                            borderRadius:
                                BorderRadius.all(Radius.circular(20.0))),
                        width: width * 0.83,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 15.0),
                          child: TextFormField(
                            style:
                                TextStyle(color: Colors.white, fontSize: 20.0),
                            decoration:
                                InputDecoration(border: InputBorder.none),
                            controller: _msgController,
                          ),
                        )),
                    // RaisedButton(
                    //     onPressed: () {
                    //       chat(_msgController.text);
                    //       _msgController.clear();
                    //     },
                    //     child: Text("Click Here")),
                    sendButton(onPressed: () {
                      chat(_msgController.text);
                      _msgController.clear();
                    })
                  ]),
                ),
              ],
            ),
          ),
        ));
  }

  Widget sendButton({Function onPressed}) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 70,
        width: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          // borderRadius: BorderRadius.all(Radius.circular(400)),
          color: Colors.blue,
        ),
        child: Center(
          child: Icon(
            Icons.send,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  chat(String query) async {
    streamController.sink.add({"type": "sender", "message": query});
    Future.delayed(Duration(milliseconds: 500), () {
      streamController.sink
          .add({"type": "loader", "message": "TikBot is typing..."});
    });
    AIResponse response = await Bot.sendMessage(query: query);
    streamController.sink
        .add({"type": "response", "message": response.getMessage()});
  }

  Widget _buildBotMessage({message, color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 6.0, bottom: 6.0),
          child: Container(
            width: 200.0,
            padding: EdgeInsets.all(10.0),
            decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.all(Radius.circular(5.0))),
            child: Text(
              message["message"],
              style: TextStyle(fontSize: 20.0, color: Colors.white),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 8.0),
          child: Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                    image: AssetImage('assets/images/bot.jpg'))),
          ),
        ),
      ],
    );
  }

  Widget _buildHumanMessage({message, color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 6.0, bottom: 6.0),
          child: Container(
            // width: 100.0,
            padding: EdgeInsets.all(10.0),
            decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.all(Radius.circular(5.0))),
            child: Text(
              message["message"],
              style: TextStyle(fontSize: 20.0, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildList(index) {
    if (index >= chatList.length) return null;
    var currMessage = chatList[index];
    if (currMessage['type'] == 'sender') {
      return _buildHumanMessage(message: currMessage, color: Color(0XFF333145));
    } else if (currMessage['type'] == 'response') {
      return _buildBotMessage(message: currMessage, color: Color(0XFF1F5DFC));
    } else {
      return Column(
        children: <Widget>[
          Loading(
              indicator: BallPulseIndicator(), size: 20.0, color: Colors.pink),
          Text(
            currMessage["message"],
            style: TextStyle(color: Colors.white),
          ),
        ],
      );
    }
  }
}

class ChatWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Row(
      children: <Widget>[
        TextField(),
        // RaisedButton(
        //     onPressed: () {
        //       //Bot.sendMessage(query: "Hello");
        //     },
        //     child: Text("Click Here")),
      ],
    );
  }
}

class MessageCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
