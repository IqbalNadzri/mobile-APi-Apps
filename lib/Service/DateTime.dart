import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


class SelectDateTime {
  Future<void> selectDateTime(BuildContext context, StateSetter setState, DateTime? selectedDateTime, TextEditingController? _controller) async {
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

      if(pickedTime != null) {
        setState (() {
          selectedDateTime = DateTime(
            pickedDateTime.year,
            pickedDateTime.month,
            pickedDateTime.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          _controller!.text = DateFormat('yy-mm-dd hh:mm:ss').format(selectedDateTime!);
        });
      }
    }
  }
}