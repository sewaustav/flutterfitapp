import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterfitapp/design/colors.dart';
import 'package:flutterfitapp/pages/profile/api_profile.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  late ApiProfile apiProfile;

  @override
  void initState() {
    super.initState();
    apiProfile = ApiProfile();
    _init();
  }

  Future<void> _init() async {
    List<dynamic> profileInfo = await apiProfile.getProfileInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyColors.blue_color,
        title: Text('Fitapp', style:
        TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),),
      ),
    );
  }

}