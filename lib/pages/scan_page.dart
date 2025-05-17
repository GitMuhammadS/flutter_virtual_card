import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:virtual_card_app/utils/constants.dart';

import '../models/contact_model.dart';
import 'form_page.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});
  static const String routeName = 'scan';

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  bool isScanOver=false;
  List<String> lines=[];
  String name='',mobile='',email='',address='',company='',designation='',website='',image='';

  void createContact(){
    final contact=ContactModel(
      name: name,
      mobile: mobile,
      email: email,
      address: address,
      company: company,
      designation: designation,
      website: website,
      image: image,
    );
    context.goNamed(FormPage.routeName,extra: contact);

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan page',style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.blue,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
              onPressed: image.isEmpty ? null : createContact,
              icon: const Icon(Icons.forward,color: Colors.white,),
          ),
        ],
      ),
      body: ListView(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton.icon(
                  onPressed: (){
                    getImage(ImageSource.camera);
                  },
                  label: const Text('Capture'),
                  icon: const Icon(Icons.camera)
              ),
              TextButton.icon(
                  onPressed: (){
                    getImage(ImageSource.gallery);
                  },
                  label: const Text('Gallery'),
                  icon: const Icon(Icons.photo_album)
              )
            ],
          ),
          if(isScanOver) Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  DropTargetItem(
                      property: ContactProperties.name,
                      onDrop: getPropertyValue,
                  ),
                  DropTargetItem(
                    property: ContactProperties.mobile,
                    onDrop: getPropertyValue,
                  ),
                  DropTargetItem(
                    property: ContactProperties.email,
                    onDrop: getPropertyValue,
                  ),
                  DropTargetItem(
                    property: ContactProperties.company,
                    onDrop: getPropertyValue,
                  ),
                  DropTargetItem(
                    property: ContactProperties.designation,
                    onDrop: getPropertyValue,
                  ),
                  DropTargetItem(
                    property: ContactProperties.address,
                    onDrop: getPropertyValue,
                  ),
                  DropTargetItem(
                    property: ContactProperties.website,
                    onDrop: getPropertyValue,
                  ),
                ],
              ),
            ),
          ),
          if(isScanOver)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(hint),
            ),
          Wrap(
            children:lines.map((line)=> LineItem(line:line)).toList(),
          )
        ],
      ),
    );
  }

  void getImage(ImageSource camera) async{
    final xFile= await ImagePicker().pickImage(source: camera);
    if(xFile !=null){
      setState(() {
        image=xFile.path;
      });
      EasyLoading.show(
        status: 'Plz wait'
      );
      final textRecognizer=TextRecognizer(script: TextRecognitionScript.latin);
      final recognizedText= await textRecognizer.processImage(InputImage.fromFile(File(xFile.path)));
      EasyLoading.dismiss();
      final tempList=<String>[];
      for(var block in recognizedText.blocks){
        for(var line in block.lines){
          tempList.add(line.text);
        }
      }
      setState(() {
        lines=tempList;
        isScanOver=true;
      });
    }
  }

  getPropertyValue(String property, String value) {
      switch(property){
        case ContactProperties.name:
          name=value;
          break;

        case ContactProperties.mobile:
          mobile=value;
          break;

        case ContactProperties.email:
          email=value;
          break;

        case ContactProperties.company:
          company=value;
          break;

        case ContactProperties.designation:
          designation=value;
          break;

        case ContactProperties.address:
          address=value;
          break;

        case ContactProperties.website:
          website=value;
          break;
      }
  }
}

class LineItem extends StatelessWidget {
  const LineItem({super.key,required this.line});
  final String line;

  @override
  Widget build(BuildContext context) {
    return LongPressDraggable(
        data: line,
        dragAnchorStrategy: childDragAnchorStrategy,
        feedback: Container(
          key: GlobalKey(),
          padding: const EdgeInsets.all(8.0),
          decoration: const BoxDecoration(
            color: Colors.black54
          ),
          child: Text(line,style: Theme.of(context).textTheme.titleMedium!.copyWith(color: Colors.white),),
        ),
        child: Chip(label: Text(line)),
    );
  }
}

class DropTargetItem extends StatefulWidget {
  final String property;
  final Function(String,String) onDrop;
  const DropTargetItem({super.key,required this.property,required this.onDrop});

  @override
  State<DropTargetItem> createState() => _DropTargetItemState();
}

class _DropTargetItemState extends State<DropTargetItem> {
  String dragItem='';
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Text(widget.property),
        ),
        Expanded(
          flex: 2,
          child: DragTarget<String>(
              builder: (context,candidateDate,rejectedData) => Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  border: candidateDate.isNotEmpty?Border.all(color: Colors.red,width: 2):null,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(dragItem.isEmpty?'Drop here':dragItem),
                    ),
                    if(dragItem.isNotEmpty) InkWell(
                      onTap: (){
                        setState(() {
                          dragItem='';
                        });
                      },
                      child: const Icon(Icons.clear,size: 15,),
                    )
                  ],
                ),
              ),
            onAcceptWithDetails: (value){
                setState(() {
                  if(dragItem.isEmpty){
                    dragItem=value as String;
                  }else{
                    dragItem+=value as String;
                  }
                });
                widget.onDrop(widget.property,dragItem);
            },
          ),
        )
      ],
    );
  }
}

