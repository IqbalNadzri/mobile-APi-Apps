import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:haulage_driver/Equipment%20Page/PrimeMover/submit.dart';
import 'package:haulage_driver/Service/SaveFIle.dart';
import 'package:haulage_driver/Widget/Navbar.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class EquipmentPage1 extends StatefulWidget {
  const EquipmentPage1({
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
  State<EquipmentPage1> createState() => _EquipmentPage1State();
}

class _EquipmentPage1State extends State<EquipmentPage1> {
  List<File?> _imageFileList = [];
  List<bool> isCheckedGoodList = [];
  List<bool> isCheckedBadList = [];
  List<String> remarkList = [];
  var token;
  var checkbody;
  var jsonReturn;
  List<dynamic> fieldNames = [];
  List<dynamic> fieldNamesDisplay = [];
  bool isSubmitEnabled = false;

  final storage = const FlutterSecureStorage();

  static const myList = {
    "name": "Save File"
  };

  @override
  void initState() {
    super.initState();
    requestStoragePermission();
    fetchData();
  }

  Future<void> postChecklistImage() async {
    Map<String, String> headers = {
      'Content-Type': 'multipart/form-data',
      'Accept': 'application/json',
    };

    for (int i = 0; i < _imageFileList.length; i++) {
      if (_imageFileList[i] != null) {
        var uri = Uri.parse('http:');
        var request = http.MultipartRequest('POST', uri);
        request.headers.addAll(headers);
        request.fields['checklist_id'] = widget.checklist_serial ?? '';
        request.fields['field_name'] = fieldNames[i];

        final fileStream = http.ByteStream(_imageFileList[i]!.openRead());
        final fileLength = await _imageFileList[i]!.length();
        final multipartFile = http.MultipartFile(
          'image',
          fileStream,
          fileLength,
          filename: '${fieldNames[i]}.jpg',
        );

        request.files.add(multipartFile);

        var response = await request.send();
        if (response.statusCode == 200) {
          print('Image for ${fieldNames[i]} uploaded successfully');
        } else {
          print('Image upload for ${fieldNames[i]} failed with status: ${response.statusCode}');
        }
      }
    }
  }

  Future<void> getChecklistImage(String fieldName, int index) async {
    final uri = Uri.http(
        '',
        {
          'equipment': widget.equipment_name,
          'equipment_category': widget.equipment_category,
          'image_name': '$fieldName.jpg',
        }
    );

    try {
      http.Response response = await http.get(uri);

      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        final tempDir = await getTemporaryDirectory();
        final file = await File('${tempDir.path}/$fieldName.jpg').writeAsBytes(bytes);

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
    final uri = Uri.http(
        '',
        {
          'equipment_name': widget.equipment_name,
          'equipment_category': widget.equipment_category,
          'division': widget.division,
          'branch': widget.branch,
        }
    );

    try {
      http.Response response = await http.get(uri);

      if (response.statusCode == 200) {
        final jsonFieldName = jsonDecode(response.body);
        setState(() {
          fieldNames = jsonFieldName['field_name'];
          fieldNamesDisplay = jsonFieldName['field_name_display'];
          isCheckedGoodList = List.generate(fieldNamesDisplay.length, (index) => false);
          isCheckedBadList = List.generate(fieldNamesDisplay.length, (index) => false);
          remarkList = List.generate(fieldNamesDisplay.length, (index) => 'No Remarks');
          _imageFileList = List.generate(fieldNamesDisplay.length, (index) => null);
        });

        for (int i = 0; i < fieldNamesDisplay.length; i++) {
          await getChecklistImage(fieldNames[i], i);
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
      return const SizedBox.shrink();
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

  Future<void> addChecklistData(String? equipment_no, String? checklist_serial, String status, String? date, List fieldNames, List remarkList) async {
    try {
      String url = 'http://192.168.10.6:83/api/driver/addchecklistdata';
      List<Map<String, dynamic>> checklistData = [];

      for (int i = 0; i < fieldNames.length; i++) {
        var data = {
          'equipment_no': equipment_no,
          'checklist_serial': checklist_serial,
          'status': isCheckedGoodList[i] ? 'Good' : isCheckedBadList[i] ? 'Bad' : 'Not Checked',
          'date': date,
          'field': fieldNames[i],
          'remark': remarkList[i],
        };

        checklistData.add(data);

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

      // Write checklist data to file
      String checklistDataString = jsonEncode(checklistData);
      await FileStorage.writeCounter(checklistDataString, 'checklist_data.txt');

    } catch (error) {
      print('Error Catching : $error');
    }
  }

  Future<void> requestStoragePermission() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      status = await Permission.storage.request();
      if (!status.isGranted) {
        throw Exception('Storage permission not granted');
      }
    }
  }

  Future<void> writeChecklistDataToFile() async {
    await requestStoragePermission();

    List<Map<String, dynamic>> checklistData = [];

    for (int i = 0; i < fieldNames.length; i++) {
      var data = {
        'equipment_no': widget.equipment_no,
        'checklist_serial': widget.checklist_serial,
        'status': isCheckedGoodList[i] ? 'Good' : isCheckedBadList[i] ? 'Bad' : 'Not Checked',
        'date': widget.date,
        'field': fieldNames[i],
        'remark': remarkList[i],
      };

      checklistData.add(data);
    }

    String checklistDataString = jsonEncode(checklistData);
    await FileStorage.writeCounter(checklistDataString, 'checklist_data.txt');
  }

  void validateSubmitButton() {
    bool allChecked = true;
    for (int i = 0; i < fieldNamesDisplay.length; i++) {
      if (!isCheckedGoodList[i] && !isCheckedBadList[i]) {
        allChecked = false;
        break;
      }
    }
    setState(() {
      isSubmitEnabled = allChecked;
    });
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
      body: fieldNamesDisplay.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: fieldNamesDisplay.length,
        itemBuilder: (BuildContext context, int index) {
          final listDataName = fieldNamesDisplay[index];
          return Padding(
            padding: const EdgeInsets.all(10),
            child: ChecklistItem(
              listDataName: listDataName,
              imageFile: _imageFileList[index],
              isCheckedGood: isCheckedGoodList[index],
              isCheckedBad: isCheckedBadList[index],
              onGoodChanged: (value) {
                setState(() {
                  isCheckedGoodList[index] = value ?? false;
                  isCheckedBadList[index] = !(value ?? false);
                  remarkList[index] = 'No Remarks';
                });
                validateSubmitButton();
              },
              onBadChanged: (value) {
                setState(() {
                  isCheckedBadList[index] = value ?? false;
                  isCheckedGoodList[index] = !(value ?? false);
                });
                validateSubmitButton();
              },
              remarkWidget: _remark(index),
              onTakePhoto: () => _takePhotoForIndex(index),
            ),
          );
        },
      ),
      bottomNavigationBar: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(
                isSubmitEnabled ? Colors.green : Colors.red,
              ),
            ),
            onPressed: isSubmitEnabled
                ? () async {
              await addChecklistData(widget.equipment_no, widget.checklist_serial, 'status', widget.date, fieldNames, remarkList);
              await postChecklistImage();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PrimeMoverSubmit(
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
          const SizedBox(width: 50),
          ElevatedButton(
            onPressed: () async {
              try {
                await writeChecklistDataToFile();
                print('File written successfully');
              } catch (e) {
                print('Error writing file: $e');
              }
            },
            child: const Text('Write to File'),
          ),
        ],
      ),
    );
  }
}

class ChecklistItem extends StatelessWidget {
  const ChecklistItem({
    Key? key,
    required this.listDataName,
    required this.imageFile,
    required this.isCheckedGood,
    required this.isCheckedBad,
    required this.onGoodChanged,
    required this.onBadChanged,
    required this.remarkWidget,
    required this.onTakePhoto,
  }) : super(key: key);

  final String listDataName;
  final File? imageFile;
  final bool isCheckedGood;
  final bool isCheckedBad;
  final ValueChanged<bool?> onGoodChanged;
  final ValueChanged<bool?> onBadChanged;
  final Widget remarkWidget;
  final VoidCallback onTakePhoto;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      color: Colors.lightBlue[50],
      elevation: 30,
      margin: const EdgeInsets.all(5),
      child: Container(
        margin: const EdgeInsets.all(14.0),
        child: Column(
          children: [
            Text(
              listDataName,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black54,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              width: 280,
              height: 150,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: imageFile != null
                      ? FileImage(imageFile!)
                      : const AssetImage('images/primemoverfrontlefttyre.png') as ImageProvider,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Condition'),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Checkbox(
                      value: isCheckedGood,
                      onChanged: onGoodChanged,
                    ),
                    const Text('Good'),
                    const SizedBox(width: 50),
                    Checkbox(
                      value: isCheckedBad,
                      onChanged: onBadChanged,
                    ),
                    const Text('Bad'),
                  ],
                ),
                remarkWidget,
              ],
            ),
          ],
        ),
      ),
    );
  }
}
