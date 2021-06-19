import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hackathon/coins_page.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String address = "";

  @override
  void initState() {
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
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              child: buildAddressField(),
            ),
          ),
          SizedBox(height: spacingHeight),
          ElevatedButton(
            onPressed: () => buildPrint(context),
            child: const Text("Login"),
          ),
        ],
      ),
    );
  }

  void buildPrint(BuildContext context) {
    print(address);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CoinsPage(title: address)),
    );
  }

  TextField buildAddressField() {
    return TextField(
      keyboardType: TextInputType.text,
      // maxLines: null,
      maxLength: 48,
      textAlignVertical: TextAlignVertical.top,
      style: TextStyle(
        fontSize: 18,
      ),
      decoration: InputDecoration(
        hintText: 'Wallet Address',
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
