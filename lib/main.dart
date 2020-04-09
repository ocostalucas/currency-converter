import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

const request =
    "https://api.hgbrasil.com/finance?format=json-cors&key=5337bbf4";

void main() async {
  print(await getData());

  runApp(MaterialApp(
    home: Home(),
    theme: ThemeData(
        hintColor: Colors.amber,
        primaryColor: Colors.white,
        inputDecorationTheme: InputDecorationTheme(
          enabledBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
          focusedBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
          hintStyle: TextStyle(color: Colors.amber),
        )),
  ));
}

Future<Map> getData() async {
  http.Response response = await http.get(request);
  return json.decode(response.body);
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final realController = TextEditingController();
  final dollarController = TextEditingController();
  final euroController = TextEditingController();

  double dollar;
  double euro;

  void _realChange(String text){
    if(text.isEmpty) {
      _clearAll();
      return;
    }

    double real = double.parse(text);
    dollarController.text =(real/dollar).toStringAsFixed(2);
    euroController.text = (real/euro).toStringAsFixed(2);
  }

  void _dollarChange(String text){
    if(text.isEmpty) {
      _clearAll();
      return;
    }

    double dollar = double.parse(text);
    realController.text =(dollar * this.dollar).toStringAsFixed(2);
    euroController.text = (dollar * this.dollar / euro).toStringAsFixed(2);
  }

  void _euroChange(String text){
    if(text.isEmpty) {
      _clearAll();
      return;
    }
    
    double euro = double.parse(text);
    realController.text =(euro * this.euro).toStringAsFixed(2);
    dollarController.text =(euro * this.euro / dollar).toStringAsFixed(2);
  }

  void _clearAll(){
    realController.text = "";
    dollarController.text = "";
    euroController.text = "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Text("\$ Converter \$"),
          backgroundColor: Colors.amber,
          centerTitle: true,
        ),
        body: FutureBuilder<Map>(
            future: getData(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.waiting:
                  return Center(
                      child: Text(
                    "Loading data...",
                    style: TextStyle(color: Colors.amber, fontSize: 25.0),
                    textAlign: TextAlign.center,
                  ));
                default:
                  if (snapshot.hasError) {
                    return Center(
                        child: Text("Error loading data :(",
                            style:
                                TextStyle(color: Colors.amber, fontSize: 25.0),
                            textAlign: TextAlign.center));
                  } else {
                    dollar =
                        snapshot.data["results"]["currencies"]["USD"]["buy"];
                    euro = snapshot.data["results"]["currencies"]["EUR"]["buy"];
                    return SingleChildScrollView(
                      padding: EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Icon(Icons.monetization_on,
                              size: 150.0, color: Colors.amber),
                          buidTextField("Real", "R\$ ", realController, _realChange),
                          Divider(),
                          buidTextField("Dollar", "US\$ ", dollarController, _dollarChange),
                          Divider(),
                          buidTextField("Euro", "€ ", euroController, _euroChange),
                        ],
                      ),
                    );
                  }
              }
            }));
  }
}

Widget buidTextField(String label, String prefix, TextEditingController controller, Function function) {
  return TextField(
    controller: controller,
    decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.amber),
        border: OutlineInputBorder(),
        prefixText: prefix),
    style: TextStyle(color: Colors.amber, fontSize: 25.0),
    onChanged: function,
    keyboardType: TextInputType.number,
  );
}
