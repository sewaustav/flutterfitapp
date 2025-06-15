import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterfitapp/design/colors.dart';
import 'package:flutterfitapp/pages/other/methods.dart';

class OtherPage extends StatefulWidget {
  const OtherPage({super.key});

  @override
  State<OtherPage> createState() => _OtherPageState();
}

class _OtherPageState extends State<OtherPage> {

  late Weight weight;
  late Calc calc;

  @override
  void initState() {
    super.initState();
    calc = Calc();
    weight = Weight();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyColors.blue_color,
        title: Text('Fitapp', style:
        TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),),
      ),
    );
  }

}