import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:haulage_driver/Home%20Page/HomePage.dart';
import 'package:haulage_driver/Login.dart';

class NavBar extends StatefulWidget {
   const NavBar({super.key, this.fullname,this.email, this.role, this.branch, this.division, this.user_id});

  final String? fullname;
  final String? email;
  final String? role;
  final String? branch;
  final String? division;
  final int? user_id;
  // final vehicleSelection vehicleSelection;

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print(widget.user_id);
  }

  final storage = const FlutterSecureStorage();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: const EdgeInsets.only(),
        children: [
           UserAccountsDrawerHeader(
            accountName:  Text('${widget.fullname}',
              style: const TextStyle(
                color: Colors.white, 
                fontWeight: FontWeight.bold,
              ),
              ), 
            accountEmail: Text('${widget.role}',
              style: const TextStyle(
                color: Colors.white,
              ),
              ),
            decoration: const BoxDecoration(
              image: DecorationImage(image: AssetImage('images/background.png'),
                alignment: Alignment.topCenter,
                fit: BoxFit.cover,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: ()=> Navigator.push(
                context,
                MaterialPageRoute(builder: (context)=> HomePage(fullname: widget.fullname, role: widget.role,branch: widget.branch, division: widget.division,user_id: widget.user_id,))
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          const ListTile(
            leading: Icon(CupertinoIcons.gear),
            title: Text('Equipment Page'),
            // onTap: () => Navigator.push(
            //     // context,
            //     // MaterialPageRoute(builder: (context)=> EquipmentPage(fullname: widget.fullname,role: widget.role, vehicleSelection: widget.vehicleSelection,))
            // ),
          ),
          const SizedBox(
            height: 10,
          ),
          // ListTile(
          //   leading: const Icon(Icons.local_car_wash_sharp),
          //   title: const Text('Vehicle Page'),
          //   onTap: () => Navigator.push(
          //       context,
          //       MaterialPageRoute(builder: (context)=> VehiclePage(fullname: widget.fullname, role: widget.role,)),
          //   ),
          // ),
          const SizedBox(
            height: 100,
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: ()=> Navigator.push(
                context, 
                MaterialPageRoute(builder: (context) => const Login())
            ),
          ),
        ],
      ),
    );
  }
}
