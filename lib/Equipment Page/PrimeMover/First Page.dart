import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:haulage_driver/Service/DateTime.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import '../../Widget/Navbar.dart';
import 'new primemover.dart';

class FirstPrimeMover extends StatefulWidget {
  const FirstPrimeMover(
      {super.key,
      this.fullname,
      this.role,
      this.division,
      this.branch,
      this.equipment_category,
      this.user_id,
      this.equipment_no,
      this.date,
      this.equipment_name
      });

  final String? fullname;
  final String? role;
  final String? division;
  final String? branch;
  final String? equipment_category;
  final String? equipment_name;
  final String? equipment_no;
  final int? user_id;
  final String? date;


  @override
  State<FirstPrimeMover> createState() => _FirstPrimeMoverState();
}

class _FirstPrimeMoverState extends State<FirstPrimeMover> {
  String equipment_no = '';

  TextEditingController _controllerInputField = TextEditingController();
  TextEditingController _controllerDate = TextEditingController();
  TextEditingController _controllerOdometer = TextEditingController();

  final storage = const FlutterSecureStorage();
  SelectDateTime selectDateTime = SelectDateTime();

  DateTime? selectedDateTime;
  String latlong = '';

  var token;
  var checkbody;
  var jsonReturn;
  var field_names;
  var field_names_display;

