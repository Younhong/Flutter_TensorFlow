import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isLoading;
  File _image;
  List _output;

  void initState() {
    super.initState();
    _isLoading = true;
    loadModel().then((value) {
      setState(() {
        _isLoading = false;
      });
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Tensorflow with flutter"),
      ),
      body: _isLoading
          ? Container(
            alignment: Alignment.center,
            child: CircularProgressIndicator()
          )
          : Container(
        child: Column(
          children: <Widget>[
            _image == null
                ? Container()
                : Image.file(_image),
            SizedBox(height: 16),
            _output == null
                ? Text("")
                : Text(_output[0]["label"])
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.image
        ),
        onPressed: () {
          chooseImage();
        },
      ),
    );
  }

  loadModel() async {
    await Tflite.loadModel(
      model: "assets/model_unquant.tflite",
      labels: "assets/labels.txt"
    );
  }

  chooseImage() async {
    File image = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (image == null) return null;
    setState(() {
      _isLoading = true;
      _image = image;
    });

    runModel(image);
  }
  
  runModel(File image) async {
    var output = await Tflite.runModelOnImage(
        path: image.path,
        numResults: 3,
        imageMean: 127.5,
        imageStd: 127.5,
        threshold: 0.5
    );
    setState(() {
      _isLoading = false;
      _output = output;
    });
  }
}