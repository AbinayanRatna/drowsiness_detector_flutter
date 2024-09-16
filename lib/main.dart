import 'package:flutter/material.dart';

import 'face_mesh_detector_view.dart';



Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Home(),
    );
  }
}

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Drowsiness app'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
            child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),onPressed: (){
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => FaceMeshDetectorView()));
            }, child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Start Driving",style: TextStyle(color: Colors.white,fontSize: 20),),
            ))
        ),
      ),
    );
  }
}

