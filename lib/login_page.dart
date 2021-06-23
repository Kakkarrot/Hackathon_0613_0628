import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hackathon/coins_page.dart';

import 'package:http/http.dart' as http;

import 'apiKeys/covalent.dart';


class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String address = "";
  String errorMessage = "";
  String loadingMessage = "";

  @override
  void initState() {
    errorMessage = "";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double spacingHeight = MediaQuery.of(context).size.height / 10;
    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: spacingHeight),
          SizedBox(height: spacingHeight),
          SizedBox(height: spacingHeight),
          Container(
            alignment: Alignment.center,
            child: Column(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: buildAddressField(),
                ),
                Text(
                  errorMessage,
                  style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: spacingHeight),
          ElevatedButton(
            onPressed: () => getAddressLogs(context),
            child: const Text("Login"),
          ),
          SizedBox(height: spacingHeight),
          Text(
            loadingMessage,
            style: TextStyle(
                color: Colors.blueAccent,
                fontWeight: FontWeight.bold
            ),
          ),
        ],
      ),
    );
  }
  
  void getAddressLogs(BuildContext context) async {
    changeLoadingText("Loading...");
    changeErrorMessage("");
    final response = await http.get(Uri.parse('https://api.covalenthq.com' +
        '/v1/250/address/' +
        address +
        '/transactions_v2/?block-signed-at-asc=true&quote-currency=USD&key=' +
        covalentApiNoPassword));
    if (response.statusCode == 200) {
      changeErrorMessage("");
      changeLoadingText("");
      print(response.body);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CoinsPage(title: address)),
      );
    } else {
      changeErrorMessage("Address Not Found");
      changeLoadingText("");
    }
  }

  void changeErrorMessage(String message){
    setState(() {
      errorMessage = message;
    });
  }

  void changeLoadingText(String message){
    setState(() {
      loadingMessage = message;
    });
  }

  TextField buildAddressField() {
    return TextField(
      keyboardType: TextInputType.text,
      // maxLines: null,
      maxLength: 60,
      textAlignVertical: TextAlignVertical.top,
      style: TextStyle(
        fontSize: 18,
      ),
      decoration: InputDecoration(
        hintText: 'Wallet Address (0x1a2b...)',
        contentPadding: EdgeInsets.symmetric(
          vertical: 8,
          horizontal: 5,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
        ),
      ),
      onChanged: (String input) {
        setState(() {
          input.isEmpty ? address = "" : address = input;
        });
      },
    );
  }
}
