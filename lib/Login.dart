import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:haulage_driver/Home%20Page/HomePage.dart';
import 'package:http/http.dart' as http;
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:http/http.dart';


class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {

  final _formkey = GlobalKey<FormState>();
  final storage = const FlutterSecureStorage();

  TextEditingController _controllerEmail = TextEditingController();
  TextEditingController _controllerPassword = TextEditingController();

  bool visible = false;
  bool isObscure = true;
  bool _rememberMe = false;

  var token;
  var checkbody;
  var jsonReturn;
  var rememberme;
  var rememberemail;
  var rememberpassword;

  @override
  void initState() {
    super.initState();
    autoFillButton();
  }

  void autoFillButton() async {
    rememberme = await storage.read(key: 'rememberme');
    rememberemail = await storage.read(key: 'rememberemail');
    rememberpassword = await storage.read(key: 'rememberpassword');

    setState(() {
      if(rememberme == 'true') {
        _rememberMe = true;
        _controllerEmail = TextEditingController(text: rememberemail);
        _controllerPassword = TextEditingController(text: rememberpassword);
      } else {
        _controllerEmail = TextEditingController();
        _controllerPassword = TextEditingController();
      }
    });
  }

  void route (String email, String password) async {
    if(_formkey.currentState!.validate()) {
      try{
        print('1');
        final queryParameters = {
          'email' : email,
          'password' : password
        };

        print('2');
        var accesstoken = token['access_token'];
        final uri = Uri.https('192.168.10.5:8243','test/driver/1.0.0/login',queryParameters);

        print('3');
        Response response = await get (
          uri,
          headers: {
            'authorization' : 'Bearer $accesstoken'
          },
        );
        checkbody = response.body;
        print('4');
        jsonReturn = jsonDecode(checkbody);
        print('APAPOAPOAPO ${jsonReturn}');
        var userdetail = jsonReturn['userdetails'];
        print('POPOP ${userdetail[0]['fullname']}');
        print('PIPI ${userdetail[0]['role']}');
        print('Hut ${userdetail[0]['division']}');
        print('Guy ${userdetail[0]['branch_name']}');
        print('WWWQQQ ${userdetail[0]['id']}');
        await storage.deleteAll();
        await storage.write(key: 'email', value: _controllerEmail.text);
        await storage.write(key: 'password', value: _controllerPassword.text);
        await storage.write(key: 'fullname', value: userdetail[0]['fullname']);
        await storage.write(key: 'role', value: userdetail[0]['role']);
        await storage.write(key: 'branch', value: userdetail[0]['branch_name']);
        await storage.write(key: 'division', value: userdetail[0]['division']);
        await storage.write(key: 'user_id', value: userdetail[0]['id'].toString());
        if(_rememberMe == true) {
          await storage.write(key: 'rememberme', value: _rememberMe.toString());
          await storage.write(key: 'rememberemail', value: _controllerEmail.text);
          await storage.write(key: 'rememberpassword', value: _controllerPassword.text);
        } else {
          await storage.write(key: 'rememberme', value: _rememberMe.toString());
        }
        if(checkbody == '"user not found"') {
          showDialog(
              context: context,
              builder: (context)=>
                  const AlertDialog(
                    title: Text('Alert'),
                    content: Text('User not found'),
                  )
          );
        } else if(checkbody == '"wrong password.try again"') {
          showDialog(
              context: context,
              builder: (context)=>
              const AlertDialog(
                title: Text('Alert'),
                content: Text('password not found'),
              )
          );
        } else {
          print('PIPI ${userdetail[0]['role']}');
          Navigator.push(context,
            MaterialPageRoute(builder: (context) {
              return HomePage(fullname: userdetail[0]['fullname'],role: userdetail[0]['role'], branch: userdetail[0]['branch_name'],division: userdetail[0]['division'],user_id: userdetail[0]['id']);
            }
            ),
          );
        }
      } catch (e) {
        print(e.toString());
        showDialog(
          context: context,
          builder: (context) => const AlertDialog(
              content: Text('Enter correct email n password'),
          ),
        );
      }
    }
  }

  void _getToken(String email, String password){
    http.post(
      Uri.parse('https://192.168.10.5:9443/oauth2/token'),
      headers: {
        'Authorization': 'Basic Q0JQcWNWaW1SRXBqdk9aRjd5dFFhcWdzUzZZYTpQelBLbklhTk16X3lsOVNmc21mRDJKMWlhX3Nh'
      },
      body : {
        "grant_type": "password",
        "username": "testhaulagemobile",
        "password": "mobilehaulage1442"
      },
    ).then((response){
      setState(() {
        token = jsonDecode(response.body);
        print('sini 2');
      });
      route(_controllerEmail.text.toString(), _controllerPassword.text.toString());
    });
  }

