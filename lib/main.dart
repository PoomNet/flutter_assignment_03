import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_assignment_03/addtodo.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
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
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Widget _buildTodoItem(BuildContext context, DocumentSnapshot document) {
    if (document['done'] == 0) {
      return ListTile(
        title: Text(document['title']),
        trailing: Checkbox(
          value: false,
          onChanged: (val) {
            Firestore.instance.runTransaction((transaction) async {
              DocumentSnapshot freshSnap =
                  await transaction.get(document.reference);
              await transaction.update(freshSnap.reference, {
                'done': 1,
              });
            });
          },
        ),
      );
    } else {
      return Column();
    }
  }

  @override
  Widget _buildDoneItem(BuildContext context, DocumentSnapshot document) {
    if (document['done'] == 1) {
      return ListTile(
        title: Text(document['title']),
        trailing: Checkbox(
          value: true,
          onChanged: (val) {
            Firestore.instance.runTransaction((transaction) async {
              DocumentSnapshot freshSnap =
                  await transaction.get(document.reference);
              await transaction.update(freshSnap.reference, {
                'done': 0,
              });
            });
          },
        ),
      );
    } else {
      return Column();
    }
  }

  void _addTodoItem() async {
    await Navigator.push(
        context, MaterialPageRoute(builder: (context) => AddTodoItemScreen()));
  }

  Future _deleteTodoItem() async {
    final QuerySnapshot result = await Firestore.instance.collection('todo').getDocuments();
    final List<DocumentSnapshot> documents = result.documents;
    for (var i=0 ; i<documents.length;i++){
      if(documents[i]['done']==1){
        Firestore.instance.collection('todo').document(documents[i].documentID).delete();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          bottomNavigationBar: Container(
            color: Colors.blue,
            child: TabBar(
              indicatorColor: Colors.white,
              tabs: <Widget>[
                Tab(
                  icon: Icon(Icons.format_list_bulleted),
                  text: "Task",
                ),
                Tab(
                  icon: Icon(Icons.done_all),
                  text: "Completed",
                ),
              ],
            ),
          ),
          body: TabBarView(
            children: <Widget>[
              new Scaffold(
                appBar: AppBar(
                  title: Text("Todo"),
                  actions: <Widget>[
                    new IconButton(
                      icon: new Icon(Icons.add),
                      color: Colors.white,
                      onPressed: _addTodoItem,
                    )
                  ],
                ),
                body: StreamBuilder(
                  stream:
                      Firestore.instance.collection('todo').snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData)
                      return Center(
                        child: Text(
                          "No Data Found..",
                          textAlign: TextAlign.center,
                        ),
                      );
                    int check = 0;
                    for (var i = 0; i < snapshot.data.documents.length; i++) {
                      if (snapshot.data.documents[i]['done'] == 0) {
                        check += 1;
                      }
                    }
                    if (check == 0) {
                      return Center(
                        child: Text(
                          "No Data Found..",
                          textAlign: TextAlign.center,
                        ),
                      );
                    } else {
                      return ListView.builder(
                        itemCount: snapshot.data.documents.length,
                        itemBuilder: (context, index) => _buildTodoItem(
                            context, snapshot.data.documents[index]),
                      );
                    }
                  },
                ),
              ),
              new Scaffold(
                appBar: AppBar(
                  title: Text("Todo"),
                  actions: <Widget>[
                    new IconButton(
                      icon: new Icon(Icons.delete),
                      color: Colors.white,
                      onPressed: _deleteTodoItem,
                    )
                  ],
                ),
                body: StreamBuilder(
                  stream:
                      Firestore.instance.collection('todo').snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData)
                      return Center(
                        child: Text(
                          "No Data Found..",
                          textAlign: TextAlign.center,
                        ),
                      );
                    int check2 = 0;
                    for (var i = 0; i < snapshot.data.documents.length; i++) {
                      if (snapshot.data.documents[i]['done'] == 1) {
                        check2 += 1;
                      }
                    }
                    if (check2 == 0) {
                      return Center(
                        child: Text(
                          "No Data Found..",
                          textAlign: TextAlign.center,
                        ),
                      );
                    } else {
                      return ListView.builder(
                        itemCount: snapshot.data.documents.length,
                        itemBuilder: (context, index) => _buildDoneItem(
                            context, snapshot.data.documents[index]),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ));
  }
}
