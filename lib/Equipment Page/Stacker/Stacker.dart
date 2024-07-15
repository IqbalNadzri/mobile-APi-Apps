import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:haulage_driver/Equipment%20Page/Stacker/submit.dart';
import 'package:haulage_driver/Widget/Navbar.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class StackerPage extends StatefulWidget {
  const StackerPage({
    Key? key,
    this.fullname,
    this.role,
    this.branch,
    this.equipment_category,
    this.equipment_name,
    this.user_id,
    this.equipment_no,
    this.date,
    this.division,
    this.checklist_serial,
    this.odometer,
  }) : super(key: key);

  final String? fullname;
  final String? role;
  final String? branch;
  final String? equipment_category;
  final String? equipment_name;

  final int? user_id;
  final String? equipment_no;
  final String? date;
  final String? division;
  final String? checklist_serial;
  final String? odometer;

  @override
  State<StackerPage> createState() => _StackerPageState();
}

class _StackerPageState extends State<StackerPage> {
  List<File?> _imageFileList = [];
  List<bool> isCheckedGoodList = [];
  List<bool> isCheckedBadList = [];
  List<String> remarkList = [];
  bool isSubmitEnabled = false;
  var token;
  var checkbody;
  var jsonReturn;
  List<dynamic> field_names = [];
  List<dynamic> field_names_display = [];

  final storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> postChecklistImage() async {
    Map<String, String> headers = {
      'Content-Type': 'multipart/form-data',
      'Accept': 'application/json',
    };

    for (int i = 0; i < _imageFileList.length; i++) {
      if (_imageFileList[i] != null) {
        var uri = Uri.parse('');
        var request = http.MultipartRequest('POST', uri);
        request.headers.addAll(headers);
        request.fields['checklist_id'] = widget.checklist_serial ?? '';
        request.fields['field_name'] = field_names[i];

        final fileStream = http.ByteStream(_imageFileList[i]!.openRead());
        final fileLength = await _imageFileList[i]!.length();
        final multipartFile = http.MultipartFile(
          'image',
          fileStream,
          fileLength,
          filename: '${field_names[i]}.jpg',
        );

        request.files.add(multipartFile);

        var response = await request.send();
        if (response.statusCode == 200) {
          print('Image for ${field_names[i]} uploaded successfully');
        } else {
          print('Image upload for ${field_names[i]} failed with status: ${response.statusCode}');
        }
      }
    }
  }

  void validateSubmitButton() {
    bool allChecked = true;
    for (int i = 0; i < field_names_display.length ; i++) {
      if (!isCheckedGoodList[i] && !isCheckedBadList[i]) {
        allChecked = false;
        break;
      }
    }
    setState(() {
      isSubmitEnabled = allChecked;
    });
  }


  Future<void> getChecklistImage(String fieldName, int index) async {
    final uri = Uri.http(
        '', {
      'equipment': widget.equipment_name,
      'equipment_category': widget.equipment_category,
      'image_name': '$fieldName.jpg',
    });

    try {
      http.Response response = await http.get(uri);

      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        final tempDir = await getTemporaryDirectory();
        final file = await File('${tempDir.path}/$fieldName.jpg')
            .writeAsBytes(bytes);

        setState(() {
          _imageFileList[index] = file;
        });
      } else {
        print('Failed to fetch image. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching image: $error');
    }
  }

  Future<void> fetchData() async {
    final uri = Uri.http('', {
      'equipment_name': widget.equipment_name,
      'equipment_category': widget.equipment_category,
      'division': widget.division,
      'branch': widget.branch,
    });

    try {
      http.Response response = await http.get(uri);

      if (response.statusCode == 200) {
        final jsonfield_name = jsonDecode(response.body);
        setState(() {
          field_names = jsonfield_name['field_name'];
          field_names_display = jsonfield_name['field_name_display'];
          isCheckedGoodList = List.generate(field_names_display.length, (index) => false);
          isCheckedBadList = List.generate(field_names_display.length, (index) => false);
          remarkList = List.generate(field_names_display.length, (index) => 'No Remarks');
          _imageFileList = List.generate(field_names_display.length, (index) => null);
        });

        for (int i = 0; i < field_names_display.length; i++) {
          await getChecklistImage(field_names[i], i);
        }
      } else {
        print('Failed to fetch data. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching data: $error');
    }
  }

  Widget _remark(int index) {
    if (isCheckedGoodList[index]) {
      remarkList[index] = 'No Remarks';
      return const SizedBox.shrink(); // Return an empty SizedBox
    } else if (isCheckedBadList[index]) {
      return Column(
        children: [
          TextFormField(
            controller: TextEditingController(text: remarkList[index]),
            decoration: const InputDecoration(
              labelText: 'Remark',
            ),
            onChanged: (value) {
              remarkList[index] = value;
            },
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () => _takePhotoForIndex(index),
            child: const Text('Take Photo'),
          ),
        ],
      );
    } else {
      return const Text('No Checklist Checked');
    }
  }

  Future<void> _takePhotoForIndex(int index) async {
    if (isCheckedBadList[index]) {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        setState(() {
          _imageFileList[index] = File(pickedFile.path);
        });
      }
    }
  }

