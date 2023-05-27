import 'package:flutter/material.dart';

class LaunchPage extends StatefulWidget {
  const LaunchPage({super.key});
  @override
  State<LaunchPage> createState() => _LaunchPageState();
}

class _LaunchPageState extends State<LaunchPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: Column(
          children: const [
            SizedBox(
              height: 160,
            ),
            Text(
              "欢迎使用-GPT",
              style: TextStyle(fontSize: 20),
            )
          ],
        ),
      ),
    );
  }
}