  void _getLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    try {
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if(!serviceEnabled) {
        setState(() {
          latlong = 'Location services are disabled.' ;
        });
        return;
      }
      permission = await Geolocator.checkPermission();
      if(permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if(permission == LocationPermission.denied) {
          setState(() {
            latlong = 'Location permission are denied!';
          });
          return;
        }
      }
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );
      setState(() {
        latlong =  '${position.latitude} , ${position.longitude}';
      });
    } catch (error) {
      setState(() {
        latlong='Error getting Location: $error';
      });
    }
  }

  Future<String?> postData(int? user_id, String? inputField, String? date, String? latlong) async {
    String url = 'http://192.168.10.6:83/api/driver/generateserialid';
    bool isPlateNo = _isPlateNo(inputField);

    Map<String, dynamic> data = {
      'user_id': user_id, // Use the passed user_id directly
      'date': date,
      'lat_long' : latlong,
    };

    if(isPlateNo) {
      data['plate_no'] = inputField;
    } else {
      data['equipment_no'] = inputField;
    }

    print('GUYYU $data');
    String body = jsonEncode(data);
    print('WEWEWEWE $body');

    try {
      final response = await http.post(
        Uri.parse(url),
        body: body,
        headers: <String, String> {
          'Content-Type' : 'application/json',
        },
      );

      if(response.statusCode == 200) {
        final dynamic jsonSerialid = jsonDecode(response.body);
        print('DADDDDAA $jsonSerialid');

        if (jsonSerialid == "this equipment doesn't exist") {
          return null;
        }

        return jsonSerialid.toString();
      } else {
        print('Failed to send POST request. Status code: ${response.statusCode}');
        return null;
      }
    } catch (error) {
      print('Error sending POST request: $error');
      return null;
    }
  }

  bool _isPlateNo(String? input) {
    if (input == null) return false;
    return RegExp(r'^[A-Za-z]+\/[A-Za-z]+\s+\d+$').hasMatch(input);
  }

  Future<void> scanBarcode() async {
    String barcodeScanResult = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666', 'Cancel', true, ScanMode.BARCODE);
    if (!mounted) return;

    setState(() {
      _controllerInputField.text = barcodeScanResult;
    });
  }


  Future<void> _scanBarcode() async {
    String barcodeScanResult = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666', 'Cancel', true, ScanMode.BARCODE);

    if (!mounted) return;

    setState(() {
     _controllerInputField.text = barcodeScanResult;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getLocation();
    _selectDateTime(context);
    _controllerDate = TextEditingController(
        text: DateFormat('yyyy-MM-dd HH:mm:ss')
            .format(DateTime.now())
            .toString());
    _controllerDate.addListener(() {
      if (_controllerDate.text.isNotEmpty) {}
    });
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDateTime = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (pickedDateTime != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        setState(() {
          selectedDateTime = DateTime(
            pickedDateTime.year,
            pickedDateTime.month,
            pickedDateTime.day,
            pickedDateTime.hour,
            pickedDateTime.minute,
          );
          _controllerDate.text =
              DateFormat('yy-MM-dd hh:mm:ss').format(selectedDateTime!);
        });
      }
    }
  }
  

  Future<void> _showErrorDialog(String message) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(message)
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
            )
          ],
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: KeyboardDismisser(
        gestures: const [
          GestureType.onTap,
          GestureType.onPanUpdateDownDirection,
        ],
        child: Scaffold(
          drawer: NavBar(
            fullname: widget.fullname,
            role: widget.role,
            branch: widget.branch,
            division: widget.division,
            user_id: widget.user_id,
          ),
          appBar: AppBar(
            title: Text(
              '${widget.equipment_category}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
            backgroundColor: const Color(0xFF1A237E),
            iconTheme: const IconThemeData(
              color: Colors.white,
            ),
          ),
          body: SingleChildScrollView(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const SizedBox(
                    height: 25,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 30, right: 30, bottom: 15),
                    child: Card(
                      color: Colors.lightBlue[50],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 50,
                      margin: const EdgeInsets.all(5),
                      child: Center(
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 20,
                            ),
                             const Text(
                              'Equipment No or No Plate:',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontSize: 20,
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 300,
                                  child: TextFormField(
                                    style: const TextStyle(fontSize: 20),
                                    controller: _controllerInputField,
                                    textAlign: TextAlign.center,
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      label: Center(
                                        child: Text(
                                          'Equipment no or No Plate:',
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ),
                                    ),
                                    onChanged: (text) {
                                      if (text.isNotEmpty) {
                                        setState(() {
                                        });
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 25),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: ElevatedButton.icon(
                                onPressed: _scanBarcode,
                                icon: const Icon(CupertinoIcons.barcode_viewfinder),
                                label: const Text("Scan Barcode"),
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: const Color(0xFF1A237E),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20)
                                  )
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 30, right: 30, bottom: 15),
                    child: Card(
                      color: Colors.lightBlue[50],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 50,
                      margin: const EdgeInsets.all(5),
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 30,
                          ),
                          const Text(
                            'Please Select Date',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 300,
                                child: TextFormField(
                                  decoration: const InputDecoration(
                                    icon: Icon(Icons.calendar_today_rounded),
                                    border: OutlineInputBorder(),
                                    label: Center(
                                      child: Text(
                                        'Select Date',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                  ),
                                  readOnly: true,
                                  onTap: () {
                                    selectDateTime.selectDateTime(context, (fn) {},
                                        selectedDateTime, _controllerDate);
                                    _selectDateTime(context);
                                  },
                                  controller: _controllerDate,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 40,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 30, right: 30, bottom: 15),
                    child: Card(
                      color: Colors.lightBlue[50],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 50,
                      margin: const EdgeInsets.all(5),
                      child: Center(
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 20,
                            ),
                            const Text('Location',
                            textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontSize: 20,
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 300,
                                  child: TextFormField(
                                    decoration: InputDecoration(
                                      icon: const Icon(CupertinoIcons.location_solid),
                                      border: const OutlineInputBorder(),
                                      label: Center(
                                        child: Text(
                                          latlong,
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w400
                                          ),
                                        ),
                                      )
                                    ),
                                    readOnly: true,
                                  )
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 30,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 30, right: 30, bottom: 15),
                    child: Card(
                      color: Colors.lightBlue[50],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 50,
                      margin: EdgeInsets.all(5),
                      child: Center(
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 20,
                            ),
                            const Text('Please Enter the Vehicle Odometer',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.black,
                            ),
                            ),
                            const SizedBox(
                              height: 30,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 300,
                                  child: TextFormField(
                                    controller: _controllerOdometer,
                                    decoration: const InputDecoration(
                                      icon: Icon(CupertinoIcons.speedometer),
                                      border: OutlineInputBorder(),
                                      label: Center(
                                        child: Text(
                                          'Odometer or hourmeter',
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      )
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 30),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          bottomNavigationBar: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              InkWell(
                onTap: () async {
                  String? jsonSerialid = await postData(widget.user_id, _controllerInputField.text, _controllerDate.text, latlong );

                  if (jsonSerialid == "this equipment doesn`t exist") {
                    _showErrorDialog("This equipment doesn't exist or Serial Id is null");
                    return;
                  }

                  else if(_controllerInputField.text.isEmpty || _controllerDate.text.isEmpty || _controllerOdometer.text.isEmpty || latlong.isEmpty) {
                    _showErrorDialog("Please fill in the form before proceed to the next page");
                    return;
                  }
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) =>
                          EquipmentPage1(
                            fullname: widget.fullname,
                            role: widget.role,
                            equipment_category: widget.equipment_category,
                            equipment_name: widget.equipment_name,
                            branch: widget.branch,
                            division: widget.division,
                            user_id: widget.user_id,
                            equipment_no: _controllerInputField.text,
                            date: _controllerDate.text,
                            checklist_serial: jsonSerialid,
                            odometer : _controllerOdometer.text,
                          )));

                },
                child: const Card(
                  color: Colors.green,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 60,
                    ),
                    child: Text(
                      'Next',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
