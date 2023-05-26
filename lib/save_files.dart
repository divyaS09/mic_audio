// // import 'package:flutter/material.dart';

// // void main() {
// //   runApp(MaterialApp());
// // }
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'File Storage',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: MyHomePage(title: 'File Storage'),
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   MyHomePage({Key? key, required this.title}) : super(key: key);

//   final String title;

//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   TextEditingController _fileNameController = TextEditingController();
//   TextEditingController _contentController = TextEditingController();
//   List<String> _fileList = []; // List to store file names

//   Future<void> _saveFile() async {
//     if (await Permission.storage.request().isGranted) {
//       Directory? appDirectory = await getExternalStorageDirectory();
//       String filePath = appDirectory!.path + '/' + _fileNameController.text;

//       File file = File(filePath);
//       await file.writeAsString(_contentController.text);

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('File saved successfully.')),
//       );
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Permission denied.')),
//       );
//     }
//   }

//   Future<void> _listFiles() async {
//     Directory? appDirectory = await getExternalStorageDirectory();
//     List<FileSystemEntity> files = Directory(appDirectory!.path).listSync();

//     setState(() {
//       _fileList = files.map((file) => file.path).toList();
//     });
//   }

//   Future<void> _deleteFile(String filePath) async {
//     try {
//       await File(filePath).delete();
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('File deleted successfully.')),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to delete file.')),
//       );
//     }
//   }

//   Future<void> _viewFileContent(String filePath) async {
//     String fileContent = await File(filePath).readAsString();

//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('File Content'),
//           content: Text(fileContent),
//           actions: <Widget>[
//             TextButton(
//               child: Text('Close'),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.title),
//       ),
//       body: Center(
//         child: Padding(
//           padding: EdgeInsets.all(20.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: <Widget>[
//               TextField(
//                 controller: _fileNameController,
//                 decoration: InputDecoration(
//                   labelText: 'File Name',
//                 ),
//               ),
//               SizedBox(height: 20.0),
//               TextField(
//                 controller: _contentController,
//                 decoration: InputDecoration(
//                   labelText: 'File Content',
//                 ),
//               ),
//               SizedBox(height: 20.0),
//               ElevatedButton(
//                 onPressed: _saveFile,
//                 child: Text('Save File'),
//               ),
//               SizedBox(height: 20.0),
//               ElevatedButton(
//                 onPressed: _listFiles,
//                 child: Text('List Files'),
//               ),
//               SizedBox(height: 20.0),
//               Expanded(
//                 child: ListView.builder(
//                   itemCount: _fileList.length,
//                   itemBuilder: (context, index) {
//                     return ListTile(
//                       title: Text(_fileList[index]),
//                       trailing: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           IconButton(
//                             icon: Icon(Icons.delete),
//                             onPressed: () => _deleteFile(_fileList[index]),
//                           ),
//                           IconButton(
//                             icon: Icon(Icons.visibility),
//                             onPressed: () => _viewFileContent(_fileList[index]),
//                           ),
//                         ],
//                       ),
//                     );
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }