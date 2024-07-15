import 'package:flutter/material.dart';
import 'package:haulage_driver/Home%20Page/HomePage.dart';
import 'package:haulage_driver/Widget/Navbar.dart';

class SubmitTrailer extends StatefulWidget {
  const SubmitTrailer({Key? key, this.fullname, this.role, this.branch, this.division, this.equipment_no, this.user_id});

  final String? fullname;
  final String? role;
  final String? branch;
  final String? division;
  final String? equipment_no;
  final int? user_id;


  @override
  State<SubmitTrailer> createState() => _SubmitTrailerState();
}

class _SubmitTrailerState extends State<SubmitTrailer> {
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
        backgroundColor: const Color(0xFF1A237E),
        title: const Text(
          'Submit',
          style: TextStyle(
              color: Colors.white
          ),
        ),
        actions: [
          Image.asset(
            'images/ideas2.png',
            fit: BoxFit.cover,
            height: 90,
            width: 200,
          ),
          const Icon(
            Icons.add,
            color: Color(0xFF1A237E),
            size: 8,
          ),
        ],
        iconTheme: const IconThemeData(
            color: Colors.white
        ),
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(
              height: 150,
            ),
            Image.asset(
              'images/trailer.png',
              height: 200,
            ),
            Center(
              child: Text(
                '${widget.equipment_no} \n COMPLETE',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage(fullname: widget.fullname,role: widget.role, division: widget.division, branch: widget.branch, user_id: widget.user_id))
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.all(15),
              ),
              child: const Text('Submit'),
            )
          ],
        ),
      ),
    );
  }
}
