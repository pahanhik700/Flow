import 'package:flutter/material.dart';

import '/src/back.dart';




class HelpPage extends StatefulWidget {
  const HelpPage({Key? key}) : super(key: key);

  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('О приложении'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Container(
                decoration: const BoxDecoration(
                    border: Border(
                        bottom: BorderSide(
                            color: Colors.grey,
                            width: 1.5
                        )
                    )
                ),
                child: const Text('Ваш идентификационный номер устройства:',
                style: TextStyle(fontSize: 18),),
              ),
            ),
            FutureBuilder(
              future: setUserId(),
              builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                return SelectableText(snapshot.data, style: const TextStyle(fontSize: 25),);
              },
            ),
          ],
        ),
      ),
    );
  }
}
