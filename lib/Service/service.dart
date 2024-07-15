import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

String baseUrl = 'http://192.168.10.6:83/api/driver/getchecklistfieldmobile';

class BaseClient{
  var client= http.Client();
  Future<dynamic> get(String api) async {
    var url = Uri.parse(baseUrl + api);
    var _headers = {
      'Authorization': 'Bearer',
      'api_key' : '',
    };
    var response = await client.get(url);
    if(response.statusCode == 200) {
      return response.body;
    } else{

    }
  }
}