 Future<String?> authenticate(String email,String password) async {
    final response = await http.post(
      Uri.parse('http://192.168.10.6:83/api/driver/login'),
      body: {
        'email':email,
        'password': password,
      },
    );

    if(response.statusCode == 200) {
      return response.body;
    } else {
      return null;
    }
 }

  Future<bool> _onWillPop() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit App'),
        content: const Text('Are you sure you want to exit the app?'),
        actions: [
          TextButton(
            onPressed: (){
              Navigator.of(context).pop(false);
              },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
              SystemNavigator.pop();
              },
            child: const Text('Exit',
            ),
          ),
        ],
      ),
    );
    return false;
  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: KeyboardDismisser(
        gestures: const [
          GestureType.onTap,
          GestureType.onPanUpdateDownDirection
        ],
        child: Scaffold(
          body: Center(
            child: SingleChildScrollView(
              child: Center(
                child: Column(
                  children: [
                    Center(
                      child: Image.asset(
                        'images/ideas1.png',
                        height: 250,
                        width: 250,
                      ),
                    ),
                    Column(
                      children:[
                        Card(
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(20),
                            ),
                          ),
                          color: const Color(0xFFE8EAF6),
                          margin: const EdgeInsets.all(45),
                          elevation: 5,
                          child: Center(
                            child: Container(
                              margin: const EdgeInsets.all(12),
                              child: Form(
                                key: _formkey,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const SizedBox(
                                      height: 15,
                                    ),
                                    TextFormField(
                                      controller: _controllerEmail,
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: CupertinoColors.white,
                                        hintText: 'Email',
                                        enabled: true,
                                        contentPadding: const EdgeInsets.only(
                                          left: 14.0, bottom: 8.0, top: 8.0
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(color: CupertinoColors.white),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        enabledBorder: UnderlineInputBorder(
                                          borderRadius: BorderRadius.circular(10),
                                          borderSide: const BorderSide(color: CupertinoColors.white),
                                        ),
                                      ),
                                      validator: (value){
                                        if(value!.isEmpty) {
                                          return 'Email cannot be Empty';
                                        } else {
                                          return null;
                                        }
                                      },
                                      onSaved: (value) {
                                        _controllerEmail.text = value!;
                                      },
                                      keyboardType: TextInputType.emailAddress,
                                    ),
                                    const SizedBox(
                                      height: 15,
                                    ),
                                    TextFormField(
                                      controller: _controllerPassword,
                                      obscureText: isObscure,
                                      decoration: InputDecoration(
                                        suffixIcon: IconButton(
                                          onPressed: () {
                                            setState(() {
                                              isObscure = !isObscure;
                                            });
                                            },
                                          icon: Icon(
                                            isObscure ? Icons.visibility : Icons.visibility_off,
                                          ),
                                        ),
                                        filled: true,
                                        fillColor: Colors.white,
                                        hintText: 'Password',
                                        enabled: true,
                                        contentPadding: const EdgeInsets.only(
                                          left: 14.0, bottom: 8.0, top: 15.0
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(color: Colors.white),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        enabledBorder: UnderlineInputBorder(
                                          borderRadius: BorderRadius.circular(10),
                                          borderSide: const BorderSide(color: Colors.white),
                                        ),
                                      ),
                                      validator: (value) {
                                        RegExp regex = RegExp(r'^.{4,}$'
                                        );
                                        if (value!.isEmpty) {
                                          return "Password cannot be empty";
                                        }
                                        if (!regex.hasMatch(value)) {
                                          return ("Please enter valid password min. 4 characters");
                                        } else {
                                          return null;
                                        }
                                      },
                                      onSaved: (value) {
                                        _controllerPassword.text = value!;
                                      },
                                      keyboardType: TextInputType.emailAddress,
                                    ),
                                    const SizedBox(
                                      height: 15,
                                    ),
                                    Row(
                                      children: [
                                        Checkbox(
                                          value: _rememberMe,
                                          onChanged: (value) {
                                            setState(() {
                                              _rememberMe = value!;
                                            });
                                          }
                                        ),
                                        const Text('Remember Me'),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 15,
                                    ),
                                    MaterialButton(
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(20.0),
                                        ),
                                      ),
                                      elevation: 5.0,
                                      splashColor: const Color(0xFF1A237E),
                                      height: 40,
                                      onPressed: (){
                                        setState(() {
                                          visible = true;
                                        });
                                        _getToken(_controllerEmail.text, _controllerPassword.text);                                        },
                                      color: const Color(0xFF1A237E),
                                      child: const Text("Login",
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: Colors.white,
                                      ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
          bottomNavigationBar: SizedBox(
            height: 70,
            child: Column(
              children: [
                const Text('Powered by'),
                Image.asset('images/infinitylogo.png',
                alignment: Alignment.bottomCenter,
                  width: 100,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
