
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:haulage_driver/Equipment%20Page/Forklift/First%20Forklift.dart';
import 'package:haulage_driver/Equipment%20Page/PrimeMover/First%20Page.dart';
import 'package:haulage_driver/Equipment%20Page/Stacker/First%20Stacker.dart';
import 'package:haulage_driver/Equipment%20Page/Trailer/First%20Trailer.dart';
import '../Widget/Navbar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, this.fullname, this.role, this.division, this.branch, this.user_id});

  final String? fullname;
  final String? role;
  final String? division;
  final String? branch;
  final int? user_id;


  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String equipmentName = 'Select the Equipment Category';
  String equipmentCategory = 'Select Your Equipment Category';

  final storage = const FlutterSecureStorage();

  void _PrimeMoverType() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select the PrimeMover type'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('PrimeMover'),
                onTap: () {
                  setState(() {
                    equipmentCategory = 'primemover';
                    equipmentName = 'primemover';
                  });
                  Navigator.of(context).push(MaterialPageRoute(builder: (context)=> FirstPrimeMover(fullname: widget.fullname, role: widget.role, equipment_category: equipmentCategory,equipment_name:equipmentName,branch: widget.branch,division: widget.division,  user_id:widget.user_id  )));
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _ForkliftType() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select the Forklift type'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Diesel Forklift'),
                onTap: () {
                  setState(() {
                    equipmentCategory = 'forklift_diesel';
                    equipmentName = 'forklift';
                  });
                  Navigator.of(context).push(MaterialPageRoute(builder: (context)=> FirstForklift(fullname: widget.fullname, role: widget.role, equipment_category: equipmentCategory,equipment_name:equipmentName,branch: widget.branch,division: widget.division, user_id: widget.user_id,)));
                },
              ),
              ListTile(
                title: const Text('Electric Forklift'),
                onTap: () {
                  setState(() {
                    equipmentCategory = 'forklift_electric';
                    equipmentName = 'forklift';
                  });
                  Navigator.of(context).push(MaterialPageRoute(builder: (context)=> FirstForklift(fullname: widget.fullname, role: widget.role, equipment_category: equipmentCategory,equipment_name:equipmentName,branch: widget.branch,division: widget.division, user_id: widget.user_id,)));
                },
              ),
              ListTile(
                title: const Text('Battery Forklift'),
                onTap: () {
                  setState(() {
                    equipmentCategory = 'forklift_battery';
                    equipmentName = 'forklift';
                  });
                  Navigator.of(context).push(MaterialPageRoute(builder: (context)=> FirstForklift(fullname: widget.fullname, role: widget.role, equipment_category: equipmentCategory,equipment_name:equipmentName,branch: widget.branch,division: widget.division, user_id: widget.user_id,)));
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _StackerType() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select the Stacker type'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Reach Stacker Laden'),
                onTap: () {
                  setState(() {
                    equipmentCategory = 'stacker';
                    equipmentName = 'reach_stacker_laden';
                  });
                  Navigator.of(context).push(MaterialPageRoute(builder: (context)=> FirstStacker(fullname: widget.fullname, role: widget.role, equipment_category: equipmentCategory,equipment_name:equipmentName,branch: widget.branch,division: widget.division, user_id: widget.user_id)));
                },
              ),
              ListTile(
                title: const Text('Empty Container Stacker'),
                onTap: () {
                  setState(() {
                    equipmentCategory = 'stacker';
                    equipmentName = 'empty_container_stacker';
                  });
                  Navigator.of(context).push(MaterialPageRoute(builder: (context)=> FirstStacker(fullname: widget.fullname, role: widget.role, equipment_category: equipmentCategory,equipment_name:equipmentName,branch: widget.branch,division: widget.division, user_id: widget.user_id)));
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _trailerType() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select the Trailer type'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('20ft'),
                onTap: () {
                  setState(() {
                    equipmentCategory = 'trailer_20ft';
                    equipmentName = 'trailer';
                  });
                  Navigator.of(context).push(MaterialPageRoute(builder: (context)=> FirstTrailer(fullname: widget.fullname,role: widget.role,branch:widget.branch, division: widget.division,  equipment_category: equipmentCategory, equipment_name: equipmentName,user_id: widget.user_id,)));
                },
              ),
              ListTile(
                title: const Text('20ft sdu'),
                onTap: () {
                  setState(() {
                    equipmentCategory = 'trailer_20ft_sdu';
                    equipmentName = 'trailer';
                  });
                  Navigator.of(context).push(MaterialPageRoute(builder: (context)=> FirstTrailer(fullname: widget.fullname,role: widget.role,branch:widget.branch, division: widget.division,  equipment_category: equipmentCategory, equipment_name: equipmentName,user_id: widget.user_id, )));
                },
              ),
              ListTile(
                title: const Text('20ft sdu 3 axles'),
                onTap: () {
                  setState(() {
                    equipmentCategory = 'trailer_20ft_sdu_3_axles';
                    equipmentName = 'trailer';
                  });
                  Navigator.of(context).push(MaterialPageRoute(builder: (context)=> FirstTrailer(fullname: widget.fullname,role: widget.role,branch:widget.branch, division: widget.division,  equipment_category: equipmentCategory, equipment_name: equipmentName,user_id: widget.user_id, )));
                },
              ),
              ListTile(
                title: const Text('20ft tipping'),
                onTap: () {
                  setState(() {
                    equipmentCategory = 'trailer_20ft_tipping';
                    equipmentName = 'trailer';
                  });
                  Navigator.of(context).push(MaterialPageRoute(builder: (context)=> FirstTrailer(fullname: widget.fullname,role: widget.role,branch:widget.branch, division: widget.division,  equipment_category: equipmentCategory, equipment_name: equipmentName,user_id: widget.user_id, )));
                },
              ),
              ListTile(
                title: const Text('40ft'),
                onTap: () {
                  setState(() {
                    equipmentCategory = 'trailer_40ft';
                    equipmentName = 'trailer';
                  });
                  Navigator.of(context).push(MaterialPageRoute(builder: (context)=> FirstTrailer(fullname: widget.fullname,role: widget.role,branch:widget.branch, division: widget.division,  equipment_category: equipmentCategory, equipment_name: equipmentName,user_id: widget.user_id )));
                },
              ),
              ListTile(
                title: const Text('40ft 3 axles'),
                onTap: () {
                  setState(() {
                    equipmentCategory = 'trailer_40ft_3_axles';
                    equipmentName = 'trailer';
                  });
                  Navigator.of(context).push(MaterialPageRoute(builder: (context)=> FirstTrailer(fullname: widget.fullname,role: widget.role,branch:widget.branch, division: widget.division,  equipment_category: equipmentCategory, equipment_name: equipmentName,user_id: widget.user_id )));
                },
              ),
              ListTile(
                title: const Text('40ft side loader'),
                onTap: () {
                  setState(() {
                    equipmentCategory = 'trailer_40ft_side_loader';
                    equipmentName = 'trailer';
                  });
                  Navigator.of(context).push(MaterialPageRoute(builder: (context)=> FirstTrailer(fullname: widget.fullname,role: widget.role,branch:widget.branch, division: widget.division,  equipment_category: equipmentCategory, equipment_name: equipmentName,user_id: widget.user_id)));
                },
              ),
            ],
          ),
        );
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer:  NavBar(
        fullname: widget.fullname,
        role: widget.role,
        branch: widget.branch,
        division: widget.division,
        user_id: widget.user_id,
      ),
      appBar: AppBar(
        title: const Text(
          'Home',
          style: TextStyle(
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
              InkWell(
                onTap: _PrimeMoverType,
                child: Container(
                  height: MediaQuery.of(context).size.width -200,
                  width: MediaQuery.of(context).size.width -50,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('images/primemover.png'),
                      fit: BoxFit.cover,
                      opacity: 100,
                    ),
                  ),
                  child: Center(
                    child: Card(
                      color: const Color(0xFF1A237E),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Text('\n      PRIMEMOVER     \n',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 25,
              ),
              InkWell(
                onTap: _ForkliftType,
                child: Container(
                  height: MediaQuery.of(context).size.width -200,
                  width: MediaQuery.of(context).size.width -50,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('images/forkliftdiesel.png'),
                      fit: BoxFit.cover,
                      opacity: 100,
                    ),
                  ),
                  child: Center(
                    child: Card(
                      color: const Color(0xFF1A237E),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Text('\n            FORKLIFT              \n',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 25,
              ),
              InkWell(
                onTap: _trailerType,
                child: Container(
                  height: MediaQuery.of(context).size.width -200,
                  width: MediaQuery.of(context).size.width -50,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(
                        'images/trailer.png',
                      ),
                      fit: BoxFit.cover,
                      opacity: 100,
                    ),
                  ),
                  child: Center(
                    child: Card(
                      color: const Color(0xFF1A237E),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Text('\n              Trailer             \n',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 25,
              ),
              InkWell(
                onTap: _StackerType,
                child: Container(
                  height: MediaQuery.of(context).size.width -200,
                  width: MediaQuery.of(context).size.width -50,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('images/stacker.png'),
                      fit: BoxFit.cover,
                      opacity: 100,
                    ),
                  ),
                  child: Center(
                    child: Card(
                      color: const Color(0xFF1A237E),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Text('\n            Stacker               \n',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              )
            ],
          ),
        ),
      ),
    );
  }
}