  Future<void> addChecklistData(String? equipment_no, String? checklist_serial, String status, String? date, List field_names, List remarkList, String? odometer) async {
    try {
      String url = '';

      for (int i = 0; i < field_names.length; i++) {
        var data = {
          'equipment_no': equipment_no,
          'checklist_serial': checklist_serial,
          'status': isCheckedGoodList[i] ? 'Good' : isCheckedBadList[i] ? 'Bad' : 'Not Checked',
          'date': date,
          'field': field_names[i],
          'remark': remarkList[i],
          'odometer' : odometer,
        };

        http.Response response = await http.post(
          Uri.parse(url),
          headers: <String, String>{
            'Content-Type': 'application/json',
          },
          body: jsonEncode(data),
        );

        if (response.statusCode == 200) {
          var jsonChecklistData = jsonDecode(response.body);
          await storage.write(key: 'checklist_data_$i', value: jsonEncode(jsonChecklistData));
          var testing = await storage.read(key: 'checklist_data_$i');
          print('Checklist Data: $testing');
        } else {
          print('Failed to send data. Status code: ${response.statusCode}');
        }
      }
    } catch (error) {
      print('Error Catching : $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavBar(
        fullname: widget.fullname,
        role: widget.role,
        branch: widget.branch,
        division: widget.division,
        user_id: widget.user_id,
      ),
      appBar: AppBar(
        title: Text(
          '${widget.equipment_name}',
          style: const TextStyle(
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF1A237E),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      body: SizedBox(
        child: Column(
          children: [
            Expanded(
              child: field_names_display == null
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                itemCount: field_names_display.length,
                itemBuilder: (BuildContext context, int index) {
                  final listdataname = field_names_display[index];
                  return Padding(
                    padding: const EdgeInsets.all(10),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            color: Colors.lightBlue[50],
                            elevation: 30,
                            margin: const EdgeInsets.all(5),
                            child: Container(
                              margin: const EdgeInsets.all(14.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    listdataname.toString(),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black54,
                                      fontSize: 20,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Container(
                                    width: 280,
                                    height: 150,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: _imageFileList[index] != null
                                            ? FileImage(_imageFileList[index]!)
                                            : const AssetImage('images/primemoverfrontlefttyre.png')
                                        as ImageProvider,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text('Condition'),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Checkbox(
                                            value: isCheckedGoodList[index],
                                            onChanged: (value) {
                                              setState(() {
                                                isCheckedGoodList[index] = value!;
                                                isCheckedBadList[index] = !value; // Uncheck other option
                                                remarkList[index] = 'No Remarks';
                                              });
                                              validateSubmitButton();
                                            },
                                          ),
                                          const Text('Good'),
                                          const SizedBox(width: 50),
                                          Checkbox(
                                            value: isCheckedBadList[index],
                                            onChanged: (value) {
                                              setState(() {
                                                isCheckedBadList[index] = value!;
                                                isCheckedGoodList[index] = !value; // Uncheck other option
                                              });
                                              validateSubmitButton();
                                            },
                                          ),
                                          const Text('Bad'),
                                        ],
                                      ),
                                      _remark(index),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(
                isSubmitEnabled ? Colors.green : Colors.red),
            ),
            onPressed: isSubmitEnabled
               ? () async {
              await addChecklistData(widget.equipment_no, widget.checklist_serial, 'status', widget.date, field_names, remarkList, widget.odometer);
              await postChecklistImage();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SubmitStacker(
                    fullname: widget.fullname,
                    role: widget.role,
                    branch: widget.branch,
                    division: widget.division,
                    equipment_no: widget.equipment_no,
                    user_id: widget.user_id,
                  ),
                ),
              );
            }
            : null,
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}
