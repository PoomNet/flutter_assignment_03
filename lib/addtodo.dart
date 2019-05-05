import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddTodoItemScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _AddTodoItemScreenState();
}

class _AddTodoItemScreenState extends State<AddTodoItemScreen> {
  final _todoNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("New Subject")),
        body: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextFormField(
                  decoration: InputDecoration(labelText: "Subject"),
                  controller: _todoNameController,
                  validator: (value) {
                    if (value.isEmpty) {
                      return "Please fill subject";
                    }
                  },
                  onSaved: (value) => print(value),
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                        child: RaisedButton(
                            child: Text("Save"),
                            onPressed: () {
                              if(_formKey.currentState.validate()){
                              Firestore.instance.runTransaction(
                                  (Transaction transaction) async {
                                CollectionReference reference =
                                    Firestore.instance.collection('todo');

                                await reference.add({
                                  "title": _todoNameController.text,
                                  "done": 0
                                });
                                _todoNameController.clear();
                              });
                              Navigator.pop(context);
                              }
                            }))
                  ],
                )
              ],
            )));
  }

  @override
  void dispose() {
    _todoNameController.dispose();
    super.dispose();
  }
}
