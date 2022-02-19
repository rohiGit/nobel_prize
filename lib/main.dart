import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:nobel_prize/model/NobelPrize.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nobel Prize',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  List<Prizes> prizeList = [];
  bool filtered = false;
  void _fetchData({String category = ""}) {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }
  void filterNobelPrize(String filter){
    if(filtered){
      setState(() {
        filtered = false;
      });
      return;
    }
    filtered = true;
    List<Prizes> newPrizeList = [];
    for(int i = 0; i < prizeList.length; i++){
      if(prizeList[i].category == filter){
        newPrizeList.add(prizeList[i]);
      }
    }
    setState(() {
      prizeList = newPrizeList;
    });
  }
  Future<List<Prizes>> getNobelPrize() async {
    var response = await http.get('http://api.nobelprize.org/v1/prize.json');
    late NobelPrize nobelPrize;
    if (response.statusCode == 200 && !filtered) {
      nobelPrize = NobelPrize.fromJson(jsonDecode(response.body));
      return prizeList = nobelPrize.prizes;
    }
    return prizeList;
  }
  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text("Nobel Prize Winners"),
        backgroundColor: Colors.black,
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(

        child: Column(
          children: [
            FutureBuilder(
                future: getNobelPrize(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Text("Loading...");
                  } else {
                    return ListView.builder(
                        physics: const ClampingScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: prizeList.length,
                        addAutomaticKeepAlives: true,
                        itemBuilder: (context, index) {
                          return Card(
                            elevation: 4.0,
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text("Year : " + prizeList[index].year.toString(), textScaleFactor: 1.5,),
                                  Text("Category : " +
                                      prizeList[index].category.toString(), textScaleFactor: 1.2,),
                                  ListView.builder(
                                      physics: const ClampingScrollPhysics(),
                                      shrinkWrap: true,
                                      itemCount: prizeList[index].laureates.length,
                                      itemBuilder: (context, idx) {
                                        List<Laureates> l =
                                            prizeList[index].laureates;
                                        return Card(
                                          elevation: 1.0,
                                          color: Colors.white70,
                                          child: Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.stretch,
                                              children: [
                                                Text("Id : " +
                                                    prizeList[index]
                                                        .laureates[idx]
                                                        .id
                                                        .toString(), style: TextStyle(color: Colors.black),),
                                                Text("Firstname : " +
                                                    prizeList[index]
                                                        .laureates[idx]
                                                        .firstname
                                                        .toString(), style: TextStyle(color: Colors.black),),
                                                Text("Surname : " +
                                                    prizeList[index]
                                                        .laureates[idx]
                                                        .surname
                                                        .toString(), style: TextStyle(color: Colors.black),),
                                                Text("Motivation : " +
                                                    prizeList[index]
                                                        .laureates[idx]
                                                        .motivation
                                                        .toString(), style: TextStyle(color: Colors.black),),
                                                Text("Share : " +
                                                    prizeList[index]
                                                        .laureates[idx]
                                                        .share
                                                        .toString(), style: TextStyle(color: Colors.black),)
                                              ],
                                            ),
                                          ),
                                        );
                                      })
                                ],
                              ),
                            ),
                          );
                        });
                  }
                }),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          filterNobelPrize("chemistry");
        },
        tooltip: 'Increment',
        child: const Icon(Icons.photo_filter_sharp),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
