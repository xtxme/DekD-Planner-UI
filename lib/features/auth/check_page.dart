import 'package:flutter/material.dart';

class CheckPage extends StatefulWidget{
  const CheckPage ({super.key});

  @override
  State<CheckPage> createState() => _CheckPageState();
}

class _CheckPageState extends State<CheckPage>{
  @override
  Widget build(BuildContext context) {
    backgroundColor: const Color(0xFFFBFAF9);
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
              ),
            );
          }
        ),
      ),
    );
  }
}