import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DiaryApp(),
    );
  }
}

class DiaryApp extends StatefulWidget {
  @override
  _DiaryAppState createState() => _DiaryAppState();
}

class _DiaryAppState extends State<DiaryApp> {
  List<DiaryEntry> diaryEntries = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Diary App'),
      ),
      body: ListView.builder(
        itemCount: diaryEntries.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      ViewDiaryEntryPage(diaryEntries[index], index),
                ),
              );
            },
            child: Card(
              margin: EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (diaryEntries[index].image != null)
                    Image.memory(
                      diaryEntries[index].image!,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  SizedBox(height: 16),
                  Container(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Title: ${diaryEntries[index].title}',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Date: ${DateFormat.yMd().add_jm().format(diaryEntries[index].dateTime.toLocal())}',
                              style: TextStyle(fontSize: 14),
                            ),
                            PopupMenuButton(
                              onSelected: (value) {
                                if (value == 'edit') {
                                  _editDiaryEntry(context, index);
                                } else if (value == 'delete') {
                                  _deleteDiaryEntry(context, index);
                                }
                              },
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit),
                                      SizedBox(width: 8),
                                      Text('Edit'),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete),
                                      SizedBox(width: 8),
                                      Text('Delete'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              _addDiaryEntry(context);
            },
            child: Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  void _addDiaryEntry(BuildContext context) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddDiaryEntryPage(),
      ),
    );

    if (result != null) {
      setState(() {
        diaryEntries.add(result);
      });
    }
  }

  void _editDiaryEntry(BuildContext context, int index) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditDiaryEntryPage(diaryEntries[index]),
      ),
    );

    if (result != null) {
      setState(() {
        diaryEntries[index] = result;
      });
    }
  }

  void _deleteDiaryEntry(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this diary entry?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  diaryEntries.removeAt(index);
                  Navigator.of(context).pop();
                });
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}

class DiaryEntry {
  final String title;
  final String text;
  final Uint8List? image;
  final DateTime dateTime;

  DiaryEntry({
    required this.title,
    required this.text,
    required this.image,
    required this.dateTime,
  });
}

class AddDiaryEntryPage extends StatefulWidget {
  @override
  _AddDiaryEntryPageState createState() => _AddDiaryEntryPageState();
}

class _AddDiaryEntryPageState extends State<AddDiaryEntryPage> {
  final TextEditingController _titleEditingController = TextEditingController();
  final TextEditingController _textEditingController = TextEditingController();
  File? _imageFile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Diary Entry'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleEditingController,
              decoration: InputDecoration(labelText: 'Diary Title'),
            ),
            TextField(
              controller: _textEditingController,
              decoration: InputDecoration(labelText: 'Diary Text'),
            ),
            SizedBox(height: 16),
            _imageFile != null ? Image.file(_imageFile!) : SizedBox(),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _pickImage();
              },
              child: Text('Choose Image'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _saveDiaryEntry();
              },
              child: Text('Save Entry'),
            ),
          ],
        ),
      ),
    );
  }

  void _pickImage() async {
    final imagePicker = ImagePicker();
    final pickedImage =
        await imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _imageFile = File(pickedImage.path);
      });
    }
  }

  void _saveDiaryEntry() {
    if (_titleEditingController.text.isEmpty ||
        _textEditingController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Please enter diary title and text.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }

    final diaryEntry = DiaryEntry(
      title: _titleEditingController.text,
      text: _textEditingController.text,
      image: _imageFile != null ? _imageFile!.readAsBytesSync() : null,
      dateTime: DateTime.now(),
    );

    Navigator.of(context).pop(diaryEntry);
  }
}

class EditDiaryEntryPage extends StatefulWidget {
  final DiaryEntry entry;

  EditDiaryEntryPage(this.entry);

  @override
  _EditDiaryEntryPageState createState() => _EditDiaryEntryPageState();
}

class _EditDiaryEntryPageState extends State<EditDiaryEntryPage> {
  TextEditingController _titleController = TextEditingController();
  TextEditingController _textController = TextEditingController();
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.entry.title;
    _textController.text = widget.entry.text;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Diary Entry'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Diary Title'),
            ),
            TextField(
              controller: _textController,
              decoration: InputDecoration(labelText: 'Diary Text'),
            ),
            SizedBox(height: 16),
            _imageFile != null ? Image.file(_imageFile!) : SizedBox(),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _pickImage();
              },
              child: Text('Choose Image'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _saveChanges();
              },
              child: Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  void _pickImage() async {
    final imagePicker = ImagePicker();
    final pickedImage =
        await imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _imageFile = File(pickedImage.path);
      });
    }
  }

  void _saveChanges() {
    final editedEntry = DiaryEntry(
      title: _titleController.text,
      text: _textController.text,
      image: _imageFile != null
          ? _imageFile!.readAsBytesSync()
          : widget.entry.image,
      dateTime: widget.entry.dateTime,
    );

    Navigator.of(context).pop(editedEntry);
  }
}

class ViewDiaryEntryPage extends StatelessWidget {
  final DiaryEntry entry;
  final int index;

  ViewDiaryEntryPage(this.entry, this.index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Diary Entry'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (entry.image != null)
              Image.memory(
                entry.image!,
                height: 200,
                fit: BoxFit.cover,
              ),
            SizedBox(height: 16),
            Text(
              'Title: ${entry.title}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              entry.text,
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Date: ${DateFormat.yMd().add_jm().format(entry.dateTime.toLocal())}',
                  style: TextStyle(fontSize: 14),
                ),
                PopupMenuButton(
                  onSelected: (value) {
                    if (value == 'edit') {
                      _editDiaryEntry(context, index);
                    } else if (value == 'delete') {
                      _deleteDiaryEntry(context, index);
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete),
                          SizedBox(width: 8),
                          Text('Delete'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _editDiaryEntry(BuildContext context, int index) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditDiaryEntryPage(entry),
      ),
    );

    if (result != null) {
      Navigator.of(context).pop(result);
    }
  }

  void _deleteDiaryEntry(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this diary entry?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(index);
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
